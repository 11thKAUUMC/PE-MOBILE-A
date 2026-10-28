import 'package:flutter/material.dart';

import '../widgets/tmdb_poster_image.dart';

class MovieDetailHeader extends StatelessWidget {
  const MovieDetailHeader({super.key, required this.posterPath});

  final String? posterPath;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.9,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return TmdbPosterImage(
            posterPath: posterPath,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
          );
        },
      ),
    );
  }
}
