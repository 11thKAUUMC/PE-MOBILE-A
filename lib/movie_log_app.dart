import 'data/session/learning_member_session.dart';
import 'core/network/movie_log_client.dart';
import 'data/services/sign_up_service.dart';
import 'data/services/rating_api_service.dart';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import 'core/network/tmdb_client.dart';
import 'data/services/tmdb_movie_service.dart';

import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'router/app_router.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LearningMemberSession()),
        Provider<Dio>(
          create: (_) => createMovieLogClient(),
          dispose: (_, dio) => dio.close(),
        ),
        Provider<SignUpService>(
          create: (context) => SignUpService(context.read<Dio>()),
        ),
        Provider<RatingApiService>(
          create: (context) => RatingApiService(context.read<Dio>()),
        ),
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MovieLog',
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
