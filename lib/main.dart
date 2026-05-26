import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:memory_chat/app/app.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/core/constants/env_keys.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env[EnvKeys.supabaseUrl] ?? '',
    anonKey: dotenv.env[EnvKeys.supabasePublishableKey] ?? '',
  );

  await configureDependencies();


  await sl<AuthCubit>().initialize();

  runApp(const MemoryChatApp());
}