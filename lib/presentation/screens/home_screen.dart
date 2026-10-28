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
import 'package:brainbox/core/constants/app_colors.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/data/repositories/daily_challenge_repository.dart';

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
                    _buildWelcomePanel(context, provider),
                    const SizedBox(height: 28),
                    SectionHeading(
                      title: 'Continue Learning',
                      action: 'View All',
                      onPressed: () => context.go('/learn'),
                    ),
                    const SizedBox(height: 16),
                    ContinueCard(
                      course: provider.continueCourse,
                      progress: provider.continueCourse == null
                          ? 0.0
                          : provider.courseProgress(
                              provider.continueCourse!.id,
                            ),
                      subtitle: provider.continueCourse == null
                          ? ''
                          : _continueSubtitle(
                              provider,
                              provider.continueCourse!,
                            ),
                      onTap: () {
                        final course = provider.continueCourse;
                        if (course == null) {
                          context.go('/explore');
                          return;
                        }
                        final next = provider.nextLessonIdFor(course.id);
                        context.push(
                          next == null
                              ? '/lesson/${course.id}'
                              : '/lesson/${course.id}?lesson=$next',
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    DailyChallengeCard(
                      onTap: () => context.push('/challenge'),
                      isCompleted: DailyChallengeRepository.isCompletedForDate(
                        DateTime.now(),
                      ),
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
                      action: 'Explore',
                      onPressed: () => context.go('/explore'),
                    ),
                    const SizedBox(height: 16),
                    _buildRecommendations(context, provider),
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

  Widget _buildWelcomePanel(BuildContext context, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 13, 17, 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.bgCard,
            AppColors.bgCard,
            AppColors.accentPrimary.withValues(alpha: 0.78),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _welcomePill('DAILY PRACTICE'),
              _welcomePill(
                '${provider.currentStreak} day${provider.currentStreak == 1 ? '' : 's'}',
                icon: 'assets/ui/fire.png',
                accent: AppColors.accentWarningLight,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildGreeting(context, provider),
          const SizedBox(height: 2),
          _buildSubtitle(context),
          const SizedBox(height: 15),
          _buildLevelCard(context, provider),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _welcomePill(String text, {String? icon, Color? accent}) {
    final color = accent ?? AppColors.accentPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Image.asset(icon, width: 13, height: 13),
            const SizedBox(width: 3),
          ],
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, AppProvider provider) {
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
      '$greeting, ${_firstName(provider)} 👋',
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  String _firstName(AppProvider provider) {
    final name = provider.profile?.displayName.trim() ?? '';
    return name.isEmpty ? 'Learner' : name.split(RegExp(r'\s+')).first;
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'Master new concepts through interactive problem-solving',
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  /// Mirrors the Figma dashboard's level panel while using the persisted
  /// profile values, so this always reflects actual learning progress.
  Widget _buildLevelCard(BuildContext context, AppProvider provider) {
    final profile = provider.profile;
    final level = provider.level;
    final currentXp = profile?.xp ?? provider.xp;
    final nextXp = profile == null
        ? currentXp
        : currentXp + profile.xpToNextLevel;
    final progress = profile?.levelProgress ?? 0.0;
    final mastered = provider.completedCourses.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.bgCard,
            AppColors.accentPrimarySoft.withValues(alpha: 0.9),
            AppColors.accentSecondarySoft.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentPrimary.withValues(alpha: 0.35),
        ),
        boxShadow: AppShadows.glow(AppColors.accentPrimary),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _levelMetric(
                context,
                label: 'LEVEL',
                value: '${level.number}',
                color: AppColors.accentPrimaryLight,
                alignment: CrossAxisAlignment.start,
              ),
              Expanded(
                child: _levelMetric(
                  context,
                  label: 'COURSES',
                  value: '$mastered',
                  suffix: ' completed',
                  color: AppColors.accentWarning,
                  alignment: CrossAxisAlignment.center,
                ),
              ),
              _levelMetric(
                context,
                label: 'TOTAL XP',
                value: '${provider.xp}',
                suffix: ' XP',
                color: AppColors.textPrimary,
                alignment: CrossAxisAlignment.end,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(
                AppColors.accentSecondary,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$currentXp XP earned',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  nextXp > currentXp
                      ? '$nextXp XP to next level'
                      : 'Top level reached',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.12, end: 0);
  }

  Widget _levelMetric(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required CrossAxisAlignment alignment,
    String suffix = '',
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        RichText(
          text: TextSpan(
            text: value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
            children: [
              if (suffix.isNotEmpty)
                TextSpan(
                  text: suffix,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
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
          return PathCard(course: course)
              .animate()
              .fadeIn(delay: (700 + index * 100).ms)
              .slideX(begin: 0.3, end: 0);
        },
      ),
    );
  }

  String _continueSubtitle(AppProvider provider, Course course) {
    final lessons = provider.lessonsFor(course.id);
    final nextId = provider.nextLessonIdFor(course.id);
    if (lessons.isEmpty) return course.shortDescription;
    if (nextId == null) return 'All ${lessons.length} lessons complete';
    final index = lessons.indexWhere((l) => l.id == nextId);
    final title = index >= 0 ? lessons[index].title : '';
    return 'Lesson ${index + 1} · $title';
  }

  Widget _buildRecommendations(BuildContext context, AppProvider provider) {
    final recommended = provider.recommendedCourses;
    if (recommended.isEmpty) {
      return Text(
        'You\'re all caught up. New courses will show up here.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < recommended.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          RecommendationTile(
            category: recommended[i].category,
            title: recommended[i].title,
            subtitle:
                '${recommended[i].lessonCount} lessons · ${recommended[i].difficulty.label}',
            color: recommended[i].category.color,
            onTap: () => context.push('/course/${recommended[i].id}'),
          ).animate().fadeIn(delay: (800 + i * 100).ms).slideY(begin: 0.2, end: 0),
        ],
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
