import 'package:test/test.dart';
import 'package:brainbox/data/models/community_models.dart';

void main() {
  group('PostReply copyWith', () {
    late PostReply originalReply;
    late List<PostReply> nestedReplies;

    setUp(() {
      nestedReplies = [
        PostReply(
          id: 'nested_1',
          postId: 'post_1',
          authorId: 'user_2',
          authorName: 'Nested Author',
          content: 'Nested reply content',
          parentReplyId: 'reply_1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      originalReply = PostReply(
        id: 'reply_1',
        postId: 'post_1',
        authorId: 'user_1',
        authorName: 'Original Author',
        content: 'Original reply content',
        parentReplyId: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        replies: [
          PostReply(
            id: 'nested_1',
            postId: 'post_1',
            authorId: 'user_2',
            authorName: 'Nested Author',
            content: 'Nested reply content',
            parentReplyId: 'reply_1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );
    });

    test('copyWith preserves all fields when no arguments provided', () {
      final copied = originalReply.copyWith();

      expect(copied.id, originalReply.id);
      expect(copied.postId, originalReply.postId);
      expect(copied.authorId, originalReply.authorId);
      expect(copied.authorName, originalReply.authorName);
      expect(copied.content, originalReply.content);
      expect(copied.parentReplyId, originalReply.parentReplyId);
      expect(copied.upvoteCount, originalReply.upvoteCount);
      expect(copied.downvoteCount, originalReply.downvoteCount);
      expect(copied.isAcceptedAnswer, originalReply.isAcceptedAnswer);
      expect(copied.isReported, originalReply.isReported);
      expect(copied.createdAt, originalReply.createdAt);
      expect(copied.updatedAt, originalReply.updatedAt);
      expect(copied.currentUserVote, originalReply.currentUserVote);
      expect(copied.replies, originalReply.replies);
    });

    test('copyWith updates content field', () {
      const newContent = 'Updated reply content';
      final copied = originalReply.copyWith(content: 'Updated reply content');

      expect(copied.content, 'Updated reply content');
      // Other fields unchanged
      expect(copied.id, originalReply.id);
      expect(copied.authorName, originalReply.authorName);
      expect(copied.replies, originalReply.replies);
    });

    test('copyWith updates replies list', () {
      final newReplies = [
        PostReply(
          id: 'new_nested',
          postId: 'post_1',
          authorId: 'user_3',
          authorName: 'New Nested Author',
          content: 'New nested reply',
          parentReplyId: 'reply_1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final copied = originalReply.copyWith(
        replies: [
          PostReply(
            id: 'new_nested',
            postId: 'post_1',
            authorId: 'user_3',
            authorName: 'New Nested Author',
            content: 'New nested reply',
            parentReplyId: 'reply_1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );

      expect(copied.replies.length, 1);
      expect(copied.replies.first.id, 'new_nested');
      expect(copied.replies.first.content, 'New nested reply');
      // Original unchanged
      expect(originalReply.replies.length, 1);
      expect(originalReply.replies.first.id, 'nested_1');
    });

    test('copyWith with null replies clears replies', () {
      final copied = originalReply.copyWith(replies: []);

      expect(copied.replies, isEmpty);
      expect(originalReply.replies, isNotEmpty);
    });

    test('copyWith preserves nested replies when not modified', () {
      final copied = originalReply.copyWith(content: 'New content');

      expect(copied.replies.length, 1);
      expect(copied.replies.first.id, 'nested_1');
      expect(copied.replies.first.content, 'Nested reply content');
    });

    test('copyWith updates multiple fields including replies', () {
      final copied = originalReply.copyWith(
        content: 'Completely new content',
        upvoteCount: 10,
        replies: [
          PostReply(
            id: 'new_1',
            postId: 'post_1',
            authorId: 'user_4',
            authorName: 'Author 4',
            content: 'Reply 1',
            parentReplyId: 'reply_1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          PostReply(
            id: 'new_2',
            postId: 'post_1',
            authorId: 'user_5',
            authorName: 'Author 5',
            content: 'Reply 2',
            parentReplyId: 'reply_1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );

      expect(copied.content, 'Completely new content');
      expect(copied.upvoteCount, 10);
      expect(copied.replies.length, 2);
      expect(copied.replies[0].id, 'new_1');
      expect(copied.replies[1].id, 'new_2');
      // Original unchanged
      expect(originalReply.content, 'Original reply content');
      expect(originalReply.upvoteCount, 0);
      expect(originalReply.replies.length, 1);
    });

    test('copyWith preserves nested replies structure', () {
      final copied = originalReply.copyWith();

      // Deep equality check for nested replies
      expect(copied.replies.length, originalReply.replies.length);
      for (int i = 0; i < originalReply.replies.length; i++) {
        expect(copied.replies[i].id, originalReply.replies[i].id);
        expect(copied.replies[i].content, originalReply.replies[i].content);
        expect(
          copied.replies[i].authorName,
          originalReply.replies[i].authorName,
        );
        expect(
          copied.replies[i].parentReplyId,
          originalReply.replies[i].parentReplyId,
        );
      }
    });
  });
}
