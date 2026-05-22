import 'package:go_router/go_router.dart';
import 'package:memory_chat/features/auth/presentation/pages/app_entry_page.dart';
import 'package:memory_chat/features/auth/presentation/pages/login_page.dart';
import 'package:memory_chat/features/auth/presentation/pages/signup_page.dart';
import 'package:memory_chat/features/workspaces/presentation/pages/workspace_list_page.dart';

import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const AppEntryPage(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: RouteNames.signup,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/workspaces',
        name: RouteNames.workspaceList,
        builder: (context, state) => const WorkspaceListPage(),
      ),
    ],
  );
}