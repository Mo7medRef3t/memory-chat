import 'package:equatable/equatable.dart';

enum CreateSectionStatus { initial, loading, success, failure }

class CreateSectionState extends Equatable {
  final CreateSectionStatus status;
  final String? errorMessage;

  const CreateSectionState({
    this.status = CreateSectionStatus.initial,
    this.errorMessage,
  });

  CreateSectionState copyWith({
    CreateSectionStatus? status,
    String? errorMessage,
  }) {
    return CreateSectionState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
