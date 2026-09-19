import 'package:flutter/material.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/data/models/learning_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class LearningCourseTile extends StatelessWidget {
  const LearningCourseTile({
    required this.course,
    required this.progress,
    required this.onTap,
    this.isCompleted = false,
    super.key,
  });

  final Course course;
  final double progress;
  final VoidCallback onTap;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = _getCategoryColors(course.category);

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
            border: Border.all(
              color: isCompleted
                  ? AppColors.accentSuccess.withValues(alpha: 0.3)
                  : AppColors.borderDefault,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCompleted
                        ? [AppColors.accentSuccess, AppColors.accentSuccess.withValues(alpha: 0.7)]
                        : colors,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : course.category.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
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
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentSuccessSoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'COMPLETED',
                              style: TextStyle(
                                color: AppColors.accentSuccess,
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
                      isCompleted
                          ? 'Completed · ${course.lessonCount} lessons'
                          : 'Lesson ${(progress * course.lessonCount).ceil()} · ${_getCurrentLesson(course)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: AppColors.bgTertiary,
                        color: isCompleted ? AppColors.accentSuccess : colors[0],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).round()}% complete',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!isCompleted)
                          Text(
                            '+${25 * course.lessonCount} XP total',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.accentPrimary,
                              fontWeight: FontWeight.w600,
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

  String _getCurrentLesson(Course course) {
    // This would come from actual progress
    return 'CSS Flexbox';
  }

  List<Color> _getCategoryColors(LearningCategory category) {
    switch (category) {
      case LearningCategory.webDevelopment:
        return [AppColors.accentSecondary, AppColors.accentSecondaryLight];
      case LearningCategory.mobileDevelopment:
        return [AppColors.accentPrimary, AppColors.accentPrimaryLight];
      case LearningCategory.programmingLanguages:
        return [AppColors.accentSuccess, AppColors.accentSuccessLight];
      case LearningCategory.machineLearning:
        return [AppColors.accentWarning, AppColors.accentWarningLight];
      default:
        return [AppColors.accentPrimary, AppColors.accentPrimaryLight];
    }
  }
}