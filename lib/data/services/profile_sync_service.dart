import '../models/user_models.dart';
import 'supabase_service.dart';

/// Best-effort cloud mirror for the local learner profile.
/// Local persistence remains the source of truth when the device is offline.
class ProfileSyncService {
  static Future<void> sync(UserProfile profile) async {
    if (!SupabaseService.isEnabled) return;
    final user = SupabaseService.client.auth.currentUser;
    if (user == null || user.id != profile.id) return;

    try {
      await SupabaseService.client.from('profiles').upsert({
        'id': user.id,
        'display_name': profile.displayName,
        'bio': profile.bio,
        'avatar_url': profile.photoUrl,
        'xp': profile.xp,
        'total_xp': profile.totalXp,
        'current_streak': profile.stats.currentStreakDays,
        'longest_streak': profile.stats.longestStreakDays,
        'last_lesson_completed_at': profile.lastLessonCompletedAt
            ?.toUtc()
            .toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {
      // Sync is retried on the next profile update; local progress is safe.
    }
  }
}
