import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/shared/dialogs/delete_confirmation_dialog.dart';
import 'package:memory_chat/shared/dialogs/edit_memory_box_dialog.dart';
import 'package:memory_chat/shared/dialogs/move_memory_box_dialog.dart';

class RootMemoryBoxTile extends StatelessWidget {
  final MemoryBoxEntity box;
  final String workspaceId;
  final String? workspaceName;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onToggleSelection;
  final Function(String) onLongPress;

  const RootMemoryBoxTile({
    super.key,
    required this.box,
    required this.workspaceId,
    this.workspaceName,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onToggleSelection,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: isSelectionMode ? null : () => onLongPress(box.id),
      onTap: isSelectionMode ? onToggleSelection : null,
      child: Card(
        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
        child: ListTile(
          leading: isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggleSelection(),
                )
              : const Icon(Icons.inventory_2, color: Colors.blue),
          title: Text(box.title),
          subtitle: Text(box.description ?? 'No description'),
          trailing: isSelectionMode
              ? null
              : PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, value),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'move', child: Text('Move to...')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
          onTap: isSelectionMode
              ? onToggleSelection
              : () {
                  // ✅ استخدم الـ Route المنفصل للـ Root Notes
                  context.goNamed(
                    RouteNames.rootNoteList,
                    pathParameters: {
                      'workspaceId': workspaceId,
                      'memoryBoxId': box.id,
                    },
                    extra: {
                      'memoryBoxTitle': box.title,
                      'workspaceName': workspaceName,
                    },
                  );
                },
        ),
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
    final sections = context.read<SectionsCubit>().state.sections;
    await showMoveMemoryBoxDialog(
      context: context,
      memoryBoxId: box.id,
      workspaceId: workspaceId,
      availableSections: sections,
      currentSectionId: null,
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
