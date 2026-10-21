import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';

/// Owns the optional Supabase client and keeps local-first mode explicit.
///
/// The app remains fully usable without cloud credentials. When credentials
/// are supplied via dart defines, repositories can use [client] to sync data.
class SupabaseService {
  static bool _initialized = false;

  static bool get isEnabled => SupabaseConfig.isConfigured && _initialized;

  static SupabaseClient get client {
    if (!isEnabled) {
      throw StateError('Supabase has not been configured for this build.');
    }
    return Supabase.instance.client;
  }

  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) return;

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
    _initialized = true;
  }
}
