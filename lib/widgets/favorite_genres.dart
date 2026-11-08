import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/week06_style.dart';

class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key});

  @override
  Widget build(BuildContext context) {
    const genres = ['드라마', 'SF', '애니메이션'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('선호하는 장르', style: Week06Style.text(17, weight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final genre in genres)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 8,
                ),
                decoration: const ShapeDecoration(
                  color: Color(0xFFEADCFD),
                  shape: StadiumBorder(),
                ),
                child: Text(
                  genre,
                  style: Week06Style.text(
                    13,
                    color: AppColors.violet,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
