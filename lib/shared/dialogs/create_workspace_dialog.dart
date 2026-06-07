import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/core/utils/validators.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/create_workspace_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/create_workspace_state.dart';
import 'package:memory_chat/shared/widgets/app_text_field.dart';

class CreateWorkspaceDialog extends StatefulWidget {
  final String currentUserId;

  const CreateWorkspaceDialog({super.key, required this.currentUserId});

  @override
  State<CreateWorkspaceDialog> createState() => _CreateWorkspaceDialogState();
}

class _CreateWorkspaceDialogState extends State<CreateWorkspaceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Workspace'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _nameController,
              hintText: 'Workspace name',
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Name'),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _descriptionController,
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
        BlocConsumer<CreateWorkspaceCubit, CreateWorkspaceState>(
          listener: (context, state) {
            if (state.status == CreateWorkspaceStatus.success) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            return ElevatedButton(
              onPressed: state.status == CreateWorkspaceStatus.loading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        await context
                            .read<CreateWorkspaceCubit>()
                            .createWorkspace(
                              name: _nameController.text,
                              description: _descriptionController.text,
                              currentUserId: widget.currentUserId,
                            );
                      }
                    },
              child: state.status == CreateWorkspaceStatus.loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create'),
            );
          },
        ),
      ],
    );
  }
}
