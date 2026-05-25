import 'package:equatable/equatable.dart';
import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';

enum SectionsStatus { initial, loading, success, failure }

class SectionsState extends Equatable {
  final SectionsStatus status;
  final List<SectionEntity> sections;
  final String? errorMessage;

  const SectionsState({
    this.status = SectionsStatus.initial,
    this.sections = const [],
    this.errorMessage,
  });

  SectionsState copyWith({
    SectionsStatus? status,
    List<SectionEntity>? sections,
    String? errorMessage,
  }) {
    return SectionsState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, sections, errorMessage];
}
