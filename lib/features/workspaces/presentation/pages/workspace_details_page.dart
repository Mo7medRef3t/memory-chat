import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/create_section_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/create_workspace_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/pages/views/workspace_details_view.dart';

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
      key: ValueKey(workspaceId),
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
