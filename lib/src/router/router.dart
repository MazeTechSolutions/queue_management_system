import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:queue_management_system/src/features/auth/presentation/admin_list.dart';
import 'package:queue_management_system/src/features/auth/presentation/admin_setup_screen.dart.dart';
import 'package:queue_management_system/src/features/auth/presentation/not_found_screen.dart';
import 'package:queue_management_system/src/features/auth/presentation/welcome_screen.dart';
import 'package:queue_management_system/src/features/auth/presentation/login_screen.dart';
import 'package:queue_management_system/src/features/queue/presentation/home_screen.dart';

enum AppRoute {
  welcome,
  login,
  adminSetup,
  home,
  notFound,
  adminListScreen,
}

final isLoggedInProvider = StateProvider<bool>((ref) => false);

final goRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(isLoggedInProvider);
  return GoRouter(
    initialLocation: '/welcome',
    // refreshListenable: GoRouterRefreshStream(ref.read(authStateProvider.stream)),
    redirect: (context, state) {
      final isLoggedIn = ref.read(isLoggedInProvider);
      if (isLoggedIn) {
        return '/home';
      }
      return null;
    },
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/welcome',
        name: AppRoute.welcome.name,
        builder: (context, state) => const WelcomScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin-setup',
        name: AppRoute.adminSetup.name,
        builder: (context, state) => AdminSetupScreen(
          onSetupComplete: () {
            // Navigate to the welcome screen after admin setup is complete
            context.goNamed(AppRoute.welcome.name);
          },
        ),
      ),
      GoRoute(
        path: '/admin-list',
        name: AppRoute.adminListScreen.name,
        builder: (context, state) => const AdminListScreen(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home.name,
        builder: (context, state) => HomeScreen(),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: const NotFoundScreen(),
    ),
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
