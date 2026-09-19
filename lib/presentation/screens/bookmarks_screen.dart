import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/data/repositories/lesson_repository.dart' as lr;
import 'package:brainbox/core/constants/app_colors.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading || provider.profile == null) {
          return const _LoadingSkeleton();
        }

        final bookmarkedLessonIds = provider.profile!.bookmarkedLessonIds;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Saved Lessons'),
            backgroundColor: AppColors.bgPrimary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: AppColors.bgPrimary,
          body: FutureBuilder<List<_BookmarkedLesson>>(
            future: _getBookmarkedLessons(provider, bookmarkedLessonIds),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingSkeleton();
              }

              final bookmarkedLessons = snapshot.data ?? [];

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, bookmarkedLessons.length),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: bookmarkedLessons.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState(context))
                        : SliverList.separated(
                            itemCount: bookmarkedLessons.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final lesson = bookmarkedLessons[index];
                              return _BookmarkLessonTile(
                                lesson: lesson,
                                courseTitle: lesson.courseTitle,
                                onTap: () => context.push('/lesson/${lesson.courseId}?lesson=${lesson.lessonId}'),
                                onRemove: () => provider.toggleBookmark('${lesson.courseId}:${lesson.lessonId}'),
                              ).animate().fadeIn(delay: (100 + index * 50).ms).slideY(begin: 0.2, end: 0);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your saved lessons',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$count lesson${count == 1 ? '' : 's'} bookmarked for quick access',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
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
            Icons.bookmark_outline_rounded,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved lessons yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bookmark lessons from the lesson screen to find them here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<List<_BookmarkedLesson>> _getBookmarkedLessons(AppProvider provider, List<String> bookmarkedIds) async {
    final lessons = <_BookmarkedLesson>[];
    
    for (final course in provider.courses) {
      final lessonData = await lr.LessonRepository.getCourseLessons(course.id);
      if (lessonData == null) continue;
      
      for (final module in lessonData.modules) {
        for (final lesson in module.lessons) {
          final lessonKey = '${course.id}:${lesson.id}';
          if (bookmarkedIds.contains(lessonKey)) {
            lessons.add(_BookmarkedLesson(
              courseId: course.id,
              courseTitle: course.title,
              lessonId: lesson.id,
              lessonTitle: lesson.title,
              lessonDescription: '',
              xpReward: lesson.xpReward,
              stepCount: lesson.steps.length,
            ));
          }
        }
      }
    }
    
    return lessons;
  }
}

class _BookmarkedLesson {
  final String courseId;
  final String courseTitle;
  final String lessonId;
  final String lessonTitle;
  final String lessonDescription;
  final int xpReward;
  final int stepCount;

  _BookmarkedLesson({
    required this.courseId,
    required this.courseTitle,
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonDescription,
    required this.xpReward,
    required this.stepCount,
  });
}

class _BookmarkLessonTile extends StatelessWidget {
  final _BookmarkedLesson lesson;
  final String courseTitle;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BookmarkLessonTile({
    required this.lesson,
    required this.courseTitle,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentPrimarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.menu_book_rounded, color: AppColors.accentPrimary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.lessonTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      courseTitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.format_list_numbered_rounded, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.stepCount} steps',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.bolt_rounded, size: 14, color: AppColors.accentWarning),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.xpReward} XP',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.accentWarning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.bookmark_rounded, color: AppColors.accentPrimary, size: 24),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.accentPrimarySoft,
                  foregroundColor: AppColors.accentPrimary,
                ),
                tooltip: 'Remove bookmark',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Saved Lessons'),
        backgroundColor: AppColors.bgPrimary,
      ),
      body: CustomScrollView(
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
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList.separated(
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, _) => _skeletonBox(width: double.infinity, height: 100),
            ),
          ),
        ],
      ),
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