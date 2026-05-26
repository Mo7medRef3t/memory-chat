import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/core/utils/validators.dart';
import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_state.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_state.dart';
import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';
import 'package:memory_chat/features/sections/presentation/cubit/create_section_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/create_section_state.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_state.dart';
import 'package:memory_chat/shared/widgets/app_text_field.dart';
import 'package:memory_chat/shared/widgets/primary_button.dart';

class WorkspaceDetailsPage extends StatelessWidget {
  final String workspaceId;
  final String? workspaceName;

  const WorkspaceDetailsPage({
    super.key,
    required this.workspaceId,
    this.workspaceName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<SectionsCubit>()..loadSections(workspaceId),
        ),
        BlocProvider(
          create: (_) => sl<MemoryBoxesCubit>()
            ..loadMemoryBoxes(
              workspaceId: workspaceId,
              sectionId: null, // ✅ Root level
            ),
        ),
        BlocProvider(create: (_) => sl<CreateSectionCubit>()),
        BlocProvider(create: (_) => sl<CreateMemoryBoxCubit>()),
      ],
      child: _WorkspaceDetailsView(
        workspaceId: workspaceId,
        workspaceName: workspaceName,
      ),
    );
  }
}

class _WorkspaceDetailsView extends StatelessWidget {
  final String workspaceId;
  final String? workspaceName;

  const _WorkspaceDetailsView({required this.workspaceId, this.workspaceName});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreateSectionCubit, CreateSectionState>(
          listener: (context, state) {
            if (state.status == CreateSectionStatus.success) {
              context.read<SectionsCubit>().loadSections(workspaceId);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Section created')));
            } else if (state.status == CreateSectionStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
        ),
        BlocListener<CreateMemoryBoxCubit, CreateMemoryBoxState>(
          listener: (context, state) {
            if (state.status == CreateMemoryBoxStatus.success) {
              context.read<MemoryBoxesCubit>().loadMemoryBoxes(
                workspaceId: workspaceId,
                sectionId: null,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Memory box created')),
              );
            } else if (state.status == CreateMemoryBoxStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.goNamed(RouteNames.workspaceList),
          ),
          title: Text(workspaceName ?? 'Workspace'),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              context.read<SectionsCubit>().loadSections(workspaceId),
              context.read<MemoryBoxesCubit>().loadMemoryBoxes(
                workspaceId: workspaceId,
                sectionId: null,
              ),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionsHeader(onAdd: () => _showCreateSectionDialog(context)),
                const SizedBox(height: 8),
                _SectionsList(
                  workspaceId: workspaceId,
                  workspaceName: workspaceName,
                ),
                const SizedBox(height: 32),
                _MemoryBoxesHeader(
                  onAdd: () => _showCreateMemoryBoxDialog(context),
                ),
                const SizedBox(height: 8),
                _RootMemoryBoxesList(
                  workspaceId: workspaceId,
                  workspaceName: workspaceName,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ SECTION DIALOGS ============

  void _showCreateSectionDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();

    showDialog(
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
                validator: (v) =>
                    Validators.requiredField(v, fieldName: 'Title'),
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

  // ============ MEMORY BOX DIALOGS ============

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
                              sectionId: null, // ✅ Root level
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
}

// ============ SECTION WIDGETS ============

class _SectionsHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _SectionsHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.folder_outlined, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        const Text(
          'Sections',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
        ),
      ],
    );
  }
}

class _SectionsList extends StatelessWidget {
  final String workspaceId;
  final String? workspaceName;

  const _SectionsList({required this.workspaceId, this.workspaceName});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SectionsCubit, SectionsState>(
      builder: (context, state) {
        if (state.status == SectionsStatus.loading && state.sections.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.sections.isEmpty) {
          return _EmptyStateCard(
            icon: Icons.folder_off_outlined,
            message: 'No sections yet',
            actionLabel: 'Create your first section',
            onAction: () {
              // Trigger create section dialog from parent
              context
                  .findAncestorWidgetOfExactType<_WorkspaceDetailsView>();
              // Alternative: use callback or directly call from here
              _showCreateSectionDialogInline(context);
            },
          );
        }

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.sections.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final section = state.sections[index];
              return _SectionTile(
                section: section,
                workspaceId: workspaceId,
                workspaceName: workspaceName,
              );
            },
          ),
        );
      },
    );
  }

  void _showCreateSectionDialogInline(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();

    showDialog(
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
                validator: (v) =>
                    Validators.requiredField(v, fieldName: 'Title'),
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
}

class _SectionTile extends StatelessWidget {
  final SectionEntity section;
  final String workspaceId;
  final String? workspaceName;

  const _SectionTile({
    required this.section,
    required this.workspaceId,
    this.workspaceName,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder, color: Colors.amber),
      title: Text(section.title),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'rename') {
            _showRenameSectionDialog(context);
          } else if (value == 'delete') {
            _showDeleteConfirmationDialog(context);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'rename', child: Text('Rename')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () {
        context.goNamed(
          RouteNames.memoryBoxList,
          pathParameters: {'workspaceId': workspaceId, 'sectionId': section.id},
          extra: {
            'sectionTitle': section.title,
            'workspaceName': workspaceName,
          },
        );
      },
    );
  }

  void _showRenameSectionDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: section.title);

    showDialog(
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
                    sectionId: section.id,
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

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Section'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete "${section.title}"?',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All memory boxes and notes inside will be permanently deleted.',
                      style: TextStyle(fontSize: 13, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SectionsCubit>().deleteSection(section.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ============ MEMORY BOX WIDGETS ============

class _MemoryBoxesHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _MemoryBoxesHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
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
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
        ),
      ],
    );
  }
}

class _RootMemoryBoxesList extends StatelessWidget {
  final String workspaceId;
  final String? workspaceName;

  const _RootMemoryBoxesList({required this.workspaceId, this.workspaceName});

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

        if (state.memoryBoxes.isEmpty) {
          return _EmptyStateCard(
            icon: Icons.inventory_2_outlined,
            message: 'No memory boxes at root level',
            actionLabel: 'Create your first memory box',
            onAction: () {
              // Will trigger create dialog (handled by parent via callback pattern)
            },
          );
        }

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.memoryBoxes.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final box = state.memoryBoxes[index];
              return _RootMemoryBoxTile(
                box: box,
                workspaceId: workspaceId,
                workspaceName: workspaceName,
              );
            },
          ),
        );
      },
    );
  }
}

class _RootMemoryBoxTile extends StatelessWidget {
  final MemoryBoxEntity box;
  final String workspaceId;
  final String? workspaceName;

  const _RootMemoryBoxTile({
    required this.box,
    required this.workspaceId,
    this.workspaceName,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.inventory_2, color: Colors.blue),
      title: Text(box.title),
      subtitle: Text(box.description ?? 'No description'),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _showEditDialog(context);
          } else if (value == 'move') {
            _showMoveToSectionDialog(context);
          } else if (value == 'delete') {
            _showDeleteConfirmationDialog(context);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'move', child: Text('Move to Section')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () {
        // ✅ Route جديد للـ Root Memory Box
        context.goNamed(
          RouteNames.rootMemoryBoxNotes, // هنضيفها بعد شوية
          pathParameters: {'workspaceId': workspaceId, 'memoryBoxId': box.id},
          extra: {'memoryBoxTitle': box.title, 'workspaceName': workspaceName},
        );
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: box.title);
    final descriptionController = TextEditingController(
      text: box.description ?? '',
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
                    memoryBoxId: box.id,
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

  void _showMoveToSectionDialog(BuildContext context) {
    final sectionsCubit = context.read<SectionsCubit>();
    final sections = sectionsCubit.state.sections;

    if (sections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Create a section first to move this memory box into it',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Move to Section'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sections.length,
              itemBuilder: (_, index) {
                final section = sections[index];
                return ListTile(
                  leading: const Icon(Icons.folder, color: Colors.amber),
                  title: Text(section.title),
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await context.read<MemoryBoxesCubit>().moveMemoryBox(
                      memoryBoxId: box.id,
                      workspaceId: workspaceId,
                      newSectionId: section.id,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Moved to "${section.title}"')),
                      );
                    }
                  },
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
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Memory Box'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete "${box.title}"?',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All notes inside will be permanently deleted.',
                      style: TextStyle(fontSize: 13, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MemoryBoxesCubit>().deleteMemoryBox(box.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ============ SHARED WIDGETS ============

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyStateCard({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
