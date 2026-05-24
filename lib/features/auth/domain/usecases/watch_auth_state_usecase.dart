import 'package:memory_chat/features/auth/domain/entities/app_user.dart';
import 'package:memory_chat/features/auth/domain/repositories/auth_repository.dart';

class WatchAuthStateUseCase {
  final AuthRepository repository;

  WatchAuthStateUseCase(this.repository);

  Stream<AppUser?> call() {
    return repository.authStateChanges();
  }
}
