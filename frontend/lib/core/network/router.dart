import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/screens/email_verification_handler_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/verification_pending_screen.dart';
import '../../features/auth/presentation/screens/verification_success_screen.dart';
import '../../features/post/presentation/screens/create_post_screen.dart';
import '../../features/post/presentation/screens/feed_screen.dart';
import '../../features/post/presentation/screens/my_profile_screen.dart';
import '../../features/post/presentation/screens/search_screen.dart';
import '../../features/post/presentation/screens/user_profile_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';
import '../../features/chat/presentation/screens/new_chat_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    routes: [
      // ── Auth routes ──────────────────────────────────────────────────────
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(
        path: '/verify-email/:uid/:token',
        builder: (_, state) => EmailVerificationHandlerScreen(
          uid: state.pathParameters['uid'] ?? '',
          token: state.pathParameters['token'] ?? '',
        ),
      ),
      GoRoute(
          path: '/verify-pending',
          builder: (_, __) => const VerificationPendingScreen()),
      GoRoute(
          path: '/verify-success',
          builder: (_, __) => const VerificationSuccessScreen()),

      // ── Chat routes ──────────────────────────────────────────────────────
      GoRoute(path: '/chat', builder: (_, __) => const ChatListScreen()),
      GoRoute(path: '/chat/new', builder: (_, __) => const NewChatScreen()),
      GoRoute(
        path: '/chat/:roomId',
        builder: (_, state) {
          final roomId = int.parse(state.pathParameters['roomId']!);
          final name = state.uri.queryParameters['name'];
          return ChatRoomScreen(roomId: roomId, roomName: name);
        },
      ),

      // ── Main shell — 4 tabs: Home | Search | Create | Profile ─────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(navigationShell: shell),
        branches: [
          // Branch 0 – Feed / Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feed',
                builder: (_, __) => const FeedScreen(),
                routes: [
                  GoRoute(
                    path: 'profile/:userId',
                    builder: (_, state) {
                      final id = int.tryParse(
                              state.pathParameters['userId'] ?? '') ??
                          0;
                      return UserProfileScreen(userId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 1 – Search
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (_, __) => const SearchScreen(),
                routes: [
                  GoRoute(
                    path: 'profile/:userId',
                    builder: (_, state) {
                      final id = int.tryParse(
                              state.pathParameters['userId'] ?? '') ??
                          0;
                      return UserProfileScreen(userId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 2 – Create Post
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create',
                builder: (_, __) => const CreatePostScreen(),
              ),
            ],
          ),

          // Branch 3 – My Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/me',
                builder: (_, __) => const MyProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'profile/:userId',
                    builder: (_, state) {
                      final id = int.tryParse(
                              state.pathParameters['userId'] ?? '') ??
                          0;
                      return UserProfileScreen(userId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;

      final isAuth = auth.status == AuthStatus.authenticated;
      final isLoading = auth.status == AuthStatus.initial ||
          auth.status == AuthStatus.loading;

      if (isLoading) return loc == '/' ? null : '/';

      if (auth.status == AuthStatus.error && loc == '/') return '/login';

      if (auth.status == AuthStatus.verificationPending &&
          loc != '/verify-pending') {
        return '/verify-pending';
      }

      // Splash resolves to feed or login
      if (loc == '/') return isAuth ? '/feed' : '/login';

      // Auth users away from auth screens → feed
      if (isAuth &&
          (loc == '/login' ||
              loc == '/signup' ||
              loc == '/verify-pending')) {
        return '/feed';
      }

      // Protected shell routes → login if not authenticated
      final protected = ['/feed', '/search', '/create', '/me'];
      if (!isAuth && protected.any((p) => loc.startsWith(p))) {
        return '/login';
      }

      return null;
    },
  );
});

// ─── Bridges Riverpod → GoRouter refresh ─────────────────────────────────────
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AuthState>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
}
