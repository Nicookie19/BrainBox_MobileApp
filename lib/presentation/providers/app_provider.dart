import 'package:flutter/foundation.dart';
import 'package:brainbox/data/repositories/community_repository.dart';
import 'package:brainbox/data/repositories/course_repository.dart';
import 'package:brainbox/data/services/storage_service.dart';
import 'package:brainbox/data/services/completion_service.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/data/models/user_models.dart';
import 'package:brainbox/data/models/community_models.dart';
import 'package:brainbox/core/utils/clock.dart';

class AppProvider extends ChangeNotifier {
  UserProfile? _profile;
  List<Course> _courses = [];
  List<CommunityPost> _posts = [];
  bool _isLoading = true;

  // For showing level up / achievement unlock notifications
  CompletionResult? _lastCompletionResult;

  UserProfile? get profile => _profile;
  List<Course> get courses => _courses;
  List<CommunityPost> get posts => _posts;
  Map<String, CourseProgress> get courseProgress =>
      StorageService.getAllCourseProgress();
  bool get isLoading => _isLoading;
  CompletionResult? get lastCompletionResult => _lastCompletionResult;

  int get xp => _profile?.xp ?? 0;
  UserLevel get level => _profile?.level ?? UserLevel.allLevels[0];
  double get levelProgress => _profile?.levelProgress ?? 0;
  int get currentStreak {
    final profile = _profile;
    final lastActiveAt = profile?.lastLessonCompletedAt;
    if (profile == null || lastActiveAt == null) return 0;
    final today = Clock.real.now().startOfLocalDay;
    final lastActiveDay = lastActiveAt.startOfLocalDay;
    return lastActiveDay == today ||
            lastActiveDay == today.subtract(const Duration(days: 1))
        ? profile.stats.currentStreakDays
        : 0;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _profile = await _loadOrCreateProfile();
    _courses = await CourseRepository.getAllCourses();
    _posts = await CommunityRepository.getPosts();

    _isLoading = false;
    notifyListeners();
  }

  void clearCompletionResult() {
    _lastCompletionResult = null;
    notifyListeners();
  }

  Future<UserProfile> _loadOrCreateProfile() async {
    final existingResult = StorageService.getUserProfile();
    final existing = existingResult.isSuccess ? existingResult.value : null;
    if (existing != null) {
      return existing;
    }

    final newProfile = UserProfile(
      id: 'local_user',
      email: 'local@brainbox.app',
      displayName: 'Alex Rivera',
      bio: 'Aspiring Frontend Developer',
      level: UserLevel.getLevelForXp(0),
      xp: 0,
      totalXp: 0,
      completedCourseIds: [],
      enrolledCourseIds: ['frontend-foundations'],
      bookmarkedLessonIds: [],
      downloadedLessonIds: [],
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
    Achievement(
      id: 'streak_30',
      title: 'Dedicated',
      description: '30 day streak',
      iconAsset: 'local_fire_department',
      type: AchievementType.streakDays,
      xpReward: 200,
      isUnlocked: false,
      progress: 0,
      target: 30,
    ),
    Achievement(
      id: 'lessons_50',
      title: 'Master Learner',
      description: 'Complete 50 lessons',
      iconAsset: 'menu_book',
      type: AchievementType.lessonsCompleted,
      xpReward: 300,
      isUnlocked: false,
      progress: 0,
      target: 50,
    ),
    Achievement(
      id: 'xp_1000',
      title: 'Rising Star',
      description: 'Earn 1000 total XP',
      iconAsset: 'star',
      type: AchievementType
          .lessonsCompleted, // Using lessonsCompleted as proxy for XP
      xpReward: 100,
      isUnlocked: false,
      progress: 0,
      target: 1000,
    ),
  ];

  Future<CompletionResult> completeLesson(
    String courseId, {
    String? lessonId,
  }) async {
    if (_profile == null) return CompletionResult.failure('No profile loaded');

    if (lessonId == null) {
      return CompletionResult.failure('Lesson ID required');
    }

    final result = await CompletionService.completeLesson(
      profile: _profile!,
      courseId: courseId,
      lessonId: lessonId,
      clock: Clock.real,
    );

    if (result.success) {
      // Reload profile to get updated data
      final profileResult = StorageService.getUserProfile();
      if (profileResult.isSuccess && profileResult.value != null) {
        _profile = profileResult.value;
      }
      _lastCompletionResult = result;
      notifyListeners();
    }

    return result;
  }

  Future<CompletionResult> completeDailyChallenge({required int score}) async {
    if (_profile == null) return CompletionResult.failure('No profile loaded');

    final today = DateTime.now();

    final result = await CompletionService.completeDailyChallenge(
      profile: _profile!,
      date: today,
      score: score,
      clock: Clock.real,
    );

    if (result.success) {
      // Reload profile to get updated data
      final profileResult = StorageService.getUserProfile();
      if (profileResult.isSuccess && profileResult.value != null) {
        _profile = profileResult.value;
      }
      _lastCompletionResult = result;
      notifyListeners();
    }

    return result;
  }

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

  Future<void> saveDownload(
    String lessonId,
    Map<String, dynamic> content,
  ) async {
    if (_profile == null) return;

    final result = await StorageService.saveDownloadedContent(
      lessonId,
      content,
    );
    if (!result.isSuccess) return;

    final downloadedLessonIds = List<String>.from(
      _profile!.downloadedLessonIds,
    );
    if (!downloadedLessonIds.contains(lessonId)) {
      downloadedLessonIds.add(lessonId);
    }
    _profile = _profile!.copyWith(downloadedLessonIds: downloadedLessonIds);
    await StorageService.saveUserProfile(_profile!);
    notifyListeners();
  }

  Future<void> removeDownload(String lessonId) async {
    if (_profile == null) return;

    final result = await StorageService.removeDownload(lessonId);
    if (!result.isSuccess) return;

    final downloadedLessonIds = List<String>.from(_profile!.downloadedLessonIds)
      ..remove(lessonId);
    _profile = _profile!.copyWith(downloadedLessonIds: downloadedLessonIds);
    await StorageService.saveUserProfile(_profile!);
    notifyListeners();
  }
}
