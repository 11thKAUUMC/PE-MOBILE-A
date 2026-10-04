import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../home/home_screen.dart';
import '../main/main_screen.dart';
import '../movie_detail/movie_detail_screen.dart';
import '../movies/movie_list_screen.dart';
import '../profile/profile_screen.dart';
import '../sign_up/sign_up_screen.dart';
import '../start_screen.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/start',
    routes: [
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const SignUpScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(
            currentIndex: indexFromLocation(state.uri.path),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) => const MovieListScreen(),
            routes: [
              GoRoute(
                path: ':movieId',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => MovieDetailScreen(
                  movieId: state.pathParameters['movieId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );

  static int indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;

    return 0;
  }
}
