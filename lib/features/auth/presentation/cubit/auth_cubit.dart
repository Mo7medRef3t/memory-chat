import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/core/sync/powersync_service.dart';
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
      await Future.delayed(const Duration(milliseconds: 500));
      await _connectPowerSync();
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }

    _subscription?.cancel();
    _subscription = watchAuthStateUseCase().listen((user) async {
      if (user != null) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
        await _connectPowerSync();
      } else {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        await _disconnectPowerSync();
      }
    });
  }

  Future<void> signOut() async {
    await _disconnectPowerSync();

    try {
      await sl<PowerSyncService>().clearDatabase();
    } catch (_) {}

    await signOutUseCase();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _connectPowerSync() async {
    try {
      final ps = sl<PowerSyncService>();

      if (!ps.isInitialized) return;
      if (ps.isConnected) return;

      await ps.clearUploadQueue();
      await ps.connect();
    } catch (_) {}
  }

  Future<void> _disconnectPowerSync() async {
    try {
      final ps = sl<PowerSyncService>();
      if (ps.isConnected) {
        await ps.disconnect();
      }
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
