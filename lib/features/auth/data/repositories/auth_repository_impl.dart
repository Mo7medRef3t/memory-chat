import 'package:memory_chat/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:memory_chat/features/auth/domain/entities/app_user.dart';
import 'package:memory_chat/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Stream<AppUser?> authStateChanges() {
    return remoteDataSource.authStateChanges().map((event) {
      final user = event.session?.user;
      if (user == null) return null;

      return AppUser(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String?,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
      );
    });
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = remoteDataSource.getCurrentAuthUser();
    if (user == null) return null;

    return AppUser(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.signIn(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Login failed');
    }

    return AppUser(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }

  @override
  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Signup failed');
    }

    return AppUser(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }
}
