import 'package:flutter/foundation.dart';
import 'package:brainbox/data/repositories/community_repository.dart';
import 'package:brainbox/data/repositories/course_repository.dart';
import 'package:brainbox/data/repositories/lesson_repository.dart' as lr;
import 'package:brainbox/data/services/storage_service.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/data/models/user_models.dart';
import 'package:brainbox/data/models/community_models.dart';

class AppProvider extends ChangeNotifier {
  static const String _activityKey = 'activity_days';
  static const String _minutesKeyPrefix = 'study_minutes_';
  static const int _challengeXp = 50;
  static const int _challengeMinutes = 5;
  static const int _defaultLessonXp = 25;
  static const int _defaultLessonMinutes = 10;

  UserProfile? _profile;
  List<Course> _courses = [];
  List<CommunityPost> _posts = [];
  Map<String, List<lr.Lesson>> _lessonsByCourse = {};
  bool _isLoading = true;

  UserProfile? get profile => _profile;
  List<Course> get courses => _courses;
  List<CommunityPost> get posts => _posts;
  bool get isLoading => _isLoading;

  int get xp => _profile?.xp ?? 0;
  UserLevel get level => _profile?.level ?? UserLevel.allLevels[0];
  double get levelProgress => _profile?.levelProgress ?? 0;

  /// Streak as it stands today: a streak whose last activity is older than
  /// yesterday (UTC) has lapsed, even though nothing has rewritten the stored
  /// value yet.
  int get currentStreak => effectiveStreak(_profile);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _profile = await _loadOrCreateProfile();
    _courses = await CourseRepository.getAllCourses();
    _lessonsByCourse = await _loadLessons(_courses);
    _posts = await CommunityRepository.getPosts();

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, List<lr.Lesson>>> _loadLessons(
    List<Course> courses,
  ) async {
    final result = <String, List<lr.Lesson>>{};
    for (final course in courses) {
      final data = await lr.LessonRepository.getCourseLessons(course.id);
      if (data == null) continue;
      result[course.id] = data.modules.expand((m) => m.lessons).toList();
    }
    return result;
  }

  Future<UserProfile> _loadOrCreateProfile() async {
    final existing = StorageService.getUserProfile();
    if (existing != null) return existing;

    final newProfile = UserProfile(
      id: 'current_user',
      email: 'user@brainbox.app',
      displayName: 'Alex Rivera',
      bio: 'Aspiring Frontend Developer',
      level: UserLevel.getLevelForXp(0),
      xp: 0,
      totalXp: 0,
      completedCourseIds: [],
      enrolledCourseIds: ['frontend-foundations'],
      bookmarkedLessonIds: [],
      completedLessonIds: [],
      achievements: _defaultAchievements(),
      stats: UserStats.empty(),
      preferences: UserPreferences(),
      joinedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      lastLessonCompletedAt: null,
    );

    await StorageService.saveUserProfile(newProfile);
    return newProfile;
  }

  List<Achievement> _defaultAchievements() => [
    Achievement(
      id: 'streak_7',
      title: 'On Fire',
      description: '7 day streak',
      iconAsset: 'local_fire_department',
      type: AchievementType.streakDays,
      xpReward: 50,
      isUnlocked: false,
      progress: 0,
      target: 7,
    ),
    Achievement(
      id: 'first_course',
      title: 'Starter',
      description: 'Complete your first course',
      iconAsset: 'rocket_launch',
      type: AchievementType.coursesCompleted,
      xpReward: 100,
      isUnlocked: false,
      progress: 0,
      target: 1,
    ),
    Achievement(
      id: 'lessons_10',
      title: 'Scholar',
      description: 'Complete 10 lessons',
      iconAsset: 'menu_book',
      type: AchievementType.lessonsCompleted,
      xpReward: 75,
      isUnlocked: false,
      progress: 0,
      target: 10,
    ),
  ];

  Future<void> addXp(int amount) async {
    if (_profile == null) return;

    final newXp = _profile!.xp + amount;
    final newTotalXp = _profile!.totalXp + amount;
    final newLevel = UserLevel.getLevelForXp(newTotalXp);

    final updatedProfile = _profile!.copyWith(
      xp: newXp,
      totalXp: newTotalXp,
      level: newLevel,
      lastActiveAt: DateTime.now(),
    );

    _profile = updatedProfile;
    await StorageService.saveUserProfile(updatedProfile);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Course and lesson progress
  // ---------------------------------------------------------------------------

  /// Whether lesson content is available for [courseId].
  bool hasLessons(String courseId) =>
      (_lessonsByCourse[courseId] ?? const <lr.Lesson>[]).isNotEmpty;

  List<lr.Lesson> lessonsFor(String courseId) =>
      _lessonsByCourse[courseId] ?? const <lr.Lesson>[];

  int totalLessonsFor(String courseId) {
    final lessons = _lessonsByCourse[courseId];
    if (lessons != null) return lessons.length;
    for (final course in _courses) {
      if (course.id == courseId) return course.lessonCount;
    }
    return 0;
  }

  int completedLessonsFor(String courseId) {
    final ids = _profile?.completedLessonIds ?? const <String>[];
    return ids.where((id) => id.startsWith('$courseId:')).length;
  }

  bool isLessonCompleted(String courseId, String lessonId) =>
      _profile?.completedLessonIds.contains('$courseId:$lessonId') ?? false;

  /// Fraction (0..1) of a course's lessons that have been completed.
  double courseProgress(String courseId) {
    final total = totalLessonsFor(courseId);
    if (total <= 0) return 0;
    return (completedLessonsFor(courseId) / total).clamp(0.0, 1.0).toDouble();
  }

  bool isEnrolled(String courseId) =>
      _profile?.enrolledCourseIds.contains(courseId) ?? false;

  bool isCourseCompleted(String courseId) =>
      _profile?.completedCourseIds.contains(courseId) ?? false;

  /// The first lesson of [courseId] that has not been completed yet, or null
  /// when every lesson is done (or the course has no lessons).
  String? nextLessonIdFor(String courseId) {
    for (final lesson in lessonsFor(courseId)) {
      if (!isLessonCompleted(courseId, lesson.id)) return lesson.id;
    }
    return null;
  }

  /// Enrolled courses that are not finished, furthest along first.
  List<Course> get inProgressCourses {
    final list = _courses
        .where((c) => isEnrolled(c.id) && !isCourseCompleted(c.id))
        .toList();
    list.sort(
      (a, b) => courseProgress(b.id).compareTo(courseProgress(a.id)),
    );
    return list;
  }

  List<Course> get completedCourses =>
      _courses.where((c) => isCourseCompleted(c.id)).toList();

  /// The course to show on the "Continue Learning" card.
  Course? get continueCourse {
    final inProgress = inProgressCourses;
    if (inProgress.isNotEmpty) return inProgress.first;
    for (final course in _courses) {
      if (!isCourseCompleted(course.id) && hasLessons(course.id)) {
        return course;
      }
    }
    return null;
  }

  /// Courses worth suggesting: not finished, not already started, with lessons.
  List<Course> get recommendedCourses {
    final fresh = _courses
        .where(
          (c) =>
              !isCourseCompleted(c.id) &&
              !isEnrolled(c.id) &&
              hasLessons(c.id),
        )
        .toList();
    final others = _courses
        .where(
          (c) =>
              !isCourseCompleted(c.id) &&
              isEnrolled(c.id) &&
              hasLessons(c.id),
        )
        .toList();
    return [...fresh, ...others].take(3).toList();
  }

  Future<void> setEnrolled(String courseId, bool enrolled) async {
    final profile = _profile;
    if (profile == null) return;
    final ids = List<String>.from(profile.enrolledCourseIds);
    if (enrolled && !ids.contains(courseId)) ids.add(courseId);
    if (!enrolled) ids.remove(courseId);
    _profile = profile.copyWith(enrolledCourseIds: ids);
    await StorageService.saveUserProfile(_profile!);
    notifyListeners();
  }

  lr.Lesson? _findLesson(String courseId, String? lessonId) {
    if (lessonId == null) return null;
    for (final lesson in lessonsFor(courseId)) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
  }

  Future<void> completeLesson(String courseId, {String? lessonId}) async {
    final profile = _profile;
    if (profile == null) return;

    final lessonKey = lessonId != null ? '$courseId:$lessonId' : null;
    if (lessonKey != null && profile.completedLessonIds.contains(lessonKey)) {
      return; // Already completed, don't award XP again
    }

    final now = DateTime.now();
    final lessonDef = _findLesson(courseId, lessonId);
    final xpGain = lessonDef?.xpReward ?? _defaultLessonXp;
    final minutes = lessonDef?.estimatedMinutes ?? _defaultLessonMinutes;

    final completedLessonIds = List<String>.from(profile.completedLessonIds);
    if (lessonKey != null) completedLessonIds.add(lessonKey);

    final enrolledIds = List<String>.from(profile.enrolledCourseIds);
    if (!enrolledIds.contains(courseId)) enrolledIds.add(courseId);

    final completedForCourse = completedLessonIds
        .where((id) => id.startsWith('$courseId:'))
        .length;
    final totalLessons = totalLessonsFor(courseId);
    final courseFinished =
        totalLessons > 0 &&
        completedForCourse >= totalLessons &&
        !profile.completedCourseIds.contains(courseId);

    final completedCourseIds = List<String>.from(profile.completedCourseIds);
    if (courseFinished) completedCourseIds.add(courseId);

    final existing = StorageService.getCourseProgress(courseId);
    final progress =
        (existing ??
                CourseProgress(
                  courseId: courseId,
                  userId: profile.id,
                  completedModules: 0,
                  totalModules: 0,
                  completedLessons: 0,
                  totalLessons: totalLessons,
                  completedQuizzes: 0,
                  totalQuizzes: 0,
                  completedProjects: 0,
                  totalProjects: 0,
                  totalStudyMinutes: 0,
                  startedAt: now,
                  lastAccessedAt: now,
                  isEnrolled: true,
                ))
            .copyWith(
              completedLessons: completedForCourse,
              totalLessons: totalLessons,
              totalStudyMinutes: (existing?.totalStudyMinutes ?? 0) + minutes,
              lastAccessedAt: now,
              isEnrolled: true,
              isCompleted: courseFinished || (existing?.isCompleted ?? false),
              completedAt: courseFinished ? now : null,
            );

    final updatedProfile = _applyActivity(
      profile,
      xpGain: xpGain,
      now: now,
      lessonsDelta: 1,
      minutesDelta: minutes,
      coursesDelta: courseFinished ? 1 : 0,
      completedLessonIds: completedLessonIds,
      completedCourseIds: completedCourseIds,
      enrolledCourseIds: enrolledIds,
    );

    _profile = updatedProfile;
    await StorageService.saveCourseProgress(progress);
    await _recordActivity(now, minutes: minutes);
    await StorageService.saveUserProfile(updatedProfile);
    notifyListeners();
  }

  Future<void> completeChallenge() async {
    final profile = _profile;
    if (profile == null) return;

    final now = DateTime.now();
    final updatedProfile = _applyActivity(
      profile,
      xpGain: _challengeXp,
      now: now,
      minutesDelta: _challengeMinutes,
    );

    _profile = updatedProfile;
    await _recordActivity(now, minutes: _challengeMinutes);
    await StorageService.saveUserProfile(updatedProfile);
    notifyListeners();
  }

  /// Applies the shared effects of any learning activity: XP and level,
  /// streak, stats, achievement progress and achievement XP rewards.
  UserProfile _applyActivity(
    UserProfile base, {
    required int xpGain,
    required DateTime now,
    int lessonsDelta = 0,
    int minutesDelta = 0,
    int coursesDelta = 0,
    List<String>? completedLessonIds,
    List<String>? completedCourseIds,
    List<String>? enrolledCourseIds,
  }) {
    final streaks = _advanceStreak(base, now);
    final stats = base.stats.copyWith(
      totalCoursesCompleted: base.stats.totalCoursesCompleted + coursesDelta,
      totalLessonsCompleted: base.stats.totalLessonsCompleted + lessonsDelta,
      totalStudyMinutes: base.stats.totalStudyMinutes + minutesDelta,
      currentStreakDays: streaks.current,
      longestStreakDays: streaks.longest,
    );

    final achievements = _updateAchievementProgress(
      base.achievements,
      lessonsCompleted: stats.totalLessonsCompleted,
      coursesCompleted: stats.totalCoursesCompleted,
      streakDays: stats.currentStreakDays,
    );

    // Pay out the XP reward of anything that unlocked just now.
    var bonusXp = 0;
    for (var i = 0; i < achievements.length; i++) {
      final wasUnlocked = i < base.achievements.length
          ? base.achievements[i].isUnlocked
          : false;
      if (achievements[i].isUnlocked && !wasUnlocked) {
        bonusXp += achievements[i].xpReward;
      }
    }

    final totalXp = base.totalXp + xpGain + bonusXp;
    return base.copyWith(
      xp: base.xp + xpGain + bonusXp,
      totalXp: totalXp,
      level: UserLevel.getLevelForXp(totalXp),
      completedLessonIds: completedLessonIds,
      completedCourseIds: completedCourseIds,
      enrolledCourseIds: enrolledCourseIds,
      lastActiveAt: now,
      lastLessonCompletedAt: now,
      stats: stats,
      achievements: achievements,
    );
  }

  List<Achievement> _updateAchievementProgress(
    List<Achievement> achievements, {
    required int lessonsCompleted,
    required int coursesCompleted,
    required int streakDays,
  }) {
    return achievements.map((achievement) {
      var newProgress = achievement.progress;

      switch (achievement.type) {
        case AchievementType.lessonsCompleted:
          newProgress = lessonsCompleted;
        case AchievementType.coursesCompleted:
          newProgress = coursesCompleted;
        case AchievementType.streakDays:
          // Streak achievements keep their best progress; a lapsed streak
          // must not lock an achievement again.
          if (streakDays > newProgress) newProgress = streakDays;
        default:
          break;
      }

      final unlocked =
          achievement.isUnlocked || newProgress >= achievement.target;

      return achievement.copyWith(
        progress: newProgress.clamp(0, achievement.target),
        isUnlocked: unlocked,
        unlockedAt: unlocked && achievement.unlockedAt == null
            ? DateTime.now()
            : achievement.unlockedAt,
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Streaks and weekly activity (all day boundaries are UTC)
  // ---------------------------------------------------------------------------

  static DateTime _utcDay(DateTime d) {
    final u = d.toUtc();
    return DateTime.utc(u.year, u.month, u.day);
  }

  static String _dayKey(DateTime d) {
    final u = d.toUtc();
    final month = u.month.toString().padLeft(2, '0');
    final day = u.day.toString().padLeft(2, '0');
    return '${u.year.toString().padLeft(4, '0')}-$month-$day';
  }

  static DateTime _weekStart(DateTime now) {
    final today = _utcDay(now);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  /// The streak a learner effectively has at [now]. Returns 0 once more than
  /// one full UTC day has passed since the last activity.
  static int effectiveStreak(UserProfile? profile, {DateTime? now}) {
    if (profile == null) return 0;
    final last = profile.lastLessonCompletedAt;
    if (last == null) return 0;
    final gap = _utcDay(now ?? DateTime.now()).difference(_utcDay(last)).inDays;
    return gap <= 1 ? profile.stats.currentStreakDays : 0;
  }

  ({int current, int longest}) _advanceStreak(UserProfile p, DateTime now) {
    final last = p.lastLessonCompletedAt;
    var current = p.stats.currentStreakDays;
    if (last == null) {
      current = 1;
    } else {
      final gap = _utcDay(now).difference(_utcDay(last)).inDays;
      if (gap <= 0) {
        if (current < 1) current = 1; // same day: unchanged
      } else if (gap == 1) {
        current += 1; // consecutive day
      } else {
        current = 1; // streak was broken
      }
    }
    final longest = current > p.stats.longestStreakDays
        ? current
        : p.stats.longestStreakDays;
    return (current: current, longest: longest);
  }

  Future<void> _recordActivity(DateTime now, {int minutes = 0}) async {
    final day = _dayKey(now);
    final days = StorageService.getStringList(_activityKey);
    if (!days.contains(day)) {
      days.add(day);
      days.sort();
      final trimmed = days.length > 60 ? days.sublist(days.length - 60) : days;
      await StorageService.setStringList(_activityKey, trimmed);
    }
    if (minutes > 0) {
      final key = '$_minutesKeyPrefix$day';
      await StorageService.setInt(key, StorageService.getInt(key) + minutes);
    }
  }

  /// Monday..Sunday flags for the current (UTC) week.
  List<bool> get weekActivity {
    final days = StorageService.getStringList(_activityKey).toSet();
    final monday = _weekStart(DateTime.now());
    return List<bool>.generate(
      7,
      (i) => days.contains(_dayKey(monday.add(Duration(days: i)))),
    );
  }

  /// Minutes studied so far in the current (UTC) week.
  int get weeklyStudyMinutes {
    final monday = _weekStart(DateTime.now());
    var total = 0;
    for (var i = 0; i < 7; i++) {
      final day = _dayKey(monday.add(Duration(days: i)));
      total += StorageService.getInt('$_minutesKeyPrefix$day');
    }
    return total;
  }

  Future<void> refreshPosts() async {
    _posts = await CommunityRepository.getPosts();
    notifyListeners();
  }

  Future<void> createPost(String title, String content, PostType type) async {
    final post = await CommunityRepository.createPost(
      title: title,
      content: content,
      type: type,
    );
    _posts.insert(0, post);
    notifyListeners();
  }

  Future<void> toggleVote(String postId, UserVote vote) async {
    final updated = await CommunityRepository.toggleVote(postId, vote);
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = updated;
      notifyListeners();
    }
  }

  Future<PostReply> createReply(
    String postId,
    String content, {
    String? parentReplyId,
  }) async {
    final reply = await CommunityRepository.createReply(
      postId: postId,
      content: content,
      parentReplyId: parentReplyId,
    );
    // Refresh posts to get updated reply count
    _posts = await CommunityRepository.getPosts();
    notifyListeners();
    return reply;
  }

  Future<List<PostReply>> getReplies(String postId) async {
    return await CommunityRepository.getReplies(postId);
  }

  Future<void> toggleReplyVote(
    String postId,
    String replyId,
    UserVote vote,
  ) async {
    await CommunityRepository.toggleReplyVote(postId, replyId, vote);
    // Update in local state if needed
    notifyListeners();
  }

  Future<void> toggleBookmark(String lessonId) async {
    if (_profile == null) return;

    final bookmarkedLessonIds = List<String>.from(
      _profile!.bookmarkedLessonIds,
    );
    if (bookmarkedLessonIds.contains(lessonId)) {
      bookmarkedLessonIds.remove(lessonId);
    } else {
      bookmarkedLessonIds.add(lessonId);
    }

    final updatedProfile = _profile!.copyWith(
      bookmarkedLessonIds: bookmarkedLessonIds,
    );
    _profile = updatedProfile;
    await StorageService.saveUserProfile(updatedProfile);
    notifyListeners();
  }

  bool isBookmarked(String lessonId) {
    return _profile?.bookmarkedLessonIds.contains(lessonId) ?? false;
  }

  List<String> get bookmarkedLessonIds => _profile?.bookmarkedLessonIds ?? [];
}
