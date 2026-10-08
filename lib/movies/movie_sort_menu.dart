import 'package:flutter/material.dart';

import '../models/movie_sort.dart';
import '../theme/app_colors.dart';

class MovieSortMenu extends StatelessWidget {
  const MovieSortMenu({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final MovieSort selected;
  final ValueChanged<MovieSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MovieSort>(
      tooltip: '정렬',
      initialValue: selected,
      onSelected: onSelected,
      icon: const Icon(Icons.sort, color: AppColors.violet),
      itemBuilder: (context) => [
        for (final sort in MovieSort.values)
          CheckedPopupMenuItem(
            value: sort,
            checked: sort == selected,
            child: Text(sort.label),
          ),
      ],
    );
  }
}
