import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_state.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_state.dart';
import 'package:memory_chat/features/memory_boxes/presentation/widgets/memory_box_tile.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_state.dart';
import 'package:memory_chat/shared/dialogs/create_memory_box_dialog.dart';
import 'package:memory_chat/shared/widgets/empty_state_card.dart';
import 'package:memory_chat/shared/widgets/loading_indicator.dart';

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
          create: (_) => sl<MemoryBoxesCubit>()
            ..loadMemoryBoxes(
              workspaceId: workspaceId,
              sectionId: sectionId,
            ),
        ),
        // ✅ الـ SectionsCubit عشان الـ Move يشتغل
        BlocProvider(
          create: (_) => sl<SectionsCubit>()..loadSections(workspaceId),
        ),
        BlocProvider(create: (_) => sl<CreateMemoryBoxCubit>()),
      ],
      child: _MemoryBoxListView(
        workspaceId: workspaceId,
        sectionId: sectionId,
        sectionTitle: sectionTitle,
        workspaceName: workspaceName,
      ),
    );
  }
}

class _MemoryBoxListView extends StatelessWidget {
  final String workspaceId;
  final String sectionId;
  final String? sectionTitle;
  final String? workspaceName;

  const _MemoryBoxListView({
    required this.workspaceId,
    required this.sectionId,
    this.sectionTitle,
    this.workspaceName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateMemoryBoxCubit, CreateMemoryBoxState>(
      listener: (context, state) {
        if (state.status == CreateMemoryBoxStatus.success) {
          context.read<MemoryBoxesCubit>().loadMemoryBoxes(
                workspaceId: workspaceId,
                sectionId: sectionId,
              );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Memory box created')),
          );
        } else if (state.status == CreateMemoryBoxStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.goNamed(
              RouteNames.workspaceDetails,
              pathParameters: {'workspaceId': workspaceId},
            ),
          ),
          title: Text(sectionTitle ?? 'Memory Boxes'),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              context.read<MemoryBoxesCubit>().loadMemoryBoxes(
                    workspaceId: workspaceId,
                    sectionId: sectionId,
                  ),
              context.read<SectionsCubit>().loadSections(workspaceId),
            ]);
          },
          // ✅ BlocBuilder للـ SectionsCubit عشان نضمن إن الـ sections جاهزة
          child: BlocBuilder<SectionsCubit, SectionsState>(
            builder: (context, sectionsState) {
              final sections = sectionsState.sections;

              return BlocBuilder<MemoryBoxesCubit, MemoryBoxesState>(
                builder: (context, memoryState) {
                  if (memoryState.status == MemoryBoxesStatus.loading &&
                      memoryState.memoryBoxes.isEmpty) {
                    return const LoadingIndicator();
                  }

                  if (memoryState.status == MemoryBoxesStatus.failure &&
                      memoryState.memoryBoxes.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Text(
                              memoryState.errorMessage ?? 'Something went wrong'),
                        ),
                      ],
                    );
                  }

                  if (memoryState.memoryBoxes.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 100),
                        EmptyStateCard(
                          icon: Icons.inventory_2_outlined,
                          message: 'No memory boxes in this section',
                          actionLabel: 'Create your first memory box',
                          onAction: () => showCreateMemoryBoxDialog(
                            context,
                            workspaceId: workspaceId,
                            sectionId: sectionId,
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: memoryState.memoryBoxes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final box = memoryState.memoryBoxes[index];
                      return MemoryBoxTile(
                        box: box,
                        workspaceId: workspaceId,
                        sectionId: sectionId,
                        sectionTitle: sectionTitle,
                        workspaceName: workspaceName,
                        availableSections: sections,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showCreateMemoryBoxDialog(
            context,
            workspaceId: workspaceId,
            sectionId: sectionId,
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}