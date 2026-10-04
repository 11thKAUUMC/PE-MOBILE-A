import 'package:flutter/material.dart';

class MovieDetailHeader extends StatelessWidget {
  const MovieDetailHeader({super.key, required this.posterAsset});

  final String posterAsset;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.9,
      child: Image.asset(posterAsset, fit: BoxFit.cover),
    );
  }
}
