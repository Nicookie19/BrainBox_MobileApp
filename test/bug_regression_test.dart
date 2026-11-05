import 'dart:convert';
import 'package:brainbox/data/models/user_models.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/data/models/learning_models.dart';
import 'package:brainbox/data/models/community_models.dart';
import 'package:brainbox/data/repositories/community_repository.dart';
import 'package:brainbox/data/repositories/daily_challenge_repository.dart';
import 'package:brainbox/data/repositories/lesson_repository.dart';
import 'package:brainbox/data/repositories/lesson_progress_repository.dart';
import 'package:brainbox/data/services/storage_backend.dart';
import 'package:brainbox/data/services/storage_service.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppProvider provider;
  setUp(() async {
    StorageService.resetForTesting();
    await StorageService.init(backend: MemoryStorageBackend());
    provider = AppProvider();
    await provider.initialize();
  });
  tearDown(() => provider.dispose());

  test('backup contains persisted local state without changing it', () async {
    await provider.completeLesson('sql-basics', lessonId: 'lesson_1');
    final backup =
        jsonDecode(StorageService.exportJson()) as Map<String, dynamic>;
    expect(backup['schemaVersion'], 1);
    final data = backup['data'] as Map<String, dynamic>;
    final profile = UserProfile.fromJson(
      jsonDecode(data['user_profile'] as String),
    );
    expect(profile.completedLessonIds, contains('sql-basics:lesson_1'));
    expect(profile.xp, provider.xp);
    expect(data['available_courses'], isNotNull);
  });

  test('reports persist across provider restarts', () async {
    final id = provider.posts.first.id;
    await provider.reportPost(id);
    await provider.initialize();
    expect(
      provider.posts.firstWhere((post) => post.id == id).isReported,
      isTrue,
    );
  });

  test('quiz question and activity types round trip', () {
    for (final type in QuestionType.values) {
      final question = QuizQuestion(
        id: 'q',
        question: 'Question',
        type: type,
        options: ['A', 'B'],
        correctAnswerIndex: 0,
        explanation: 'Explanation',
      );
      expect(QuizQuestion.fromJson(question.toJson()).type, type);
    }
    for (final type in ActivityType.values) {
      final activity = UserActivity(
        id: 'a',
        userId: 'u',
        type: type,
        title: 'Activity',
        description: 'Description',
        createdAt: DateTime.now(),
      );
      expect(UserActivity.fromJson(activity.toJson()).type, type);
    }
  });

  test('restart preserves identity and achievement types', () async {
    final profile = provider.profile!.copyWith(displayName: 'Alex Rivera');
    await StorageService.saveUserProfile(profile);
    await provider.initialize();
    expect(provider.profile!.displayName, 'Alex Rivera');
    expect(
      provider.profile!.achievements.map((a) => a.type),
      profile.achievements.map((a) => a.type),
    );
    final post = await CommunityRepository.createPost(
      content: 'My first useful question',
    );
    expect(post.authorName, 'Alex Rivera');
  });

  test('stats and interests preserve distinct enum keys', () {
    final stats = UserStats.empty().copyWith(
      categoryProgress: {
        for (final c in LearningCategory.values) c: c.index + 1,
      },
      difficultyBreakdown: {
        for (final d in DifficultyLevel.values) d: d.index + 1,
      },
    );
    final restored = UserStats.fromJson(stats.toJson());
    expect(restored.categoryProgress, stats.categoryProgress);
    expect(restored.difficultyBreakdown, stats.difficultyBreakdown);
    const preferences = UserPreferences(
      interestedCategories: LearningCategory.values,
    );
    expect(
      UserPreferences.fromJson(preferences.toJson()).interestedCategories,
      LearningCategory.values,
    );
    for (final type in AchievementType.values) {
      final achievement = provider.profile!.achievements.first.copyWith(
        type: type,
      );
      expect(Achievement.fromJson(achievement.toJson()).type, type);
      expect(
        Achievement.fromJson(achievement.toJson()..['type'] = type.name).type,
        type,
      );
    }
  });

  test('community post types survive reload', () async {
    for (final type in PostType.values) {
      final post = await CommunityRepository.createPost(
        content: 'A useful community post',
        type: type,
      );
      expect(CommunityPost.fromJson(post.toJson()).type, type);
      expect(
        CommunityPost.fromJson(post.toJson()..['type'] = type.name).type,
        type,
      );
    }
  });

  test(
    'reset preserves catalog, preferences, bookmarks, downloads, and posts',
    () async {
      await provider.completeLesson('sql-basics', lessonId: 'lesson_1');
      await provider.completeChallenge();
      await DailyChallengeRepository.markCompletedForDate(DateTime.now(), 4);
      await provider.toggleBookmark('sql-basics:lesson_1');
      await StorageService.saveDownloadedContent('sql-basics:lesson_1', {
        'title': 'SQL',
      });
      final before = provider.profile!;
      final posts = provider.posts.map((p) => p.id).toList();
      final courseIds = provider.courses.map((c) => c.id).toList();
      await provider.resetLearningProgress();
      await provider.initialize();
      expect(provider.xp, 0);
      expect(provider.profile!.completedLessonIds, isEmpty);
      expect(provider.profile!.lastLessonCompletedAt, isNull);
      expect(provider.weeklyStudyMinutes, 0);
      expect(provider.profile!.displayName, before.displayName);
      expect(
        provider.profile!.preferences.toJson(),
        before.preferences.toJson(),
      );
      expect(provider.bookmarkedLessonIds, before.bookmarkedLessonIds);
      expect(StorageService.getDownloadedContent(), isNotEmpty);
      expect(provider.courses.map((c) => c.id), courseIds);
      expect(provider.posts.map((p) => p.id), posts);
      expect(
        DailyChallengeRepository.isCompletedForDate(DateTime.now()),
        isFalse,
      );
      await provider.completeChallenge();
      expect(provider.xp, 50);
    },
  );

  test('invalid lesson completions cannot earn rewards', () async {
    for (final call in [
      () => provider.completeLesson('unknown', lessonId: 'lesson_1'),
      () => provider.completeLesson('sql-basics', lessonId: 'unknown'),
      () => provider.completeLesson('sql-basics'),
    ]) {
      await expectLater(call(), throwsArgumentError);
    }
    expect(provider.xp, 0);
    expect(provider.profile!.stats.totalLessonsCompleted, 0);
  });

  test(
    'challenge reward is idempotent during rapid taps and after restart',
    () async {
      await Future.wait([
        provider.completeChallenge(),
        provider.completeChallenge(),
      ]);
      expect(provider.xp, 50);
      await provider.initialize();
      await provider.completeChallenge();
      expect(provider.xp, 50);
      expect(provider.profile!.stats.totalStudyMinutes, 5);
    },
  );

  test(
    'invalid reply targets do not change counts or create orphan replies',
    () async {
      final post = provider.posts.first;
      await expectLater(
        CommunityRepository.createReply(postId: 'missing', content: 'Hello'),
        throwsStateError,
      );
      await expectLater(
        CommunityRepository.createReply(
          postId: post.id,
          parentReplyId: 'missing',
          content: 'Hello',
        ),
        throwsStateError,
      );
      expect(await CommunityRepository.getReplies(post.id), isEmpty);
      expect(
        (await CommunityRepository.getPosts()).first.replyCount,
        post.replyCount,
      );
    },
  );

  test('negative and malformed saved lesson indices are rejected', () async {
    for (final data in [
      {'currentStepIndex': -1, 'answeredSteps': <String, int>{}},
      {
        'currentStepIndex': 0,
        'answeredSteps': {'-1': 0},
      },
      {
        'currentStepIndex': 0,
        'answeredSteps': {'0': -1},
      },
      {
        'currentStepIndex': 0,
        'answeredSteps': {'bad': 0},
      },
    ]) {
      await StorageService.setString(
        'lesson_progress_sql-basics:lesson_1',
        jsonEncode(data),
      );
      expect(
        await LessonProgressRepository.loadProgress('sql-basics', 'lesson_1'),
        isNull,
      );
    }
    expect(
      await LessonRepository.getLessonStep('sql-basics', 'lesson_1', -1),
      isNull,
    );
  });
}
