import 'package:equatable/equatable.dart';

class WorkspaceEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkspaceEntity({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    ownerId,
    createdAt,
    updatedAt,
  ];
}
