import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_state.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/shared/dialogs/create_memory_box_dialog.dart';
import 'package:memory_chat/shared/dialogs/move_memory_box_dialog.dart';
import 'package:memory_chat/shared/widgets/empty_state_card.dart';
import 'root_memory_box_tile.dart';

class MemoryBoxesSection extends StatefulWidget {
  final String workspaceId;
  final String? workspaceName;

  const MemoryBoxesSection({
    super.key,
    required this.workspaceId,
    this.workspaceName,
  });

  @override
  State<MemoryBoxesSection> createState() => _MemoryBoxesSectionState();
}

class _MemoryBoxesSectionState extends State<MemoryBoxesSection> {
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  void _toggleSelection(String boxId) {
    setState(() {
      if (_selectedIds.contains(boxId)) {
        _selectedIds.remove(boxId);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(boxId);
      }
    });
  }

  void _enterSelectionMode(String initialBoxId) {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.add(initialBoxId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _moveSelectedBoxes() async {
    final sections = context.read<SectionsCubit>().state.sections;
    // ignore: unused_local_variable
    final rootBoxes = context
        .read<MemoryBoxesCubit>()
        .state
        .memoryBoxes
        .where((b) => b.sectionId == null)
        .toList();

    await showMoveMemoryBoxDialog(
      context: context,
      memoryBoxId: _selectedIds.first, // هنعدل الـ Dialog عشان يدعم Multi
      workspaceId: widget.workspaceId,
      availableSections: sections,
      currentSectionId: null,
      selectedIds: _selectedIds.toList(), // ✅ Multi-select
    );

    _exitSelectionMode();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MemoryBoxesHeader(
          isSelectionMode: _isSelectionMode,
          selectedCount: _selectedIds.length,
          onAdd: () => showCreateMemoryBoxDialog(
            context,
            workspaceId: widget.workspaceId,
            sectionId: null,
          ),
          onSelect: () => setState(() => _isSelectionMode = true),
          onCancel: _exitSelectionMode,
          onMove: _moveSelectedBoxes,
        ),
        const SizedBox(height: 8),
        _MemoryBoxesBody(
          workspaceId: widget.workspaceId,
          workspaceName: widget.workspaceName,
          isSelectionMode: _isSelectionMode,
          selectedIds: _selectedIds,
          onToggleSelection: _toggleSelection,
          onLongPress: _enterSelectionMode,
        ),
      ],
    );
  }
}

class _MemoryBoxesHeader extends StatelessWidget {
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback onAdd;
  final VoidCallback onSelect;
  final VoidCallback onCancel;
  final VoidCallback onMove;

  const _MemoryBoxesHeader({
    required this.isSelectionMode,
    required this.selectedCount,
    required this.onAdd,
    required this.onSelect,
    required this.onCancel,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelectionMode) {
      return Row(
        children: [
          IconButton(icon: const Icon(Icons.close), onPressed: onCancel),
          Text(
            '$selectedCount selected',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: selectedCount > 0 ? onMove : null,
            icon: const Icon(Icons.move_to_inbox_outlined, size: 18),
            label: const Text('Move'),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        const Text(
          'Memory Boxes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onSelect,
          icon: const Icon(Icons.checklist_outlined, size: 18),
          label: const Text('Select'),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
        ),
      ],
    );
  }
}

class _MemoryBoxesBody extends StatelessWidget {
  final String workspaceId;
  final String? workspaceName;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final Function(String) onToggleSelection;
  final Function(String) onLongPress;

  const _MemoryBoxesBody({
    required this.workspaceId,
    this.workspaceName,
    required this.isSelectionMode,
    required this.selectedIds,
    required this.onToggleSelection,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryBoxesCubit, MemoryBoxesState>(
      builder: (context, state) {
        if (state.status == MemoryBoxesStatus.loading &&
            state.memoryBoxes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Filter only root boxes (sectionId == null)
        final rootBoxes = state.memoryBoxes
            .where((b) => b.sectionId == null)
            .toList();

        if (rootBoxes.isEmpty) {
          return EmptyStateCard(
            icon: Icons.inventory_2_outlined,
            message: 'No memory boxes at root level',
            actionLabel: 'Create your first memory box',
            onAction: () => showCreateMemoryBoxDialog(
              context,
              workspaceId: workspaceId,
              sectionId: null,
            ),
          );
        }

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rootBoxes.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final box = rootBoxes[index];
              return RootMemoryBoxTile(
                box: box,
                workspaceId: workspaceId,
                workspaceName: workspaceName,
                isSelectionMode: isSelectionMode,
                isSelected: selectedIds.contains(box.id),
                onToggleSelection: () => onToggleSelection(box.id),
                onLongPress: (_) => onLongPress(box.id),
              );
            },
          ),
        );
      },
    );
  }
}
