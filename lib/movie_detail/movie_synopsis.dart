import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MovieSynopsis extends StatelessWidget {
  const MovieSynopsis({super.key, required this.synopsis});

  final String synopsis;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('시놉시스', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Text(
            synopsis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15,
              color: AppColors.darkGray,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
