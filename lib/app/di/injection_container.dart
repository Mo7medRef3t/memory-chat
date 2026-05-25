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

import 'package:memory_chat/features/workspaces/data/datasources/workspaces_remote_data_source.dart';
import 'package:memory_chat/features/workspaces/data/repositories/workspaces_repository_impl.dart';
import 'package:memory_chat/features/workspaces/domain/repositories/workspaces_repository.dart';
import 'package:memory_chat/features/workspaces/domain/usecases/create_workspace_usecase.dart';
import 'package:memory_chat/features/workspaces/domain/usecases/get_user_workspaces_usecase.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/create_workspace_cubit.dart';
import 'package:memory_chat/features/workspaces/presentation/cubit/workspace_list_cubit.dart';

import 'package:memory_chat/features/sections/data/datasources/sections_remote_data_source.dart';
import 'package:memory_chat/features/sections/data/repositories/sections_repository_impl.dart';
import 'package:memory_chat/features/sections/domain/repositories/sections_repository.dart';
import 'package:memory_chat/features/sections/domain/usecases/create_section_usecase.dart';
import 'package:memory_chat/features/sections/domain/usecases/delete_section_usecase.dart';
import 'package:memory_chat/features/sections/domain/usecases/get_sections_usecase.dart';
import 'package:memory_chat/features/sections/domain/usecases/rename_section_usecase.dart';
import 'package:memory_chat/features/sections/presentation/cubit/create_section_cubit.dart';
import 'package:memory_chat/features/sections/presentation/cubit/sections_cubit.dart';

import 'package:memory_chat/features/memory_boxes/data/datasources/memory_boxes_remote_data_source.dart';
import 'package:memory_chat/features/memory_boxes/data/repositories/memory_boxes_repository_impl.dart';
import 'package:memory_chat/features/memory_boxes/domain/repositories/memory_boxes_repository.dart';
import 'package:memory_chat/features/memory_boxes/domain/usecases/create_memory_box_usecase.dart';
import 'package:memory_chat/features/memory_boxes/domain/usecases/delete_memory_box_usecase.dart';
import 'package:memory_chat/features/memory_boxes/domain/usecases/get_memory_boxes_usecase.dart';
import 'package:memory_chat/features/memory_boxes/domain/usecases/update_memory_box_usecase.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/create_memory_box_cubit.dart';
import 'package:memory_chat/features/memory_boxes/presentation/cubit/memory_boxes_cubit.dart';

import 'package:memory_chat/features/notes/data/datasources/notes_remote_data_source.dart';
import 'package:memory_chat/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:memory_chat/features/notes/domain/repositories/notes_repository.dart';
import 'package:memory_chat/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:memory_chat/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:memory_chat/features/notes/domain/usecases/get_note_by_id_usecase.dart';
import 'package:memory_chat/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:memory_chat/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:memory_chat/features/notes/presentation/cubit/note_editor_cubit.dart';
import 'package:memory_chat/features/notes/presentation/cubit/notes_cubit.dart';

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

  sl.registerLazySingleton<WorkspacesRemoteDataSource>(
    () => WorkspacesRemoteDataSource(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<WorkspacesRepository>(
    () => WorkspacesRepositoryImpl(
      remoteDataSource: sl<WorkspacesRemoteDataSource>(),
      idGenerator: sl<IdGenerator>(),
    ),
  );

  sl.registerLazySingleton(
    () => GetUserWorkspacesUseCase(sl<WorkspacesRepository>()),
  );

  sl.registerLazySingleton(
    () => CreateWorkspaceUseCase(sl<WorkspacesRepository>()),
  );

  sl.registerFactory(() => WorkspaceListCubit(sl<GetUserWorkspacesUseCase>()));

  sl.registerFactory(
    () => CreateWorkspaceCubit(
      createWorkspaceUseCase: sl<CreateWorkspaceUseCase>(),
      idGenerator: sl<IdGenerator>(),
    ),
  );

  sl.registerLazySingleton<SectionsRemoteDataSource>(
    () => SectionsRemoteDataSource(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<SectionsRepository>(
    () => SectionsRepositoryImpl(sl<SectionsRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => GetSectionsUseCase(sl<SectionsRepository>()));

  sl.registerLazySingleton(
    () => CreateSectionUseCase(sl<SectionsRepository>()),
  );

  sl.registerLazySingleton(
    () => RenameSectionUseCase(sl<SectionsRepository>()),
  );

  sl.registerLazySingleton(
    () => DeleteSectionUseCase(sl<SectionsRepository>()),
  );

  sl.registerFactory(
    () => SectionsCubit(
      getSectionsUseCase: sl<GetSectionsUseCase>(),
      renameSectionUseCase: sl<RenameSectionUseCase>(),
      deleteSectionUseCase: sl<DeleteSectionUseCase>(),
    ),
  );

  sl.registerFactory(
    () => CreateSectionCubit(
      createSectionUseCase: sl<CreateSectionUseCase>(),
      idGenerator: sl<IdGenerator>(),
    ),
  );

  sl.registerLazySingleton<MemoryBoxesRemoteDataSource>(
    () => MemoryBoxesRemoteDataSource(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<MemoryBoxesRepository>(
    () => MemoryBoxesRepositoryImpl(sl<MemoryBoxesRemoteDataSource>()),
  );

  sl.registerLazySingleton(
    () => GetMemoryBoxesUseCase(sl<MemoryBoxesRepository>()),
  );

  sl.registerLazySingleton(
    () => CreateMemoryBoxUseCase(sl<MemoryBoxesRepository>()),
  );

  sl.registerLazySingleton(
    () => UpdateMemoryBoxUseCase(sl<MemoryBoxesRepository>()),
  );

  sl.registerLazySingleton(
    () => DeleteMemoryBoxUseCase(sl<MemoryBoxesRepository>()),
  );

  sl.registerFactory(
    () => MemoryBoxesCubit(
      getMemoryBoxesUseCase: sl<GetMemoryBoxesUseCase>(),
      updateMemoryBoxUseCase: sl<UpdateMemoryBoxUseCase>(),
      deleteMemoryBoxUseCase: sl<DeleteMemoryBoxUseCase>(),
    ),
  );

  sl.registerFactory(
    () => CreateMemoryBoxCubit(
      createMemoryBoxUseCase: sl<CreateMemoryBoxUseCase>(),
      idGenerator: sl<IdGenerator>(),
    ),
  );

  sl.registerLazySingleton<NotesRemoteDataSource>(
    () => NotesRemoteDataSource(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(sl<NotesRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => GetNotesUseCase(sl<NotesRepository>()));

  sl.registerLazySingleton(() => GetNoteByIdUseCase(sl<NotesRepository>()));

  sl.registerLazySingleton(() => CreateNoteUseCase(sl<NotesRepository>()));

  sl.registerLazySingleton(() => UpdateNoteUseCase(sl<NotesRepository>()));

  sl.registerLazySingleton(() => DeleteNoteUseCase(sl<NotesRepository>()));

  sl.registerFactory(
    () => NotesCubit(
      getNotesUseCase: sl<GetNotesUseCase>(),
      deleteNoteUseCase: sl<DeleteNoteUseCase>(),
    ),
  );

  sl.registerFactory(
    () => NoteEditorCubit(
      createNoteUseCase: sl<CreateNoteUseCase>(),
      updateNoteUseCase: sl<UpdateNoteUseCase>(),
      idGenerator: sl<IdGenerator>(),
    ),
  );
}
