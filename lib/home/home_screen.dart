import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movie_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'MovieLog'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오늘은 어떤\n영화를 볼까요?',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: 24),
              SizedBox(width: 160, child: MovieCard(movie: movies.first)),
            ],
          ),
        ),
      ),
    );
  }
}
