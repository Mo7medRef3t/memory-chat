import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:memory_chat/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:memory_chat/features/auth/domain/usecases/watch_auth_state_usecase.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final WatchAuthStateUseCase watchAuthStateUseCase;
  final SignOutUseCase signOutUseCase;

  StreamSubscription? _subscription;

  AuthCubit({
    required this.getCurrentUserUseCase,
    required this.watchAuthStateUseCase,
    required this.signOutUseCase,
  }) : super(const AuthState.initial());

  Future<void> initialize() async {
    final user = await getCurrentUserUseCase();

    if (user != null) {
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }

    _subscription?.cancel();
    _subscription = watchAuthStateUseCase().listen((user) {
      if (user != null) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
      } else {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    });
  }

  Future<void> signOut() async {
    await signOutUseCase();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
