import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../widgets/movie_card.dart';

class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key, required this.movies});

  static const _crossAxisCount = 2;
  static const _horizontalPadding = 16.0;
  static const _crossAxisSpacing = 16.0;
  static const _cardTextHeight = 64.0;

  static const padding = EdgeInsets.fromLTRB(
    _horizontalPadding,
    0,
    _horizontalPadding,
    24,
  );

  static SliverGridDelegate gridDelegate(double maxWidth) {
    final itemWidth =
        (maxWidth -
            _horizontalPadding * 2 -
            _crossAxisSpacing * (_crossAxisCount - 1)) /
        _crossAxisCount;
    final itemHeight =
        itemWidth / MovieCard.posterAspectRatio + _cardTextHeight;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: _crossAxisCount,
      crossAxisSpacing: _crossAxisSpacing,
      mainAxisSpacing: 16,
      childAspectRatio: itemWidth / itemHeight,
    );
  }

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          itemCount: movies.length,
          gridDelegate: gridDelegate(constraints.maxWidth),
          itemBuilder: (context, index) => MovieCard(movie: movies[index]),
        );
      },
    );
  }
}
