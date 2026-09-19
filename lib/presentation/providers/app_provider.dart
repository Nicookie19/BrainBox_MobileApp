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
      achievements: _defaultAchievements(),
      stats: UserStats.empty(),
      preferences: UserPreferences(),
      joinedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
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

  Future<void> completeLesson(String courseId) async {
    if (_profile == null) return;

    final courseProgress = StorageService.getCourseProgress(courseId);
    final now = DateTime.now();

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

    final enrolledIds = List<String>.from(_profile!.enrolledCourseIds);
    if (!enrolledIds.contains(courseId)) {
      enrolledIds.add(courseId);
    }

    final updatedProfile = _profile!.copyWith(
      xp: _profile!.xp + 25,
      totalXp: _profile!.totalXp + 25,
      enrolledCourseIds: enrolledIds,
      lastActiveAt: now,
    );

    _profile = updatedProfile;
    await StorageService.saveUserProfile(updatedProfile);
    notifyListeners();
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