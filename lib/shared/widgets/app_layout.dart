import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/workspace_list_cubit.dart';
import 'app_sidebar.dart';

class AppLayout extends StatelessWidget {
  final String? selectedWorkspaceId;
  final String? selectedSectionId;
  final Widget child;
  final VoidCallback? onCreateWorkspace;
  final VoidCallback? onCreateSection;
  final PreferredSizeWidget? appBar;

  const AppLayout({
    super.key,
    this.selectedWorkspaceId,
    this.selectedSectionId,
    required this.child,
    this.onCreateWorkspace,
    this.onCreateSection,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState.user?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<WorkspaceListCubit>()..loadWorkspaces(currentUserId),
        ),
      ],
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: appBar,
      drawer: Drawer(
        width: 280,
        child: SafeArea(
          child: AppSidebar(
            selectedWorkspaceId: selectedWorkspaceId,
            selectedSectionId: selectedSectionId,
            onCreateWorkspace: onCreateWorkspace,
            onCreateSection: onCreateSection,
          ),
        ),
      ),
      body: child,
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          AppSidebar(
            selectedWorkspaceId: selectedWorkspaceId,
            selectedSectionId: selectedSectionId,
            onCreateWorkspace: onCreateWorkspace,
            onCreateSection: onCreateSection,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
