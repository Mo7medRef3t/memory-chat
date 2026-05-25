import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/core/utils/validators.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/create_workspace_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/create_workspace_state.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/workspace_list_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/workspace_list_state.dart';
import 'package:memory_chat/shared/widgets/app_text_field.dart';
import 'package:memory_chat/shared/widgets/loading_indicator.dart';
import 'package:memory_chat/shared/widgets/primary_button.dart';

class WorkspaceListPage extends StatelessWidget {
  const WorkspaceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState.user?.id;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<WorkspaceListCubit>()..loadWorkspaces(currentUserId ?? ''),
        ),
        BlocProvider(create: (_) => sl<CreateWorkspaceCubit>()),
      ],
      child: _WorkspaceListView(currentUserId: currentUserId ?? ''),
    );
  }
}

class _WorkspaceListView extends StatelessWidget {
  final String currentUserId;

  const _WorkspaceListView({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateWorkspaceCubit, CreateWorkspaceState>(
      listener: (context, state) {
        if (state.status == CreateWorkspaceStatus.success) {
          context.read<WorkspaceListCubit>().loadWorkspaces(currentUserId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workspace created successfully')),
          );
        }

        if (state.status == CreateWorkspaceStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
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
        body: BlocBuilder<WorkspaceListCubit, WorkspaceListState>(
          builder: (context, state) {
            if (state.status == WorkspaceListStatus.loading) {
              return const LoadingIndicator();
            }

            if (state.status == WorkspaceListStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? 'Something went wrong'),
              );
            }

            if (state.workspaces.isEmpty) {
              return const Center(child: Text('No workspaces yet'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.workspaces.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final workspace = state.workspaces[index];

                return Card(
                  child: ListTile(
                    title: Text(workspace.name),
                    subtitle: Text(workspace.description ?? 'No description'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showCreateWorkspaceDialog(context, currentUserId);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showCreateWorkspaceDialog(BuildContext context, String currentUserId) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<CreateWorkspaceCubit>(),
          child: AlertDialog(
            title: const Text('Create Workspace'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: nameController,
                    hintText: 'Workspace name',
                    validator: (value) =>
                        Validators.requiredField(value, fieldName: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: descriptionController,
                    hintText: 'Description (optional)',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              BlocBuilder<CreateWorkspaceCubit, CreateWorkspaceState>(
                builder: (context, state) {
                  return SizedBox(
                    width: 120,
                    child: PrimaryButton(
                      text: 'Create',
                      isLoading: state.status == CreateWorkspaceStatus.loading,
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await context
                              .read<CreateWorkspaceCubit>()
                              .createWorkspace(
                                name: nameController.text,
                                description: descriptionController.text,
                                currentUserId: currentUserId,
                              );

                          if (context.mounted &&
                              context
                                      .read<CreateWorkspaceCubit>()
                                      .state
                                      .status ==
                                  CreateWorkspaceStatus.success) {
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
