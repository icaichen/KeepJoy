import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keepjoy_app/config/supabase_config.dart';
import 'package:keepjoy_app/services/subscription_service.dart';

/// Authentication Service
/// Handles user authentication, registration, and session management
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Initialize Supabase
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Supabase credentials are missing. '
          'App will run in offline mode. '
          'Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define for full functionality.',
        );
      }
      // Don't throw - allow app to run without Supabase in development
      return;
    }
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to initialize Supabase: $e');
      }
      // Don't throw - allow app to continue
    }
  }

  /// Get current user
  User? get currentUser => client?.auth.currentUser;

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
  Stream<AuthState>? get authStateChanges => client?.auth.onAuthStateChange;

  /// Sign up with email and password
  Future<AuthResponse?> signUp({
    required String email,
    required String password,
  }) async {
    if (client == null) {
      throw StateError(
        'Authentication is not available. Supabase is not configured. '
        'Please configure SUPABASE_URL and SUPABASE_ANON_KEY to use authentication.',
      );
    }

    final response = await client!.auth.signUp(
      email: email,
      password: password,
    );

    // Login to RevenueCat with Supabase user ID to link subscription
    if (response.user != null) {
      try {
        await SubscriptionService.loginUser(response.user!.id);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Warning: Failed to login to RevenueCat: $e');
        }
        // Don't fail the signup if RevenueCat fails
      }
    }

    return response;
  }

  /// Sign in with email and password
  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    if (client == null) {
      throw StateError(
        'Authentication is not available. Supabase is not configured. '
        'Please configure SUPABASE_URL and SUPABASE_ANON_KEY to use authentication.',
      );
    }

    final response = await client!.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Login to RevenueCat with Supabase user ID to link subscription
    if (response.user != null) {
      try {
        await SubscriptionService.loginUser(response.user!.id);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Warning: Failed to login to RevenueCat: $e');
        }
        // Don't fail the login if RevenueCat fails
      }
    }

    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    if (client == null) return;

    try {
      if (kDebugMode) {
        debugPrint('🔐 Starting logout process...');
      }

      // Logout from RevenueCat first
      await SubscriptionService.logoutUser();

      // Sign out from Supabase with scope: 'global' to clear ALL sessions
      // This ensures the user is completely logged out and cannot access the app
      await client!.auth.signOut(scope: SignOutScope.global);

      // NOTE: We do NOT clear Hive data on logout
      // This preserves local-first architecture - data stays cached locally
      // When user logs in again, sync will merge local and cloud data

      // Force verify logout worked
      final currentUser = client!.auth.currentUser;
      if (kDebugMode) {
        debugPrint(
          '✅ User signed out successfully. Current user: $currentUser',
        );
      }

      if (currentUser != null) {
        throw StateError('Logout failed - user still authenticated');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error during sign out: $e');
      }
      // Rethrow to let caller handle
      rethrow;
    }
  }

  /// Reset password (send reset email)
  Future<void> resetPassword(String email) async {
    if (client == null) return;
    await client!.auth.resetPasswordForEmail(email);
  }

  /// Update password (when user is logged in)
  Future<UserResponse?> updatePassword(String newPassword) async {
    if (client == null) return null;
    return await client!.auth.updateUser(UserAttributes(password: newPassword));
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
