/// Runtime configuration for the optional BrainBox cloud backend.
///
/// Keep keys out of source control. Use:
/// `flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co
///              --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key`
class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured =>
      url.startsWith('https://') && publishableKey.isNotEmpty;
}
