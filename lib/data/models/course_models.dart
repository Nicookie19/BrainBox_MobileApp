import 'learning_models.dart';

class Course {
  final String id;
  final String title;
  final String shortDescription;
  final String longDescription;
  final LearningCategory category;
  final DifficultyLevel difficulty;
  final String thumbnailUrl;
  final int estimatedHours;
  final int lessonCount;
  final int quizCount;
  final int projectCount;
  final List<String> prerequisites;
  final List<String> learningOutcomes;
  final List<String> tags;
  final bool isFeatured;
  final bool isNew;
  final double rating;
  final int enrollmentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Course({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.category,
    required this.difficulty,
    required this.thumbnailUrl,
    required this.estimatedHours,
    required this.lessonCount,
    required this.quizCount,
    required this.projectCount,
    required this.prerequisites,
    required this.learningOutcomes,
    required this.tags,
    required this.isFeatured,
    required this.isNew,
    required this.rating,
    required this.enrollmentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalContentCount => lessonCount + quizCount + projectCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'shortDescription': shortDescription,
        'longDescription': longDescription,
        'category': category.toString(),
        'difficulty': difficulty.toString(),
        'thumbnailUrl': thumbnailUrl,
        'estimatedHours': estimatedHours,
        'lessonCount': lessonCount,
        'quizCount': quizCount,
        'projectCount': projectCount,
        'prerequisites': prerequisites,
        'learningOutcomes': learningOutcomes,
        'tags': tags,
        'isFeatured': isFeatured,
        'isNew': isNew,
        'rating': rating,
        'enrollmentCount': enrollmentCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'],
        title: json['title'],
        shortDescription: json['shortDescription'],
        longDescription: json['longDescription'],
        category: LearningCategory.values.firstWhere(
          (e) => e.toString() == 'LearningCategory.${json['category']}',
          orElse: () => LearningCategory.webDevelopment,
        ),
        difficulty: DifficultyLevel.values.firstWhere(
          (e) => e.toString() == 'DifficultyLevel.${json['difficulty']}',
          orElse: () => DifficultyLevel.beginner,
        ),
        thumbnailUrl: json['thumbnailUrl'],
        estimatedHours: json['estimatedHours'],
        lessonCount: json['lessonCount'],
        quizCount: json['quizCount'],
        projectCount: json['projectCount'],
        prerequisites: List<String>.from(json['prerequisites'] ?? []),
        learningOutcomes:
            List<String>.from(json['learningOutcomes'] ?? []),
        tags: List<String>.from(json['tags'] ?? []),
        isFeatured: json['isFeatured'] ?? false,
        isNew: json['isNew'] ?? false,
        rating: json['rating']?.toDouble() ?? 0.0,
        enrollmentCount: json['enrollmentCount'] ?? 0,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Course copyWith({
    String? id,
    String? title,
    String? shortDescription,
    String? longDescription,
    LearningCategory? category,
    DifficultyLevel? difficulty,
    String? thumbnailUrl,
    int? estimatedHours,
    int? lessonCount,
    int? quizCount,
    int? projectCount,
    List<String>? prerequisites,
    List<String>? learningOutcomes,
    List<String>? tags,
    bool? isFeatured,
    bool? isNew,
    double? rating,
    int? enrollmentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      longDescription: longDescription ?? this.longDescription,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      lessonCount: lessonCount ?? this.lessonCount,
      quizCount: quizCount ?? this.quizCount,
      projectCount: projectCount ?? this.projectCount,
      prerequisites: prerequisites ?? this.prerequisites,
      learningOutcomes: learningOutcomes ?? this.learningOutcomes,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      rating: rating ?? this.rating,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Module {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final int order;
  final List<Lesson> lessons;
  final List<Quiz> quizzes;
  final List<Project> projects;
  final bool isLocked;
  final bool isCompleted;

  const Module({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.order,
    required this.lessons,
    required this.quizzes,
    required this.projects,
    this.isLocked = false,
    this.isCompleted = false,
  });

  int get totalItems => lessons.length + quizzes.length + projects.length;
  int get completedItems =>
      lessons.where((l) => l.isCompleted).length +
      quizzes.where((q) => q.isCompleted).length +
      projects.where((p) => p.isCompleted).length;

  double get progress => totalItems > 0 ? completedItems / totalItems : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'title': title,
        'description': description,
        'order': order,
        'lessons': lessons.map((l) => l.toJson()).toList(),
        'quizzes': quizzes.map((q) => q.toJson()).toList(),
        'projects': projects.map((p) => p.toJson()).toList(),
        'isLocked': isLocked,
        'isCompleted': isCompleted,
      };

  factory Module.fromJson(Map<String, dynamic> json) => Module(
        id: json['id'],
        courseId: json['courseId'],
        title: json['title'],
        description: json['description'],
        order: json['order'],
        lessons: List<Lesson>.from(
            json['lessons']?.map((l) => Lesson.fromJson(l)) ?? []),
        quizzes: List<Quiz>.from(
            json['quizzes']?.map((q) => Quiz.fromJson(q)) ?? []),
        projects: List<Project>.from(
            json['projects']?.map((p) => Project.fromJson(p)) ?? []),
        isLocked: json['isLocked'] ?? false,
        isCompleted: json['isCompleted'] ?? false,
      );
}

class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final String content;
  final String? videoUrl;
  final List<String> codeSnippets;
  final List<String> keyTakeaways;
  final int estimatedMinutes;
  final int order;
  final bool isLocked;
  final bool isCompleted;
  final bool isBookmarked;
  final DateTime? completedAt;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.content,
    this.videoUrl,
    required this.codeSnippets,
    required this.keyTakeaways,
    required this.estimatedMinutes,
    required this.order,
    this.isLocked = false,
    this.isCompleted = false,
    this.isBookmarked = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'title': title,
        'content': content,
        'videoUrl': videoUrl,
        'codeSnippets': codeSnippets,
        'keyTakeaways': keyTakeaways,
        'estimatedMinutes': estimatedMinutes,
        'order': order,
        'isLocked': isLocked,
        'isCompleted': isCompleted,
        'isBookmarked': isBookmarked,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'],
        moduleId: json['moduleId'],
        title: json['title'],
        content: json['content'],
        videoUrl: json['videoUrl'],
        codeSnippets: List<String>.from(json['codeSnippets'] ?? []),
        keyTakeaways: List<String>.from(json['keyTakeaways'] ?? []),
        estimatedMinutes: json['estimatedMinutes'],
        order: json['order'],
        isLocked: json['isLocked'] ?? false,
        isCompleted: json['isCompleted'] ?? false,
        isBookmarked: json['isBookmarked'] ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
      );

  Lesson copyWith({
    String? id,
    String? moduleId,
    String? title,
    String? content,
    String? videoUrl,
    List<String>? codeSnippets,
    List<String>? keyTakeaways,
    int? estimatedMinutes,
    int? order,
    bool? isLocked,
    bool? isCompleted,
    bool? isBookmarked,
    DateTime? completedAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      content: content ?? this.content,
      videoUrl: videoUrl ?? this.videoUrl,
      codeSnippets: codeSnippets ?? this.codeSnippets,
      keyTakeaways: keyTakeaways ?? this.keyTakeaways,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      order: order ?? this.order,
      isLocked: isLocked ?? this.isLocked,
      isCompleted: isCompleted ?? this.isCompleted,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class Quiz {
  final String id;
  final String moduleId;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int timeLimitMinutes;
  final int passingScore;
  final int order;
  final bool isLocked;
  final bool isCompleted;
  final int bestScore;
  final int attempts;
  final DateTime? completedAt;

  const Quiz({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.questions,
    required this.timeLimitMinutes,
    required this.passingScore,
    required this.order,
    this.isLocked = false,
    this.isCompleted = false,
    this.bestScore = 0,
    this.attempts = 0,
    this.completedAt,
  });

  int get totalQuestions => questions.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'title': title,
        'description': description,
        'questions': questions.map((q) => q.toJson()).toList(),
        'timeLimitMinutes': timeLimitMinutes,
        'passingScore': passingScore,
        'order': order,
        'isLocked': isLocked,
        'isCompleted': isCompleted,
        'bestScore': bestScore,
        'attempts': attempts,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        id: json['id'],
        moduleId: json['moduleId'],
        title: json['title'],
        description: json['description'],
        questions: List<QuizQuestion>.from(
            json['questions']?.map((q) => QuizQuestion.fromJson(q)) ?? []),
        timeLimitMinutes: json['timeLimitMinutes'],
        passingScore: json['passingScore'],
        order: json['order'],
        isLocked: json['isLocked'] ?? false,
        isCompleted: json['isCompleted'] ?? false,
        bestScore: json['bestScore'] ?? 0,
        attempts: json['attempts'] ?? 0,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
      );
}

class QuizQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String? codeSnippet;
  final int points;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.codeSnippet,
    this.points = 10,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'type': type.toString(),
        'options': options,
        'correctAnswerIndex': correctAnswerIndex,
        'explanation': explanation,
        'codeSnippet': codeSnippet,
        'points': points,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'],
        question: json['question'],
        type: QuestionType.values.firstWhere(
          (e) => e.toString() == 'QuestionType.${json['type']}',
          orElse: () => QuestionType.singleChoice,
        ),
        options: List<String>.from(json['options'] ?? []),
        correctAnswerIndex: json['correctAnswerIndex'],
        explanation: json['explanation'],
        codeSnippet: json['codeSnippet'],
        points: json['points'] ?? 10,
      );
}

enum QuestionType {
  singleChoice('Single Choice'),
  multipleChoice('Multiple Choice'),
  trueFalse('True/False'),
  codeOutput('Code Output'),
  fillInBlank('Fill in the Blank');

  const QuestionType(this.label);
  final String label;
}

class Project {
  final String id;
  final String moduleId;
  final String title;
  final String description;
  final List<String> requirements;
  final List<String> starterFiles;
  final String solutionUrl;
  final int estimatedHours;
  final int order;
  final bool isLocked;
  final bool isCompleted;
  final bool isSubmitted;
  final String? submissionUrl;
  final DateTime? completedAt;

  const Project({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.requirements,
    required this.starterFiles,
    required this.solutionUrl,
    required this.estimatedHours,
    required this.order,
    this.isLocked = false,
    this.isCompleted = false,
    this.isSubmitted = false,
    this.submissionUrl,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'title': title,
        'description': description,
        'requirements': requirements,
        'starterFiles': starterFiles,
        'solutionUrl': solutionUrl,
        'estimatedHours': estimatedHours,
        'order': order,
        'isLocked': isLocked,
        'isCompleted': isCompleted,
        'isSubmitted': isSubmitted,
        'submissionUrl': submissionUrl,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'],
        moduleId: json['moduleId'],
        title: json['title'],
        description: json['description'],
        requirements: List<String>.from(json['requirements'] ?? []),
        starterFiles: List<String>.from(json['starterFiles'] ?? []),
        solutionUrl: json['solutionUrl'],
        estimatedHours: json['estimatedHours'],
        order: json['order'],
        isLocked: json['isLocked'] ?? false,
        isCompleted: json['isCompleted'] ?? false,
        isSubmitted: json['isSubmitted'] ?? false,
        submissionUrl: json['submissionUrl'],
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
      );
}
