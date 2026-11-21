import '../data/models/tmdb_movie_dto.dart';
import '../screens/movie_detail_loader.dart';
import '../screens/login_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/movielog_button.dart';
import '../theme/week06_style.dart';

import 'package:flutter/material.dart';

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

  static GoRouter create(AuthViewModel auth) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    return GoRouter(
      initialLocation: '/start',
      navigatorKey: rootNavigatorKey,
      refreshListenable: auth,
      redirect: (_, state) => authRedirect(auth.status, state.uri.path),
      routes: [
        GoRoute(
          path: '/start',
          builder: (context, state) {
            final session = context.watch<AuthViewModel>();
            return StartScreen(
              sessionCheck: true,
              message: session.restoreError,
              onRetry: session.status == AuthStatus.retryRequired
                  ? session.restoreSession
                  : null,
            );
          },
        ),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, _) => const SignUpScreen()),
        GoRoute(path: '/signup', redirect: (_, _) => '/register'),
        ShellRoute(
          builder: (context, state, child) {
            final currentIndex = switch (state.uri.path) {
              '/home' => 0,
              '/movies' => 1,
              final path when path.startsWith('/my') => 2,
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
                  builder: (_, _) => const MyRatingsScreen(),
                ),
                GoRoute(
                  path: 'profile/edit',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, _) {
                    final session = context.watch<AuthViewModel>();
                    final member = session.member;
                    if (member != null) {
                      return EditProfileScreen(member: member);
                    }
                    return Scaffold(
                      backgroundColor: Week06Style.background,
                      appBar: AppBar(title: const Text('프로필 수정')),
                      body: Center(
                        child: session.memberStatus == MemberLoadStatus.error
                            ? MovieLogButton(
                                label: '다시 시도',
                                onPressed: session.loadMember,
                              )
                            : const CircularProgressIndicator(),
                      ),
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
}

String? authRedirect(AuthStatus status, String path) {
  const publicPaths = {'/login', '/register', '/signup'};
  return switch (status) {
    AuthStatus.initializing ||
    AuthStatus.retryRequired => path == '/start' ? null : '/start',
    AuthStatus.signedOut ||
    AuthStatus.authenticating => publicPaths.contains(path) ? null : '/login',
    AuthStatus.signedIn =>
      path == '/start' || publicPaths.contains(path) ? '/home' : null,
  };
}
