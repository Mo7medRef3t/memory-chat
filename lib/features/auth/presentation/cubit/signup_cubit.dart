import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:memory_chat/features/auth/presentation/cubit/signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final SignUpUseCase signUpUseCase;

  SignupCubit(this.signUpUseCase) : super(const SignupState());

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: SignupStatus.loading, errorMessage: null));
    try {
      await signUpUseCase(fullName: fullName, email: email, password: password);
      emit(state.copyWith(status: SignupStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: SignupStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
