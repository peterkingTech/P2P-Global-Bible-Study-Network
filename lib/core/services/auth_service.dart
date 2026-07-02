import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

/// Handles all authentication operations via Supabase Auth.
class AuthService {
  final SupabaseClient _client;

  AuthService({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  // ── Current session ────────────────────────────────────────────────────────

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentSession != null;

  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // ── Sign up ────────────────────────────────────────────────────────────────

  /// Creates a new account with email + password.
  /// On success, inserts a skeleton [UserModel] into the users table.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Step 1: Create the Supabase Auth account. This is the authoritative step —
    // if it fails we throw so the caller can show the real AuthException message.
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );

    // Step 2: Seed a profile row. This is best-effort — the auth account already
    // exists at this point, so a DB failure here must NOT block registration.
    // The profile can be created later on first login via an upsert or trigger.
    if (response.user != null) {
      try {
        await _client.from(SupabaseService.usersTable).upsert({
          'id': response.user!.id,
          'email': email,
          'display_name': displayName,
          'created_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id');
      } catch (_) {
        // Profile seeding failed (table not yet created, RLS, etc.).
        // Auth account exists — proceed. Profile setup screen will handle it.
      }
    }

    return response;
  }

  // ── Sign in ────────────────────────────────────────────────────────────────

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _client.auth.signInWithPassword(email: email, password: password);

  Future<void> signInWithMagicLink(String email) =>
      _client.auth.signInWithOtp(email: email);

  Future<bool> signInWithGoogle() =>
      _client.auth.signInWithOAuth(OAuthProvider.google);

  // ── Sign out ───────────────────────────────────────────────────────────────

  Future<void> signOut() => _client.auth.signOut();

  // ── Password reset ─────────────────────────────────────────────────────────

  Future<void> requestPasswordReset(String email) =>
      _client.auth.resetPasswordForEmail(email);

  Future<UserResponse> updatePassword(String newPassword) =>
      _client.auth.updateUser(UserAttributes(password: newPassword));

  // ── Profile ────────────────────────────────────────────────────────────────

  /// Fetches the full [UserModel] for [userId] from the users table.
  Future<UserModel?> fetchProfile(String userId) async {
    final data = await _client
        .from(SupabaseService.usersTable)
        .select()
        .eq('id', userId)
        .maybeSingle();

    return data == null ? null : UserModel.fromMap(data);
  }

  /// Updates mutable profile fields for the authenticated user.
  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> fields,
  ) =>
      _client
          .from(SupabaseService.usersTable)
          .update(fields)
          .eq('id', userId);
}
