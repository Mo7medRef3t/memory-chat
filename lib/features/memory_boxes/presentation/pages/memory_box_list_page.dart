import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/core/utils/validators.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_state.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_state.dart';
import 'package:memory_chat/shared/widgets/app_text_field.dart';
import 'package:memory_chat/shared/widgets/loading_indicator.dart';
import 'package:memory_chat/shared/widgets/primary_button.dart';

class MemoryBoxListPage extends StatelessWidget {
  final String workspaceId;
  final String sectionId;
  final String? sectionTitle;
  final String? workspaceName;

  const MemoryBoxListPage({
    super.key,
    required this.workspaceId,
    required this.sectionId,
    this.sectionTitle,
    this.workspaceName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<MemoryBoxesCubit>()..loadMemoryBoxes(sectionId),
        ),
        BlocProvider(create: (_) => sl<CreateMemoryBoxCubit>()),
      ],
      child: _MemoryBoxListView(
        workspaceId: workspaceId,
        sectionId: sectionId,
        sectionTitle: sectionTitle,
      ),
    );
  }
}

class _MemoryBoxListView extends StatelessWidget {
  final String workspaceId;
  final String sectionId;
  final String? sectionTitle;

  const _MemoryBoxListView({
    required this.workspaceId,
    required this.sectionId,
    this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateMemoryBoxCubit, CreateMemoryBoxState>(
      listener: (context, state) {
        if (state.status == CreateMemoryBoxStatus.success) {
          context.read<MemoryBoxesCubit>().loadMemoryBoxes(sectionId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Memory box created successfully')),
          );
        }

        if (state.status == CreateMemoryBoxStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(sectionTitle ?? 'Memory Boxes')),
        body: BlocBuilder<MemoryBoxesCubit, MemoryBoxesState>(
          builder: (context, state) {
            if (state.status == MemoryBoxesStatus.loading) {
              return const LoadingIndicator();
            }

            if (state.status == MemoryBoxesStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? 'Something went wrong'),
              );
            }

            if (state.memoryBoxes.isEmpty) {
              return const Center(child: Text('No memory boxes yet'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.memoryBoxes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final box = state.memoryBoxes[index];

                return Card(
                  child: ListTile(
                    title: Text(box.title),
                    subtitle: Text(box.description ?? 'No description'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditMemoryBoxDialog(
                            context,
                            box.id,
                            box.title,
                            box.description,
                          );
                        } else if (value == 'delete') {
                          context.read<MemoryBoxesCubit>().deleteMemoryBox(
                            box.id,
                          );
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateMemoryBoxDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showCreateMemoryBoxDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
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
                    validator: (value) =>
                        Validators.requiredField(value, fieldName: 'Title'),
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
                  return SizedBox(
                    width: 120,
                    child: PrimaryButton(
                      text: 'Create',
                      isLoading: state.status == CreateMemoryBoxStatus.loading,
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await context
                              .read<CreateMemoryBoxCubit>()
                              .createMemoryBox(
                                sectionId: sectionId,
                                title: titleController.text,
                                description: descriptionController.text,
                              );

                          if (context.mounted &&
                              context
                                      .read<CreateMemoryBoxCubit>()
                                      .state
                                      .status ==
                                  CreateMemoryBoxStatus.success) {
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditMemoryBoxDialog(
    BuildContext context,
    String memoryBoxId,
    String currentTitle,
    String? currentDescription,
  ) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: currentTitle);
    final descriptionController = TextEditingController(
      text: currentDescription ?? '',
    );

    showDialog(
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
                  validator: (value) =>
                      Validators.requiredField(value, fieldName: 'Title'),
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

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
