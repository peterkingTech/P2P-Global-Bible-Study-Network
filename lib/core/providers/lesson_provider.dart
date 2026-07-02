import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_model.dart';
import '../models/module_model.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// ── Modules ────────────────────────────────────────────────────────────────────

final modulesProvider = FutureProvider<List<ModuleModel>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);

  // Base module list
  final rows = await SupabaseService.client
      .from(SupabaseService.modulesTable)
      .select()
      .order('order');

  if (uid == null) {
    return (rows as List).map((r) => ModuleModel.fromMap(r)).toList();
  }

  // Join with progress counts via RPC for efficiency
  final progress = await SupabaseService.client.rpc(
    'module_progress_for_user',
    params: {'p_user_id': uid},
  ) as List<dynamic>;

  final progressMap = {
    for (final p in progress)
      p['module_id'] as String: p['completed'] as int,
  };

  return (rows as List).map((r) {
    final id = r['id'] as String;
    return ModuleModel.fromMap({
      ...r as Map<String, dynamic>,
      'completed_lessons': progressMap[id] ?? 0,
      'is_unlocked': true, // TODO: check against user's tree level
    });
  }).toList();
});

// ── Lessons within a module ────────────────────────────────────────────────────

final lessonsForModuleProvider =
    FutureProvider.family<List<LessonModel>, String>((ref, moduleId) async {
  final uid = ref.watch(currentUserIdProvider);

  final rows = await SupabaseService.client
      .from(SupabaseService.lessonsTable)
      .select()
      .eq('module_id', moduleId)
      .order('order');

  if (uid == null) {
    return (rows as List).map((r) => LessonModel.fromMap(r)).toList();
  }

  final completed = await SupabaseService.client
      .from(SupabaseService.progressTable)
      .select('lesson_id, completed_at')
      .eq('user_id', uid)
      .eq('module_id', moduleId);

  final completedMap = {
    for (final p in completed as List)
      p['lesson_id'] as String: p['completed_at'] as String,
  };

  return (rows as List).map((r) {
    final id = r['id'] as String;
    final completedAt = completedMap[id];
    return LessonModel.fromMap({
      ...r as Map<String, dynamic>,
      'is_completed': completedAt != null,
      'completed_at': completedAt,
    });
  }).toList();
});

// ── Single lesson ──────────────────────────────────────────────────────────────

final lessonProvider =
    FutureProvider.family<LessonModel?, String>((ref, lessonId) async {
  final data = await SupabaseService.client
      .from(SupabaseService.lessonsTable)
      .select()
      .eq('id', lessonId)
      .maybeSingle();

  return data == null ? null : LessonModel.fromMap(data);
});

// ── Mark lesson complete ───────────────────────────────────────────────────────

class LessonProgressNotifier extends StateNotifier<void> {
  final Ref _ref;
  LessonProgressNotifier(this._ref) : super(null);

  Future<void> markComplete(String lessonId, String moduleId) async {
    final uid = _ref.read(currentUserIdProvider);
    if (uid == null) return;

    await SupabaseService.client.from(SupabaseService.progressTable).upsert({
      'user_id': uid,
      'lesson_id': lessonId,
      'module_id': moduleId,
      'completed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,lesson_id');

    // Invalidate caches
    _ref.invalidate(lessonsForModuleProvider(moduleId));
    _ref.invalidate(modulesProvider);
  }
}

final lessonProgressNotifierProvider =
    StateNotifierProvider<LessonProgressNotifier, void>(
  (ref) => LessonProgressNotifier(ref),
);
