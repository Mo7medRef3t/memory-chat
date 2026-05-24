import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/core/utils/go_router_refresh_stream.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_state.dart';
import 'package:memory_chat/features/auth/presentation/pages/app_entry_page.dart';
import 'package:memory_chat/features/auth/presentation/pages/login_page.dart';
import 'package:memory_chat/features/auth/presentation/pages/signup_page.dart';
import 'package:memory_chat/features/workspaces/presentation/pages/workspace_list_page.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(sl<AuthCubit>().stream),
    redirect: (context, state) {
      final authState = sl<AuthCubit>().state;
      final isLoggedIn = authState.status == AuthStatus.authenticated;

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';
      final isAtRoot = state.matchedLocation == '/';

      if (authState.status == AuthStatus.initial) {
        return isAtRoot ? null : '/';
      }

      if (!isLoggedIn) {
        if (isGoingToLogin || isGoingToSignup ) {
          return null;
        }
        return '/login';
      }

      if (isLoggedIn && (isGoingToLogin || isGoingToSignup || isAtRoot)) {
        return '/workspaces';
      }

      return null;
    },
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
