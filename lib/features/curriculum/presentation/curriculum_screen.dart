import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../application/curriculum_provider.dart';

class CurriculumScreen extends ConsumerWidget {
  const CurriculumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curriculums = ref.watch(curriculumsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Curriculum")),
      body: curriculums.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final curriculum = data[index];

            return ListTile(
              title: Text(curriculum.title),
              subtitle: Text(curriculum.description),
              onTap: () => context.push(
                '${Routes.curriculumModules}?id=${curriculum.id}',
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text("Error: $e"),
      ),
    );
  }
}
