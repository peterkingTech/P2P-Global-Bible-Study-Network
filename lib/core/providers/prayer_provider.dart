import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prayer_model.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// ── Prayer wall (paginated) ────────────────────────────────────────────────────

final prayerWallProvider = FutureProvider<List<PrayerModel>>((ref) async {
  final rows = await SupabaseService.client
      .from(SupabaseService.prayersTable)
      .select()
      .eq('is_answered', false)
      .order('created_at', ascending: false)
      .limit(30);

  return (rows as List).map((r) => PrayerModel.fromMap(r)).toList();
});

// ── My prayer requests ─────────────────────────────────────────────────────────

final myPrayersProvider = FutureProvider<List<PrayerModel>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return [];

  final rows = await SupabaseService.client
      .from(SupabaseService.prayersTable)
      .select()
      .eq('user_id', uid)
      .order('created_at', ascending: false);

  return (rows as List).map((r) => PrayerModel.fromMap(r)).toList();
});

// ── Realtime prayer wall stream ────────────────────────────────────────────────

final realtimePrayerWallProvider =
    StreamProvider<List<PrayerModel>>((ref) async* {
  // Initial fetch
  final initial = await ref.read(prayerWallProvider.future);
  yield initial;

  // Subscribe to new inserts
  final channel = SupabaseService.client
      .channel(SupabaseService.prayerChannel)
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: SupabaseService.prayersTable,
        callback: (_) => ref.invalidate(prayerWallProvider),
      )
    ..subscribe();

  ref.onDispose(() => channel.unsubscribe());
});

// ── Prayer actions ─────────────────────────────────────────────────────────────

class PrayerNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  PrayerNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> submitRequest({
    required String request,
    required PrayerCategory category,
    bool anonymous = false,
  }) async {
    final uid = _ref.read(currentUserIdProvider);
    if (uid == null) return;

    state = const AsyncValue.loading();
    try {
      await SupabaseService.client.from(SupabaseService.prayersTable).insert({
        'user_id': uid,
        'request': request,
        'category': category.name,
        'is_anonymous': anonymous,
        'created_at': DateTime.now().toIso8601String(),
      });

      _ref.invalidate(prayerWallProvider);
      _ref.invalidate(myPrayersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markPrayed(String prayerId) async {
    final uid = _ref.read(currentUserIdProvider);
    if (uid == null) return;

    await SupabaseService.client.from(SupabaseService.prayedTable).upsert(
      {'user_id': uid, 'prayer_id': prayerId},
      onConflict: 'user_id,prayer_id',
    );

    // Increment prayed_count
    await SupabaseService.client.rpc(
      'increment_prayed_count',
      params: {'p_prayer_id': prayerId},
    );

    _ref.invalidate(prayerWallProvider);
  }

  Future<void> markAnswered(String prayerId) async {
    await SupabaseService.client
        .from(SupabaseService.prayersTable)
        .update({
          'is_answered': true,
          'answered_at': DateTime.now().toIso8601String(),
        })
        .eq('id', prayerId);

    _ref.invalidate(myPrayersProvider);
    _ref.invalidate(prayerWallProvider);
  }
}

final prayerNotifierProvider =
    StateNotifierProvider<PrayerNotifier, AsyncValue<void>>(
  (ref) => PrayerNotifier(ref),
);
