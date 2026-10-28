import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import '../home/home_screen.dart';
import '../main/main_screen.dart';
import '../movie_detail/movie_detail_screen.dart';
import '../movies/movie_list_screen.dart';
import '../profile/profile_screen.dart';
import '../sign_up/sign_up_screen.dart';
import '../start_screen.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/start',
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const SignUpScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) =>
                    ChangeNotifierProvider<MovieHomeViewModel>(
                      create: (context) => MovieHomeViewModel(
                        context.read<TmdbMovieService>(),
                      )..loadPopular(),
                      child: const HomeScreen(),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/movies',
                builder: (context, state) =>
                    ChangeNotifierProvider<MovieListViewModel>(
                      create: (context) => MovieListViewModel(
                        context.read<TmdbMovieService>(),
                      )..loadInitial(),
                      child: const MovieListScreen(),
                    ),
                routes: [
                  GoRoute(
                    path: ':movieId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final extra = state.extra;
                      return MovieDetailScreen(
                        movieId: state.pathParameters['movieId']!,
                        movie: extra is TmdbMovieDto ? extra : null,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
