// Supabase Configuration
//
// IMPORTANT:
// 1. Create a Supabase project at https://supabase.com
// 2. Copy your project URL and anon key from Project Settings > API
// 3. Pass them to Flutter via --dart-define (e.g. flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...)
// 4. Run the SQL schema from supabase/schema.sql in the Supabase SQL Editor

class SupabaseConfig {
  // Values are injected at build time via --dart-define
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
