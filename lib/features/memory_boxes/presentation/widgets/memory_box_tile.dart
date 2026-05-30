import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';
import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';
import 'package:memory_chat/shared/dialogs/delete_confirmation_dialog.dart';
import 'package:memory_chat/shared/dialogs/edit_memory_box_dialog.dart';
import 'package:memory_chat/shared/dialogs/move_memory_box_dialog.dart';

class MemoryBoxTile extends StatelessWidget {
  final MemoryBoxEntity box;
  final String workspaceId;
  final String sectionId;
  final String? sectionTitle;
  final String? workspaceName;
  final List<SectionEntity> availableSections; // ✅ ضيف ده كـ parameter

  const MemoryBoxTile({
    super.key,
    required this.box,
    required this.workspaceId,
    required this.sectionId,
    required this.availableSections, // ✅ Required
    this.sectionTitle,
    this.workspaceName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.inventory_2, color: Colors.blue),
        title: Text(box.title),
        subtitle: Text(box.description ?? 'No description'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'move', child: Text('Move to...')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () {
          context.goNamed(
            RouteNames.noteList,
            pathParameters: {
              'workspaceId': workspaceId,
              'sectionId': sectionId,
              'memoryBoxId': box.id,
            },
            extra: {'memoryBoxTitle': box.title, 'sectionTitle': sectionTitle},
          );
        },
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        showEditMemoryBoxDialog(
          context: context,
          memoryBoxId: box.id,
          currentTitle: box.title,
          currentDescription: box.description,
        );
        break;
      case 'move':
        _handleMove(context);
        break;
      case 'delete':
        _handleDelete(context);
        break;
    }
  }

  Future<void> _handleMove(BuildContext context) async {
    // ✅ استخدم الـ parameter بدل ما تقرأ من context
    await showMoveMemoryBoxDialog(
      context: context,
      memoryBoxId: box.id,
      workspaceId: workspaceId,
      availableSections: availableSections, // ✅ من الـ parent
      currentSectionId: sectionId,
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Memory Box',
      itemName: box.title,
      warningMessage: 'All notes inside will be permanently deleted.',
    );

    if (confirmed && context.mounted) {
      context.read<MemoryBoxesCubit>().deleteMemoryBox(box.id);
    }
  }
}
