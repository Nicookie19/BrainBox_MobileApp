import 'package:flutter/material.dart';

class LearningPath {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final List<String> courseIds;
  final int order;

  LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.courseIds,
    required this.order,
  });

  factory LearningPath.fromJson(Map<String, dynamic> json) => LearningPath(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    iconName: json['iconName'] as String,
    courseIds: List<String>.from(json['courseIds'] as List),
    order: json['order'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'iconName': iconName,
    'courseIds': courseIds,
    'order': order,
  };

  IconData get icon {
    switch (iconName) {
      case 'web':
        return Icons.web_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'cloud':
        return Icons.cloud_rounded;
      case 'mobile':
        return Icons.phone_android_rounded;
      case 'data':
        return Icons.storage_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (id) {
      case 'web_development':
        return const Color(0xFF3B82F6);
      case 'programming_fundamentals':
        return const Color(0xFF8B5CF6);
      case 'backend_cloud':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6366F1);
    }
  }
}

class CourseContent {
  final String courseId;
  final String learningPathId;
  final int version;
  final List<ModuleContent> modules;

  CourseContent({
    required this.courseId,
    required this.learningPathId,
    required this.version,
    required this.modules,
  });

  factory CourseContent.fromJson(Map<String, dynamic> json) => CourseContent(
    courseId: json['courseId'] as String,
    learningPathId: json['learningPathId'] as String,
    version: json['version'] as int? ?? 1,
    modules: (json['modules'] as List<dynamic>)
        .map((m) => ModuleContent.fromJson(m as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'learningPathId': learningPathId,
    'version': version,
    'modules': modules.map((m) => m.toJson()).toList(),
  };

  int get totalLessons => modules.fold(0, (sum, m) => sum + m.lessons.length);
  int get totalSteps => modules.fold(
    0,
    (sum, m) => sum + m.lessons.fold(0, (s, l) => s + l.steps.length),
  );
}

class ModuleContent {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<LessonContent> lessons;

  ModuleContent({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.lessons,
  });

  factory ModuleContent.fromJson(Map<String, dynamic> json) => ModuleContent(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    order: json['order'] as int,
    lessons: (json['lessons'] as List<dynamic>)
        .map((l) => LessonContent.fromJson(l as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'order': order,
    'lessons': lessons.map((l) => l.toJson()).toList(),
  };
}

class LessonContent {
  final String id;
  final String title;
  final String description;
  final int order;
  final int estimatedMinutes;
  final int xpReward;
  final List<LessonStepContent> steps;
  final int contentVersion;

  LessonContent({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.estimatedMinutes,
    required this.xpReward,
    required this.steps,
    this.contentVersion = 1,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) => LessonContent(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    order: json['order'] as int,
    estimatedMinutes: json['estimatedMinutes'] as int,
    xpReward: json['xpReward'] as int,
    steps: (json['steps'] as List<dynamic>)
        .map((s) => LessonStepContent.fromJson(s as Map<String, dynamic>))
        .toList(),
    contentVersion: json['contentVersion'] as int? ?? 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'order': order,
    'estimatedMinutes': estimatedMinutes,
    'xpReward': xpReward,
    'steps': steps.map((s) => s.toJson()).toList(),
    'contentVersion': contentVersion,
  };
}

enum StepType {
  explanation('explanation'),
  multipleChoice('multiple_choice'),
  trueFalse('true_false'),
  fillInBlank('fill_in_blank'),
  codeOrdering('code_ordering');

  const StepType(this.value);
  final String value;

  static StepType fromString(String value) {
    return StepType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StepType.explanation,
    );
  }
}

class LessonStepContent {
  final StepType type;
  final String? content;
  final String? question;
  final List<String>? options;
  final int? correctAnswer;
  final bool? correctAnswerBool;
  final String? explanation;
  final List<String>? hints;
  final String? answer;
  final List<String>? acceptedAnswers;
  final List<String>? snippets;
  final List<int>? correctOrder;

  LessonStepContent({
    required this.type,
    this.content,
    this.question,
    this.options,
    this.correctAnswer,
    this.correctAnswerBool,
    this.explanation,
    this.hints,
    this.answer,
    this.acceptedAnswers,
    this.snippets,
    this.correctOrder,
  });

  factory LessonStepContent.fromJson(Map<String, dynamic> json) {
    return LessonStepContent(
      type: StepType.fromString(json['type'] as String? ?? 'explanation'),
      content: json['content'] as String?,
      question: json['question'] as String?,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      correctAnswer: json['correctAnswer'] as int?,
      correctAnswerBool: json['correctAnswerBool'] as bool?,
      explanation: json['explanation'] as String?,
      hints: json['hints'] != null
          ? List<String>.from(json['hints'] as List)
          : null,
      answer: json['answer'] as String?,
      acceptedAnswers: json['acceptedAnswers'] != null
          ? List<String>.from(json['acceptedAnswers'] as List)
          : null,
      snippets: json['snippets'] != null
          ? List<String>.from(json['snippets'] as List)
          : null,
      correctOrder: json['correctOrder'] != null
          ? List<int>.from(json['correctOrder'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.value,
    if (content != null) 'content': content,
    if (question != null) 'question': question,
    if (options != null) 'options': options,
    if (correctAnswer != null) 'correctAnswer': correctAnswer,
    if (correctAnswerBool != null) 'correctAnswerBool': correctAnswerBool,
    if (explanation != null) 'explanation': explanation,
    if (hints != null) 'hints': hints,
    if (answer != null) 'answer': answer,
    if (acceptedAnswers != null) 'acceptedAnswers': acceptedAnswers,
    if (snippets != null) 'snippets': snippets,
    if (correctOrder != null) 'correctOrder': correctOrder,
  };
}
