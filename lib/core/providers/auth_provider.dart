import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// ── Service provider ───────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Auth state stream ─────────────────────────────────────────────────────────

/// Emits [AuthState] changes from Supabase — login, logout, token refresh.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ── Current session ────────────────────────────────────────────────────────────

final currentSessionProvider = Provider<Session?>((ref) {
  return ref.watch(authServiceProvider).currentSession;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentSessionProvider) != null;
});

// ── Current user profile ───────────────────────────────────────────────────────

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authServiceProvider).currentUser?.id;
});

final currentUserProfileProvider = FutureProvider<UserModel?>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return null;
  return ref.watch(authServiceProvider).fetchProfile(uid);
});

// ── Auth notifier (sign in / sign up / sign out actions) ──────────────────────

@immutable
class AuthFormState {
  final bool isLoading;
  final String? error;
  const AuthFormState({this.isLoading = false, this.error});

  AuthFormState copyWith({bool? isLoading, String? error}) =>
      AuthFormState(isLoading: isLoading ?? this.isLoading, error: error);
}

class AuthNotifier extends StateNotifier<AuthFormState> {
  final AuthService _auth;

  AuthNotifier(this._auth) : super(const AuthFormState());

  Future<bool> signIn(String email, String password) async {
    state = const AuthFormState(isLoading: true);
    try {
      await _auth.signInWithEmail(email: email, password: password);
      state = const AuthFormState();
      return true;
    } on AuthException catch (e) {
      state = AuthFormState(error: e.message);
      return false;
    } catch (_) {
      state = const AuthFormState(error: 'An unexpected error occurred.');
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    state = const AuthFormState(isLoading: true);
    try {
      await _auth.signUpWithEmail(
          email: email, password: password, displayName: name);
      state = const AuthFormState();
      return true;
    } on AuthException catch (e) {
      state = AuthFormState(error: e.message);
      return false;
    } catch (_) {
      state = const AuthFormState(error: 'An unexpected error occurred.');
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const AuthFormState();
  }

  void clearError() => state = state.copyWith(error: null);
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthFormState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
