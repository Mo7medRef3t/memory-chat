import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_state.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_state.dart';
import 'package:memory_chat/features/sections/presentation/cubit/create_section_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/create_section_state.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/create_workspace_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/widgets/memory_boxes_section.dart';
import 'package:memory_chat/features/workspaces/presentation/widgets/sections_section.dart';
import 'package:memory_chat/shared/dialogs/create_memory_box_dialog.dart';
import 'package:memory_chat/shared/dialogs/create_section_dialog.dart';
import 'package:memory_chat/shared/dialogs/create_workspace_dialog.dart';
import 'package:memory_chat/shared/widgets/app_layout.dart';

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
      child: WorkspaceDetailsView(
        workspaceId: workspaceId,
        workspaceName: workspaceName,
      ),
    );
  }
}

class WorkspaceDetailsView extends StatelessWidget {
  final String workspaceId;
  final String? workspaceName;

  const WorkspaceDetailsView({
    super.key,
    required this.workspaceId,
    this.workspaceName,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState.user?.id ?? '';

    return AppLayout(
      selectedWorkspaceId: workspaceId,
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
      onCreateWorkspace: () =>
          _showCreateWorkspaceDialog(context, currentUserId),
      onCreateSection: () => _showCreateSectionDialog(context),
      child: BlocListener<CreateSectionCubit, CreateSectionState>(
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
            builder: (context, memoryState) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<SectionsCubit>().loadSections(workspaceId);
                  context.read<MemoryBoxesCubit>().loadMemoryBoxes(
                    workspaceId: workspaceId,
                    sectionId: null,
                  );
                  return Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionsSection(
                        workspaceId: workspaceId,
                        workspaceName: workspaceName,
                        rootMemoryBoxes: memoryState.memoryBoxes,
                      ),
                      const SizedBox(height: 32),
                      MemoryBoxesSection(
                        workspaceId: workspaceId,
                        workspaceName: workspaceName,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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

  void _showCreateSectionDialog(BuildContext context) {
    showCreateSectionDialog(context, workspaceId);
  }
}
