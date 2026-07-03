import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/curriculum.dart';
import '../domain/module.dart';
import '../domain/lesson.dart';
import '../domain/lesson_block.dart';

class CurriculumRepository {
  final SupabaseClient _client;

  CurriculumRepository(this._client);

  // CURRICULUMS
  Future<List<Curriculum>> getCurriculums() async {
    final res = await _client.from('p2p_curriculums').select();
    return res.map((e) => Curriculum.fromJson(e)).toList();
  }

  // MODULES
  Future<List<Module>> getModules(String curriculumId) async {
    final res = await _client
        .from('p2p_modules')
        .select()
        .eq('curriculum_id', curriculumId);

    return res.map((e) => Module.fromJson(e)).toList();
  }

  // LESSONS
  Future<List<Lesson>> getLessons(String moduleId) async {
    final res = await _client
        .from('p2p_lessons')
        .select()
        .eq('module_id', moduleId);

    return res.map((e) => Lesson.fromJson(e)).toList();
  }

  // LESSON BLOCKS
  Future<List<LessonBlock>> getLessonBlocks(String lessonId) async {
    final res = await _client
        .from('p2p_lesson_blocks')
        .select()
        .eq('lesson_id', lessonId)
        .order('order_index');

    return res.map((e) => LessonBlock.fromJson(e)).toList();
  }

  // PROGRESS
  Future<void> markLessonComplete(String userId, String lessonId) async {
    await _client.from('p2p_lesson_progress').upsert({
      'user_id': userId,
      'lesson_id': lessonId,
      'completed': true,
      'progress_percent': 100,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateLessonProgress({
    required String userId,
    required String lessonId,
    required int percent,
  }) async {
    await _client.from('p2p_lesson_progress').upsert({
      'user_id': userId,
      'lesson_id': lessonId,
      'progress_percent': percent,
      'completed': percent >= 100,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> getLessonProgress(String userId, String lessonId) async {
    final res = await _client
        .from('p2p_lesson_progress')
        .select('progress_percent')
        .eq('user_id', userId)
        .eq('lesson_id', lessonId)
        .maybeSingle();

    return (res?['progress_percent'] as int?) ?? 0;
  }
}
