import 'dart:convert';

import '../models/community_models.dart';
import '../services/storage_service.dart';

class CommunityRepository {
  static const _postsKey = 'community_posts';

  static Future<List<CommunityPost>> getPosts() async {
    final encoded = StorageService.getString(_postsKey);
    if (encoded == null || encoded.isEmpty) {
      final seeded = _seedPosts();
      await savePosts(seeded);
      return seeded;
    }

    try {
      final decoded = jsonDecode(encoded) as List<dynamic>;
      final posts = decoded
          .map((item) => CommunityPost.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
      if (posts.isEmpty) {
        final seeded = _seedPosts();
        await savePosts(seeded);
        return seeded;
      }
      return posts;
    } catch (_) {
      final seeded = _seedPosts();
      await savePosts(seeded);
      return seeded;
    }
  }

  static Future<void> savePosts(List<CommunityPost> posts) async {
    await StorageService.setString(
      _postsKey,
      jsonEncode(posts.map((post) => post.toJson()).toList()),
    );
  }

  static Future<CommunityPost> createPost({
    required String content,
    String title = 'New question',
    PostType type = PostType.question,
  }) async {
    final trimmedContent = content.trim();
    final trimmedTitle = title.trim();
    if (trimmedContent.length < 5) {
      throw const FormatException('Post content must be at least 5 characters.');
    }
    if (trimmedTitle.isEmpty) {
      throw const FormatException('Post title cannot be empty.');
    }

    final now = DateTime.now();
    final post = CommunityPost(
      id: 'local_${now.microsecondsSinceEpoch}',
      authorId: 'current_user',
      authorName: 'Alex Rivera',
      title: trimmedTitle,
      content: trimmedContent,
      type: type,
      tags: const [],
      courseIds: const [],
      createdAt: now,
      updatedAt: now,
    );
    final posts = await getPosts();
    await savePosts([post, ...posts]);
    return post;
  }

  static Future<CommunityPost> toggleVote(
    String postId,
    UserVote vote,
  ) async {
    final posts = await getPosts();
    final index = posts.indexWhere((post) => post.id == postId);
    if (index == -1) throw StateError('Post not found: $postId');

    final current = posts[index];
    final nextVote = current.currentUserVote == vote ? null : vote;
    var upvotes = current.upvoteCount;
    var downvotes = current.downvoteCount;
    if (current.currentUserVote == UserVote.upvote) upvotes--;
    if (current.currentUserVote == UserVote.downvote) downvotes--;
    if (nextVote == UserVote.upvote) upvotes++;
    if (nextVote == UserVote.downvote) downvotes++;

    final updated = current.copyWith(
      upvoteCount: upvotes,
      downvoteCount: downvotes,
      currentUserVote: nextVote,
      updatedAt: DateTime.now(),
    );
    posts[index] = updated;
    await savePosts(posts);
    return updated;
  }

  static Future<CommunityPost> reportPost(String postId) async {
    final posts = await getPosts();
    final index = posts.indexWhere((post) => post.id == postId);
    if (index == -1) throw StateError('Post not found: $postId');
    final updated = posts[index].copyWith(
      isReported: true,
      updatedAt: DateTime.now(),
    );
    posts[index] = updated;
    await savePosts(posts);
    return updated;
  }

  static List<CommunityPost> _seedPosts() {
    final now = DateTime.now();
    return [
      CommunityPost(
        id: 'seed_css_positioning',
        authorId: 'user1',
        authorName: 'Mika Santos',
        title: 'What finally made CSS positioning click for you?',
        content: 'I understand flexbox, but I still get confused about relative, absolute, and fixed.',
        type: PostType.question,
        tags: const ['css', 'frontend'],
        courseIds: const ['frontend-foundations'],
        upvoteCount: 24,
        replyCount: 12,
        viewCount: 158,
        createdAt: now.subtract(const Duration(minutes: 18)),
        updatedAt: now.subtract(const Duration(minutes: 18)),
      ),
      CommunityPost(
        id: 'seed_python_automation',
        authorId: 'user2',
        authorName: 'Jordan Lee',
        title: 'My first automation project!',
        content: 'I made a script that organizes my downloads folder by file type. Tiny win, but I am proud of it!',
        type: PostType.project,
        tags: const ['python', 'automation'],
        courseIds: const ['python-essentials'],
        upvoteCount: 36,
        replyCount: 8,
        viewCount: 203,
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }
}
