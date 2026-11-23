import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/network/movie_log_client.dart';
import 'core/network/tmdb_client.dart';
import 'core/storage/saved_email_store.dart';
import 'core/storage/token_storage.dart';
import 'data/services/auth_api_service.dart';
import 'data/services/member_api_service.dart';
import 'data/services/rating_api_service.dart';
import 'data/services/sign_up_service.dart';
import 'data/services/tmdb_movie_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/session_ratings_store.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({
    super.key,
    this.tmdbMovieService,
    this.signUpService,
    this.ratingApiService,
    this.authApiService,
    this.memberApiService,
    this.tokenStorage,
    this.authViewModel,
    this.sessionRatingsStore,
    this.savedEmailStore,
  });

  /// 테스트에서 Fake 서비스를 주입할 때 사용합니다.
  final TmdbMovieService? tmdbMovieService;
  final SignUpService? signUpService;
  final RatingApiService? ratingApiService;
  final AuthApiService? authApiService;
  final MemberApiService? memberApiService;
  final TokenStorage? tokenStorage;
  final AuthViewModel? authViewModel;
  final SessionRatingsStore? sessionRatingsStore;
  final SavedEmailStore? savedEmailStore;

  @override
  Widget build(BuildContext context) {
    final storage = tokenStorage ?? SecureTokenStorage(const FlutterSecureStorage());
    final publicClient = createMovieLogClient();
    final authClient = createAuthMovieLogClient(storage);
    final sessionRatings = sessionRatingsStore ?? SessionRatingsStore();

    return MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: storage),
        Provider<SavedEmailStore>(
          create: (_) => savedEmailStore ?? SavedEmailStore(),
        ),
        ChangeNotifierProvider<SessionRatingsStore>.value(value: sessionRatings),
        Provider<TmdbMovieService>(
          create: (_) =>
              tmdbMovieService ?? TmdbMovieService(createTmdbClient()),
        ),
        Provider<AuthApiService>(
          create: (_) => authApiService ?? AuthApiService(publicClient),
        ),
        Provider<SignUpService>(
          create: (_) => signUpService ?? SignUpService(publicClient),
        ),
        Provider<MemberApiService>(
          create: (_) => memberApiService ?? MemberApiService(authClient),
        ),
        Provider<RatingApiService>(
          create: (_) =>
              ratingApiService ?? RatingApiService(publicClient, authClient),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) =>
              authViewModel ??
              AuthViewModel(
                context.read<AuthApiService>(),
                context.read<MemberApiService>(),
                context.read<TokenStorage>(),
                sessionRatings: context.read<SessionRatingsStore>(),
              ),
        ),
      ],
      child: const _MovieLogRouterApp(),
    );
  }
}

class _MovieLogRouterApp extends StatefulWidget {
  const _MovieLogRouterApp();

  @override
  State<_MovieLogRouterApp> createState() => _MovieLogRouterAppState();
}

class _MovieLogRouterAppState extends State<_MovieLogRouterApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authViewModel = context.read<AuthViewModel>();
    _router = AppRouter.createRouter(authViewModel);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) authViewModel.restoreSession();
    });
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
