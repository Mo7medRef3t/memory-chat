import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/create_workspace_cubit.dart';
import 'package:memory_chat/shared/dialogs/create_workspace_dialog.dart';
import 'package:memory_chat/shared/widgets/app_layout.dart';

class WorkspaceListPage extends StatelessWidget {
  const WorkspaceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateWorkspaceCubit>(),
      child: const _WorkspaceListView(),
    );
  }
}

class _WorkspaceListView extends StatelessWidget {
  const _WorkspaceListView();

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState.user?.id ?? '';

    return AppLayout(
      onCreateWorkspace: () => _showCreateWorkspaceDialog(context, currentUserId),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspaces,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Select a workspace to get started',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Or create a new workspace from the sidebar',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreateWorkspaceDialog(context, currentUserId),
              icon: const Icon(Icons.add),
              label: const Text('Create Workspace'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateWorkspaceDialog(BuildContext context, String currentUserId) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CreateWorkspaceCubit>(),
        child: CreateWorkspaceDialog(currentUserId: currentUserId),
      ),
    );
  }
}