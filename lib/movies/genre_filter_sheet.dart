import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GenreFilterSheet extends StatefulWidget {
  const GenreFilterSheet({
    super.key,
    required this.genres,
    required this.initialSelected,
    required this.scrollController,
  });

  final List<String> genres;
  final Set<String> initialSelected;
  final ScrollController scrollController;

  static Future<Set<String>?> show(
    BuildContext context, {
    required List<String> genres,
    required Set<String> selected,
  }) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.warmWhite,
      showDragHandle: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return GenreFilterSheet(
              genres: genres,
              initialSelected: selected,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  @override
  State<GenreFilterSheet> createState() => _GenreFilterSheetState();
}

class _GenreFilterSheetState extends State<GenreFilterSheet> {
  late final Set<String> _selected = {...widget.initialSelected};

  void _toggle(String genre, bool checked) {
    setState(() {
      if (checked) {
        _selected.add(genre);
      } else {
        _selected.remove(genre);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Text('장르 선택', style: AppTextStyles.titleMedium),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: widget.genres.length,
            itemBuilder: (context, index) {
              final genre = widget.genres[index];

              return CheckboxListTile(
                value: _selected.contains(genre),
                onChanged: (checked) => _toggle(genre, checked ?? false),
                title: Text(genre, style: AppTextStyles.bodyMedium),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, {..._selected}),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
              child: const Text('확인'),
            ),
          ),
        ),
      ],
    );
  }
}
