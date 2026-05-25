import 'package:equatable/equatable.dart';

enum CreateWorkspaceStatus { initial, loading, success, failure }

class CreateWorkspaceState extends Equatable {
  final CreateWorkspaceStatus status;
  final String? errorMessage;

  const CreateWorkspaceState({
    this.status = CreateWorkspaceStatus.initial,
    this.errorMessage,
  });

  CreateWorkspaceState copyWith({
    CreateWorkspaceStatus? status,
    String? errorMessage,
  }) {
    return CreateWorkspaceState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
