import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/presentation/widgets/learning_course_tile.dart';
import 'package:brainbox/presentation/widgets/section_heading.dart';
import 'package:brainbox/presentation/widgets/week_activity.dart';
import 'package:brainbox/presentation/widgets/achievement_card.dart';
import 'package:brainbox/presentation/widgets/stat_summary.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/data/models/learning_models.dart';
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
                      onPressed: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildInProgressCourses(context, provider),
                    const SizedBox(height: 28),
                    SectionHeading(
                      title: 'Completed',
                      action: 'View All',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildCompletedCourses(context),
                    const SizedBox(height: 28),
                    SectionHeading(
                      title: 'Weekly Activity',
                      action: 'Details',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 16),
                    const WeekActivity(),
                    const SizedBox(height: 28),
                    SectionHeading(
                      title: 'Achievements',
                      action: 'View All',
                      onPressed: () => context.go('/profile'),
                    ),
                    const SizedBox(height: 16),
                    _buildAchievements(context),
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
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
              value: '2.5h',
              label: 'This Week',
              icon: Icons.schedule_rounded,
              color: AppColors.accentSecondary,
            ),
          ),
          Container(width: 1, height: 50, color: AppColors.borderDefault),
          Expanded(
            child: StatSummary(
              value: '5',
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
    final enrolledCourses = provider.courses
        .where((c) => provider.profile?.enrolledCourseIds.contains(c.id) ?? false)
        .toList();

    if (enrolledCourses.isEmpty) {
      return _buildEmptyInProgress(context);
    }

    return Column(
      children: enrolledCourses.asMap().entries.map((entry) {
        final index = entry.key;
        final course = entry.value;
        return LearningCourseTile(
          course: course,
          progress: _getCourseProgress(course.id),
          onTap: () => context.go('/lesson/${course.id}'),
        ).animate().fadeIn(delay: (300 + index * 100).ms).slideY(begin: 0.2, end: 0);
      }).toList(),
    );
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
          Icon(
            Icons.school_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'No courses in progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start a course from Explore to see it here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCourses(BuildContext context) {
    return LearningCourseTile(
      course: Course(
        id: 'digital-productivity',
        title: 'Digital Productivity',
        shortDescription: 'Master productivity tools',
        longDescription: '',
        category: LearningCategory.projectManagement,
        difficulty: DifficultyLevel.beginner,
        thumbnailUrl: '',
        estimatedHours: 3,
        lessonCount: 8,
        quizCount: 2,
        projectCount: 1,
        prerequisites: [],
        learningOutcomes: [],
        tags: [],
        isFeatured: false,
        isNew: false,
        rating: 4.5,
        enrollmentCount: 1200,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      progress: 1.0,
      onTap: () {},
      isCompleted: true,
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAchievements(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AchievementCard(
            icon: Icons.local_fire_department_rounded,
            title: 'On Fire',
            subtitle: '7 day streak',
            color: AppColors.accentWarning,
            isUnlocked: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AchievementCard(
            icon: Icons.rocket_launch_rounded,
            title: 'Starter',
            subtitle: 'First course',
            color: AppColors.accentPrimary,
            isUnlocked: false,
            progress: 0,
            target: 1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AchievementCard(
            icon: Icons.menu_book_rounded,
            title: 'Scholar',
            subtitle: '10 lessons',
            color: AppColors.accentSecondary,
            isUnlocked: false,
            progress: 5,
            target: 10,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0);
  }

  double _getCourseProgress(String courseId) {
    // This would come from actual progress tracking
    switch (courseId) {
      case 'frontend-foundations':
        return 0.42;
      case 'python-essentials':
        return 0.18;
      default:
        return 0.0;
    }
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
                    Expanded(child: _skeletonBox(width: double.infinity, height: 80)),
                    const SizedBox(width: 12),
                    Expanded(child: _skeletonBox(width: double.infinity, height: 80)),
                    const SizedBox(width: 12),
                    Expanded(child: _skeletonBox(width: double.infinity, height: 80)),
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