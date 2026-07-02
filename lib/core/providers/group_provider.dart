import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_model.dart';

/// Current user's group (if any).
final userGroupProvider = FutureProvider<GroupModel?>((ref) async {
  final supabase = Supabase.instance.client;
  final me = supabase.auth.currentUser;
  if (me == null) return null;

  final membership = await supabase
      .from('group_members')
      .select('group_id')
      .eq('user_id', me.id)
      .maybeSingle();

  if (membership == null) return null;

  final group = await supabase
      .from('groups')
      .select()
      .eq('id', membership['group_id'])
      .maybeSingle();

  return group != null ? GroupModel.fromJson(group) : null;
});

// ── Notifier ───────────────────────────────────────────────────────────────────

class GroupNotifier extends AsyncNotifier<GroupModel?> {
  @override
  Future<GroupModel?> build() async {
    final supabase = Supabase.instance.client;
    final me = supabase.auth.currentUser;
    if (me == null) return null;

    final membership = await supabase
        .from('group_members')
        .select('group_id')
        .eq('user_id', me.id)
        .maybeSingle();

    if (membership == null) return null;

    final group = await supabase
        .from('groups')
        .select()
        .eq('id', membership['group_id'])
        .maybeSingle();

    return group != null ? GroupModel.fromJson(group) : null;
  }

  Future<void> joinGroup(String code) async {
    state = const AsyncValue.loading();
    try {
      final supabase = Supabase.instance.client;
      final me = supabase.auth.currentUser!;

      final group = await supabase
          .from('groups')
          .select()
          .eq('code', code)
          .maybeSingle();

      if (group == null) {
        throw Exception('Group code "$code" not found. Please check and try again.');
      }

      await supabase.from('group_members').upsert({
        'group_id': group['id'],
        'user_id': me.id,
        'joined_at': DateTime.now().toIso8601String(),
      });

      state = AsyncValue.data(GroupModel.fromJson(group));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> createGroup(String name) async {
    state = const AsyncValue.loading();
    try {
      final supabase = Supabase.instance.client;
      final me = supabase.auth.currentUser!;
      final code = _generateGroupCode();

      final group = await supabase
          .from('groups')
          .insert({
            'name': name,
            'code': code,
            'admin_id': me.id,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      await supabase.from('group_members').insert({
        'group_id': group['id'],
        'user_id': me.id,
        'joined_at': DateTime.now().toIso8601String(),
      });

      state = AsyncValue.data(GroupModel.fromJson(group));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  String _generateGroupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final seed = DateTime.now().millisecondsSinceEpoch;
    var result = '';
    var s = seed;
    for (var i = 0; i < 6; i++) {
      result += chars[s % chars.length];
      s ~/= 3;
      s += seed ~/ (i + 2);
    }
    return result;
  }
}

final groupNotifierProvider =
    AsyncNotifierProvider<GroupNotifier, GroupModel?>(GroupNotifier.new);
