// Supabase Configuration
//
// IMPORTANT:
// 1. Create a Supabase project at https://supabase.com
// 2. Copy your project URL and anon key from Project Settings > API
// 3. Configure via one of these methods:
//    a) Pass via --dart-define: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
//    b) Create lib/config/supabase_config_local.dart (gitignored) with your credentials for development
//       See supabase_config_local.dart.example for template
// 4. Run the SQL schema from supabase/schema.sql in the Supabase SQL Editor

// Import local config (for development convenience)
// This file is gitignored - create it from supabase_config_local.dart.example
import 'supabase_config_local.dart' as local_config;

class SupabaseConfig {
  // First try local config (for development), then fall back to --dart-define
  static String get supabaseUrl {
    // Check if local config has values (not empty)
    if (local_config._SupabaseConfigLocal.url.isNotEmpty) {
      return local_config._SupabaseConfigLocal.url;
    }
    // Fall back to environment variable
    return const String.fromEnvironment('SUPABASE_URL');
  }

  static String get supabaseAnonKey {
    // Check if local config has values (not empty)
    if (local_config._SupabaseConfigLocal.key.isNotEmpty) {
      return local_config._SupabaseConfigLocal.key;
    }
    // Fall back to environment variable
    return const String.fromEnvironment('SUPABASE_ANON_KEY');
  }

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
