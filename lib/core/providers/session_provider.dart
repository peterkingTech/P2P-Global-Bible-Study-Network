import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_model.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// ── Upcoming sessions ──────────────────────────────────────────────────────────

final upcomingSessionsProvider = FutureProvider<List<SessionModel>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return [];

  final rows = await SupabaseService.client
      .from(SupabaseService.sessionsTable)
      .select()
      .or('host_user_id.eq.$uid,guest_user_id.eq.$uid')
      .inFilter('status', ['scheduled', 'live'])
      .order('scheduled_at');

  return (rows as List).map((r) => SessionModel.fromMap(r)).toList();
});

// ── Past sessions ──────────────────────────────────────────────────────────────

final pastSessionsProvider = FutureProvider<List<SessionModel>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return [];

  final rows = await SupabaseService.client
      .from(SupabaseService.sessionsTable)
      .select()
      .or('host_user_id.eq.$uid,guest_user_id.eq.$uid')
      .eq('status', 'completed')
      .order('ended_at', ascending: false)
      .limit(20);

  return (rows as List).map((r) => SessionModel.fromMap(r)).toList();
});

// ── Live session state ─────────────────────────────────────────────────────────

@immutable
class LiveSessionState {
  final SessionModel? session;
  final bool isHost;
  final int elapsedSeconds;
  final bool ended;

  const LiveSessionState({
    this.session,
    this.isHost = false,
    this.elapsedSeconds = 0,
    this.ended = false,
  });

  LiveSessionState copyWith({
    SessionModel? session,
    bool? isHost,
    int? elapsedSeconds,
    bool? ended,
  }) =>
      LiveSessionState(
        session: session ?? this.session,
        isHost: isHost ?? this.isHost,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        ended: ended ?? this.ended,
      );
}

class LiveSessionNotifier extends StateNotifier<LiveSessionState> {
  LiveSessionNotifier() : super(const LiveSessionState());

  void startSession(SessionModel session, {required bool isHost}) {
    state = LiveSessionState(session: session, isHost: isHost);
  }

  void tick() {
    state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
  }

  Future<void> endSession(String reflection) async {
    final s = state.session;
    if (s == null) return;

    final field = state.isHost ? 'host_reflection' : 'guest_reflection';
    final completedField =
        state.isHost ? 'host_completed' : 'guest_completed';

    await SupabaseService.client
        .from(SupabaseService.sessionsTable)
        .update({
          field: reflection,
          completedField: true,
          'ended_at': DateTime.now().toIso8601String(),
          'duration_seconds': state.elapsedSeconds,
        })
        .eq('id', s.id);

    state = state.copyWith(ended: true);
  }

  void reset() => state = const LiveSessionState();
}

final liveSessionProvider =
    StateNotifierProvider<LiveSessionNotifier, LiveSessionState>(
  (ref) => LiveSessionNotifier(),
);
