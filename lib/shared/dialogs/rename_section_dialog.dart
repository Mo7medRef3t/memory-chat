import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/core/utils/validators.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/shared/widgets/app_text_field.dart';
import 'package:memory_chat/shared/widgets/primary_button.dart';

Future<void> showRenameSectionDialog({
  required BuildContext context,
  required String sectionId,
  required String currentTitle,
}) async {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController(text: currentTitle);

  await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Rename Section'),
        content: Form(
          key: formKey,
          child: AppTextField(
            controller: titleController,
            hintText: 'Section title',
            validator: (v) => Validators.requiredField(v, fieldName: 'Title'),
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
                await context.read<SectionsCubit>().renameSection(
                  sectionId: sectionId,
                  newTitle: titleController.text,
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
