import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keepjoy_app/config/supabase_config.dart';

/// Authentication Service
/// Handles user authentication, registration, and session management
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase credentials are missing. '
        'Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
      );
    }
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Get current user ID
  String? get currentUserId => currentUser?.id;

  /// Require an authenticated user ID or throw.
  String requireUserId() {
    final id = currentUserId;
    if (id == null) {
      throw StateError('An authenticated user is required for this action.');
    }
    return id;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password (send reset email)
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Update password (when user is logged in)
  Future<UserResponse> updatePassword(String newPassword) async {
    return await client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Delete account
  Future<void> deleteAccount() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('No user logged in');

    // Sign out first
    await signOut();

    // Note: Actual user deletion needs to be handled via Supabase admin API
    // or a database function with proper security
  }
}
