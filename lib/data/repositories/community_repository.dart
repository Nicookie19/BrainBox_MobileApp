import 'dart:convert';

import '../models/community_models.dart';
import '../services/storage_service.dart';

class CommunityRepository {
  static const _postsKey = 'community_posts';
  static const _repliesKey = 'community_replies';

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

  static Future<List<PostReply>> getReplies(String postId) async {
    final encoded = StorageService.getString('$_repliesKey$postId');
    if (encoded == null || encoded.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded
          .map((item) => PostReply.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveReplies(String postId, List<PostReply> replies) async {
    await StorageService.setString(
      '$_repliesKey$postId',
      jsonEncode(replies.map((reply) => reply.toJson()).toList()),
    );
  }

  static Future<PostReply> createReply({
    required String postId,
    required String content,
    String? parentReplyId,
  }) async {
    final trimmedContent = content.trim();
    if (trimmedContent.length < 3) {
      throw const FormatException('Reply must be at least 3 characters.');
    }

    final now = DateTime.now();
    final reply = PostReply(
      id: 'reply_${now.microsecondsSinceEpoch}',
      postId: postId,
      authorId: 'current_user',
      authorName: 'Alex Rivera',
      content: trimmedContent,
      parentReplyId: parentReplyId,
      createdAt: now,
      updatedAt: now,
    );

    final replies = await getReplies(postId);
    if (parentReplyId != null) {
      // Find parent and add as nested reply
      final updatedReplies = _addNestedReply(replies, parentReplyId, reply);
      await saveReplies(postId, updatedReplies);
    } else {
      replies.add(reply);
      await saveReplies(postId, replies);
    }

    // Update post reply count
    final posts = await getPosts();
    final postIndex = posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final updatedPost = posts[postIndex].copyWith(
        replyCount: posts[postIndex].replyCount + 1,
        updatedAt: now,
      );
      posts[postIndex] = updatedPost;
      await savePosts(posts);
    }

    return reply;
  }

  static Future<PostReply> toggleReplyVote(
    String postId,
    String replyId,
    UserVote vote,
  ) async {
    final replies = await getReplies(postId);
    final updatedReplies = _toggleReplyVoteRecursive(replies, replyId, vote);
    await saveReplies(postId, updatedReplies);
    
    // Find and return the updated reply
    final updated = _findReplyById(updatedReplies, replyId);
    if (updated == null) throw StateError('Reply not found: $replyId');
    return updated;
  }

  static List<PostReply> _addNestedReply(List<PostReply> replies, String parentId, PostReply newReply) {
    return replies.map((reply) {
      if (reply.id == parentId) {
        return reply.copyWith(replies: [...reply.replies, newReply]);
      }
      if (reply.replies.isNotEmpty) {
        return reply.copyWith(replies: _addNestedReply(reply.replies, parentId, newReply));
      }
      return reply;
    }).toList();
  }

  static List<PostReply> _toggleReplyVoteRecursive(List<PostReply> replies, String replyId, UserVote vote) {
    return replies.map((reply) {
      if (reply.id == replyId) {
        final nextVote = reply.currentUserVote == vote ? null : vote;
        var upvotes = reply.upvoteCount;
        var downvotes = reply.downvoteCount;
        if (reply.currentUserVote == UserVote.upvote) upvotes--;
        if (reply.currentUserVote == UserVote.downvote) downvotes--;
        if (nextVote == UserVote.upvote) upvotes++;
        if (nextVote == UserVote.downvote) downvotes++;
        
        return reply.copyWith(
          upvoteCount: upvotes,
          downvoteCount: downvotes,
          currentUserVote: nextVote,
          updatedAt: DateTime.now(),
        );
      }
      if (reply.replies.isNotEmpty) {
        return reply.copyWith(replies: _toggleReplyVoteRecursive(reply.replies, replyId, vote));
      }
      return reply;
    }).toList();
  }

  static PostReply? _findReplyById(List<PostReply> replies, String replyId) {
    for (final reply in replies) {
      if (reply.id == replyId) return reply;
      if (reply.replies.isNotEmpty) {
        final found = _findReplyById(reply.replies, replyId);
        if (found != null) return found;
      }
    }
    return null;
  }

  static Future<PostReply> acceptAnswer(String postId, String replyId) async {
    final replies = await getReplies(postId);
    final updatedReplies = _acceptAnswerRecursive(replies, replyId);
    await saveReplies(postId, updatedReplies);
    
    final updated = _findReplyById(updatedReplies, replyId);
    if (updated == null) throw StateError('Reply not found: $replyId');
    return updated;
  }

  static List<PostReply> _acceptAnswerRecursive(List<PostReply> replies, String replyId) {
    return replies.map((reply) {
      if (reply.id == replyId) {
        return reply.copyWith(isAcceptedAnswer: true);
      }
      if (reply.replies.isNotEmpty) {
        return reply.copyWith(replies: _acceptAnswerRecursive(reply.replies, replyId));
      }
      return reply;
    }).toList();
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
