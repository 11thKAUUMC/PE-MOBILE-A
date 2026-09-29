import 'package:flutter/material.dart';

import 'movie_rating_input.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double rating = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '영화는 어떠셨나요?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            MovieRatingInput(
              rating: rating,
              onChanged: (value) {
                setState(() {
                  rating = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: rating == 0
                  ? null
                  : () {
                      Navigator.pop(context, rating);
                    },
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}