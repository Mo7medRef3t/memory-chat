import 'package:equatable/equatable.dart';

class SectionEntity extends Equatable {
  final String id;
  final String workspaceId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const SectionEntity({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id,
    workspaceId,
    title,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
