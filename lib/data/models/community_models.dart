import 'package:flutter/material.dart';

class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String title;
  final String content;
  final PostType type;
  final List<String> tags;
  final List<String> courseIds;
  final int upvoteCount;
  final int downvoteCount;
  final int replyCount;
  final int viewCount;
  final bool isPinned;
  final bool isLocked;
  final bool isReported;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserVote? currentUserVote;

  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.title,
    required this.content,
    required this.type,
    required this.tags,
    required this.courseIds,
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.replyCount = 0,
    this.viewCount = 0,
    this.isPinned = false,
    this.isLocked = false,
    this.isReported = false,
    required this.createdAt,
    required this.updatedAt,
    this.currentUserVote,
  });

  int get score => upvoteCount - downvoteCount;
  bool get hasUserUpvoted => currentUserVote == UserVote.upvote;
  bool get hasUserDownvoted => currentUserVote == UserVote.downvote;

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'title': title,
        'content': content,
        'type': type.toString(),
        'tags': tags,
        'courseIds': courseIds,
        'upvoteCount': upvoteCount,
        'downvoteCount': downvoteCount,
        'replyCount': replyCount,
        'viewCount': viewCount,
        'isPinned': isPinned,
        'isLocked': isLocked,
        'isReported': isReported,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'currentUserVote': currentUserVote?.toString(),
      };

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
        id: json['id'],
        authorId: json['authorId'],
        authorName: json['authorName'],
        authorPhotoUrl: json['authorPhotoUrl'],
        title: json['title'],
        content: json['content'],
        type: PostType.values.firstWhere(
          (e) => e.toString() == 'PostType.${json['type']}',
          orElse: () => PostType.discussion,
        ),
        tags: List<String>.from(json['tags'] ?? []),
        courseIds: List<String>.from(json['courseIds'] ?? []),
        upvoteCount: json['upvoteCount'] ?? 0,
        downvoteCount: json['downvoteCount'] ?? 0,
        replyCount: json['replyCount'] ?? 0,
        viewCount: json['viewCount'] ?? 0,
        isPinned: json['isPinned'] ?? false,
        isLocked: json['isLocked'] ?? false,
        isReported: json['isReported'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        currentUserVote: json['currentUserVote'] != null
            ? UserVote.values.firstWhere(
                (e) => e.toString() == 'UserVote.${json['currentUserVote']}',
                orElse: () => UserVote.none,
              )
            : null,
      );

  CommunityPost copyWith({
    int? upvoteCount,
    int? downvoteCount,
    bool? isReported,
    DateTime? updatedAt,
    UserVote? currentUserVote,
  }) => CommunityPost(
        id: id,
        authorId: authorId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        title: title,
        content: content,
        type: type,
        tags: tags,
        courseIds: courseIds,
        upvoteCount: upvoteCount ?? this.upvoteCount,
        downvoteCount: downvoteCount ?? this.downvoteCount,
        replyCount: replyCount,
        viewCount: viewCount,
        isPinned: isPinned,
        isLocked: isLocked,
        isReported: isReported ?? this.isReported,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        currentUserVote: currentUserVote,
      );
}

enum PostType {
  question('Question', Icons.help_outline_rounded, Color(0xFF339AF0)),
  discussion(
    'Discussion',
    Icons.chat_bubble_outline_rounded,
    Color(0xFF8B5CF6),
  ),
  project('Project Showcase', Icons.folder_outlined, Color(0xFF10B981)),
  resource('Resource Share', Icons.link_outlined, Color(0xFFF59E0B)),
  announcement('Announcement', Icons.campaign_outlined, Color(0xFFEF4444)),
  help('Help Request', Icons.support_agent_rounded, Color(0xFF06B6D4));

  const PostType(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum UserVote { upvote, downvote, none }

class PostReply {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final String? parentReplyId;
  final int upvoteCount;
  final int downvoteCount;
  final bool isAcceptedAnswer;
  final bool isReported;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserVote? currentUserVote;
  final List<PostReply> replies;

  const PostReply({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    this.parentReplyId,
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.isAcceptedAnswer = false,
    this.isReported = false,
    required this.createdAt,
    required this.updatedAt,
    this.currentUserVote,
    this.replies = const [],
  });

  int get score => upvoteCount - downvoteCount;
  bool get hasUserUpvoted => currentUserVote == UserVote.upvote;
  bool get hasUserDownvoted => currentUserVote == UserVote.downvote;
  bool get isNested => parentReplyId != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'authorId': authorId,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'content': content,
        'parentReplyId': parentReplyId,
        'upvoteCount': upvoteCount,
        'downvoteCount': downvoteCount,
        'isAcceptedAnswer': isAcceptedAnswer,
        'isReported': isReported,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'currentUserVote': currentUserVote?.toString(),
        'replies': replies.map((r) => r.toJson()).toList(),
      };

  factory PostReply.fromJson(Map<String, dynamic> json) => PostReply(
        id: json['id'],
        postId: json['postId'],
        authorId: json['authorId'],
        authorName: json['authorName'],
        authorPhotoUrl: json['authorPhotoUrl'],
        content: json['content'],
        parentReplyId: json['parentReplyId'],
        upvoteCount: json['upvoteCount'] ?? 0,
        downvoteCount: json['downvoteCount'] ?? 0,
        isAcceptedAnswer: json['isAcceptedAnswer'] ?? false,
        isReported: json['isReported'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        currentUserVote: json['currentUserVote'] != null
            ? UserVote.values.firstWhere(
                (e) => e.toString() == 'UserVote.${json['currentUserVote']}',
                orElse: () => UserVote.none,
              )
            : null,
        replies: List<PostReply>.from(
            json['replies']?.map((r) => PostReply.fromJson(r)) ?? []),
      );
}

class CommunityCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int postCount;
  final int memberCount;
  final bool isJoined;

  const CommunityCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.postCount,
    required this.memberCount,
    this.isJoined = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon.toString(),
      'color': color.toARGB32(),
        'postCount': postCount,
        'memberCount': memberCount,
        'isJoined': isJoined,
      };

  factory CommunityCategory.fromJson(Map<String, dynamic> json) => CommunityCategory(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        icon: Icons.category_rounded, // Default icon, in a real app we'd map this properly
        color: Color(json['color']),
        postCount: json['postCount'] ?? 0,
        memberCount: json['memberCount'] ?? 0,
        isJoined: json['isJoined'] ?? false,
      );
}

class UserActivity {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final String description;
  final String? relatedCourseId;
  final String? relatedPostId;
  final int xpEarned;
  final DateTime createdAt;

  const UserActivity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    this.relatedCourseId,
    this.relatedPostId,
    this.xpEarned = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type.toString(),
        'title': title,
        'description': description,
        'relatedCourseId': relatedCourseId,
        'relatedPostId': relatedPostId,
        'xpEarned': xpEarned,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserActivity.fromJson(Map<String, dynamic> json) => UserActivity(
        id: json['id'],
        userId: json['userId'],
        type: ActivityType.values.firstWhere(
          (e) => e.toString() == 'ActivityType.${json['type']}',
          orElse: () => ActivityType.courseCompleted,
        ),
        title: json['title'],
        description: json['description'],
        relatedCourseId: json['relatedCourseId'],
        relatedPostId: json['relatedPostId'],
        xpEarned: json['xpEarned'] ?? 0,
        createdAt: DateTime.parse(json['createdAt']),
      );
}

enum ActivityType {
  courseCompleted('Course Completed', Icons.school_rounded, Color(0xFF40C057)),
  lessonCompleted(
    'Lesson Completed',
    Icons.menu_book_rounded,
    Color(0xFF339AF0),
  ),
  quizPassed('Quiz Passed', Icons.quiz_rounded, Color(0xFF8B5CF6)),
  projectCompleted(
    'Project Completed',
    Icons.folder_rounded,
    Color(0xFFF59E0B),
  ),
  achievementUnlocked(
    'Achievement Unlocked',
    Icons.emoji_events_rounded,
    Color(0xFFF97316),
  ),
  levelUp('Level Up', Icons.trending_up_rounded, Color(0xFFEC4899)),
  streakMilestone(
    'Streak Milestone',
    Icons.local_fire_department_rounded,
    Color(0xFFFF6B6B),
  ),
  postCreated('Post Created', Icons.create_rounded, Color(0xFF06B6D4)),
  replyCreated('Reply Posted', Icons.reply_rounded, Color(0xFF845EF7)),
  courseEnrolled(
    'Course Enrolled',
    Icons.play_circle_rounded,
    Color(0xFF10B981),
  );

  const ActivityType(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}
