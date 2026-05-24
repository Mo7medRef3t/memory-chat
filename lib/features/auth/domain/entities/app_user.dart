import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, fullName, avatarUrl];
}