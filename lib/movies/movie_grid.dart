import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../theme/app_text_styles.dart';
import '../widgets/movie_card.dart';

class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key, required this.movies});

  static const _crossAxisCount = 2;
  static const _horizontalPadding = 16.0;
  static const _crossAxisSpacing = 16.0;
  static const _cardTextHeight = 64.0;

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
        child: Text('해당 장르의 영화가 없습니다.', style: AppTextStyles.bodySmall),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth -
                _horizontalPadding * 2 -
                _crossAxisSpacing * (_crossAxisCount - 1)) /
            _crossAxisCount;
        final itemHeight =
            itemWidth / MovieCard.posterAspectRatio + _cardTextHeight;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            _horizontalPadding,
            0,
            _horizontalPadding,
            24,
          ),
          itemCount: movies.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _crossAxisCount,
            crossAxisSpacing: _crossAxisSpacing,
            mainAxisSpacing: 16,
            childAspectRatio: itemWidth / itemHeight,
          ),
          itemBuilder: (context, index) => MovieCard(movie: movies[index]),
        );
      },
    );
  }
}
