import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/data/models/community_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class CommunityPostWidget extends StatelessWidget {
  const CommunityPostWidget({
    required this.post,
    required this.onVote,
    required this.onReply,
    super.key,
  });

  final CommunityPost post;
  final ValueChanged<UserVote> onVote;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildContent(context),
          const SizedBox(height: 12),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: post.type.color.withValues(alpha: 0.2),
          child: Text(
            post.authorName[0].toUpperCase(),
            style: TextStyle(
              color: post.type.color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _timeAgo(post.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: post.type.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(post.type.icon, size: 12, color: post.type.color),
              const SizedBox(width: 4),
              Text(
                post.type.label,
                style: TextStyle(
                  color: post.type.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          post.content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        if (post.tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: post.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#$tag',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: post.hasUserUpvoted ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
          count: post.upvoteCount,
          color: post.hasUserUpvoted ? AppColors.accentPrimary : AppColors.textMuted,
          onTap: () => onVote(UserVote.upvote),
        ),
        const SizedBox(width: 16),
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          count: post.replyCount,
          color: AppColors.textMuted,
          onTap: onReply,
        ),
        const SizedBox(width: 16),
        _ActionButton(
          icon: Icons.favorite_border_rounded,
          count: post.viewCount,
          color: AppColors.textMuted,
          onTap: () {},
        ),
        const Spacer(),
        if (!post.isLocked)
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_horiz_rounded, color: AppColors.textMuted),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.bgTertiary,
            ),
          ),
      ],
    );
  }

  String _timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}