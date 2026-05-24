import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:memory_chat/features/auth/presentation/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final SignInUseCase signInUseCase;

  LoginCubit(this.signInUseCase) : super(const LoginState());

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));
    try {
      await signInUseCase(email: email, password: password);
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
