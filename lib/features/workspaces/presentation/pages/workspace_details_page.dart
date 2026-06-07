import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/app/theme/app_colors.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_state.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_state.dart';
import 'package:memory_chat/features/sections/presentation/cubit/create_section_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/create_section_state.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/create_workspace_cubit.dart';
import 'package:memory_chat/shared/dialogs/create_memory_box_dialog.dart';
import 'package:memory_chat/shared/dialogs/create_section_dialog.dart';
import 'package:memory_chat/shared/dialogs/create_workspace_dialog.dart';
import 'package:memory_chat/shared/widgets/app_layout.dart';
import 'package:memory_chat/shared/widgets/loading_indicator.dart';

class WorkspaceDetailsPage extends StatelessWidget {
  final String workspaceId;
  final String? workspaceName;

  const WorkspaceDetailsPage({
    super.key,
    required this.workspaceId,
    this.workspaceName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<SectionsCubit>()..loadSections(workspaceId),
        ),
        BlocProvider(
          create: (_) =>
              sl<MemoryBoxesCubit>()
                ..loadMemoryBoxes(workspaceId: workspaceId, sectionId: null),
        ),
        BlocProvider(create: (_) => sl<CreateSectionCubit>()),
        BlocProvider(create: (_) => sl<CreateMemoryBoxCubit>()),
        BlocProvider(create: (_) => sl<CreateWorkspaceCubit>()),
      ],
      child: _WorkspaceDetailsView(
        workspaceId: workspaceId,
        workspaceName: workspaceName,
      ),
    );
  }
}

class _WorkspaceDetailsView extends StatelessWidget {
  final String workspaceId;
  final String? workspaceName;

  const _WorkspaceDetailsView({required this.workspaceId, this.workspaceName});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState.user?.id ?? '';

    return AppLayout(
      selectedWorkspaceId: workspaceId,
      onCreateWorkspace: () =>
          _showCreateWorkspaceDialog(context, currentUserId),
      onCreateSection: () => _showCreateSectionDialog(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(workspaceName ?? 'Workspace'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              tooltip: 'Create Memory Box',
              onPressed: () => showCreateMemoryBoxDialog(
                context,
                workspaceId: workspaceId,
                sectionId: null,
              ),
            ),
          ],
        ),
        body: BlocListener<CreateSectionCubit, CreateSectionState>(
          listener: (context, state) {
            if (state.status == CreateSectionStatus.success) {
              context.read<SectionsCubit>().loadSections(workspaceId);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Section created')));
            }
          },
          child: BlocListener<CreateMemoryBoxCubit, CreateMemoryBoxState>(
            listener: (context, state) {
              if (state.status == CreateMemoryBoxStatus.success) {
                context.read<MemoryBoxesCubit>().loadMemoryBoxes(
                  workspaceId: workspaceId,
                  sectionId: null,
                );
              }
            },
            child: BlocBuilder<MemoryBoxesCubit, MemoryBoxesState>(
              builder: (context, state) {
                if (state.status == MemoryBoxesStatus.loading &&
                    state.memoryBoxes.isEmpty) {
                  return const LoadingIndicator();
                }

                if (state.memoryBoxes.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<MemoryBoxesCubit>().loadMemoryBoxes(
                      workspaceId: workspaceId,
                      sectionId: null,
                    );
                    return Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.memoryBoxes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final box = state.memoryBoxes[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.inventory_2_outlined),
                          title: Text(box.title),
                          subtitle: Text(box.description ?? 'No description'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.goNamed(
                              RouteNames.rootNoteList,
                              pathParameters: {
                                'workspaceId': workspaceId,
                                'memoryBoxId': box.id,
                              },
                              extra: {'memoryBoxTitle': box.title},
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.darkTextMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            'No memory boxes yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first memory box to get started',
            style: TextStyle(color: AppColors.darkTextSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => showCreateMemoryBoxDialog(
              context,
              workspaceId: workspaceId,
              sectionId: null,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create Memory Box'),
          ),
        ],
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

  void _showCreateSectionDialog(BuildContext context) {
    showCreateSectionDialog(context, workspaceId);
  }
}
