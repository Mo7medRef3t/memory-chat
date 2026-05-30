import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/core/utils/validators.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_state.dart';
import 'package:memory_chat/shared/widgets/app_text_field.dart';
import 'package:memory_chat/shared/widgets/primary_button.dart';

Future<void> showCreateMemoryBoxDialog(
  BuildContext context, {
  required String workspaceId,
  String? sectionId,
}) async {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  await showDialog(
    context: context,
    builder: (_) {
      return BlocProvider.value(
        value: context.read<CreateMemoryBoxCubit>(),
        child: AlertDialog(
          title: const Text('Create Memory Box'),
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
            BlocBuilder<CreateMemoryBoxCubit, CreateMemoryBoxState>(
              builder: (context, state) {
                return PrimaryButton(
                  text: 'Create',
                  isLoading: state.status == CreateMemoryBoxStatus.loading,
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await context
                          .read<CreateMemoryBoxCubit>()
                          .createMemoryBox(
                            workspaceId: workspaceId,
                            sectionId: sectionId,
                            title: titleController.text,
                            description: descriptionController.text,
                          );
                      if (context.mounted &&
                          context.read<CreateMemoryBoxCubit>().state.status ==
                              CreateMemoryBoxStatus.success) {
                        Navigator.pop(context);
                      }
                    }
                  },
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
