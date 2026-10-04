import 'package:go_router/go_router.dart';

import '../home/home_screen.dart';
import '../movie_detail/movie_detail_screen.dart';
import '../sign_up/sign_up_screen.dart';
import '../start_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
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
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) =>
            MovieDetailScreen(movieId: state.pathParameters['movieId']!),
      ),
    ],
  );
}
