import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/data/models/learning_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    required this.course,
    required this.onTap,
    super.key,
  });

  final Course course;
  final VoidCallback onTap;

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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: _getCategoryGradient(course.category),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  course.category.icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (course.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentPrimary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'NEW',
                              style: TextStyle(
                                color: AppColors.textOnAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.shortDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _buildMetaItem(
                          context,
                          Icons.menu_book_rounded,
                          '${course.lessonCount} lessons',
                        ),
                        _buildMetaItem(
                          context,
                          Icons.schedule_rounded,
                          '${course.estimatedHours}h',
                        ),
                        _buildMetaItem(
                          context,
                          Icons.bar_chart_rounded,
                          course.difficulty.label,
                          color: course.difficulty.color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.accentWarning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_formatNumber(course.enrollmentCount)} learners',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(BuildContext context, IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color ?? AppColors.textMuted,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color ?? AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  LinearGradient _getCategoryGradient(LearningCategory category) {
    switch (category) {
      case LearningCategory.webDevelopment:
        return const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0891B2)]);
      case LearningCategory.mobileDevelopment:
        return const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]);
      case LearningCategory.programmingLanguages:
        return const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]);
      case LearningCategory.machineLearning:
        return const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]);
      case LearningCategory.networking:
        return const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]);
      case LearningCategory.databases:
        return const LinearGradient(colors: [Color(0xFF84CC16), Color(0xFF65A30D)]);
      case LearningCategory.devops:
        return const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEA580C)]);
      case LearningCategory.projectManagement:
        return const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFDB2777)]);
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}