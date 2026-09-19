import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/presentation/widgets/menu_row.dart';
import 'package:brainbox/data/services/storage_service.dart';
import 'package:brainbox/data/models/user_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading || provider.profile == null) {
          return const _LoadingSkeleton();
        }

        final preferences = provider.profile!.preferences;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: AppColors.bgPrimary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: AppColors.bgPrimary,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Appearance'),
                      const SizedBox(height: 16),
                      _buildThemeSelector(context, preferences),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Notifications'),
                      const SizedBox(height: 16),
                      _buildNotificationToggles(context, preferences),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Preferences'),
                      const SizedBox(height: 16),
                      _buildPreferenceToggles(context, preferences),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Data & Privacy'),
                      const SizedBox(height: 16),
                      _buildDataPrivacyMenu(context, provider),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'About'),
                      const SizedBox(height: 16),
                      _buildAboutMenu(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildThemeSelector(BuildContext context, UserPreferences preferences) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.palette_outlined, color: AppColors.accentPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Choose your preferred color scheme',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  context,
                  'System',
                  Icons.settings_brightness_rounded,
                  !preferences.darkMode && !preferences.darkMode,
                  () => _updateTheme(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOption(
                  context,
                  'Dark',
                  Icons.dark_mode_rounded,
                  preferences.darkMode,
                  () => _updateTheme(context, false, forceDark: true),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPrimarySoft : AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentPrimary : AppColors.borderDefault,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.accentPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateTheme(BuildContext context, bool useSystem,
      {bool forceDark = false}) async {
    final provider = context.read<AppProvider>();
    if (provider.profile == null) return;

    final updatedPreferences = provider.profile!.preferences.copyWith(
      darkMode: forceDark || !useSystem,
    );

    final updatedProfile = provider.profile!.copyWith(preferences: updatedPreferences);
    await StorageService.saveUserProfile(updatedProfile);
    provider.initialize();
  }

  Widget _buildNotificationToggles(BuildContext context, UserPreferences preferences) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          _buildToggleTile(
            context,
            'Push Notifications',
            'Receive notifications about streaks, new content, and reminders',
            Icons.notifications_outlined,
            preferences.pushNotifications,
            (value) => _updateNotificationPreference(context, pushNotifications: value),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
          _buildToggleTile(
            context,
            'Email Notifications',
            'Receive weekly progress summaries and updates via email',
            Icons.email_outlined,
            preferences.emailNotifications,
            (value) => _updateNotificationPreference(context, emailNotifications: value),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
          _buildToggleTile(
            context,
            'Daily Reminder',
            'Get reminded to practice at your preferred time',
            Icons.alarm_outlined,
            preferences.notificationsEnabled,
            (value) => _updateNotificationPreference(context, notificationsEnabled: value),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPreferenceToggles(BuildContext context, UserPreferences preferences) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          _buildToggleTile(
            context,
            'Haptic Feedback',
            'Feel subtle vibrations for interactions',
            Icons.vibration_outlined,
            preferences.hapticFeedback,
            (value) => _updatePreference(context, hapticFeedback: value),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
          _buildToggleTile(
            context,
            'Reduce Motion',
            'Minimize animations for accessibility',
            Icons.accessibility_outlined,
            preferences.reduceMotion,
            (value) => _updatePreference(context, reduceMotion: value),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
          _buildToggleTile(
            context,
            'Auto-play Videos',
            'Automatically play video content in lessons',
            Icons.play_circle_outline_rounded,
            preferences.autoPlayVideos,
            (value) => _updatePreference(context, autoPlayVideos: value),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
          _buildToggleTile(
            context,
            'Download on WiFi Only',
            'Prevent downloads over cellular data',
            Icons.wifi_outlined,
            preferences.downloadOnWifiOnly,
            (value) => _updatePreference(context, downloadOnWifiOnly: value),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildToggleTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accentPrimarySoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.accentPrimary, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.accentPrimary,
        activeTrackColor: AppColors.accentPrimarySoft,
      ),
    );
  }

  Future<void> _updateNotificationPreference(BuildContext context,
      {bool? notificationsEnabled,
      bool? emailNotifications,
      bool? pushNotifications}) async {
    final provider = context.read<AppProvider>();
    if (provider.profile == null) return;

    final updatedPreferences = provider.profile!.preferences.copyWith(
      notificationsEnabled: notificationsEnabled ?? provider.profile!.preferences.notificationsEnabled,
      emailNotifications: emailNotifications ?? provider.profile!.preferences.emailNotifications,
      pushNotifications: pushNotifications ?? provider.profile!.preferences.pushNotifications,
    );

    final updatedProfile = provider.profile!.copyWith(preferences: updatedPreferences);
    await StorageService.saveUserProfile(updatedProfile);
    provider.initialize();
  }

  Future<void> _updatePreference(BuildContext context,
      {bool? hapticFeedback,
      bool? reduceMotion,
      bool? autoPlayVideos,
      bool? downloadOnWifiOnly}) async {
    final provider = context.read<AppProvider>();
    if (provider.profile == null) return;

    final updatedPreferences = provider.profile!.preferences.copyWith(
      hapticFeedback: hapticFeedback ?? provider.profile!.preferences.hapticFeedback,
      reduceMotion: reduceMotion ?? provider.profile!.preferences.reduceMotion,
      autoPlayVideos: autoPlayVideos ?? provider.profile!.preferences.autoPlayVideos,
      downloadOnWifiOnly: downloadOnWifiOnly ?? provider.profile!.preferences.downloadOnWifiOnly,
    );

    final updatedProfile = provider.profile!.copyWith(preferences: updatedPreferences);
    await StorageService.saveUserProfile(updatedProfile);
    provider.initialize();
  }

  Widget _buildDataPrivacyMenu(BuildContext context, AppProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          MenuRow(
            icon: Icons.download_outlined,
            title: 'Export Data',
            subtitle: 'Download your learning data and progress',
            onTap: () => _showExportDialog(context),
          ),
          const Divider(height: 1, color: AppColors.borderDefault, indent: 56, endIndent: 16),
          MenuRow(
            icon: Icons.delete_outline_rounded,
            title: 'Reset Progress',
            subtitle: 'Clear all progress, XP, and start fresh',
            onTap: () => _showResetProgressDialog(context, provider),
            isDestructive: true,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Future<void> _showExportDialog(BuildContext context) async {
    final provider = context.read<AppProvider>();
    if (provider.profile == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your data has been prepared for export. In a full implementation, this would save a JSON file to your device.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Profile: ${provider.profile!.displayName}\nXP: ${provider.profile!.xp}\nLessons Completed: ${provider.profile!.completedLessonIds.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetProgressDialog(BuildContext context, AppProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset All Progress?'),
        content: Text(
          'This will permanently delete your XP, streak, completed lessons, achievements, and course progress. This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentError,
            ),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await StorageService.clearAll();
      provider.initialize();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress reset successfully')),
        );
      }
    }
  }

  Widget _buildAboutMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          MenuRow(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: 'BrainBox v1.0.0',
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.borderDefault, indent: 56, endIndent: 16),
          MenuRow(
            icon: Icons.article_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms and conditions',
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.borderDefault, indent: 56, endIndent: 16),
          MenuRow(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Learn how we handle your data',
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.borderDefault, indent: 56, endIndent: 16),
          MenuRow(
            icon: Icons.star_outline_rounded,
            title: 'Rate the App',
            subtitle: 'Share your feedback on the store',
            onTap: () {},
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.bgPrimary,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonBox(width: 120, height: 24),
                  const SizedBox(height: 16),
                  _skeletonBox(width: double.infinity, height: 120),
                  const SizedBox(height: 24),
                  _skeletonBox(width: 120, height: 24),
                  const SizedBox(height: 16),
                  _skeletonBox(width: double.infinity, height: 180),
                  const SizedBox(height: 24),
                  _skeletonBox(width: 120, height: 24),
                  const SizedBox(height: 16),
                  _skeletonBox(width: double.infinity, height: 180),
                  const SizedBox(height: 24),
                  _skeletonBox(width: 120, height: 24),
                  const SizedBox(height: 16),
                  _skeletonBox(width: double.infinity, height: 140),
                  const SizedBox(height: 24),
                  _skeletonBox(width: 120, height: 24),
                  const SizedBox(height: 16),
                  _skeletonBox(width: double.infinity, height: 180),
                ],
              ),
            ),
          ),
        ],
      ),
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