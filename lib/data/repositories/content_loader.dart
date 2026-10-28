import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/content_models.dart';

class ContentValidationError implements Exception {
  final String message;
  final String? courseId;
  final String? moduleId;
  final String? lessonId;
  final String? stepId;

  ContentValidationError(
    this.message, {
    this.courseId,
    this.moduleId,
    this.lessonId,
    this.stepId,
  });

  @override
  String toString() {
    final parts = <String>[];
    if (courseId != null) parts.add('course=$courseId');
    if (moduleId != null) parts.add('module=$moduleId');
    if (lessonId != null) parts.add('lesson=$lessonId');
    if (stepId != null) parts.add('step=$stepId');
    final context = parts.isNotEmpty ? ' [${parts.join(', ')}]' : '';
    return 'ContentValidationError$context: $message';
  }
}

class ContentLoader {
  static const String _manifestPath = 'assets/content/manifest.json';
  static const String _contentBasePath = 'assets/content/';

  static Map<String, LearningPath>? _learningPaths;
  static Map<String, CourseContent>? _courseContents;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    await _loadManifest();
    await _loadAllCourses();
    _initialized = true;
  }

  static Future<void> _loadManifest() async {
    try {
      final jsonString = await rootBundle.loadString(_manifestPath);
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

      _learningPaths = {};
      for (final entry
          in (jsonMap['learningPaths'] as List<dynamic>)
              .cast<Map<String, dynamic>>()) {
        final path = LearningPath.fromJson(entry);
        _learningPaths![path.id] = path;
      }
    } catch (e) {
      throw ContentValidationError('Failed to load manifest: $e');
    }
  }

  static Future<void> _loadAllCourses() async {
    if (_learningPaths == null) return;

    _courseContents = {};
    for (final path in _learningPaths!.values) {
      for (final courseId in path.courseIds) {
        await _loadCourse(courseId);
      }
    }
  }

  static Future<CourseContent?> _loadCourse(String courseId) async {
    if (_courseContents!.containsKey(courseId)) {
      return _courseContents![courseId];
    }

    final assetPath = '$_contentBasePath$courseId.json';
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final course = CourseContent.fromJson(jsonMap);

      _validateCourse(course);
      _courseContents![courseId] = course;
      return course;
    } catch (e) {
      if (e is ContentValidationError) rethrow;
      throw ContentValidationError('Failed to load course $courseId: $e');
    }
  }

  static void _validateCourse(CourseContent course) {
    final seenLessonIds = <String>{};
    final seenModuleIds = <String>{};

    for (final module in course.modules) {
      if (seenModuleIds.contains(module.id)) {
        throw ContentValidationError(
          'Duplicate module ID: ${module.id}',
          courseId: course.courseId,
          moduleId: module.id,
        );
      }
      seenModuleIds.add(module.id);

      for (final lesson in module.lessons) {
        final lessonKey = '${module.id}:${lesson.id}';
        if (seenLessonIds.contains(lessonKey)) {
          throw ContentValidationError(
            'Duplicate lesson ID: ${lesson.id} in module ${module.id}',
            courseId: course.courseId,
            moduleId: module.id,
            lessonId: lesson.id,
          );
        }
        seenLessonIds.add(lessonKey);

        _validateLesson(course.courseId, module.id, lesson);
      }
    }

    // Validate minimum content requirements
    if (course.modules.isEmpty) {
      throw ContentValidationError(
        'Course must have at least 1 module',
        courseId: course.courseId,
      );
    }
    if (course.totalLessons < 4) {
      throw ContentValidationError(
        'Course must have at least 4 lessons',
        courseId: course.courseId,
      );
    }
  }

  static void _validateLesson(
    String courseId,
    String moduleId,
    LessonContent lesson,
  ) {
    if (lesson.steps.length < 5) {
      throw ContentValidationError(
        'Lesson must have at least 5 steps',
        courseId: courseId,
        moduleId: moduleId,
        lessonId: lesson.id,
      );
    }
    if (lesson.steps.length > 8) {
      throw ContentValidationError(
        'Lesson must have at most 8 steps',
        courseId: courseId,
        moduleId: moduleId,
        lessonId: lesson.id,
      );
    }

    final stepTypes = <StepType>{};
    for (var i = 0; i < lesson.steps.length; i++) {
      final step = lesson.steps[i];
      stepTypes.add(step.type);
      _validateStep(courseId, moduleId, lesson.id, i, step);
    }

    if (stepTypes.length < 3) {
      throw ContentValidationError(
        'Lesson must use at least 3 different step types (found: ${stepTypes.map((e) => e.value).join(', ')})',
        courseId: courseId,
        moduleId: moduleId,
        lessonId: lesson.id,
      );
    }
  }

  static void _validateStep(
    String courseId,
    String moduleId,
    String lessonId,
    int stepIndex,
    LessonStepContent step,
  ) {
    final stepRef = 'step_$stepIndex';

    switch (step.type) {
      case StepType.explanation:
        if (step.content == null || step.content!.trim().isEmpty) {
          throw ContentValidationError(
            'Explanation step must have non-empty content',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        break;

      case StepType.multipleChoice:
        if (step.question == null || step.question!.trim().isEmpty) {
          throw ContentValidationError(
            'Multiple choice step must have a question',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        if (step.options == null || step.options!.length < 2) {
          throw ContentValidationError(
            'Multiple choice step must have at least 2 options',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        if (step.correctAnswer == null ||
            step.correctAnswer! < 0 ||
            step.correctAnswer! >= step.options!.length) {
          throw ContentValidationError(
            'Multiple choice step must have a valid correctAnswer index',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        if (step.explanation == null || step.explanation!.trim().isEmpty) {
          throw ContentValidationError(
            'Multiple choice step must have an explanation',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        break;

      case StepType.trueFalse:
        if (step.question == null || step.question!.trim().isEmpty) {
          throw ContentValidationError(
            'True/false step must have a question',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        if (step.correctAnswerBool == null) {
          throw ContentValidationError(
            'True/false step must have correctAnswerBool',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        if (step.explanation == null || step.explanation!.trim().isEmpty) {
          throw ContentValidationError(
            'True/false step must have an explanation',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        break;

      case StepType.fillInBlank:
        if (step.question == null || step.question!.trim().isEmpty) {
          throw ContentValidationError(
            'Fill-in-blank step must have a question',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        if (step.acceptedAnswers == null || step.acceptedAnswers!.isEmpty) {
          throw ContentValidationError(
            'Fill-in-blank step must have at least one accepted answer',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        if (step.explanation == null || step.explanation!.trim().isEmpty) {
          throw ContentValidationError(
            'Fill-in-blank step must have an explanation',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        break;

      case StepType.codeOrdering:
        if (step.question == null || step.question!.trim().isEmpty) {
          throw ContentValidationError(
            'Code ordering step must have a question',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        if (step.snippets == null || step.snippets!.length < 2) {
          throw ContentValidationError(
            'Code ordering step must have at least 2 snippets',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        // Check snippets are unique
        if (step.snippets!.toSet().length != step.snippets!.length) {
          throw ContentValidationError(
            'Code ordering snippets must be unique',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        if (step.correctOrder == null ||
            step.correctOrder!.length != step.snippets!.length) {
          throw ContentValidationError(
            'Code ordering step must have correctOrder matching snippets length',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        // Validate correctOrder is a valid permutation
        final expectedIndices = List<int>.generate(
          step.snippets!.length,
          (i) => i,
        ).toSet();
        final actualIndices = step.correctOrder!.toSet();
        // Use manual comparison to avoid potential Set equality issues
        final setsEqual =
            expectedIndices.length == actualIndices.length &&
            expectedIndices.every((e) => actualIndices.contains(e));
        if (!setsEqual) {
          throw ContentValidationError(
            'Code ordering correctOrder must be a valid permutation of indices. Expected: $expectedIndices, Actual: $actualIndices, snippets length: ${step.snippets!.length}, correctOrder: ${step.correctOrder}',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        if (step.explanation == null || step.explanation!.trim().isEmpty) {
          throw ContentValidationError(
            'Code ordering step must have an explanation',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
        break;
    }

    // Validate hints if present
    if (step.hints != null && step.hints!.isNotEmpty) {
      if (step.hints!.length > 2) {
        // Using length is fine here since we need the count
        throw ContentValidationError(
          'Step can have at most 2 hints',
          courseId: courseId,
          moduleId: moduleId,
          lessonId: lessonId,
          stepId: stepRef,
        );
      }
      for (final hint in step.hints!) {
        if (hint.trim().isEmpty) {
          throw ContentValidationError(
            'Hints cannot be empty',
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
            stepId: stepRef,
          );
        }
      }
    }
  }

  static List<LearningPath> getLearningPaths() {
    if (!_initialized) {
      throw StateError(
        'ContentLoader not initialized. Call initialize() first.',
      );
    }
    return _learningPaths!.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  static LearningPath? getLearningPath(String pathId) {
    if (!_initialized) return null;
    return _learningPaths![pathId];
  }

  static CourseContent? getCourse(String courseId) {
    if (!_initialized) return null;
    return _courseContents![courseId];
  }

  static List<CourseContent> getCoursesForPath(String pathId) {
    if (!_initialized) return [];
    final path = _learningPaths![pathId];
    if (path == null) return [];
    return path.courseIds
        .map((id) => _courseContents![id])
        .whereType<CourseContent>()
        .toList();
  }

  static ModuleContent? getModule(String courseId, String moduleId) {
    final course = getCourse(courseId);
    if (course == null) return null;
    for (final module in course.modules) {
      if (module.id == moduleId) return module;
    }
    return null;
  }

  static LessonContent? getLesson(
    String courseId,
    String moduleId,
    String lessonId,
  ) {
    final module = getModule(courseId, moduleId);
    if (module == null) return null;
    for (final lesson in module.lessons) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
  }

  static LessonStepContent? getStep(
    String courseId,
    String moduleId,
    String lessonId,
    int stepIndex,
  ) {
    final lesson = getLesson(courseId, moduleId, lessonId);
    if (lesson == null || stepIndex >= lesson.steps.length) return null;
    return lesson.steps[stepIndex];
  }

  static void resetForTesting() {
    _learningPaths = null;
    _courseContents = null;
    _initialized = false;
  }
}
