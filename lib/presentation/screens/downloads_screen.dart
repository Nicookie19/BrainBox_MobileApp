import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/data/repositories/content_loader.dart';
import 'package:brainbox/data/models/content_models.dart';
import 'package:brainbox/presentation/widgets/shared_widgets.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: AppColors.bgPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: AppColors.bgPrimary,
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading || provider.profile == null) {
            return const AppLoadingSkeleton();
          }

          final downloads = _getDownloadedContent(provider);

          if (downloads.isEmpty) {
            return AppEmptyState(
              message: 'No downloaded content',
              actionLabel: 'Explore Lessons',
              onAction: () => context.go('/learn'),
              icon: Icons.download_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final download = downloads[index];
              return _DownloadCard(
                    download: download,
                    onTap: () => context.go(
                      '/lesson/${download.courseId}?lesson=${download.lessonId}',
                    ),
                    onRemove: () => _showRemoveDialog(context, download),
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
}

List<DownloadInfo> _getDownloadedContent(AppProvider provider) {
  final downloads = provider.profile?.downloadedLessonIds ?? [];
  final List<DownloadInfo> result = [];

  for (final downloadId in downloads) {
    final parts = downloadId.split(':');
    if (parts.length != 2) continue;

    final courseId = parts[0];
    final lessonId = parts[1];

    final lesson = _findLesson(courseId, lessonId);
    if (lesson != null) {
      result.add(
        DownloadInfo(
          courseId: courseId,
          lessonId: lessonId,
          lessonTitle: lesson.title,
          courseTitle: _getCourseTitle(courseId),
          downloadedAt: DateTime.now(), // In real app, this would be stored
          sizeBytes: lesson.estimatedMinutes * 50 * 1024, // Rough estimate
        ),
      );
    }
  }

  return result;
}

LessonContent? _findLesson(String courseId, String lessonId) {
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

String _getCourseTitle(String courseId) {
  final course = ContentLoader.getCourse(courseId);
  return course?.title ?? courseId;
}

Future<void> _showRemoveDialog(
  BuildContext context,
  DownloadInfo download,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Remove Download?'),
      content: Text('Remove "${download.lessonTitle}" from downloads?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.accentError),
          child: const Text('Remove'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    // In a real app, this would remove from storage
    // For now, just show a snackbar
  }
}

class DownloadInfo {
  final String courseId;
  final String lessonId;
  final String lessonTitle;
  final String courseTitle;
  final DateTime downloadedAt;
  final int sizeBytes;

  DownloadInfo({
    required this.courseId,
    required this.lessonId,
    required this.lessonTitle,
    required this.courseTitle,
    required this.downloadedAt,
    required this.sizeBytes,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '${sizeBytes} B';
    if (sizeBytes < 1024 * 1024)
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _DownloadCard extends StatelessWidget {
  final DownloadInfo download;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _DownloadCard({
    required this.download,
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
                  color: AppColors.accentSecondarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.download_done_rounded,
                  color: AppColors.accentSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      download.lessonTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      download.courseTitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.file_download_rounded,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          download.formattedSize,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') onRemove();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.accentError,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text('Remove download'),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
