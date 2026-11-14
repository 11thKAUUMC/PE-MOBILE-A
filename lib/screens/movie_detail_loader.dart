import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import 'movie_detail_screen.dart';

class MovieDetailLoader extends StatefulWidget {
  const MovieDetailLoader({super.key, required this.movieId});

  final int movieId;

  @override
  State<MovieDetailLoader> createState() => _MovieDetailLoaderState();
}

class _MovieDetailLoaderState extends State<MovieDetailLoader> {
  late Future<TmdbMovieDto> _movie = _fetch();

  Future<TmdbMovieDto> _fetch() =>
      context.read<TmdbMovieService>().fetchMovieDetail(widget.movieId);

  @override
  Widget build(BuildContext context) => FutureBuilder<TmdbMovieDto>(
    future: _movie,
    builder: (context, snapshot) {
      if (snapshot.data case final movie?) {
        return MovieDetailScreen(
          movieId: movie.id,
          movie: movie.toMovie(const []),
        );
      }
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: snapshot.hasError
              ? TextButton(
                  onPressed: () => setState(() => _movie = _fetch()),
                  child: const Text('영화를 불러오지 못했습니다. 다시 시도'),
                )
              : const CircularProgressIndicator(),
        ),
      );
    },
  );
}
