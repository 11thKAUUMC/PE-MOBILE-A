import 'package:flutter/material.dart';

class TmdbPosterImage extends StatelessWidget {
  const TmdbPosterImage({
    super.key,
    required this.posterPath,
    this.width = double.infinity,
    this.height = double.infinity,
    this.fit = BoxFit.cover,
    this.placeholder,
  });
  final String? posterPath;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;
  @override
  Widget build(BuildContext context) {
    Widget fallback() =>
        placeholder ??
        Container(
          width: width,
          height: height,
          color: const Color(0xFFE9E5EE),
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported_outlined, size: 36),
              SizedBox(height: 8),
              Text('포스터 없음'),
            ],
          ),
        );
    if (posterPath == null || posterPath!.isEmpty) return fallback();
    return Image.network(
      'https://image.tmdb.org/t/p/w500$posterPath',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => fallback(),
    );
  }
}
