import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/data/models/community_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({
    required this.onSubmit,
    super.key,
  });

  final Future<void> Function(String title, String content, PostType type) onSubmit;

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  PostType _selectedType = PostType.question;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Create Post',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.bgTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTypeSelector(),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.titleMedium,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'What\'s your question or thought?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Content',
                hintText: 'Share details, code snippets, or context...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 5,
              minLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _canSubmit && !_isSubmitting ? _submit : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Post'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Post Type',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PostType.values.map((type) {
            final isSelected = type == _selectedType;
            return InkWell(
              onTap: () => setState(() => _selectedType = type),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? type.color.withValues(alpha: 0.2)
                      : AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? type.color : AppColors.borderDefault,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(type.icon, size: 16, color: isSelected ? type.color : AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      type.label,
                      style: TextStyle(
                        color: isSelected ? type.color : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool get _canSubmit =>
      _titleController.text.trim().isNotEmpty &&
      _contentController.text.trim().length >= 5;

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(
        _titleController.text.trim(),
        _contentController.text.trim(),
        _selectedType,
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}