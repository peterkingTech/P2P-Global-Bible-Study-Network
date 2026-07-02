import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tree_model.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// ── Current user's tree ────────────────────────────────────────────────────────

final myTreeProvider = FutureProvider<TreeModel?>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return null;

  final data = await SupabaseService.client
      .from(SupabaseService.treesTable)
      .select()
      .eq('user_id', uid)
      .maybeSingle();

  return data == null ? null : TreeModel.fromMap(data);
});

// ── Another user's tree ────────────────────────────────────────────────────────

final userTreeProvider =
    FutureProvider.family<TreeModel?, String>((ref, userId) async {
  final data = await SupabaseService.client
      .from(SupabaseService.treesTable)
      .select()
      .eq('user_id', userId)
      .maybeSingle();

  return data == null ? null : TreeModel.fromMap(data);
});

// ── Disciple trees (my mentees) ────────────────────────────────────────────────

final discipleTreesProvider = FutureProvider<List<TreeModel>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return [];

  // Fetch user IDs of all disciples whose mentor_id == uid
  final disciples = await SupabaseService.client
      .from(SupabaseService.usersTable)
      .select('id')
      .eq('mentor_id', uid);

  final ids = (disciples as List).map((d) => d['id'] as String).toList();
  if (ids.isEmpty) return [];

  final rows = await SupabaseService.client
      .from(SupabaseService.treesTable)
      .select()
      .inFilter('user_id', ids);

  return (rows as List).map((r) => TreeModel.fromMap(r)).toList();
});

// ── Tree notifier (level-up, increment stats) ──────────────────────────────────

class TreeNotifier extends StateNotifier<AsyncValue<TreeModel?>> {
  final String userId;

  TreeNotifier(this.userId) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final data = await SupabaseService.client
          .from(SupabaseService.treesTable)
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      state = AsyncValue.data(data == null ? null : TreeModel.fromMap(data));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Increments [studiesCompleted] by 1 and recalculates level.
  Future<void> recordStudy() async {
    final tree = state.valueOrNull;
    if (tree == null) return;
    final newCount = tree.studiesCompleted + 1;
    await SupabaseService.client
        .from(SupabaseService.treesTable)
        .update({'studies_completed': newCount, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', tree.id);
    await _load();
  }
}

final treeNotifierProvider =
    StateNotifierProvider<TreeNotifier, AsyncValue<TreeModel?>>((ref) {
  final uid = ref.watch(currentUserIdProvider) ?? '';
  return TreeNotifier(uid);
});
