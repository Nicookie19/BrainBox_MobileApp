import 'package:flutter/material.dart';

import 'learning_models.dart';

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String bio;
  final UserLevel level;
  final int xp;
  final int totalXp;
  final List<String> completedCourseIds;
  final List<String> enrolledCourseIds;
  final List<String> bookmarkedLessonIds;
  final List<Achievement> achievements;
  final UserStats stats;
  final UserPreferences preferences;
  final DateTime joinedAt;
  final DateTime lastActiveAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio = '',
    required this.level,
    required this.xp,
    required this.totalXp,
    required this.completedCourseIds,
    required this.enrolledCourseIds,
    required this.bookmarkedLessonIds,
    required this.achievements,
    required this.stats,
    required this.preferences,
    required this.joinedAt,
    required this.lastActiveAt,
  });

  int get xpToNextLevel => (UserLevel.getNextLevel(level)?.xpRequired ?? xp) - xp;
  double get levelProgress {
    final nextLevel = UserLevel.getNextLevel(level);
    if (nextLevel == null) return 1;
    final previousThreshold = level.xpRequired;
    final range = nextLevel.xpRequired - previousThreshold;
    return ((xp - previousThreshold) / range).clamp(0.0, 1.0).toDouble();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'bio': bio,
        'level': level.toJson(),
        'xp': xp,
        'totalXp': totalXp,
        'completedCourseIds': completedCourseIds,
        'enrolledCourseIds': enrolledCourseIds,
        'bookmarkedLessonIds': bookmarkedLessonIds,
        'achievements': achievements.map((a) => a.toJson()).toList(),
        'stats': stats.toJson(),
        'preferences': preferences.toJson(),
        'joinedAt': joinedAt.toIso8601String(),
        'lastActiveAt': lastActiveAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        email: json['email'],
        displayName: json['displayName'],
        photoUrl: json['photoUrl'],
        bio: json['bio'] ?? '',
        level: UserLevel.fromJson(json['level']),
        xp: json['xp'],
        totalXp: json['totalXp'],
        completedCourseIds:
            List<String>.from(json['completedCourseIds'] ?? []),
        enrolledCourseIds:
            List<String>.from(json['enrolledCourseIds'] ?? []),
        bookmarkedLessonIds:
            List<String>.from(json['bookmarkedLessonIds'] ?? []),
        achievements: List<Achievement>.from(
            json['achievements']?.map((a) => Achievement.fromJson(a)) ?? []),
        stats: UserStats.fromJson(json['stats']),
        preferences: UserPreferences.fromJson(json['preferences']),
        joinedAt: DateTime.parse(json['joinedAt']),
        lastActiveAt: DateTime.parse(json['lastActiveAt']),
      );

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    UserLevel? level,
    int? xp,
    int? totalXp,
    List<String>? completedCourseIds,
    List<String>? enrolledCourseIds,
    List<String>? bookmarkedLessonIds,
    List<Achievement>? achievements,
    UserStats? stats,
    UserPreferences? preferences,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      totalXp: totalXp ?? this.totalXp,
      completedCourseIds:
          completedCourseIds ?? this.completedCourseIds,
      enrolledCourseIds: enrolledCourseIds ?? this.enrolledCourseIds,
      bookmarkedLessonIds:
          bookmarkedLessonIds ?? this.bookmarkedLessonIds,
      achievements: achievements ?? this.achievements,
      stats: stats ?? this.stats,
      preferences: preferences ?? this.preferences,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

class UserLevel {
  final int number;
  final String title;
  final int xpRequired;
  final String badgeAsset;
  final Color color;

  const UserLevel({
    required this.number,
    required this.title,
    required this.xpRequired,
    required this.badgeAsset,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'number': number,
        'title': title,
        'xpRequired': xpRequired,
        'badgeAsset': badgeAsset,
      'color': color.toARGB32(),
      };

  factory UserLevel.fromJson(Map<String, dynamic> json) => UserLevel(
        number: json['number'],
        title: json['title'],
        xpRequired: json['xpRequired'],
        badgeAsset: json['badgeAsset'],
        color: Color(json['color']),
      );

  static const List<UserLevel> allLevels = [
    UserLevel(
      number: 1,
      title: 'Novice',
      xpRequired: 100,
      badgeAsset: '🌱',
      color: Color(0xFF40C057),
    ),
    UserLevel(
      number: 2,
      title: 'Learner',
      xpRequired: 300,
      badgeAsset: '📚',
      color: Color(0xFF339AF0),
    ),
    UserLevel(
      number: 3,
      title: 'Explorer',
      xpRequired: 600,
      badgeAsset: '🧭',
      color: Color(0xFF845EF7),
    ),
    UserLevel(
      number: 4,
      title: 'Builder',
      xpRequired: 1000,
      badgeAsset: '🔨',
      color: Color(0xFFF59E0B),
    ),
    UserLevel(
      number: 5,
      title: 'Developer',
      xpRequired: 1500,
      badgeAsset: '💻',
      color: Color(0xFFEF4444),
    ),
    UserLevel(
      number: 6,
      title: 'Engineer',
      xpRequired: 2200,
      badgeAsset: '⚙️',
      color: Color(0xFF06B6D4),
    ),
    UserLevel(
      number: 7,
      title: 'Architect',
      xpRequired: 3200,
      badgeAsset: '🏗️',
      color: Color(0xFF8B5CF6),
    ),
    UserLevel(
      number: 8,
      title: 'Expert',
      xpRequired: 4500,
      badgeAsset: '🎯',
      color: Color(0xFF10B981),
    ),
    UserLevel(
      number: 9,
      title: 'Master',
      xpRequired: 6000,
      badgeAsset: '🏆',
      color: Color(0xFFF97316),
    ),
    UserLevel(
      number: 10,
      title: 'Legend',
      xpRequired: 8000,
      badgeAsset: '⭐',
      color: Color(0xFFEC4899),
    ),
  ];

  static UserLevel getLevelForXp(int totalXp) {
    for (int i = allLevels.length - 1; i >= 0; i--) {
      if (totalXp >= allLevels[i].xpRequired) {
        return allLevels[i];
      }
    }
    return allLevels[0];
  }

  static UserLevel? getNextLevel(UserLevel current) {
    final index = allLevels.indexOf(current);
    if (index < allLevels.length - 1) {
      return allLevels[index + 1];
    }
    return null;
  }
}

class UserStats {
  final int totalCoursesCompleted;
  final int totalLessonsCompleted;
  final int totalQuizzesPassed;
  final int totalProjectsCompleted;
  final int totalStudyMinutes;
  final int currentStreakDays;
  final int longestStreakDays;
  final Map<LearningCategory, int> categoryProgress;
  final Map<DifficultyLevel, int> difficultyBreakdown;

  const UserStats({
    required this.totalCoursesCompleted,
    required this.totalLessonsCompleted,
    required this.totalQuizzesPassed,
    required this.totalProjectsCompleted,
    required this.totalStudyMinutes,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.categoryProgress,
    required this.difficultyBreakdown,
  });

  Map<String, dynamic> toJson() => {
        'totalCoursesCompleted': totalCoursesCompleted,
        'totalLessonsCompleted': totalLessonsCompleted,
        'totalQuizzesPassed': totalQuizzesPassed,
        'totalProjectsCompleted': totalProjectsCompleted,
        'totalStudyMinutes': totalStudyMinutes,
        'currentStreakDays': currentStreakDays,
        'longestStreakDays': longestStreakDays,
        'categoryProgress': categoryProgress.map(
            (key, value) => MapEntry(key.toString(), value)),
        'difficultyBreakdown': difficultyBreakdown.map(
            (key, value) => MapEntry(key.toString(), value)),
      };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        totalCoursesCompleted: json['totalCoursesCompleted'],
        totalLessonsCompleted: json['totalLessonsCompleted'],
        totalQuizzesPassed: json['totalQuizzesPassed'],
        totalProjectsCompleted: json['totalProjectsCompleted'],
        totalStudyMinutes: json['totalStudyMinutes'],
        currentStreakDays: json['currentStreakDays'],
        longestStreakDays: json['longestStreakDays'],
        categoryProgress: (json['categoryProgress'] as Map<String, dynamic>?)
                ?.map((key, value) =>
                    MapEntry(LearningCategory.values.firstWhere(
                        (e) => e.toString() == 'LearningCategory.$key',
                        orElse: () => LearningCategory.webDevelopment),
                        value as int)) ??
            {},
        difficultyBreakdown: (json['difficultyBreakdown'] as Map<String, dynamic>?)
                ?.map((key, value) => MapEntry(
                    DifficultyLevel.values.firstWhere(
                        (e) => e.toString() == 'DifficultyLevel.$key',
                        orElse: () => DifficultyLevel.beginner),
                    value as int)) ??
            {},
      );

  factory UserStats.empty() {
    return UserStats(
      totalCoursesCompleted: 0,
      totalLessonsCompleted: 0,
      totalQuizzesPassed: 0,
      totalProjectsCompleted: 0,
      totalStudyMinutes: 0,
      currentStreakDays: 0,
      longestStreakDays: 0,
      categoryProgress: {},
      difficultyBreakdown: {},
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final AchievementType type;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int target;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.type,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    required this.target,
  });

  double get progressPercent => target > 0 ? progress / target : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconAsset': iconAsset,
        'type': type.toString(),
        'xpReward': xpReward,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'progress': progress,
        'target': target,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        iconAsset: json['iconAsset'],
        type: AchievementType.values.firstWhere(
          (e) => e.toString() == 'AchievementType.${json['type']}',
          orElse: () => AchievementType.coursesCompleted,
        ),
        xpReward: json['xpReward'],
        isUnlocked: json['isUnlocked'],
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'])
            : null,
        progress: json['progress'],
        target: json['target'],
      );
}

enum AchievementType {
  coursesCompleted('Courses Completed'),
  lessonsCompleted('Lessons Completed'),
  quizzesPassed('Quizzes Passed'),
  streakDays('Study Streak'),
  studyTime('Study Time'),
  categoriesExplored('Categories Explored'),
  perfectScore('Perfect Score'),
  firstProject('First Project'),
  socialButterfly('Community Active'),
  earlyBird('Early Bird'),
  nightOwl('Night Owl'),
  weekendWarrior('Weekend Warrior');

  const AchievementType(this.label);
  final String label;
}

class UserPreferences {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool darkMode;
  final bool autoPlayVideos;
  final bool downloadOnWifiOnly;
  final String preferredLanguage;
  final List<LearningCategory> interestedCategories;
  final Duration dailyReminderTime;
  final bool hapticFeedback;
  final bool reduceMotion;

  const UserPreferences({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.darkMode = false,
    this.autoPlayVideos = false,
    this.downloadOnWifiOnly = true,
    this.preferredLanguage = 'en',
    this.interestedCategories = const [],
    this.dailyReminderTime = const Duration(hours: 19),
    this.hapticFeedback = true,
    this.reduceMotion = false,
  });

  Map<String, dynamic> toJson() => {
        'notificationsEnabled': notificationsEnabled,
        'emailNotifications': emailNotifications,
        'pushNotifications': pushNotifications,
        'darkMode': darkMode,
        'autoPlayVideos': autoPlayVideos,
        'downloadOnWifiOnly': downloadOnWifiOnly,
        'preferredLanguage': preferredLanguage,
        'interestedCategories':
            interestedCategories.map((e) => e.toString()).toList(),
        'dailyReminderTime': dailyReminderTime.inSeconds,
        'hapticFeedback': hapticFeedback,
        'reduceMotion': reduceMotion,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) => UserPreferences(
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        emailNotifications: json['emailNotifications'] ?? true,
        pushNotifications: json['pushNotifications'] ?? true,
        darkMode: json['darkMode'] ?? false,
        autoPlayVideos: json['autoPlayVideos'] ?? false,
        downloadOnWifiOnly: json['downloadOnWifiOnly'] ?? true,
        preferredLanguage: json['preferredLanguage'] ?? 'en',
        interestedCategories: (json['interestedCategories'] as List<dynamic>?)
                ?.map((e) => LearningCategory.values.firstWhere(
                    (cat) => cat.toString() == 'LearningCategory.$e',
                    orElse: () => LearningCategory.webDevelopment))
                .toList() ??
            [],
        dailyReminderTime: Duration(seconds: json['dailyReminderTime'] ?? 19 * 3600),
        hapticFeedback: json['hapticFeedback'] ?? true,
        reduceMotion: json['reduceMotion'] ?? false,
      );

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? darkMode,
    bool? autoPlayVideos,
    bool? downloadOnWifiOnly,
    String? preferredLanguage,
    List<LearningCategory>? interestedCategories,
    Duration? dailyReminderTime,
    bool? hapticFeedback,
    bool? reduceMotion,
  }) {
    return UserPreferences(
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      darkMode: darkMode ?? this.darkMode,
      autoPlayVideos: autoPlayVideos ?? this.autoPlayVideos,
      downloadOnWifiOnly: downloadOnWifiOnly ?? this.downloadOnWifiOnly,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      interestedCategories:
          interestedCategories ?? this.interestedCategories,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}

class CourseProgress {
  final String courseId;
  final String userId;
  final int completedModules;
  final int totalModules;
  final int completedLessons;
  final int totalLessons;
  final int completedQuizzes;
  final int totalQuizzes;
  final int completedProjects;
  final int totalProjects;
  final int totalStudyMinutes;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;
  final bool isEnrolled;
  final bool isCompleted;

  const CourseProgress({
    required this.courseId,
    required this.userId,
    required this.completedModules,
    required this.totalModules,
    required this.completedLessons,
    required this.totalLessons,
    required this.completedQuizzes,
    required this.totalQuizzes,
    required this.completedProjects,
    required this.totalProjects,
    required this.totalStudyMinutes,
    required this.startedAt,
    this.completedAt,
    required this.lastAccessedAt,
    this.isEnrolled = false,
    this.isCompleted = false,
  });

  double get overallProgress {
    final total = totalModules + totalLessons + totalQuizzes + totalProjects;
    if (total == 0) return 0.0;
    final completed =
        completedModules +
        completedLessons +
        completedQuizzes +
        completedProjects;
    return completed / total;
  }

  Map<String, dynamic> toJson() => {
        'courseId': courseId,
        'userId': userId,
        'completedModules': completedModules,
        'totalModules': totalModules,
        'completedLessons': completedLessons,
        'totalLessons': totalLessons,
        'completedQuizzes': completedQuizzes,
        'totalQuizzes': totalQuizzes,
        'completedProjects': completedProjects,
        'totalProjects': totalProjects,
        'totalStudyMinutes': totalStudyMinutes,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'lastAccessedAt': lastAccessedAt.toIso8601String(),
        'isEnrolled': isEnrolled,
        'isCompleted': isCompleted,
      };

  factory CourseProgress.fromJson(Map<String, dynamic> json) => CourseProgress(
        courseId: json['courseId'],
        userId: json['userId'],
        completedModules: json['completedModules'],
        totalModules: json['totalModules'],
        completedLessons: json['completedLessons'],
        totalLessons: json['totalLessons'],
        completedQuizzes: json['completedQuizzes'],
        totalQuizzes: json['totalQuizzes'],
        completedProjects: json['completedProjects'],
        totalProjects: json['totalProjects'],
        totalStudyMinutes: json['totalStudyMinutes'],
        startedAt: DateTime.parse(json['startedAt']),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        lastAccessedAt: DateTime.parse(json['lastAccessedAt']),
        isEnrolled: json['isEnrolled'],
        isCompleted: json['isCompleted'],
      );

  CourseProgress copyWith({
    String? courseId,
    String? userId,
    int? completedModules,
    int? totalModules,
    int? completedLessons,
    int? totalLessons,
    int? completedQuizzes,
    int? totalQuizzes,
    int? completedProjects,
    int? totalProjects,
    int? totalStudyMinutes,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
    bool? isEnrolled,
    bool? isCompleted,
  }) {
    return CourseProgress(
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      completedModules: completedModules ?? this.completedModules,
      totalModules: totalModules ?? this.totalModules,
      completedLessons: completedLessons ?? this.completedLessons,
      totalLessons: totalLessons ?? this.totalLessons,
      completedQuizzes: completedQuizzes ?? this.completedQuizzes,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      completedProjects: completedProjects ?? this.completedProjects,
      totalProjects: totalProjects ?? this.totalProjects,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
