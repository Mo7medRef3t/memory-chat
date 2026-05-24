import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/app/router/app_router.dart';
import 'package:memory_chat/app/theme/app_theme.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';

class MemoryChatApp extends StatelessWidget {
  const MemoryChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>(),
      child: MaterialApp.router(
        title: 'Memory Chat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
