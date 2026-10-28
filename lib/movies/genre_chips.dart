import 'package:flutter/material.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../theme/app_colors.dart';

class GenreChips extends StatelessWidget {
  const GenreChips({
    super.key,
    required this.genres,
    required this.selectedGenreIds,
    required this.onSelected,
    this.enabled = true,
  });

  final List<TmdbGenreDto> genres;
  final List<int> selectedGenreIds;
  final ValueChanged<int?> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final items = <({int? id, String name})>[
      (id: null, name: '전체'),
      ...genres.map((genre) => (id: genre.id, name: genre.name)),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item.id == null
              ? selectedGenreIds.isEmpty
              : selectedGenreIds.length == 1 &&
                    selectedGenreIds.first == item.id;

          return ChoiceChip(
            label: Text(item.name),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: AppColors.violet,
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.violet,
            ),
            onSelected: !enabled
                ? null
                : (_) => onSelected(item.id),
          );
        },
      ),
    );
  }
}
