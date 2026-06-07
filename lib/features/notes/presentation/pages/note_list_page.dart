import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/features/notes/domain/entities/note_entity.dart';
import 'package:memory_chat/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:memory_chat/features/notes/presentation/cubit/notes_state.dart';
import 'package:memory_chat/features/notes/presentation/widgets/note_tile.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/create_workspace_cubit.dart';
import 'package:memory_chat/shared/widgets/app_layout.dart';
import 'package:memory_chat/shared/widgets/empty_state_card.dart';
import 'package:memory_chat/shared/widgets/loading_indicator.dart';

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
      child: _NoteListView(
        workspaceId: workspaceId,
        sectionId: sectionId,
        memoryBoxId: memoryBoxId,
        memoryBoxTitle: memoryBoxTitle,
        isRootBox: isRootBox,
      ),
    );
  }
}

class _NoteListView extends StatelessWidget {
  final String workspaceId;
  final String sectionId;
  final String memoryBoxId;
  final String? memoryBoxTitle;
  final bool isRootBox;

  const _NoteListView({
    required this.workspaceId,
    required this.sectionId,
    required this.memoryBoxId,
    this.memoryBoxTitle,
    this.isRootBox = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      selectedWorkspaceId: workspaceId,
      selectedSectionId: isRootBox ? null : sectionId,
      child: Scaffold(
        appBar: AppBar(
          title: Text(memoryBoxTitle ?? 'Notes'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToEditor(context, noteId: null),
            ),
          ],
        ),
        body: BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) {
            if (state.status == NotesStatus.loading && state.notes.isEmpty) {
              return const LoadingIndicator();
            }

            if (state.notes.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 100),
                  EmptyStateCard(
                    icon: Icons.note_alt_outlined,
                    message: 'No notes yet',
                    actionLabel: 'Create your first note',
                    onAction: () => _navigateToEditor(context, noteId: null),
                  ),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotesCubit>().loadNotes(memoryBoxId);
                return Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.notes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final note = state.notes[index];
                  return NoteTile(
                    note: note,
                    onEdit: () => _navigateToEditor(context, noteId: note.id),
                    onDelete: () =>
                        context.read<NotesCubit>().deleteNote(note.id),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToEditor(BuildContext context, {String? noteId}) {
    NoteEntity? existingNote;
    if (noteId != null) {
      try {
        existingNote = context.read<NotesCubit>().state.notes.firstWhere(
          (n) => n.id == noteId,
        );
      } catch (_) {
        existingNote = null;
      }
    }

    if (isRootBox) {
      context.goNamed(
        RouteNames.rootNoteEditor,
        pathParameters: {
          'workspaceId': workspaceId,
          'memoryBoxId': memoryBoxId,
        },
        extra: {
          'noteId': noteId,
          'title': existingNote?.title,
          'content': existingNote?.content,
          'memoryBoxTitle': memoryBoxTitle,
          'isRootBox': true,
        },
      );
    } else {
      context.goNamed(
        RouteNames.noteEditor,
        pathParameters: {
          'workspaceId': workspaceId,
          'sectionId': sectionId,
          'memoryBoxId': memoryBoxId,
        },
        extra: {
          'noteId': noteId,
          'title': existingNote?.title,
          'content': existingNote?.content,
          'memoryBoxTitle': memoryBoxTitle,
          'isRootBox': false,
        },
      );
    }
  }
}
