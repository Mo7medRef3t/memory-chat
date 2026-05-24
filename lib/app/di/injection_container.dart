import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:memory_chat/core/services/supabase_service.dart';
import 'package:memory_chat/core/utils/id_generator.dart';

import 'package:memory_chat/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:memory_chat/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:memory_chat/features/auth/domain/repositories/auth_repository.dart';
import 'package:memory_chat/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:memory_chat/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:memory_chat/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:memory_chat/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:memory_chat/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:memory_chat/features/auth/presentation/cubit/login_cubit.dart';
import 'package:memory_chat/features/auth/presentation/cubit/signup_cubit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl.registerLazySingleton<Uuid>(() => const Uuid());
  sl.registerLazySingleton<IdGenerator>(() => IdGenerator(sl<Uuid>()));

  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<SupabaseService>(() => SupabaseService());

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => WatchAuthStateUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()));

  sl.registerLazySingleton(
    () => AuthCubit(
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
      watchAuthStateUseCase: sl<WatchAuthStateUseCase>(),
      signOutUseCase: sl<SignOutUseCase>(),
    ),
  );

  sl.registerFactory(() => LoginCubit(sl<SignInUseCase>()));
  sl.registerFactory(() => SignupCubit(sl<SignUpUseCase>()));
}
