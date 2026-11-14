import '../data/models/tmdb_movie_dto.dart';

import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'movie_card.dart';

class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key, required this.movies, this.tmdbById = const {}});

  final List<Movie> movies;
  final Map<int, TmdbMovieDto> tmdbById;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: movies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.54,
      ),
      itemBuilder: (context, index) {
        return MovieCard(
          movie: movies[index],
          tmdbMovie: tmdbById[movies[index].id],
        );
      },
    );
  }
}
