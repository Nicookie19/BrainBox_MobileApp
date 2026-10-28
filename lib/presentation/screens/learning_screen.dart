import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/presentation/widgets/learning_course_tile.dart';
import 'package:brainbox/presentation/widgets/section_heading.dart';
import 'package:brainbox/presentation/widgets/week_activity.dart';
import 'package:brainbox/presentation/widgets/achievement_card.dart';
import 'package:brainbox/presentation/widgets/achievement_style.dart';
import 'package:brainbox/presentation/widgets/stat_summary.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

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
                    _buildStatsSummary(context, provider),
                    const SizedBox(height: 24),
                    SectionHeading(
                      title: 'In Progress',
                      action: 'Sort',
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Courses are sorted by your progress.',
                              ),
                            ),
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInProgressCourses(context, provider),
                    const SizedBox(height: 28),
                    SectionHeading(
                      title: 'Completed',
                      action: 'View All',
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'All completed courses are shown below.',
                              ),
                            ),
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildCompletedCourses(context, provider),
                    const SizedBox(height: 28),
                    SectionHeading(
                      title: 'Weekly Activity',
                      action: 'Details',
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${provider.weeklyStudyMinutes} min studied this week.',
                              ),
                            ),
                          ),
                    ),
                    const SizedBox(height: 16),
                    WeekActivity(activity: provider.weekActivity),
                    const SizedBox(height: 28),
                    SectionHeading(
                      title: 'Achievements',
                      action: 'View All',
                      onPressed: () => context.go('/profile'),
                    ),
                    const SizedBox(height: 16),
                    _buildAchievements(context, provider),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keep the thread\ngoing.',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'BrainBox remembers the ideas you\'ve started',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatsSummary(BuildContext context, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Expanded(
            child: StatSummary(
              value: _formatMinutes(provider.weeklyStudyMinutes),
              label: 'This Week',
              icon: Icons.schedule_rounded,
              color: AppColors.accentSecondary,
            ),
          ),
          Container(width: 1, height: 50, color: AppColors.borderDefault),
          Expanded(
            child: StatSummary(
              value: '${provider.profile?.stats.totalLessonsCompleted ?? 0}',
              label: 'Lessons Done',
              icon: Icons.menu_book_rounded,
              color: AppColors.accentPrimary,
            ),
          ),
          Container(width: 1, height: 50, color: AppColors.borderDefault),
          Expanded(
            child: StatSummary(
              value: '${provider.xp}',
              label: 'Total XP',
              icon: Icons.bolt_rounded,
              color: AppColors.accentWarning,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildInProgressCourses(BuildContext context, AppProvider provider) {
    final courses = provider.inProgressCourses;

    if (courses.isEmpty) {
      return _buildEmptyInProgress(context);
    }

    return Column(
      children: courses.asMap().entries.map((entry) {
        final index = entry.key;
        final course = entry.value;
        return LearningCourseTile(
              course: course,
              progress: provider.courseProgress(course.id),
              onTap: () => _openCourse(context, provider, course),
            )
            .animate()
            .fadeIn(delay: (300 + index * 100).ms)
            .slideY(begin: 0.2, end: 0);
      }).toList(),
    );
  }

  void _openCourse(BuildContext context, AppProvider provider, Course course) {
    final next = provider.nextLessonIdFor(course.id);
    if (!provider.hasLessons(course.id)) {
      context.push('/course/${course.id}');
    } else if (next == null) {
      context.push('/lesson/${course.id}?lesson=${provider.lessonsFor(course.id).first.id}');
    } else {
      context.push('/lesson/${course.id}?lesson=$next');
    }
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    return '${(minutes / 60).toStringAsFixed(1)}h';
  }

  Widget _buildEmptyInProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            'No courses in progress',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Start a course from Explore to see it here',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCourses(BuildContext context, AppProvider provider) {
    final completed = provider.completedCourses;

    if (completed.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Text(
          'Finish every lesson in a course and it will show up here.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
    }

    return Column(
      children: completed.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LearningCourseTile(
            course: entry.value,
            progress: 1.0,
            isCompleted: true,
            onTap: () => context.push('/course/${entry.value.id}'),
          ),
        ).animate().fadeIn(delay: (400 + entry.key * 100).ms).slideY(begin: 0.2, end: 0);
      }).toList(),
    );
  }

  Widget _buildAchievements(BuildContext context, AppProvider provider) {
    final achievements = provider.profile?.achievements ?? const [];

    return Row(
      children: achievements.asMap().entries.map((entry) {
        final achievement = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: entry.key == achievements.length - 1 ? 0 : 12,
            ),
            child: AchievementCard(
              icon: achievementIcon(achievement.iconAsset),
              title: achievement.title,
              subtitle: achievement.description,
              color: achievementColor(achievement.type),
              isUnlocked: achievement.isUnlocked,
              progress: achievement.progress.toDouble(),
              target: achievement.target.toDouble(),
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0);
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
                _skeletonBox(width: 200, height: 32),
                const SizedBox(height: 8),
                _skeletonBox(width: 300, height: 20),
                const SizedBox(height: 24),
                _skeletonBox(width: double.infinity, height: 100),
                const SizedBox(height: 24),
                _skeletonBox(width: 150, height: 24),
                const SizedBox(height: 16),
                _skeletonBox(width: double.infinity, height: 120),
                const SizedBox(height: 12),
                _skeletonBox(width: double.infinity, height: 120),
                const SizedBox(height: 28),
                _skeletonBox(width: 150, height: 24),
                const SizedBox(height: 16),
                _skeletonBox(width: double.infinity, height: 100),
                const SizedBox(height: 28),
                _skeletonBox(width: 150, height: 24),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _skeletonBox(width: double.infinity, height: 80),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _skeletonBox(width: double.infinity, height: 80),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _skeletonBox(width: double.infinity, height: 80),
                    ),
                  ],
                ),
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
        borderRadius: BorderRadius.circular(12),
      ),
    ).animate().shimmer(duration: 1500.ms);
  }
}
