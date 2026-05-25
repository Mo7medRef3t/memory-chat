import 'package:equatable/equatable.dart';

class MemoryBoxEntity extends Equatable {
  final String id;
  final String sectionId;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const MemoryBoxEntity({
    required this.id,
    required this.sectionId,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id,
    sectionId,
    title,
    description,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
