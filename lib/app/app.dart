import 'package:flutter/material.dart';
import 'package:memory_chat/app/router/app_router.dart';
import 'package:memory_chat/app/theme/app_theme.dart';
import 'package:memory_chat/core/constants/app_constants.dart';

class MemoryChatApp extends StatelessWidget {
  const MemoryChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}