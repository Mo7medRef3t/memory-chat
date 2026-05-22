import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import 'package:memory_chat/core/utils/id_generator.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl.registerLazySingleton<Uuid>(() => const Uuid());
  sl.registerLazySingleton<IdGenerator>(() => IdGenerator(sl<Uuid>()));
}
