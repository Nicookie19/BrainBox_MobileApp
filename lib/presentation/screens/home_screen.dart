import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/presentation/widgets/continue_card.dart';
import 'package:brainbox/presentation/widgets/daily_challenge_card.dart';
import 'package:brainbox/presentation/widgets/path_card.dart';
import 'package:brainbox/presentation/widgets/recommendation_tile.dart';
import 'package:brainbox/presentation/widgets/section_heading.dart';
import 'package:brainbox/presentation/widgets/stat_pill.dart';
import 'package:brainbox/presentation/widgets/brand_mark.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const _LoadingSkeleton();
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, provider),
                    const SizedBox(height: 24),
                    _buildGreeting(context),
                    const SizedBox(height: 8),
                    _buildSubtitle(context),
                    const SizedBox(height: 20),
                    _buildStats(context, provider),
                    const SizedBox(height: 28),
                    SectionHeading(
                      title: 'Continue Learning',
                      action: 'View All',
                      onPressed: () => context.go('/learn'),
                    ),
                    const SizedBox(height: 16),
                    ContinueCard(
                      course: provider.courses.isNotEmpty
                          ? provider.courses.firstWhere(
                              (c) => c.id == 'frontend-foundations',
                              orElse: () => provider.courses.first,
                            )
                          : null,
                      onTap: () => context.go('/lesson/frontend-foundations'),
                    ),
                    const SizedBox(height: 24),
                    DailyChallengeCard(
                      onTap: () => context.go('/challenge'),
                      isCompleted: false,
                    ),
                    const SizedBox(height: 28),
                    SectionHeading(
                      title: 'Learning Paths',
                      action: 'Explore All',
                      onPressed: () => context.go('/explore'),
                    ),
                    const SizedBox(height: 16),
                    _buildPathCards(provider),
                    const SizedBox(height: 28),
                    SectionHeading(
                      title: 'Recommended for You',
                      action: 'Refresh',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildRecommendations(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider provider) {
    return Row(
      children: [
        const BrandMark(size: 40),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BrainBox',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Daily Practice',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.bgTertiary,
            foregroundColor: AppColors.textSecondary,
          ),
        ).animate().scale(delay: 200.ms),
        const SizedBox(width: 8),
        _buildAvatar(provider),
      ],
    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildAvatar(AppProvider provider) {
    final initials = provider.profile?.displayName
        .split(' ')
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase() ?? 'AR';

    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.accentPrimarySoft,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.accentPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    ).animate().scale(delay: 300.ms);
  }

  Widget _buildGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Text(
      '$greeting. Ready to learn?',
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'Master new concepts through interactive problem-solving',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppColors.textSecondary,
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStats(BuildContext context, AppProvider provider) {
    return Row(
      children: [
        StatPill(
          icon: Icons.local_fire_department_rounded,
          value: '${provider.currentStreak} day streak',
          color: AppColors.accentWarning,
          background: AppColors.accentWarningSoft,
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(width: 12),
        StatPill(
          icon: Icons.bolt_rounded,
          value: '${provider.xp} XP',
          color: AppColors.accentPrimary,
          background: AppColors.accentPrimarySoft,
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
        const Spacer(),
        _buildLevelBadge(context, provider),
      ],
    );
  }

  Widget _buildLevelBadge(BuildContext context, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16, color: AppColors.textOnAccent),
          const SizedBox(width: 4),
          Text(
            'Level ${provider.level.number}',
            style: TextStyle(
              color: AppColors.textOnAccent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildPathCards(AppProvider provider) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: provider.courses.length.clamp(0, 6),
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final course = provider.courses[index];
          return PathCard(course: course).animate().fadeIn(delay: (700 + index * 100).ms).slideX(begin: 0.3, end: 0);
        },
      ),
    );
  }

  Widget _buildRecommendations() {
    return Column(
      children: [
        RecommendationTile(
          icon: Icons.psychology_rounded,
          title: 'Neural Networks',
          subtitle: '8 min · Intermediate',
          color: AppColors.accentPrimary,
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 12),
        RecommendationTile(
          icon: Icons.code_rounded,
          title: 'Algorithms & Data Structures',
          subtitle: '12 min · Beginner',
          color: AppColors.accentSecondary,
        ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 12),
        RecommendationTile(
          icon: Icons.cloud_rounded,
          title: 'Cloud Fundamentals',
          subtitle: '15 min · Beginner',
          color: AppColors.accentSuccess,
        ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2, end: 0),
      ],
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
                _skeletonBox(width: 120, height: 24),
                const SizedBox(height: 24),
                _skeletonBox(width: 200, height: 32),
                const SizedBox(height: 8),
                _skeletonBox(width: 300, height: 20),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _skeletonCircle(36),
                    const SizedBox(width: 12),
                    _skeletonCircle(36),
                  ],
                ),
                const SizedBox(height: 28),
                _skeletonBox(width: 150, height: 24),
                const SizedBox(height: 16),
                _skeletonBox(width: double.infinity, height: 140),
                const SizedBox(height: 24),
                _skeletonBox(width: double.infinity, height: 100),
                const SizedBox(height: 28),
                _skeletonBox(width: 180, height: 24),
                const SizedBox(height: 16),
                _skeletonBox(width: double.infinity, height: 80),
                const SizedBox(height: 12),
                _skeletonBox(width: double.infinity, height: 80),
              ],
            ),
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
        borderRadius: BorderRadius.circular(8),
      ),
    ).animate().shimmer(duration: 1500.ms);
  }

  Widget _skeletonCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        shape: BoxShape.circle,
      ),
    ).animate().shimmer(duration: 1500.ms);
  }
}