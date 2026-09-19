import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brainbox/data/models/community_models.dart';
import 'package:brainbox/data/repositories/community_repository.dart';
import 'package:brainbox/data/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTesting();
    await StorageService.init();
    await StorageService.clearAll();
  });

  test('UserVote enum serialization round-trip', () {
    // Test that UserVote enum serializes and deserializes correctly
    final vote = UserVote.upvote;
    final json = vote.toString();
    expect(json, 'UserVote.upvote');

    final parsed = UserVote.values.firstWhere(
      (e) => e.toString() == json,
      orElse: () => UserVote.none,
    );
    expect(parsed, UserVote.upvote);

    // Test null handling
    final nullJson = null;
    final parsedNull = nullJson != null
        ? UserVote.values.firstWhere(
            (e) => e.toString() == nullJson,
            orElse: () => UserVote.none,
          )
        : null;
    expect(parsedNull, isNull);
  });

  test('CommunityPost currentUserVote serialization', () {
    final post = CommunityPost(
      id: 'test',
      authorId: 'user1',
      authorName: 'Test User',
      title: 'Test Post',
      content: 'Test content',
      type: PostType.question,
      tags: const [],
      courseIds: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      currentUserVote: UserVote.upvote,
    );

    final json = post.toJson();
    expect(json['currentUserVote'], 'UserVote.upvote');

    final parsed = CommunityPost.fromJson(json);
    expect(parsed.currentUserVote, UserVote.upvote);
  });

  test('CommunityPost currentUserVote null serialization', () {
    final post = CommunityPost(
      id: 'test',
      authorId: 'user1',
      authorName: 'Test User',
      title: 'Test Post',
      content: 'Test content',
      type: PostType.question,
      tags: const [],
      courseIds: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      currentUserVote: null,
    );

    final json = post.toJson();
    expect(json['currentUserVote'], isNull);

    final parsed = CommunityPost.fromJson(json);
    expect(parsed.currentUserVote, isNull);
  });

  test('CommunityPost copyWith preserves currentUserVote', () {
    final post = CommunityPost(
      id: 'test',
      authorId: 'user1',
      authorName: 'Test User',
      title: 'Test Post',
      content: 'Test content',
      type: PostType.question,
      tags: const [],
      courseIds: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      currentUserVote: UserVote.upvote,
    );

    // Copy with explicit null should set to null
    final copiedNull = post.copyWith(currentUserVote: null);
    expect(copiedNull.currentUserVote, isNull);

    // Copy without currentUserVote should preserve original
    final copiedPreserve = post.copyWith(upvoteCount: 10);
    expect(copiedPreserve.currentUserVote, UserVote.upvote);
  });

  test('seeds and persists community posts', () async {
    final posts = await CommunityRepository.getPosts();
    expect(posts, isNotEmpty);

    final created = await CommunityRepository.createPost(
      title: 'A useful question',
      content: 'How do I practice loops effectively?',
    );
    final reloaded = await CommunityRepository.getPosts();

    expect(reloaded.any((post) => post.id == created.id), isTrue);
    expect(reloaded.firstWhere((post) => post.id == created.id).content, contains('practice loops'));
  });

  test('toggles a vote without contradictory counts', () async {
    final posts = await CommunityRepository.getPosts();
    final post = posts.first;
    final originalUpvotes = post.upvoteCount;

    final voted = await CommunityRepository.toggleVote(
      post.id,
      UserVote.upvote,
    );
    expect(voted.currentUserVote, UserVote.upvote);
    expect(voted.upvoteCount, originalUpvotes + 1);

    final undone = await CommunityRepository.toggleVote(
      post.id,
      UserVote.upvote,
    );
    expect(undone.currentUserVote, isNull);
    expect(undone.upvoteCount, originalUpvotes);
  });

  test('rejects empty posts', () async {
    expect(
      () => CommunityRepository.createPost(content: '  '),
      throwsFormatException,
    );
  });
}
