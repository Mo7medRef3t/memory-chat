import 'package:memory_chat/features/auth/domain/entities/app_user.dart';
import 'package:memory_chat/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<AppUser> call({required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}
