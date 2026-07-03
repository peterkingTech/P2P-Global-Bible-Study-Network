import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../application/curriculum_provider.dart';

class ModuleScreen extends ConsumerWidget {
  final String curriculumId;

  const ModuleScreen({super.key, required this.curriculumId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesProvider(curriculumId));

    return Scaffold(
      appBar: AppBar(title: const Text("Modules")),
      body: modules.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final module = data[index];

            return ListTile(
              title: Text(module.title),
              subtitle: Text(module.description),
              onTap: () => context.push(
                '${Routes.curriculumLessons}?id=${module.id}',
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
