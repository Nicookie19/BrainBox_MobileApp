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
    // TODO: Implement reply dialog
    return;
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
            itemBuilder: (_, __) => _skeletonBox(width: double.infinity, height: 180),
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