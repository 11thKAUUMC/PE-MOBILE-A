import 'package:flutter/material.dart';

class MovieListLoading extends StatelessWidget {
  const MovieListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '영화를 불러오는 중이에요.',
      liveRegion: true,
      child: ExcludeSemantics(
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.54,
          ),
          itemBuilder: (context, index) => const _MovieCardSkeleton(),
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
        Expanded(
          child: Stack(
            children: [
              const Positioned.fill(child: _SkeletonBlock(radius: 12)),
              Positioned(
                top: 8,
                right: 8,
                child: SizedBox(
                  width: 44,
                  height: 24,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1CCD8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const FractionallySizedBox(
          widthFactor: 0.75,
          child: SizedBox(height: 18, child: _SkeletonBlock()),
        ),
        const SizedBox(height: 3),
        const FractionallySizedBox(
          widthFactor: 0.5,
          child: SizedBox(height: 16, child: _SkeletonBlock()),
        ),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({this.radius = 4});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE9E5EE),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
