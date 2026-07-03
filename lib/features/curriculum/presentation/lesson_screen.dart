import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../application/curriculum_provider.dart';

class LessonScreen extends ConsumerWidget {
  final String moduleId;

  const LessonScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(lessonsProvider(moduleId));

    return Scaffold(
      appBar: AppBar(title: const Text("Lessons")),
      body: lessons.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final lesson = data[index];

            return ListTile(
              title: Text(lesson.title),
              subtitle: Text(lesson.summary),
              onTap: () => context.push(
                '${Routes.curriculumReader}?id=${lesson.id}',
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text("$e"),
      ),
    );
  }
}
