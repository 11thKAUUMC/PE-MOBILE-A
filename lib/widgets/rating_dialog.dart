import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'movie_rating_input.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, this.initialRating = 0});

  final double initialRating;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double _rating = widget.initialRating;
  int _resetCount = 0;

  void _reset() {
    setState(() {
      _rating = 0;
      _resetCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasRating = _rating > 0;

    return Dialog(
      backgroundColor: AppColors.warmWhite,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '영화는 어떠셨나요?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            MovieRatingInput(
              key: ValueKey(_resetCount),
              rating: _rating,
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 12),
            Text(
              hasRating ? '${_rating.toStringAsFixed(1)}점' : '별을 눌러 평점을 선택해주세요',
              style: AppTextStyles.bodySmall.copyWith(
                color: hasRating ? AppColors.violet : AppColors.gray,
                fontWeight: hasRating ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            TextButton.icon(
              onPressed: hasRating ? _reset : null,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('초기화하고 다시 선택하기'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: hasRating
                        ? () => Navigator.pop(context, _rating)
                        : null,
                    child: const Text('확인'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
