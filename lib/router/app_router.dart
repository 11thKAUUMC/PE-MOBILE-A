import 'package:go_router/go_router.dart';

import '../screens/start_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/my_page_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/start', // 워크북 Step 1 지침: 시작 화면 경로 지정
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // 탭 화면들을 감싸는 ShellRoute (NavigationBar 유지)
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(
            currentIndex: _indexFromLocation(state.uri.path),
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
              // Path Parameter :movieId 설정
              GoRoute(
                path: ':movieId',
                builder: (context, state) {
                  final movieId = state.pathParameters['movieId'];
                  return MovieDetailScreen(movieId: movieId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const MyPageScreen(),
          ),
        ],
      ),
    ],
  );

  // URL 경로에 맞춰 NavigationBar의 selectedIndex 계산
  static int _indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;
    return 0;
  }
}
