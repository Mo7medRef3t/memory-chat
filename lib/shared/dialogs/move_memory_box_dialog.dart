import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';
import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';

Future<void> showMoveMemoryBoxDialog({
  required BuildContext context,
  required String memoryBoxId, // للتوافق مع الـ Single Select القديم
  required String workspaceId,
  required List<SectionEntity> availableSections,
  String? currentSectionId,
  List<String>? selectedIds, // ✅ جديد: Multi-select support
}) async {
  final isMultiSelect = selectedIds != null && selectedIds.isNotEmpty;
  final idsToMove = isMultiSelect ? selectedIds : [memoryBoxId];

  final destinationType = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        isMultiSelect
            ? 'Move ${idsToMove.length} Memory Boxes'
            : 'Move Memory Box',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentSectionId != null) ...[
            ListTile(
              leading: const Icon(Icons.home_outlined, color: Colors.blue),
              title: const Text('Workspace Root'),
              subtitle: const Text('Remove from current section'),
              onTap: () => Navigator.pop(dialogContext, 'root'),
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.folder_outlined, color: Colors.amber),
            title: const Text('Into a Section'),
            subtitle: const Text('Choose a section to move into'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pop(dialogContext, 'section'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );

  if (!context.mounted || destinationType == null) return;

  if (destinationType == 'root') {
    await _executeMove(
      context: context,
      idsToMove: idsToMove,
      workspaceId: workspaceId,
      newSectionId: null,
      successMessage: isMultiSelect
          ? 'Moved ${idsToMove.length} boxes to Workspace Root'
          : 'Moved to Workspace Root',
    );
  } else if (destinationType == 'section') {
    if (!context.mounted) return;
    await _showSectionsListDialog(
      context: context,
      idsToMove: idsToMove,
      workspaceId: workspaceId,
      availableSections: availableSections,
      currentSectionId: currentSectionId,
      isMultiSelect: isMultiSelect,
    );
  }
}

Future<void> _showSectionsListDialog({
  required BuildContext context,
  required List<String> idsToMove,
  required String workspaceId,
  required List<SectionEntity> availableSections,
  String? currentSectionId,
  required bool isMultiSelect,
}) async {
  final otherSections = availableSections
      .where((s) => s.id != currentSectionId)
      .toList();

  if (otherSections.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No other sections available. Create a new section first.',
        ),
      ),
    );
    return;
  }

  final selectedSectionId = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Choose a Section'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: otherSections.length,
          itemBuilder: (_, index) {
            final section = otherSections[index];
            return ListTile(
              leading: const Icon(Icons.folder, color: Colors.amber),
              title: Text(section.title),
              onTap: () => Navigator.pop(dialogContext, section.id),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );

  if (selectedSectionId != null) {
    final sectionName = otherSections
        .firstWhere((s) => s.id == selectedSectionId)
        .title;
        
    if (context.mounted) {
      await _executeMove(
      context: context,
      idsToMove: idsToMove,
      workspaceId: workspaceId,
      newSectionId: selectedSectionId,
      successMessage: isMultiSelect
          ? 'Moved ${idsToMove.length} boxes to "$sectionName"'
          : 'Moved to "$sectionName"',
    );
    }
  }
}

Future<void> _executeMove({
  required BuildContext context,
  required List<String> idsToMove,
  required String workspaceId,
  required String? newSectionId,
  required String successMessage,
}) async {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }

  final cubit = context.read<MemoryBoxesCubit>();

  for (final id in idsToMove) {
    if (!context.mounted) return;
    await cubit.moveMemoryBox(
      memoryBoxId: id,
      workspaceId: workspaceId,
      newSectionId: newSectionId,
    );
  }

  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successMessage)));
  }
}
