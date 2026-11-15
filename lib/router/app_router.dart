import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/services/member_check_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';

import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';

import 'package:movielog/screens/home_screen.dart';
import 'package:movielog/screens/main_screen.dart';
import 'package:movielog/screens/movie_list_screen.dart';
import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:movielog/screens/my_page_screen.dart';
import 'package:movielog/screens/my_ratings_screen.dart';
import 'package:movielog/screens/register_screen.dart';

import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:provider/provider.dart';

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: '/register',
    navigatorKey: rootNavigatorKey,

    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(
        path: '/register',
        builder: (context, state) => ChangeNotifierProvider<SignUpViewModel>(
          create: (context) =>
              SignUpViewModel(context.read<MemberCheckService>()),
          child: const RegisterScreen(),
        ),
      ),

      GoRoute(
        path: '/movies/:id',
        builder: (context, state) {
          final extra = state.extra;

          return MovieDetailScreen(
            movieId: state.pathParameters['id'],
            movie: extra is TmdbMovieDto ? extra : null,
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          final path = state.uri.path;

          final currentIndex = path.startsWith('/movies')
              ? 1
              : path.startsWith('/my')
              ? 2
              : 0;

          return MainScreen(currentIndex: currentIndex, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                ChangeNotifierProvider<MovieHomeViewModel>(
                  create: (context) =>
                      MovieHomeViewModel(context.read<TmdbMovieService>())
                        ..loadPopular(),
                  child: const HomeScreen(),
                ),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) =>
                ChangeNotifierProvider<MovieListViewModel>(
                  create: (context) =>
                      MovieListViewModel(context.read<TmdbMovieService>())
                        ..loadInitial(),
                  child: const MovieListScreen(),
                ),
          ),

          GoRoute(
            path: '/my',
            builder: (context, state) => const MyPageScreen(),
            routes: [
              GoRoute(
                path: 'ratings',

                // [추가] 하단 NavigationBar 없이 표시
                parentNavigatorKey: rootNavigatorKey,

                builder: (context, state) =>
                    ChangeNotifierProvider<MyRatingsViewModel>(
                      create: (context) => MyRatingsViewModel(
                        context.read<RatingApiService>(),
                        context.read<TmdbMovieService>(),
                        sampleMemberId,
                      )..load(),
                      child: const MyRatingsScreen(),
                    ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
