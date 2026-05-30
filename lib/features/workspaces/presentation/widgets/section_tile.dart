import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';
import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/shared/dialogs/create_memory_box_dialog.dart';
import 'package:memory_chat/shared/dialogs/delete_confirmation_dialog.dart';
import 'package:memory_chat/shared/dialogs/rename_section_dialog.dart';
import 'package:memory_chat/shared/dialogs/select_memory_boxes_dialog.dart';

class SectionTile extends StatelessWidget {
  final SectionEntity section;
  final String workspaceId;
  final String? workspaceName;
  final List<MemoryBoxEntity> rootMemoryBoxes;

  const SectionTile({
    super.key,
    required this.section,
    required this.workspaceId,
    this.workspaceName,
    required this.rootMemoryBoxes,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder, color: Colors.amber),
      title: Text(section.title),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleMenuAction(context, value),
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'add_box',
            child: Row(
              children: [
                Icon(Icons.add_box_outlined, size: 20),
                SizedBox(width: 12),
                Text('Add Memory Box'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'move_boxes',
            child: Row(
              children: [
                Icon(Icons.move_to_inbox_outlined, size: 20),
                SizedBox(width: 12),
                Text('Move Boxes Here'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 'rename', child: Text('Rename')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () {
        context.goNamed(
          RouteNames.memoryBoxList,
          pathParameters: {'workspaceId': workspaceId, 'sectionId': section.id},
          extra: {
            'sectionTitle': section.title,
            'workspaceName': workspaceName,
          },
        );
      },
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'add_box':
        showCreateMemoryBoxDialog(
          context,
          workspaceId: workspaceId,
          sectionId: section.id,
        );
        break;
      case 'move_boxes':
        _handleMoveBoxesHere(context);
        break;
      case 'rename':
        showRenameSectionDialog(
          context: context,
          sectionId: section.id,
          currentTitle: section.title,
        );
        break;
      case 'delete':
        _handleDelete(context);
        break;
    }
  }

  Future<void> _handleMoveBoxesHere(BuildContext context) async {
    final rootBoxes = rootMemoryBoxes
        .where((b) => b.sectionId == null)
        .toList();

    final selectedIds = await showSelectMemoryBoxesToMoveDialog(
      context: context,
      availableRootBoxes: rootBoxes,
    );

    // ✅ Check mounted after await
    if (selectedIds.isNotEmpty && context.mounted) {
      final cubit = context.read<MemoryBoxesCubit>();

      for (final boxId in selectedIds) {
        // ✅ Check mounted inside loop to prevent errors if widget is disposed
        if (!context.mounted) return;

        await cubit.moveMemoryBox(
          memoryBoxId: boxId,
          workspaceId: workspaceId,
          newSectionId: section.id,
        );
      }

      // ✅ Check mounted before showing SnackBar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Moved ${selectedIds.length} box(es) to "${section.title}"',
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Section',
      itemName: section.title,
      warningMessage:
          'All memory boxes and notes inside will be permanently deleted.',
    );

    // ✅ Check mounted after await
    if (confirmed && context.mounted) {
      context.read<SectionsCubit>().deleteSection(section.id);
    }
  }
}
