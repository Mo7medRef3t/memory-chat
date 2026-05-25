import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/core/utils/validators.dart';
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

  const NoteEditorPage({
    super.key,
    required this.workspaceId,
    required this.sectionId,
    required this.memoryBoxId,
    this.noteId,
    this.initialTitle,
    this.initialContent,
    this.memoryBoxTitle,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool get isEditMode => widget.noteId != null;

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

  Future<void> _save(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authorId = context.read<AuthCubit>().state.user!.id;

      await context.read<NoteEditorCubit>().saveNote(
        noteId: widget.noteId,
        memoryBoxId: widget.memoryBoxId,
        authorId: authorId,
        title: _titleController.text,
        content: _contentController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NoteEditorCubit>(),
      child: Builder(
        builder: (context) {
          return BlocListener<NoteEditorCubit, NoteEditorState>(
            listener: (context, state) {
              if (state.status == NoteEditorStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditMode
                          ? 'Note updated successfully'
                          : 'Note created successfully',
                    ),
                  ),
                );
                Navigator.pop(context);
              }

              if (state.status == NoteEditorStatus.failure &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(isEditMode ? 'Edit Note' : 'New Note'),
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
                          validator: (value) => Validators.requiredField(
                            value,
                            fieldName: 'Title',
                          ),
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
                            ),
                            validator: (value) => Validators.requiredField(
                              value,
                              fieldName: 'Content',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<NoteEditorCubit, NoteEditorState>(
                          builder: (context, state) {
                            return PrimaryButton(
                              text: 'Save',
                              isLoading:
                                  state.status == NoteEditorStatus.loading,
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
          );
        },
      ),
    );
  }
}
