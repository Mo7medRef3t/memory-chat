import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';

class WorkspaceListPage extends StatelessWidget {
  const WorkspaceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workspaces = ['Mobile Team', 'Design Squad', 'Study Group'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspaces'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: workspaces.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final workspace = workspaces[index];
          return Card(
            child: ListTile(
              title: Text(workspace),
              subtitle: const Text('Workspace placeholder'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
