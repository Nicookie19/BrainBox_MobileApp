import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/presentation/widgets/community_post.dart';
import 'package:brainbox/presentation/widgets/create_post_dialog.dart';
import 'package:brainbox/data/models/community_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const _LoadingSkeleton();
        }

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreatePostDialog(context, provider),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Ask a question'),
            backgroundColor: AppColors.accentPrimary,
            foregroundColor: AppColors.textOnAccent,
          ).animate().fadeIn(delay: 600.ms).scale(),
          body: RefreshIndicator(
            onRefresh: () => provider.refreshPosts(),
            color: AppColors.accentPrimary,
            backgroundColor: AppColors.bgCard,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 16),
                        _buildLiveLearners(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: provider.posts.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState(context))
                      : SliverList.separated(
                          itemCount: provider.posts.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final post = provider.posts[index];
                            return CommunityPostWidget(
                              post: post,
                              onVote: (vote) => provider.toggleVote(post.id, vote),
                              onReply: () => _showReplyDialog(context, post),
                            ).animate().fadeIn(delay: (200 + index * 50).ms).slideY(begin: 0.2, end: 0);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Learn better, together',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildLiveLearners(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPrimary.withValues(alpha: 0.15),
            AppColors.accentPrimarySoft,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1,248 learners active now',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentPrimary,
                  ),
                ),
                Text(
                  'Join discussions, share projects, get help',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to start a discussion!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showCreatePostDialog(BuildContext context, AppProvider provider) {
    return showDialog(
      context: context,
      builder: (context) => CreatePostDialog(
        onSubmit: (title, content, type) => provider.createPost(title, content, type),
      ),
    );
  }

  Future<void> _showReplyDialog(BuildContext context, CommunityPost post) async {
    final provider = context.read<AppProvider>();
    final replies = await provider.getReplies(post.id);
    
    if (!context.mounted) return;
    
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReplyBottomSheet(
        post: post,
        replies: replies,
        onReply: (content) => provider.createReply(post.id, content),
        onReplyToReply: (parentReplyId, content) => provider.createReply(post.id, content, parentReplyId: parentReplyId),
      ),
    );
  }
}

class _ReplyBottomSheet extends StatefulWidget {
  final CommunityPost post;
  final List<PostReply> replies;
  final Future<void> Function(String content) onReply;
  final Future<void> Function(String parentReplyId, String content) onReplyToReply;

  const _ReplyBottomSheet({
    required this.post,
    required this.replies,
    required this.onReply,
    required this.onReplyToReply,
  });

  @override
  State<_ReplyBottomSheet> createState() => _ReplyBottomSheetState();
}

class _ReplyBottomSheetState extends State<_ReplyBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _replyingToId;
  String? _replyingToName;
  List<PostReply> _replies = [];

  @override
  void initState() {
    super.initState();
    _replies = widget.replies;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startReply(String? parentReplyId, String? authorName) {
    setState(() {
      _replyingToId = parentReplyId;
      _replyingToName = authorName;
    });
    _controller.clear();
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToName = null;
    });
    _controller.clear();
  }

  Future<void> _submitReply() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    if (_replyingToId != null) {
      await widget.onReplyToReply(_replyingToId!, content);
    } else {
      await widget.onReply(content);
    }

    _controller.clear();
    setState(() {
      _replyingToId = null;
      _replyingToName = null;
    });

    // Refresh replies
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    final updatedReplies = await provider.getReplies(widget.post.id);
    if (mounted) {
      setState(() {
        _replies = updatedReplies;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          const Divider(height: 1, color: AppColors.borderDefault),
          Expanded(
            child: _replies.isEmpty
                ? _buildEmptyReplies()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    itemCount: _replies.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _buildReplyTile(_replies[index], 0),
                  ),
          ),
          _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.borderDefault,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replies',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_replies.length} reply${_replies.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.bgTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReplies() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No replies yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to respond!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyTile(PostReply reply, int depth) {
    final isNested = depth > 0;
    
    return Padding(
      padding: EdgeInsets.only(left: isNested ? 48.0 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.accentPrimarySoft,
                child: Text(
                  reply.authorName[0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.accentPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          reply.authorName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (reply.isAcceptedAnswer) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentSuccessSoft,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Accepted',
                              style: TextStyle(
                                color: AppColors.accentSuccess,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reply.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _formatTime(reply.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildVoteButton(reply),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => _startReply(reply.id, reply.authorName),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              color: AppColors.accentPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (reply.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...reply.replies.map((nested) => _buildReplyTile(nested, depth + 1)),
          ],
        ],
      ),
    );
  }

  Widget _buildVoteButton(PostReply reply) {
    final hasUpvoted = reply.hasUserUpvoted;
    final hasDownvoted = reply.hasUserDownvoted;
    
    return Row(
      children: [
        IconButton(
          onPressed: () => _vote(reply.id, UserVote.upvote),
          icon: Icon(
            hasUpvoted ? Icons.arrow_upward_rounded : Icons.arrow_upward_outlined,
            size: 18,
            color: hasUpvoted ? AppColors.accentSuccess : AppColors.textMuted,
          ),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(36, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        Text(
          '${reply.score}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: hasUpvoted ? AppColors.accentSuccess : hasDownvoted ? AppColors.accentError : AppColors.textSecondary,
          ),
        ),
        IconButton(
          onPressed: () => _vote(reply.id, UserVote.downvote),
          icon: Icon(
            hasDownvoted ? Icons.arrow_downward_rounded : Icons.arrow_downward_outlined,
            size: 18,
            color: hasDownvoted ? AppColors.accentError : AppColors.textMuted,
          ),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(36, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Future<void> _vote(String replyId, UserVote vote) async {
    final provider = context.read<AppProvider>();
    await provider.toggleReplyVote(widget.post.id, replyId, vote);
    final updatedReplies = await provider.getReplies(widget.post.id);
    if (mounted) {
      setState(() {
        _replies = updatedReplies;
      });
    }
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildReplyInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (_replyingToId != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.reply_rounded, size: 16, color: AppColors.accentPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Replying to $_replyingToName',
                        style: TextStyle(
                          color: AppColors.accentPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Icon(Icons.close_rounded, size: 18, color: AppColors.accentPrimary),
                    ),
                  ],
                ),
              ),
            if (_replyingToId != null) const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.accentPrimarySoft,
                  child: Text(
                    'AR',
                    style: TextStyle(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: _replyingToId != null ? 'Write your reply...' : 'Write a reply...',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.bgTertiary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _controller.text.trim().isNotEmpty ? _submitReply : null,
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    foregroundColor: AppColors.textOnAccent,
                    disabledBackgroundColor: AppColors.bgTertiary,
                    disabledForegroundColor: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(width: 150, height: 32),
                const SizedBox(height: 4),
                _skeletonBox(width: 200, height: 20),
                const SizedBox(height: 16),
                _skeletonBox(width: double.infinity, height: 80),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList.separated(
            itemCount: 5,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, _) => _skeletonBox(width: double.infinity, height: 180),
          ),
        ),
      ],
    );
  }

  Widget _skeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
    ).animate().shimmer(duration: 1500.ms);
  }
}