import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/data/models/user_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';
import 'package:brainbox/presentation/widgets/level_badge.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.profile, super.key});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName.trim();
    final initials = name.isEmpty
        ? 'B'
        : name
              .split(RegExp(r'\s+'))
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part.characters.first.toUpperCase())
              .join();
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF055CFF), Color(0xFFE6E90B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.glow(AppColors.accentPrimary),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF40497B),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
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
                      child: LevelBadge(
                        levelNumber: profile.level.number,
                        size: 18,
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
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LevelBadge(levelNumber: profile.level.number, size: 20),
                const SizedBox(width: 6),
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
