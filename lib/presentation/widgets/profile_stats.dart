import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/data/models/user_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({required this.profile, super.key});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              value: '${profile.stats.currentStreakDays}',
              label: 'Day Streak',
              icon: Icons.local_fire_department_rounded,
              color: AppColors.accentWarning,
            ),
          ),
          Container(width: 1, height: 50, color: AppColors.borderDefault),
          Expanded(
            child: _StatItem(
              value: '${profile.totalXp}',
              label: 'Total XP',
              icon: Icons.bolt_rounded,
              color: AppColors.accentPrimary,
            ),
          ),
          Container(width: 1, height: 50, color: AppColors.borderDefault),
          Expanded(
            child: _StatItem(
              value: '${profile.enrolledCourseIds.length}',
              label: 'Active Paths',
              icon: Icons.school_rounded,
              color: AppColors.accentSecondary,
            ),
          ),
          Container(width: 1, height: 50, color: AppColors.borderDefault),
          Expanded(
            child: _StatItem(
              value: '${profile.stats.totalCoursesCompleted}',
              label: 'Completed',
              icon: Icons.check_circle_rounded,
              color: AppColors.accentSuccess,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}