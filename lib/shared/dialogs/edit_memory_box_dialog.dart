import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/core/utils/validators.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';
import 'package:memory_chat/shared/widgets/app_text_field.dart';
import 'package:memory_chat/shared/widgets/primary_button.dart';

Future<void> showEditMemoryBoxDialog({
  required BuildContext context,
  required String memoryBoxId,
  required String currentTitle,
  String? currentDescription,
}) async {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController(text: currentTitle);
  final descriptionController = TextEditingController(
    text: currentDescription ?? '',
  );

  await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Edit Memory Box'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: titleController,
                hintText: 'Title',
                validator: (v) =>
                    Validators.requiredField(v, fieldName: 'Title'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: descriptionController,
                hintText: 'Description (optional)',
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Save',
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await context.read<MemoryBoxesCubit>().updateMemoryBox(
                  memoryBoxId: memoryBoxId,
                  title: titleController.text,
                  description: descriptionController.text,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      );
    },
  );
}
