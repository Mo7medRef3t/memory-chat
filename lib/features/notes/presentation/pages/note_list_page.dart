import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:memory_chat/features/notes/presentation/cubit/notes_state.dart';
import 'package:memory_chat/shared/widgets/loading_indicator.dart';

class NoteListPage extends StatelessWidget {
  final String workspaceId;
  final String sectionId;
  final String memoryBoxId;
  final String? memoryBoxTitle;
  final String? sectionTitle;

  const NoteListPage({
    super.key,
    required this.workspaceId,
    required this.sectionId,
    required this.memoryBoxId,
    this.memoryBoxTitle,
    this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotesCubit>()..loadNotes(memoryBoxId),
      child: _NoteListView(
        workspaceId: workspaceId,
        sectionId: sectionId,
        memoryBoxId: memoryBoxId,
        memoryBoxTitle: memoryBoxTitle,
      ),
    );
  }
}

class _NoteListView extends StatelessWidget {
  final String workspaceId;
  final String sectionId;
  final String memoryBoxId;
  final String? memoryBoxTitle;

  const _NoteListView({
    required this.workspaceId,
    required this.sectionId,
    required this.memoryBoxId,
    this.memoryBoxTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(memoryBoxTitle ?? 'Notes'),
        centerTitle: true,
        leading: BackButton(
          onPressed: () => context.goNamed(
            RouteNames.memoryBoxList,
            pathParameters: {
              'workspaceId': workspaceId,
              'sectionId': sectionId,
            },
          ),
        ),
      ),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          if (state.status == NotesStatus.loading) {
            return const LoadingIndicator();
          }

          if (state.status == NotesStatus.failure) {
            return Center(
              child: Text(state.errorMessage ?? 'Something went wrong'),
            );
          }

          if (state.notes.isEmpty) {
            return const Center(child: Text('No notes yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.notes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final note = state.notes[index];

              return Card(
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.goNamed(
                          RouteNames.noteEditor,
                          pathParameters: {
                            'workspaceId': workspaceId,
                            'sectionId': sectionId,
                            'memoryBoxId': memoryBoxId,
                          },
                          extra: {
                            'noteId': note.id,
                            'title': note.title,
                            'content': note.content,
                            'memoryBoxTitle': memoryBoxTitle,
                          },
                        );
                      } else if (value == 'delete') {
                        context.read<NotesCubit>().deleteNote(note.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  onTap: () {
                    context.goNamed(
                      RouteNames.noteEditor,
                      pathParameters: {
                        'workspaceId': workspaceId,
                        'sectionId': sectionId,
                        'memoryBoxId': memoryBoxId,
                      },
                      extra: {
                        'noteId': note.id,
                        'title': note.title,
                        'content': note.content,
                        'memoryBoxTitle': memoryBoxTitle,
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed(
            RouteNames.noteEditor,
            pathParameters: {
              'workspaceId': workspaceId,
              'sectionId': sectionId,
              'memoryBoxId': memoryBoxId,
            },
            extra: {'memoryBoxTitle': memoryBoxTitle},
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
