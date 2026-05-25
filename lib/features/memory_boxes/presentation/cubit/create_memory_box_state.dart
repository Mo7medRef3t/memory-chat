import 'package:equatable/equatable.dart';

enum CreateMemoryBoxStatus { initial, loading, success, failure }

class CreateMemoryBoxState extends Equatable {
  final CreateMemoryBoxStatus status;
  final String? errorMessage;

  const CreateMemoryBoxState({
    this.status = CreateMemoryBoxStatus.initial,
    this.errorMessage,
  });

  CreateMemoryBoxState copyWith({
    CreateMemoryBoxStatus? status,
    String? errorMessage,
  }) {
    return CreateMemoryBoxState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
