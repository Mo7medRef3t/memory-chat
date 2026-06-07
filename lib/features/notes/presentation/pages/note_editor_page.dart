import 'package:flutter/material.dart';
import 'package:memory_chat/features/notes/presentation/pages/views/note_editor_page_state.dart';

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
  State<NoteEditorPage> createState() => NoteEditorPageState();
}
