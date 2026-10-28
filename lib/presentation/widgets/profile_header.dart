import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/data/models/user_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.profile, super.key});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.glow(AppColors.accentPrimary),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Image.asset(
                      'assets/ui/avatar.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ).animate().scale(delay: 100.ms),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.accentWarning,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bgPrimary, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset(
                        'assets/ui/crown.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              profile.displayName.isEmpty
                  ? 'BrainBox Learner'
                  : profile.displayName,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 4),
            Text(
              profile.bio.isNotEmpty
                  ? profile.bio
                  : 'Building skills one lesson at a time',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 14),
            _buildLevelProgress(context, profile),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(Icons.settings_outlined, color: AppColors.textMuted),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.bgTertiary,
              side: const BorderSide(color: AppColors.borderDefault),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ),
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
        : (currentXp - xpForCurrentLevel) /
              (xpForNextLevel - xpForCurrentLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimarySoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accentPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'Level ${profile.level.number}',
                    style: TextStyle(
                      color: AppColors.accentPrimaryLight,
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
              '${profile.xp} / $xpForNextLevel XP',
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
            color: AppColors.accentSecondary,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
