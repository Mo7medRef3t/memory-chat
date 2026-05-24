import 'package:memory_chat/features/auth/domain/entities/app_user.dart';
import 'package:memory_chat/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<AppUser?> call() {
    return repository.getCurrentUser();
  }
}
