import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/network/auth_interceptor.dart';
import 'core/network/movie_log_client.dart';
import 'core/network/tmdb_client.dart';
import 'data/services/auth_api_service.dart';
import 'data/services/member_api_service.dart';
import 'data/services/rating_api_service.dart';
import 'data/services/sign_up_service.dart';
import 'data/services/tmdb_movie_service.dart';
import 'data/session/token_storage.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/my_ratings_view_model.dart';

class MovieLogApp extends StatefulWidget {
  const MovieLogApp({super.key});

  @override
  State<MovieLogApp> createState() => _MovieLogAppState();
}

class _MovieLogAppState extends State<MovieLogApp> {
  final _publicClient = createMovieLogClient();
  final _tmdbClient = createTmdbClient();
  late final _protectedClient = createMovieLogClient(
    auth: AuthInterceptor(
      session: () => _auth.credentials,
      onExpired: (version) => _auth.expireSession(version),
    ),
  );
  late final _memberApi = MemberApiService(_protectedClient);
  late final AuthViewModel _auth = AuthViewModel(
    const SecureTokenStorage(),
    AuthApiService(_publicClient),
    _memberApi,
  );
  late final _ratings = MyRatingsViewModel(
    RatingApiService(_publicClient, _protectedClient),
    _auth,
  );
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.create(_auth);
    _auth.restoreSession();
  }

  @override
  void dispose() {
    _router.dispose();
    _ratings.dispose();
    _auth.dispose();
    _protectedClient.close(force: true);
    _publicClient.close(force: true);
    _tmdbClient.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: _auth),
      ChangeNotifierProvider.value(value: _ratings),
      Provider.value(value: _memberApi),
      Provider(create: (_) => SignUpService(_publicClient)),
      Provider(create: (_) => TmdbMovieService(_tmdbClient)),
    ],
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      routerConfig: _router,
    ),
  );
}
