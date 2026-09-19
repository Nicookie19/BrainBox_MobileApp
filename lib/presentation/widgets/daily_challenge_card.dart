import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({
    required this.onTap,
    required this.isCompleted,
    super.key,
  });

  final VoidCallback onTap;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isCompleted ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isCompleted
                ? LinearGradient(
                    colors: [
                      AppColors.accentSuccess.withValues(alpha: 0.2),
                      AppColors.accentSuccessSoft,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      AppColors.accentWarning.withValues(alpha: 0.15),
                      AppColors.accentWarningSoft,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? AppColors.accentSuccess.withValues(alpha: 0.3)
                  : AppColors.accentWarning.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.accentSuccess
                      : AppColors.accentWarning,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : Icons.bolt_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Challenge',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? 'Completed · +50 XP earned'
                          : 'JavaScript Quick Check · 3 questions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentWarning,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+50 XP',
                    style: TextStyle(
                      color: AppColors.textOnAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}