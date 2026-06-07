import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/features/notes/domain/entities/note_entity.dart';
import 'package:memory_chat/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:memory_chat/features/notes/presentation/cubit/notes_state.dart';
import 'package:memory_chat/features/notes/presentation/widgets/note_tile.dart';
import 'package:memory_chat/shared/widgets/app_layout.dart';
import 'package:memory_chat/shared/widgets/empty_state_card.dart';
import 'package:memory_chat/shared/widgets/loading_indicator.dart';

class NoteListView extends StatelessWidget {
  final String workspaceId;
  final String sectionId;
  final String memoryBoxId;
  final String? memoryBoxTitle;
  final bool isRootBox;

  const NoteListView({super.key, 
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
      appBar: AppBar(
        title: Text(memoryBoxTitle ?? 'Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToEditor(context, noteId: null),
          ),
        ],
      ),
      child: BlocBuilder<NotesCubit, NotesState>(
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
