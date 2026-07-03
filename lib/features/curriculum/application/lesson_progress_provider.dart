import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── In-memory scroll-progress cache ──────────────────────────────────────────

final lessonProgressProvider =
    StateNotifierProvider<LessonProgressNotifier, Map<String, int>>(
  (ref) => LessonProgressNotifier(),
);

class LessonProgressNotifier extends StateNotifier<Map<String, int>> {
  LessonProgressNotifier() : super({});

  void setProgress(String lessonId, int percent) {
    state = {
      ...state,
      lessonId: percent,
    };
  }

  int getProgress(String lessonId) {
    return state[lessonId] ?? 0;
  }
}

// ── Resume last lesson (global — most recently touched by this user) ──────────
//
// Named "Last" to make clear this is not scoped to a module.
// Use it to show a "Continue where you left off" card on the home/learn tab.

final resumeLastLessonProvider = FutureProvider<String?>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) return null;

  final res = await Supabase.instance.client
      .from('p2p_lesson_progress')
      .select('lesson_id')
      .eq('user_id', userId)
      .order('updated_at', ascending: false)
      .limit(1)
      .maybeSingle();

  return res?['lesson_id'] as String?;
});
