import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/login_screen.dart';
import '../auth/splash_screen.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/member_api_service.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../home/home_screen.dart';
import '../main/main_screen.dart';
import '../movie_detail/movie_detail_loader.dart';
import '../movies/movie_list_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/my_ratings_screen.dart';
import '../profile/profile_screen.dart';
import '../sign_up/sign_up_screen.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/session_ratings_store.dart';
import '../widgets/movielog_button.dart';
import 'auth_redirect.dart';

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: '/start',
      navigatorKey: rootNavigatorKey,
      refreshListenable: authViewModel,
      redirect: (context, state) {
        return authRedirect(authViewModel.status, state.uri.path);
      },
      routes: [
        GoRoute(
          path: '/start',
          builder: (context, state) {
            final auth = context.watch<AuthViewModel>();
            return SplashScreen(
              message: auth.message,
              onRetry: auth.status == AuthStatus.retryRequired
                  ? auth.restoreSession
                  : null,
            );
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
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
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        final id = int.tryParse(
                          state.pathParameters['movieId'] ?? '',
                        );
                        if (id == null || id < 1) {
                          return const Scaffold(
                            body: Center(child: Text('영화 ID가 올바르지 않습니다.')),
                          );
                        }
                        final extra = state.extra;
                        return MovieDetailLoader(
                          movieId: id,
                          initialMovie:
                              extra is TmdbMovieDto && extra.id == id
                              ? extra
                              : null,
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
                  routes: [
                    GoRoute(
                      path: 'ratings',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        return ChangeNotifierProvider<MyRatingsViewModel>(
                          create: (context) => MyRatingsViewModel(
                            context.read<RatingApiService>(),
                            context.read<TmdbMovieService>(),
                            context.read<SessionRatingsStore>(),
                            context.read<AuthViewModel>(),
                          )..load(),
                          child: const MyRatingsScreen(),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'profile/edit',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        final auth = context.watch<AuthViewModel>();
                        if (auth.member == null) {
                          return Scaffold(
                            appBar: AppBar(
                              centerTitle: true,
                              title: const Text('프로필 수정'),
                            ),
                            body: Center(
                              child:
                                  auth.memberStatus == MemberLoadStatus.error
                                  ? MovieLogButton(
                                      label: '다시 시도',
                                      onPressed: () =>
                                          auth.loadMember(force: true),
                                    )
                                  : const CircularProgressIndicator(),
                            ),
                          );
                        }
                        return ChangeNotifierProvider<EditProfileViewModel>(
                          create: (context) => EditProfileViewModel(
                            context.read<MemberApiService>(),
                            auth,
                          ),
                          child: const EditProfileScreen(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
