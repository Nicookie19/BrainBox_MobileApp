import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isUnlocked = false,
    this.progress = 0,
    this.target = 1,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isUnlocked;
  final double progress;
  final double target;

  @override
  Widget build(BuildContext context) {
    final progressPercent = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked
              ? color.withValues(alpha: 0.1)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? color.withValues(alpha: 0.3)
                : AppColors.borderDefault,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? color.withValues(alpha: 0.2)
                    : AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isUnlocked ? color : AppColors.textMuted,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isUnlocked) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 5,
                  backgroundColor: AppColors.bgTertiary,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${progress.toInt()} / ${target.toInt()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentSuccessSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_rounded, size: 12, color: AppColors.accentSuccess),
                      const SizedBox(width: 4),
                      Text(
                        'Unlocked',
                        style: TextStyle(
                          color: AppColors.accentSuccess,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }
}