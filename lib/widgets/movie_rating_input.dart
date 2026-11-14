import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../theme/app_colors.dart';

class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  final double rating;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return RatingBar(
      initialRating: rating,
      minRating: 1,
      itemCount: 5,
      itemSize: 36,
      ratingWidget: RatingWidget(
        full: const Icon(Icons.star, color: AppColors.violet),
        half: const Icon(Icons.star_half, color: AppColors.violet),
        empty: const Icon(Icons.star_border, color: AppColors.violet),
      ),
      onRatingUpdate: onChanged,
    );
  }
}
