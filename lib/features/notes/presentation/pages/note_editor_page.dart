import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:memory_chat/features/notes/presentation/cubit/note_editor_cubit.dart';
import 'package:memory_chat/features/notes/presentation/cubit/note_editor_state.dart';
import 'package:memory_chat/shared/widgets/app_text_field.dart';
import 'package:memory_chat/shared/widgets/primary_button.dart';

class NoteEditorPage extends StatefulWidget {
  final String workspaceId;
  final String sectionId;
  final String memoryBoxId;
  final String? noteId;
  final String? initialTitle;
  final String? initialContent;
  final String? memoryBoxTitle;
  final bool isRootBox;

  const NoteEditorPage({
    super.key,
    required this.workspaceId,
    required this.sectionId,
    required this.memoryBoxId,
    this.noteId,
    this.initialTitle,
    this.initialContent,
    this.memoryBoxTitle,
    this.isRootBox = false,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool get isEditMode => widget.noteId != null;
  bool get _isDirty =>
      _titleController.text != (widget.initialTitle ?? '') ||
      _contentController.text != (widget.initialContent ?? '');

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController = TextEditingController(
      text: widget.initialContent ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return shouldDiscard ?? false;
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authorId = context.read<AuthCubit>().state.user?.id;
    if (authorId == null) return;

    await context.read<NoteEditorCubit>().saveNote(
      noteId: widget.noteId,
      memoryBoxId: widget.memoryBoxId,
      authorId: authorId,
      title: _titleController.text,
      content: _contentController.text,
    );

    if (context.mounted) {
      final state = context.read<NoteEditorCubit>().state;
      if (state.status == NoteEditorStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditMode ? 'Note updated' : 'Note created')),
        );

        // ✅ ارجع للـ List الصح حسب الـ Type
        if (widget.isRootBox) {
          context.goNamed(
            RouteNames.rootNoteList,
            pathParameters: {
              'workspaceId': widget.workspaceId,
              'memoryBoxId': widget.memoryBoxId,
            },
            extra: {'memoryBoxTitle': widget.memoryBoxTitle},
          );
        } else {
          context.goNamed(
            RouteNames.noteList,
            pathParameters: {
              'workspaceId': widget.workspaceId,
              'sectionId': widget.sectionId,
              'memoryBoxId': widget.memoryBoxId,
            },
            extra: {'memoryBoxTitle': widget.memoryBoxTitle},
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NoteEditorCubit>(),
      child: BlocListener<NoteEditorCubit, NoteEditorState>(
        listener: (context, state) {
          if (state.status == NoteEditorStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: PopScope(
          canPop: !_isDirty,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await _onWillPop();
            if (shouldPop && context.mounted) {
              Navigator.pop(context);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(isEditMode ? 'Edit Note' : 'New Note'),
              leading: BackButton(
                onPressed: () async {
                  final shouldPop = await _onWillPop();
                  if (shouldPop && context.mounted) {
                    if (widget.isRootBox) {
                      context.goNamed(
                        RouteNames.rootNoteList,
                        pathParameters: {
                          'workspaceId': widget.workspaceId,
                          'memoryBoxId': widget.memoryBoxId,
                        },
                        extra: {'memoryBoxTitle': widget.memoryBoxTitle},
                      );
                    } else {
                      context.goNamed(
                        RouteNames.noteList,
                        pathParameters: {
                          'workspaceId': widget.workspaceId,
                          'sectionId': widget.sectionId,
                          'memoryBoxId': widget.memoryBoxId,
                        },
                        extra: {'memoryBoxTitle': widget.memoryBoxTitle},
                      );
                    }
                  }
                },
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _titleController,
                        hintText: 'Note title',
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Title is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _contentController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: 'Write your note here...',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Content is required'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<NoteEditorCubit, NoteEditorState>(
                        builder: (context, state) {
                          return PrimaryButton(
                            text: isEditMode ? 'Update Note' : 'Save Note',
                            isLoading: state.status == NoteEditorStatus.loading,
                            onPressed: () => _save(context),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
