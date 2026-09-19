import 'package:flutter/foundation.dart';
import 'package:brainbox/data/repositories/community_repository.dart';
import 'package:brainbox/data/repositories/course_repository.dart';
import 'package:brainbox/data/services/storage_service.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/data/models/user_models.dart';
import 'package:brainbox/data/models/community_models.dart';

class AppProvider extends ChangeNotifier {
  UserProfile? _profile;
  List<Course> _courses = [];
  List<CommunityPost> _posts = [];
  bool _isLoading = true;

  UserProfile? get profile => _profile;
  List<Course> get courses => _courses;
  List<CommunityPost> get posts => _posts;
  bool get isLoading => _isLoading;

  int get xp => _profile?.xp ?? 0;
  UserLevel get level => _profile?.level ?? UserLevel.allLevels[0];
  double get levelProgress => _profile?.levelProgress ?? 0;
  int get currentStreak => _profile?.stats.currentStreakDays ?? 0;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _profile = await _loadOrCreateProfile();
    _courses = await CourseRepository.getAllCourses();
    _posts = await CommunityRepository.getPosts();

    _isLoading = false;
    notifyListeners();
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

  Future<void> completeLesson(String courseId, {String? lessonId}) async {
    if (_profile == null) return;

    final lessonIdKey = lessonId != null ? '$courseId:$lessonId' : null;
    
    // Check if lesson was already completed
    if (lessonIdKey != null && _profile!.completedLessonIds.contains(lessonIdKey)) {
      return; // Already completed, don't award XP again
    }

    final courseProgress = StorageService.getCourseProgress(courseId);
    final now = DateTime.now();
    final nowUtc = now.toUtc();
    final todayUtc = DateTime(nowUtc.year, nowUtc.month, nowUtc.day);

    final updatedProgress = (courseProgress ?? CourseProgress(
      courseId: courseId,
      userId: 'current_user',
      completedModules: 0,
      totalModules: 1,
      completedLessons: 0,
      totalLessons: 10,
      completedQuizzes: 0,
      totalQuizzes: 3,
      completedProjects: 0,
      totalProjects: 2,
      totalStudyMinutes: 0,
      startedAt: now,
      lastAccessedAt: now,
      isEnrolled: true,
    )).copyWith(
      completedLessons: (courseProgress?.completedLessons ?? 0) + 1,
      totalStudyMinutes: (courseProgress?.totalStudyMinutes ?? 0) + 10,
      lastAccessedAt: now,
    );

    await StorageService.saveCourseProgress(updatedProgress);

    // Update completed lesson IDs
    final completedLessonIds = List<String>.from(_profile!.completedLessonIds);
    if (lessonIdKey != null && !completedLessonIds.contains(lessonIdKey)) {
      completedLessonIds.add(lessonIdKey);
    }

    // Update enrolled course IDs
    final enrolledIds = List<String>.from(_profile!.enrolledCourseIds);
    if (!enrolledIds.contains(courseId)) {
      enrolledIds.add(courseId);
    }

    // Calculate streak
    int newStreak = _profile!.stats.currentStreakDays;
    int newLongestStreak = _profile!.stats.longestStreakDays;
    DateTime? lastLessonDate = _profile!.lastLessonCompletedAt;

    if (lastLessonDate != null) {
      final lastLessonUtc = lastLessonDate.toUtc();
      final lastLessonDay = DateTime(lastLessonUtc.year, lastLessonUtc.month, lastLessonUtc.day);
      final yesterdayUtc = todayUtc.subtract(const Duration(days: 1));

      if (lastLessonDay == yesterdayUtc) {
        // Consecutive day - increment streak
        newStreak += 1;
      } else if (lastLessonDay == todayUtc) {
        // Same day - streak unchanged
      } else {
        // Streak broken
        newStreak = 1;
      }
    } else {
      // First lesson ever
      newStreak = 1;
    }

if (newStreak > newLongestStreak) {
      newLongestStreak = newStreak;
    }

    final updatedProfile = _profile!.copyWith(
      xp: _profile!.xp + 25,
      totalXp: _profile!.totalXp + 25,
      enrolledCourseIds: enrolledIds,
      completedLessonIds: completedLessonIds,
      lastActiveAt: DateTime.now(),
      lastLessonCompletedAt: DateTime.now(),
      stats: _profile!.stats.copyWith(
        totalLessonsCompleted: _profile!.stats.totalLessonsCompleted + 1,
        currentStreakDays: newStreak,
        longestStreakDays: newLongestStreak > _profile!.stats.longestStreakDays
            ? newStreak : _profile!.stats.longestStreakDays,
        totalStudyMinutes: _profile!.stats.totalStudyMinutes + 10,
      ),
      achievements: _updateAchievementProgress(
        _profile!.achievements,
        lessonsCompleted: _profile!.stats.totalLessonsCompleted + 1,
        streakDays: newStreak,
      ),
    );

    _profile = updatedProfile;
    await StorageService.saveUserProfile(updatedProfile);
    notifyListeners();
  }

  List<Achievement> _updateAchievementProgress(
    List<Achievement> achievements, {
    required int lessonsCompleted,
    required int streakDays,
  }) {
    return achievements.map((achievement) {
      int newProgress = achievement.progress;
      bool isUnlocked = achievement.isUnlocked;

      switch (achievement.type) {
        case AchievementType.lessonsCompleted:
          newProgress = lessonsCompleted;
          break;
        case AchievementType.streakDays:
          newProgress = streakDays;
          break;
        case AchievementType.coursesCompleted:
          // Would need course completion tracking
          break;
        default:
          break;
      }

      if (newProgress >= achievement.target && !achievement.isUnlocked) {
        isUnlocked = true;
        // Could trigger achievement unlock notification here
      }

      return achievement.copyWith(
        progress: newProgress.clamp(0, achievement.target),
        isUnlocked: isUnlocked,
        unlockedAt: isUnlocked && achievement.unlockedAt == null ? DateTime.now() : achievement.unlockedAt,
      );
    }).toList();
  }

  Future<void> completeChallenge() async {
    await addXp(50);
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
}