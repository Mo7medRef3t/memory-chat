import 'package:memory_chat/features/auth/domain/entities/app_user.dart';
import 'package:memory_chat/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<AppUser> call({
    required String fullName,
    required String email,
    required String password,
  }) {
    return repository.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}
