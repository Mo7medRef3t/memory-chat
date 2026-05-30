import 'package:flutter/material.dart';
import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';

Future<List<String>> showSelectMemoryBoxesToMoveDialog({
  required BuildContext context,
  required List<MemoryBoxEntity> availableRootBoxes,
}) async {
  final selectedIds = <String>{};

  final result = await showDialog<List<String>>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Memory Boxes'),
            content: SizedBox(
              width: double.maxFinite,
              child: availableRootBoxes.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No memory boxes at root level.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableRootBoxes.length,
                      itemBuilder: (_, index) {
                        final box = availableRootBoxes[index];
                        return CheckboxListTile(
                          value: selectedIds.contains(box.id),
                          title: Text(box.title),
                          subtitle: Text(box.description ?? 'No description'),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedIds.add(box.id);
                              } else {
                                selectedIds.remove(box.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                // ✅ الحل: استخدم <String>[] لتحديد النوع الصريح
                onPressed: () => Navigator.pop(dialogContext, <String>[]),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: selectedIds.isEmpty
                    ? null
                    : () => Navigator.pop(dialogContext, selectedIds.toList()),
                child: Text('Move ${selectedIds.length} Box(es)'),
              ),
            ],
          );
        },
      );
    },
  );

  // ✅ Fallback آمن: لو المستخدم قفل الـ Dialog من بره (back button)
  return result ?? <String>[];
}
