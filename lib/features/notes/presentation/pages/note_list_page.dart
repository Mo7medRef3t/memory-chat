import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:memory_chat/features/notes/presentation/pages/views/note_list_view.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/create_workspace_cubit.dart';

class NoteListPage extends StatelessWidget {
  final String workspaceId;
  final String sectionId;
  final String memoryBoxId;
  final String? memoryBoxTitle;
  final bool isRootBox;

  const NoteListPage({
    super.key,
    required this.workspaceId,
    required this.sectionId,
    required this.memoryBoxId,
    this.memoryBoxTitle,
    this.isRootBox = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<NotesCubit>()..loadNotes(memoryBoxId)),
        BlocProvider(
          create: (_) => sl<SectionsCubit>()..loadSections(workspaceId),
        ),
        BlocProvider(create: (_) => sl<CreateWorkspaceCubit>()),
      ],
      child: NoteListView(
        workspaceId: workspaceId,
        sectionId: sectionId,
        memoryBoxId: memoryBoxId,
        memoryBoxTitle: memoryBoxTitle,
        isRootBox: isRootBox,
      ),
    );
  }
}
