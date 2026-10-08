import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/movie_card.dart';
import 'movie_grid.dart';

class MovieListLoading extends StatefulWidget {
  const MovieListLoading({super.key});

  static const _itemCount = 6;

  @override
  State<MovieListLoading> createState() => _MovieListLoadingState();
}

class _MovieListLoadingState extends State<MovieListLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.4,
    end: 1,
  ).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '영화 목록을 불러오는 중',
      child: FadeTransition(
        opacity: _opacity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              padding: MovieGrid.padding.copyWith(top: 48),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: MovieListLoading._itemCount,
              gridDelegate: MovieGrid.gridDelegate(constraints.maxWidth),
              itemBuilder: (context, index) => const _MovieCardSkeleton(),
            );
          },
        ),
      ),
    );
  }
}

class _MovieCardSkeleton extends StatelessWidget {
  const _MovieCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: MovieCard.posterAspectRatio,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.lavender,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const _SkeletonBar(widthFactor: 0.8, height: 18),
        const SizedBox(height: 8),
        const _SkeletonBar(widthFactor: 0.5, height: 14),
      ],
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.widthFactor, required this.height});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.lavender,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
