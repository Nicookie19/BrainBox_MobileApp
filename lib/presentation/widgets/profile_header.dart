import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/data/models/user_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.profile, super.key});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final initials = profile.displayName
        .split(' ')
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.accentPrimarySoft,
          child: Text(
            initials,
            style: TextStyle(
              color: AppColors.accentPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
          ),
        ).animate().scale(delay: 100.ms),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0),
              const SizedBox(height: 4),
              Text(
                profile.bio.isNotEmpty ? profile.bio : 'Aspiring Developer',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              _buildLevelProgress(context, profile),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.settings_outlined, color: AppColors.textMuted),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.bgTertiary,
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildLevelProgress(BuildContext context, UserProfile profile) {
    final nextLevel = UserLevel.getNextLevel(profile.level);
    final currentXp = profile.xp;
    final xpForCurrentLevel = profile.level.xpRequired;
    final xpForNextLevel = nextLevel?.xpRequired ?? profile.level.xpRequired;
    final progress = nextLevel == null
        ? 1.0
        : (currentXp - xpForCurrentLevel) / (xpForNextLevel - xpForCurrentLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Level ${profile.level.number}',
                    style: TextStyle(
                      color: AppColors.textOnAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  profile.level.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '${profile.xp} / ${xpForNextLevel} XP',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.bgTertiary,
            color: AppColors.accentPrimary,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }
}