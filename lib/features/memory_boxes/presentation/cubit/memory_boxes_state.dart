import 'package:equatable/equatable.dart';
import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';

enum MemoryBoxesStatus { initial, loading, success, failure }

class MemoryBoxesState extends Equatable {
  final MemoryBoxesStatus status;
  final List<MemoryBoxEntity> memoryBoxes;
  final String? errorMessage;

  const MemoryBoxesState({
    this.status = MemoryBoxesStatus.initial,
    this.memoryBoxes = const [],
    this.errorMessage,
  });

  MemoryBoxesState copyWith({
    MemoryBoxesStatus? status,
    List<MemoryBoxEntity>? memoryBoxes,
    String? errorMessage,
  }) {
    return MemoryBoxesState(
      status: status ?? this.status,
      memoryBoxes: memoryBoxes ?? this.memoryBoxes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, memoryBoxes, errorMessage];
}
