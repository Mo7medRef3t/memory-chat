import 'package:flutter/material.dart';
import 'package:memory_chat/features/notes/domain/entities/note_entity.dart';
import 'package:memory_chat/shared/dialogs/delete_confirmation_dialog.dart';

class NoteTile extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteTile({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.description_outlined, color: Colors.blue),
        title: Text(
          note.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          note.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, context),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }

  void _handleMenuAction(String value, BuildContext context) {
    if (value == 'edit') {
      onEdit();
    } else if (value == 'delete') {
      _confirmDelete(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Note',
      itemName: note.title,
      warningMessage: 'This note will be permanently deleted.',
    );

    if (confirmed) onDelete();
  }
}