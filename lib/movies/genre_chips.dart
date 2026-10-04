import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GenreChips extends StatelessWidget {
  const GenreChips({
    super.key,
    required this.genres,
    required this.selectedGenre,
    required this.onSelected,
  });

  final List<String> genres;
  final String? selectedGenre;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = <String?>[null, ...genres];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = items[index];
          final selected = genre == selectedGenre;

          return ChoiceChip(
            label: Text(genre ?? '전체'),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => onSelected(genre),
            selectedColor: AppColors.violet,
            backgroundColor: AppColors.chipUnselected,
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.darkGray,
            ),
          );
        },
      ),
    );
  }
}
