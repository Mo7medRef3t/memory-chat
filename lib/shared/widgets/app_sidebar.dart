import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/app/theme/app_colors.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/workspace_list_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/workspace_list_state.dart';

class AppSidebar extends StatelessWidget {
  final String? selectedWorkspaceId;
  final VoidCallback? onCreateWorkspace;

  const AppSidebar({
    super.key,
    this.selectedWorkspaceId,
    this.onCreateWorkspace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.darkSidebarBg,
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(color: AppColors.darkDivider, height: 1),
          Expanded(
            child: BlocBuilder<WorkspaceListCubit, WorkspaceListState>(
              builder: (context, state) {
                if (state.status == WorkspaceListStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.darkTextSecondary,
                    ),
                  );
                }

                if (state.workspaces.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.workspaces_outlined,
                          color: AppColors.darkTextMuted,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No workspaces yet',
                          style: TextStyle(color: AppColors.darkTextMuted),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: onCreateWorkspace,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Create Workspace'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.workspaces.length,
                  itemBuilder: (context, index) {
                    final workspace = state.workspaces[index];
                    final isSelected = workspace.id == selectedWorkspaceId;

                    return _buildWorkspaceItem(
                      context,
                      workspace.name,
                      isSelected,
                      onTap: () {
                        context.goNamed(
                          RouteNames.workspaceDetails,
                          pathParameters: {'workspaceId': workspace.id},
                          extra: workspace.name,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
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

  Widget _buildWorkspaceItem(
    BuildContext context,
    String name,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkSidebarActive : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              Icons.workspaces,
              color: isSelected ? Colors.white : AppColors.darkTextSecondary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
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
