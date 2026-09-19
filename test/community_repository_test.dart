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
