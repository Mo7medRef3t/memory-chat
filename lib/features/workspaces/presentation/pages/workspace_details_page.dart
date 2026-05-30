import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_state.dart';
import 'package:memory_chat/features/sections/presentation/cubit/create_section_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/widgets/sections_section.dart';
import 'package:memory_chat/features/workspaces/presentation/widgets/memory_boxes_section.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.goNamed(RouteNames.workspaceList),
        ),
        title: Text(workspaceName ?? 'Workspace'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<SectionsCubit>().loadSections(workspaceId),
            context.read<MemoryBoxesCubit>().loadMemoryBoxes(
              workspaceId: workspaceId,
              sectionId: null,
            ),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<MemoryBoxesCubit, MemoryBoxesState>(
                builder: (context, memoryState) {
                  return SectionsSection(
                    workspaceId: workspaceId,
                    workspaceName: workspaceName,
                    rootMemoryBoxes: memoryState.memoryBoxes,
                  );
                },
              ),
              const SizedBox(height: 32),
              MemoryBoxesSection(
                workspaceId: workspaceId,
                workspaceName: workspaceName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
