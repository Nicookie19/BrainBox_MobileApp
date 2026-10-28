import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/core/constants/app_colors.dart';
import 'package:brainbox/data/services/storage_service.dart';

/// Lists lessons the learner saved for offline access and lets them remove
/// or reopen them.
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final raw = StorageService.getDownloadedContent();
    final items = <Map<String, dynamic>>[];
    for (final entry in raw.entries) {
      final value = entry.value;
      if (value is Map) {
        items.add({'key': entry.key, ...Map<String, dynamic>.from(value)});
      }
    }
    items.sort(
      (a, b) => ((b['downloadedAt'] as String?) ?? '').compareTo(
        (a['downloadedAt'] as String?) ?? '',
      ),
    );
    _items = items;
  }

  Future<void> _remove(String key) async {
    await StorageService.removeDownload(key);
    if (!mounted) return;
    setState(_load);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from downloads.')),
    );
  }

  Future<void> _removeAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove all downloads?'),
        content: const Text('Your lesson progress is not affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove all'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await StorageService.clearDownloads();
    if (!mounted) return;
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: AppColors.bgPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_items.isNotEmpty)
            TextButton(onPressed: _removeAll, child: const Text('Remove all')),
        ],
      ),
      body: _items.isEmpty ? _buildEmptyState(context) : _buildList(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'No downloads yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the download button inside a lesson to keep it here.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: _items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _items[index];
        final key = item['key'] as String;
        final title = (item['title'] as String?) ?? 'Lesson';
        final courseTitle = (item['courseTitle'] as String?) ?? '';
        final courseId = item['courseId'] as String?;
        final lessonId = item['lessonId'] as String?;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: courseId == null || lessonId == null
                ? null
                : () => context.push('/lesson/$courseId?lesson=$lessonId'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.download_done_rounded,
                    color: AppColors.accentPrimary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (courseTitle.isNotEmpty)
                          Text(
                            courseTitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    onPressed: () => _remove(key),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (100 + index * 50).ms).slideY(begin: 0.2, end: 0),
        );
      },
    );
  }
}
