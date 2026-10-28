import 'package:flutter/material.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

Future<List<int>?> showGenreFilterSheet({
  required BuildContext context,
  required List<TmdbGenreDto> genres,
  required List<int> initiallySelected,
}) {
  return showModalBottomSheet<List<int>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return _GenreFilterSheet(
        genres: genres,
        initiallySelected: initiallySelected,
      );
    },
  );
}

class _GenreFilterSheet extends StatefulWidget {
  const _GenreFilterSheet({
    required this.genres,
    required this.initiallySelected,
  });

  final List<TmdbGenreDto> genres;
  final List<int> initiallySelected;

  @override
  State<_GenreFilterSheet> createState() => _GenreFilterSheetState();
}

class _GenreFilterSheetState extends State<_GenreFilterSheet> {
  late final Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<int>.from(widget.initiallySelected);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('장르 선택', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text(
            '여러 장르를 선택하면 OR 조건으로 검색합니다.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.45,
            ),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final genre in widget.genres)
                    FilterChip(
                      label: Text(genre.name),
                      selected: _selected.contains(genre.id),
                      selectedColor: AppColors.lavender,
                      checkmarkColor: AppColors.violet,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selected.add(genre.id);
                          } else {
                            _selected.remove(genre.id);
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(_selected.clear),
                  child: const Text('초기화'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_selected.toList()..sort()),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
