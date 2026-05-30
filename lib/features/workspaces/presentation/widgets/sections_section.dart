import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_state.dart';
import 'package:memory_chat/shared/dialogs/create_section_dialog.dart';
import 'package:memory_chat/shared/widgets/empty_state_card.dart';
import 'section_tile.dart';

class SectionsSection extends StatelessWidget {
  final String workspaceId;
  final String? workspaceName;
  final List<MemoryBoxEntity> rootMemoryBoxes; // ✅ Required

  const SectionsSection({
    super.key,
    required this.workspaceId,
    this.workspaceName,
    required this.rootMemoryBoxes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          onAdd: () => showCreateSectionDialog(context, workspaceId),
        ),
        const SizedBox(height: 8),
        _SectionsBody(
          workspaceId: workspaceId,
          workspaceName: workspaceName,
          rootMemoryBoxes: rootMemoryBoxes, // ✅ تمرير للـ Body
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _SectionHeader({required this.onAdd});

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

class _SectionsBody extends StatelessWidget {
  final String workspaceId;
  final String? workspaceName;
  final List<MemoryBoxEntity> rootMemoryBoxes; // ✅ ضفناها

  const _SectionsBody({
    required this.workspaceId,
    this.workspaceName,
    required this.rootMemoryBoxes,
  });

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
          return EmptyStateCard(
            icon: Icons.folder_off_outlined,
            message: 'No sections yet',
            actionLabel: 'Create your first section',
            onAction: () => showCreateSectionDialog(context, workspaceId),
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
              return SectionTile(
                section: section,
                workspaceId: workspaceId,
                workspaceName: workspaceName,
                rootMemoryBoxes: rootMemoryBoxes, // ✅ تمرير للـ Tile
              );
            },
          ),
        );
      },
    );
  }
}
