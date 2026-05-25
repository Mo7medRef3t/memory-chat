import 'package:equatable/equatable.dart';
import 'package:memory_chat/features/workspaces/domain/entities/workspace_entity.dart';

enum WorkspaceListStatus { initial, loading, success, failure }

class WorkspaceListState extends Equatable {
  final WorkspaceListStatus status;
  final List<WorkspaceEntity> workspaces;
  final String? errorMessage;

  const WorkspaceListState({
    this.status = WorkspaceListStatus.initial,
    this.workspaces = const [],
    this.errorMessage,
  });

  WorkspaceListState copyWith({
    WorkspaceListStatus? status,
    List<WorkspaceEntity>? workspaces,
    String? errorMessage,
  }) {
    return WorkspaceListState(
      status: status ?? this.status,
      workspaces: workspaces ?? this.workspaces,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, workspaces, errorMessage];
}
