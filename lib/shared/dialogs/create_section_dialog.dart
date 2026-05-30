import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/core/utils/validators.dart';
import 'package:memory_chat/features/sections/presentation/cubit/create_section_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/create_section_state.dart';
import 'package:memory_chat/shared/widgets/app_text_field.dart';
import 'package:memory_chat/shared/widgets/primary_button.dart';

Future<void> showCreateSectionDialog(
  BuildContext context,
  String workspaceId,
) async {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();

  await showDialog(
    context: context,
    builder: (_) {
      return BlocProvider.value(
        value: context.read<CreateSectionCubit>(),
        child: AlertDialog(
          title: const Text('Create Section'),
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
            BlocBuilder<CreateSectionCubit, CreateSectionState>(
              builder: (context, state) {
                return PrimaryButton(
                  text: 'Create',
                  isLoading: state.status == CreateSectionStatus.loading,
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await context.read<CreateSectionCubit>().createSection(
                        workspaceId: workspaceId,
                        title: titleController.text,
                      );
                      if (context.mounted &&
                          context.read<CreateSectionCubit>().state.status ==
                              CreateSectionStatus.success) {
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
