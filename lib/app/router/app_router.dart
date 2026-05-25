import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/core/utils/go_router_refresh_stream.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:memory_chat/features/auth/presentation/cubit/auth_state.dart';
import 'package:memory_chat/features/auth/presentation/pages/app_entry_page.dart';
import 'package:memory_chat/features/auth/presentation/pages/login_page.dart';
import 'package:memory_chat/features/auth/presentation/pages/signup_page.dart';
import 'package:memory_chat/features/chat/presentation/pages/chat_page.dart';
import 'package:memory_chat/features/notes/presentation/pages/note_editor_page.dart';
import 'package:memory_chat/features/notes/presentation/pages/note_list_page.dart';
import 'package:memory_chat/features/workspaces/presentation/pages/workspace_list_page.dart';
import 'package:memory_chat/features/workspaces/presentation/pages/workspace_details_page.dart';
import 'package:memory_chat/features/memory_boxes/presentation/pages/memory_box_list_page.dart';
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
        if (isGoingToLogin || isGoingToSignup) {
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
      GoRoute(
        path: '/workspaces/:workspaceId',
        name: RouteNames.workspaceDetails,
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId']!;
          final workspaceName = state.extra as String?;

          return WorkspaceDetailsPage(
            workspaceId: workspaceId,
            workspaceName: workspaceName,
          );
        },
      ),
      GoRoute(
        path: '/workspaces/:workspaceId/sections/:sectionId/memory-boxes',
        name: RouteNames.memoryBoxList,
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId']!;
          final sectionId = state.pathParameters['sectionId']!;
          final extra = state.extra as Map<String, dynamic>?;

          return MemoryBoxListPage(
            workspaceId: workspaceId,
            sectionId: sectionId,
            sectionTitle: extra?['sectionTitle'] as String?,
            workspaceName: extra?['workspaceName'] as String?,
          );
        },
      ),
      GoRoute(
        path:
            '/workspaces/:workspaceId/sections/:sectionId/memory-boxes/:memoryBoxId/notes',
        name: RouteNames.noteList,
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId']!;
          final sectionId = state.pathParameters['sectionId']!;
          final memoryBoxId = state.pathParameters['memoryBoxId']!;
          final extra = state.extra as Map<String, dynamic>?;

          return NoteListPage(
            workspaceId: workspaceId,
            sectionId: sectionId,
            memoryBoxId: memoryBoxId,
            memoryBoxTitle: extra?['memoryBoxTitle'] as String?,
            sectionTitle: extra?['sectionTitle'] as String?,
          );
        },
      ),
      GoRoute(
        path:
            '/workspaces/:workspaceId/sections/:sectionId/memory-boxes/:memoryBoxId/notes/editor',
        name: RouteNames.noteEditor,
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId']!;
          final sectionId = state.pathParameters['sectionId']!;
          final memoryBoxId = state.pathParameters['memoryBoxId']!;
          final extra = state.extra as Map<String, dynamic>?;

          return NoteEditorPage(
            workspaceId: workspaceId,
            sectionId: sectionId,
            memoryBoxId: memoryBoxId,
            noteId: extra?['noteId'] as String?,
            initialTitle: extra?['title'] as String?,
            initialContent: extra?['content'] as String?,
            memoryBoxTitle: extra?['memoryBoxTitle'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/workspace/:workspaceId/chat',
        name: 'workspaceChat',
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId']!;
          return ChatPage(workspaceId: workspaceId);
        },
      ),
    ],
  );
}
