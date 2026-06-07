import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/app/theme/app_colors.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_state.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/workspace_list_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/workspace_list_state.dart';

class AppSidebar extends StatelessWidget {
  final String? selectedWorkspaceId;
  final String? selectedSectionId;
  final VoidCallback? onCreateWorkspace;
  final VoidCallback? onCreateSection;

  const AppSidebar({
    super.key,
    this.selectedWorkspaceId,
    this.selectedSectionId,
    this.onCreateWorkspace,
    this.onCreateSection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: AppColors.darkSidebarBg,
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(color: AppColors.darkDivider, height: 1),

          // Workspaces List
          _buildWorkspacesSection(context),

          // Sections List (لو في workspace محدد)
          if (selectedWorkspaceId != null) ...[
            const Divider(color: AppColors.darkDivider, height: 1),
            Expanded(child: _buildSectionsSection(context)),
          ] else ...[
            const Expanded(child: SizedBox()),
          ],

          const Divider(color: AppColors.darkDivider, height: 1),
          _buildUserSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.memory, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Memory Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your workspaces',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCreateWorkspace,
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.darkTextSecondary,
            ),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspacesSection(BuildContext context) {
    return BlocBuilder<WorkspaceListCubit, WorkspaceListState>(
      builder: (context, state) {
        if (state.status == WorkspaceListStatus.loading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.darkTextSecondary,
              ),
            ),
          );
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.workspaces.length,
            itemBuilder: (context, index) {
              final workspace = state.workspaces[index];
              final isSelected = workspace.id == selectedWorkspaceId;

              return InkWell(
                onTap: () {
                  context.goNamed(
                    RouteNames.workspaceDetails,
                    pathParameters: {'workspaceId': workspace.id},
                    extra: workspace.name,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.darkSidebarActive
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.workspaces,
                        color: isSelected
                            ? Colors.white
                            : AppColors.darkTextSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          workspace.name,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.darkTextSecondary,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionsSection(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SectionsCubit>()..loadSections(selectedWorkspaceId!),
      child: BlocBuilder<SectionsCubit, SectionsState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    const Text(
                      'SECTIONS',
                      style: TextStyle(
                        color: AppColors.darkTextMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    if (onCreateSection != null)
                      InkWell(
                        onTap: onCreateSection,
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.add,
                            color: AppColors.darkTextMuted,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Root Memory Boxes Item
              _buildSectionItem(
                context,
                icon: Icons.home_outlined,
                title: 'All Notes',
                isSelected: selectedSectionId == null,
                onTap: () {
                  context.goNamed(
                    RouteNames.workspaceDetails,
                    pathParameters: {'workspaceId': selectedWorkspaceId!},
                  );
                },
              ),

              // Sections List
              if (state.status == SectionsStatus.loading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.darkTextSecondary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              else if (state.sections.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'No sections yet',
                    style: TextStyle(
                      color: AppColors.darkTextMuted,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: state.sections.length,
                    itemBuilder: (context, index) {
                      final section = state.sections[index];
                      final isSelected = section.id == selectedSectionId;

                      return _buildSectionItem(
                        context,
                        icon: Icons.folder_outlined,
                        title: section.title,
                        isSelected: isSelected,
                        onTap: () {
                          context.goNamed(
                            RouteNames.memoryBoxList,
                            pathParameters: {
                              'workspaceId': selectedWorkspaceId!,
                              'sectionId': section.id,
                            },
                            extra: {'sectionTitle': section.title},
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkSidebarActive : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.darkTextSecondary,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.darkTextSecondary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              user?.email.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.email.split('@').first ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Online',
                  style: TextStyle(color: AppColors.success, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.read<AuthCubit>().signOut(),
            icon: const Icon(Icons.logout, color: AppColors.darkTextSecondary),
            iconSize: 18,
          ),
        ],
      ),
    );
  }
}
