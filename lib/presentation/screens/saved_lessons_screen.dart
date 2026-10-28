import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/data/repositories/content_loader.dart';
import 'package:brainbox/data/models/content_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class SavedLessonsScreen extends StatelessWidget {
  const SavedLessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Lessons'),
        backgroundColor: AppColors.bgPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: AppColors.bgPrimary,
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading || provider.profile == null) {
            return const _LoadingSkeleton();
          }

          final bookmarkedIds = provider.bookmarkedLessonIds;

          if (bookmarkedIds.isEmpty) {
            return EmptyState(
              message: 'No saved lessons yet',
              actionLabel: 'Explore Lessons',
              onAction: () => context.go('/learn'),
              icon: Icons.bookmark_outline_rounded,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            itemCount: bookmarkedIds.length,
            itemBuilder: (context, index) {
              final lessonId = bookmarkedIds[index];
              final lesson = _findLesson(lessonId);

              if (lesson == null) {
                return _buildUnknownLessonCard(
                  lessonId,
                  () => _showRemoveDialog(context, lessonId),
                );
              }

              return _SavedLessonCard(
                    lesson: lesson,
                    courseId: _extractCourseId(lessonId),
                    onTap: () => context.go(
                      '/lesson/${_extractCourseId(lessonId)}?lesson=$lessonId',
                    ),
                    onRemove: () => _showRemoveDialog(context, lessonId),
                  )
                  .animate()
                  .fadeIn(delay: (100 + index * 50).ms)
                  .slideY(begin: 0.2, end: 0);
            },
          );
        },
      ),
    );
  }

  static LessonContent? _findLesson(String lessonIdKey) {
    // lessonIdKey format: "courseId:lessonId"
    final parts = lessonIdKey.split(':');
    if (parts.length != 2) return null;

    final courseId = parts[0];
    final lessonId = parts[1];

    final course = ContentLoader.getCourse(courseId);
    if (course == null) return null;

    for (final module in course.modules) {
      for (final lesson in module.lessons) {
        if (lesson.id == lessonId) {
          return lesson;
        }
      }
    }
    return null;
  }

  static String _extractCourseId(String lessonIdKey) {
    return lessonIdKey.split(':').first;
  }

  static Widget _buildUnknownLessonCard(
    String lessonIdKey,
    VoidCallback onRemove,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.bgCard,
      child: ListTile(
        leading: const Icon(
          Icons.bookmark_outline_rounded,
          color: AppColors.textMuted,
        ),
        title: Text(
          'Unknown Lesson',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        subtitle: Text(
          lessonIdKey,
          style: TextStyle(color: AppColors.textMuted),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.accentError,
          ),
          onPressed: onRemove,
        ),
      ),
    );
  }

  static Future<void> _showRemoveDialog(
    BuildContext context,
    String lessonIdKey,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove from Saved?'),
        content: const Text(
          'This lesson will be removed from your saved lessons.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentError,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AppProvider>().toggleBookmark(lessonIdKey);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from saved lessons')),
      );
    }
  }
}

class _SavedLessonCard extends StatelessWidget {
  final LessonContent lesson;
  final String courseId;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedLessonCard({
    required this.lesson,
    required this.courseId,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.accentPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lesson.estimatedMinutes} min · ${lesson.xpReward} XP',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: lesson.steps.take(3).map((step) {
                        return Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStepTypeColor(
                              step.type,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStepTypeLabel(step.type),
                            style: TextStyle(
                              fontSize: 9,
                              color: _getStepTypeColor(step.type),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.accentError,
                ),
                tooltip: 'Remove from saved',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _getStepTypeColor(StepType type) {
    switch (type) {
      case StepType.explanation:
        return AppColors.accentPrimary;
      case StepType.multipleChoice:
        return AppColors.accentSecondary;
      case StepType.trueFalse:
        return AppColors.accentSuccess;
      case StepType.fillInBlank:
        return AppColors.accentWarning;
      case StepType.codeOrdering:
        return AppColors.accentError;
    }
  }

  static String _getStepTypeLabel(StepType type) {
    switch (type) {
      case StepType.explanation:
        return 'Read';
      case StepType.multipleChoice:
        return 'MCQ';
      case StepType.trueFalse:
        return 'T/F';
      case StepType.fillInBlank:
        return 'Fill';
      case StepType.codeOrdering:
        return 'Code';
    }
  }
}

class EmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  const EmptyState({
    required this.message,
    this.actionLabel,
    this.onAction,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.explore_rounded),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                ),
              ),
            ],
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
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: 4,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: AppColors.bgCard,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ).animate().shimmer(duration: 1500.ms),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ).animate().shimmer(duration: 1500.ms),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ).animate().shimmer(duration: 1500.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
