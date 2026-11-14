import '../data/models/tmdb_movie_dto.dart';
import '../screens/movie_detail_loader.dart';
import '../data/session/learning_member_session.dart';

import 'package:flutter/material.dart';

import '../data/services/rating_api_service.dart';
import '../view_models/my_ratings_view_model.dart';
import '../screens/my_ratings_screen.dart';

import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../data/services/tmdb_movie_service.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';

import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/start_screen.dart';
import '../widgets/main_screen.dart';

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: '/home',
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final currentIndex = switch (state.uri.path) {
            '/home' => 0,
            '/movies' => 1,
            '/my' => 2,
            _ => 0,
          };

          return MainScreen(currentIndex: currentIndex, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) =>
                  MovieHomeViewModel(context.read<TmdbMovieService>())
                    ..loadPopular(),
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) =>
                  MovieListViewModel(context.read<TmdbMovieService>())
                    ..loadInitial(),
              child: const MovieListScreen(),
            ),
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'ratings',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final session = context.watch<LearningMemberSession?>();
                  final memberId = session?.memberId;
                  if (memberId == null) return const MyRatingsScreen();
                  return ChangeNotifierProvider(
                    key: ValueKey(memberId),
                    create: (context) => MyRatingsViewModel(
                      context.read<RatingApiService>(),
                      context.read<TmdbMovieService>(),
                      memberId,
                    )..load(),
                    child: const MyRatingsScreen(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          final movieId = int.tryParse(state.pathParameters['movieId'] ?? '');

          if (movieId == null || movieId < 1) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('영화 ID가 올바르지 않습니다.')),
            );
          }
          final extra = state.extra;
          if (extra is TmdbMovieDto && extra.id == movieId) {
            return MovieDetailScreen(
              movieId: movieId,
              movie: extra.toMovie(const []),
            );
          }
          if (extra is Movie && extra.id == movieId) {
            return MovieDetailScreen(movieId: movieId, movie: extra);
          }
          return MovieDetailLoader(key: ValueKey(movieId), movieId: movieId);
        },
      ),
    ],
  );
}
