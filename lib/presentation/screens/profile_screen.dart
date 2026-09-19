import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/presentation/widgets/profile_header.dart';
import 'package:brainbox/presentation/widgets/profile_stats.dart';
import 'package:brainbox/presentation/widgets/week_activity.dart';
import 'package:brainbox/presentation/widgets/achievement_card.dart';
import 'package:brainbox/presentation/widgets/menu_row.dart';
import 'package:brainbox/data/models/user_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading || provider.profile == null) {
          return const _LoadingSkeleton();
        }

        final profile = provider.profile!;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(profile: profile),
                    const SizedBox(height: 24),
                    ProfileStats(profile: profile),
                    const SizedBox(height: 28),
                    _buildSectionTitle(context, 'Your Progress'),
                    const SizedBox(height: 16),
                    const WeekActivity(),
                    const SizedBox(height: 28),
                    _buildSectionTitle(context, 'Achievements'),
                    const SizedBox(height: 16),
                    _buildAchievements(context, profile),
                    const SizedBox(height: 28),
                    _buildSectionTitle(context, 'Account'),
                    const SizedBox(height: 16),
                    _buildMenuItems(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildAchievements(BuildContext context, UserProfile profile) {
    final achievements = profile.achievements;

    return Row(
      children: achievements.asMap().entries.map((entry) {
        final index = entry.key;
        final achievement = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == achievements.length - 1 ? 0 : 12),
            child: AchievementCard(
              icon: _getAchievementIcon(achievement.iconAsset),
              title: achievement.title,
              subtitle: achievement.description,
              color: _getAchievementColor(achievement.type),
              isUnlocked: achievement.isUnlocked,
              progress: achievement.progress.toDouble(),
              target: achievement.target.toDouble(),
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        MenuRow(
          icon: Icons.bookmark_outline_rounded,
          title: 'Saved Lessons',
          subtitle: 'Access your bookmarked content',
          onTap: () {},
        ),
        MenuRow(
          icon: Icons.download_outlined,
          title: 'Downloads',
          subtitle: 'Manage offline content',
          onTap: () {},
        ),
        MenuRow(
          icon: Icons.dark_mode_outlined,
          title: 'Appearance',
          subtitle: 'Customize theme and display',
          onTap: () {},
        ),
        MenuRow(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage reminders and alerts',
          onTap: () {},
        ),
        MenuRow(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle: 'FAQs, contact us, feedback',
          onTap: () {},
        ),
        MenuRow(
          icon: Icons.logout_rounded,
          title: 'Sign Out',
          subtitle: 'Log out of your account',
          onTap: () {},
          isDestructive: true,
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  IconData _getAchievementIcon(String asset) {
    switch (asset) {
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

  Color _getAchievementColor(AchievementType type) {
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
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(width: 100, height: 24),
                const SizedBox(height: 24),
                _skeletonBox(width: double.infinity, height: 100),
                const SizedBox(height: 28),
                _skeletonBox(width: 120, height: 24),
                const SizedBox(height: 16),
                _skeletonBox(width: double.infinity, height: 100),
                const SizedBox(height: 28),
                _skeletonBox(width: 120, height: 24),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _skeletonBox(width: double.infinity, height: 100)),
                    const SizedBox(width: 12),
                    Expanded(child: _skeletonBox(width: double.infinity, height: 100)),
                    const SizedBox(width: 12),
                    Expanded(child: _skeletonBox(width: double.infinity, height: 100)),
                  ],
                ),
                const SizedBox(height: 28),
                _skeletonBox(width: 120, height: 24),
                const SizedBox(height: 16),
                _skeletonBox(width: double.infinity, height: 60),
                const SizedBox(height: 8),
                _skeletonBox(width: double.infinity, height: 60),
                const SizedBox(height: 8),
                _skeletonBox(width: double.infinity, height: 60),
                const SizedBox(height: 8),
                _skeletonBox(width: double.infinity, height: 60),
                const SizedBox(height: 8),
                _skeletonBox(width: double.infinity, height: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _skeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
    ).animate().shimmer(duration: 1500.ms);
  }
}