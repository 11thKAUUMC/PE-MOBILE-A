import 'core/network/movie_log_client.dart';
import 'data/services/member_check_service.dart';

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
        Provider<Dio>(
          create: (_) => createMovieLogClient(),
          dispose: (_, dio) => dio.close(),
        ),
        Provider<MemberCheckService>(
          create: (context) => MemberCheckService(context.read<Dio>()),
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
