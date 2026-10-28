import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/data/models/learning_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';
import 'package:brainbox/presentation/widgets/course_artwork.dart';

class ContinueCard extends StatelessWidget {
  const ContinueCard({
    required this.course,
    required this.onTap,
    this.progress = 0.0,
    this.subtitle = '',
    super.key,
  });

  final Course? course;
  final VoidCallback onTap;

  /// Fraction (0..1) of the course completed.
  final double progress;

  /// Line shown under the title, e.g. the next lesson.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    if (course == null) {
      return _buildEmptyState(context);
    }

    final c = course!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.bgCard,
                AppColors.accentPrimarySoft.withValues(alpha: 0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.38),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: _getCategoryGradient(c.category),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: CourseArtwork(category: c.category, size: 34),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        color: AppColors.accentSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 14,
                    color: AppColors.accentWarning,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '+25 XP per lesson',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${c.estimatedHours}h total',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentPrimarySoft.withValues(alpha: 0.92),
                AppColors.accentSecondarySoft.withValues(alpha: 0.75),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.42),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.school_outlined,
                  color: AppColors.accentPrimary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Your Learning Journey',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explore courses to begin',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  LinearGradient _getCategoryGradient(LearningCategory category) {
    switch (category) {
      case LearningCategory.webDevelopment:
        return const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
        );
      case LearningCategory.mobileDevelopment:
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        );
      case LearningCategory.programmingLanguages:
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
      case LearningCategory.machineLearning:
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        );
      default:
        return AppColors.primaryGradient;
    }
  }
}
