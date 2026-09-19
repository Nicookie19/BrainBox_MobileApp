import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class LessonRepository {
  static const Map<String, String> _lessonAssets = {
    'frontend-foundations': 'assets/lessons/frontend-foundations.json',
    'python-essentials': 'assets/lessons/python-essentials.json',
    'data-structures': 'assets/lessons/data-structures.json',
    'sql-basics': 'assets/lessons/sql-basics.json',
  };

  static Future<LessonModuleData?> getCourseLessons(String courseId) async {
    final assetPath = _lessonAssets[courseId];
    if (assetPath == null) return null;

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return LessonModuleData.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  static Future<List<LessonModule>> getAllModules(String courseId) async {
    final data = await getCourseLessons(courseId);
    return data?.modules ?? [];
  }

  static Future<Lesson?> getLesson(String courseId, String lessonId) async {
    final modules = await getAllModules(courseId);
    for (final module in modules) {
      for (final lesson in module.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }

  static Future<LessonStep?> getLessonStep(
    String courseId,
    String lessonId,
    int stepIndex,
  ) async {
    final lesson = await getLesson(courseId, lessonId);
    if (lesson == null || stepIndex >= lesson.steps.length) return null;
    return lesson.steps[stepIndex];
  }
}

class LessonModuleData {
  final String courseId;
  final List<LessonModule> modules;

  LessonModuleData({
    required this.courseId,
    required this.modules,
  });

  factory LessonModuleData.fromJson(Map<String, dynamic> json) {
    return LessonModuleData(
      courseId: json['courseId'] as String,
      modules: (json['modules'] as List<dynamic>)
          .map((m) => LessonModule.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LessonModule {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<Lesson> lessons;

  LessonModule({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.lessons,
  });

  factory LessonModule.fromJson(Map<String, dynamic> json) {
    return LessonModule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      lessons: (json['lessons'] as List<dynamic>)
          .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final List<LessonStep> steps;
  final int estimatedMinutes;
  final int xpReward;

  Lesson({
    required this.id,
    required this.title,
    required this.steps,
    required this.estimatedMinutes,
    required this.xpReward,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((s) => LessonStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      estimatedMinutes: json['estimatedMinutes'] as int,
      xpReward: json['xpReward'] as int,
    );
  }
}

class LessonStep {
  final LessonStepType type;
  final String? content;
  final String? question;
  final List<String>? options;
  final int? correctAnswer;
  final String? explanation;
  final String? answer;
  final List<String>? snippets;
  final List<int>? correctOrder;

  LessonStep({
    required this.type,
    this.content,
    this.question,
    this.options,
    this.correctAnswer,
    this.explanation,
    this.answer,
    this.snippets,
    this.correctOrder,
  });

  factory LessonStep.fromJson(Map<String, dynamic> json) {
    return LessonStep(
      type: LessonStepType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LessonStepType.explanation,
      ),
      content: json['content'] as String?,
      question: json['question'] as String?,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      correctAnswer: json['correctAnswer'] as int?,
      explanation: json['explanation'] as String?,
      answer: json['answer'] as String?,
      snippets: json['snippets'] != null
          ? List<String>.from(json['snippets'] as List)
          : null,
      correctOrder: json['correctOrder'] != null
          ? List<int>.from(json['correctOrder'] as List)
          : null,
    );
  }
}

enum LessonStepType {
  explanation,
  multipleChoice,
  fillInBlank,
  codeOrdering,
}