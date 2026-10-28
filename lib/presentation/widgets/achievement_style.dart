import 'package:flutter/material.dart';
import 'package:brainbox/core/constants/app_colors.dart';
import 'package:brainbox/data/models/user_models.dart';

/// Icon for an achievement's `iconAsset` name.
IconData achievementIcon(String iconAsset) {
  switch (iconAsset) {
    case 'local_fire_department':
      return Icons.local_fire_department_rounded;
    case 'rocket_launch':
      return Icons.rocket_launch_rounded;
    case 'menu_book':
      return Icons.menu_book_rounded;
    default:
      return Icons.emoji_events_rounded;
  }
}

/// Accent color for an achievement type.
Color achievementColor(AchievementType type) {
  switch (type) {
    case AchievementType.streakDays:
      return AppColors.accentWarning;
    case AchievementType.coursesCompleted:
      return AppColors.accentPrimary;
    case AchievementType.lessonsCompleted:
      return AppColors.accentSecondary;
    default:
      return AppColors.accentPrimary;
  }
}
