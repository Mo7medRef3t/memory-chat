import 'package:equatable/equatable.dart';
import 'package:memory_chat/features/auth/domain/entities/app_user.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;

  const AuthState({required this.status, this.user});

  const AuthState.initial() : status = AuthStatus.initial, user = null;

  AuthState copyWith({AuthStatus? status, AppUser? user}) {
    return AuthState(status: status ?? this.status, user: user ?? this.user);
  }

  @override
  List<Object?> get props => [status, user];
}
