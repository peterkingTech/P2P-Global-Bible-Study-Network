import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/curriculum_repository.dart';
import '../domain/curriculum.dart';
import '../domain/module.dart';
import '../domain/lesson.dart';
import '../domain/lesson_block.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final curriculumRepositoryProvider = Provider(
  (ref) => CurriculumRepository(Supabase.instance.client),
);

// CURRICULUM LIST
final curriculumsProvider = FutureProvider<List<Curriculum>>((ref) async {
  return ref.watch(curriculumRepositoryProvider).getCurriculums();
});

// MODULES
final modulesProvider = FutureProvider.family<List<Module>, String>(
  (ref, curriculumId) {
    return ref
        .watch(curriculumRepositoryProvider)
        .getModules(curriculumId);
  },
);

// LESSONS
final lessonsProvider = FutureProvider.family<List<Lesson>, String>(
  (ref, moduleId) {
    return ref
        .watch(curriculumRepositoryProvider)
        .getLessons(moduleId);
  },
);

// LESSON BLOCKS
final lessonBlocksProvider =
    FutureProvider.family<List<LessonBlock>, String>(
  (ref, lessonId) {
    return ref
        .watch(curriculumRepositoryProvider)
        .getLessonBlocks(lessonId);
  },
);
