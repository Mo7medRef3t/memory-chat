import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/core/utils/validators.dart';
import 'package:memory_chat/features/sections/presentation/cubit/create_section_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/create_section_state.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_state.dart';
import 'package:memory_chat/shared/widgets/app_text_field.dart';
import 'package:memory_chat/shared/widgets/loading_indicator.dart';
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
        BlocProvider(create: (_) => sl<CreateSectionCubit>()),
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
    return BlocListener<CreateSectionCubit, CreateSectionState>(
      listener: (context, state) {
        if (state.status == CreateSectionStatus.success) {
          context.read<SectionsCubit>().loadSections(workspaceId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Section created successfully')),
          );
        }

        if (state.status == CreateSectionStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.goNamed(RouteNames.workspaceList),
          ),
          title: Text(workspaceName ?? 'Workspace'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                context.goNamed(
                  'workspaceChat',
                  pathParameters: {'workspaceId': workspaceId},
                  extra: workspaceName,
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<SectionsCubit, SectionsState>(
          builder: (context, state) {
            if (state.status == SectionsStatus.loading) {
              return const LoadingIndicator();
            }

            if (state.status == SectionsStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? 'Something went wrong'),
              );
            }

            if (state.sections.isEmpty) {
              return const Center(child: Text('No sections yet'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.sections.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final section = state.sections[index];

                return Card(
                  child: ListTile(
                    title: Text(section.title),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'rename') {
                          _showRenameSectionDialog(
                            context,
                            section.id,
                            section.title,
                          );
                        } else if (value == 'delete') {
                          context.read<SectionsCubit>().deleteSection(
                            section.id,
                          );
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'rename', child: Text('Rename')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                    onTap: () {
                      context.goNamed(
                        RouteNames.memoryBoxList,
                        pathParameters: {
                          'workspaceId': workspaceId,
                          'sectionId': section.id,
                        },
                        extra: {
                          'sectionTitle': section.title,
                          'workspaceName': workspaceName,
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateSectionDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

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
                validator: (value) =>
                    Validators.requiredField(value, fieldName: 'Section title'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              BlocBuilder<CreateSectionCubit, CreateSectionState>(
                builder: (context, state) {
                  return SizedBox(
                    width: 120,
                    child: PrimaryButton(
                      text: 'Create',
                      isLoading: state.status == CreateSectionStatus.loading,
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await context
                              .read<CreateSectionCubit>()
                              .createSection(
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

  void _showRenameSectionDialog(
    BuildContext context,
    String sectionId,
    String currentTitle,
  ) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: currentTitle);

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
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Section title'),
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
