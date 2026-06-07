import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/create_workspace_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/pages/views/workspace_list_view.dart';

class WorkspaceListPage extends StatelessWidget {
  const WorkspaceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateWorkspaceCubit>(),
      child: const WorkspaceListView(),
    );
  }
}
