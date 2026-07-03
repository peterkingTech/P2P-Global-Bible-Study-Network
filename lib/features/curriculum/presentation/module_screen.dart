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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(module.title),
                  subtitle: Text(module.description),
                  onTap: () => context.push(
                    '${Routes.curriculumLessons}?id=${module.id}',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  // placeholder value — will be connected to Supabase
                  // once completed-lessons count is available
                  child: LinearProgressIndicator(value: 0.0),
                ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text("$e"),
      ),
    );
  }
}
