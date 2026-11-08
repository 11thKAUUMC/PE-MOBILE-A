import 'package:flutter/material.dart';

abstract final class Week06Style {
  static const background = Color(0xFFFEFCF9);
  static const ink = Color(0xFF25232A);
  static const muted = Color(0xFF655F6C);
  static const outline = Color(0xFFD9D3E1);

  static TextStyle text(
    double size, {
    Color color = ink,
    FontWeight weight = FontWeight.w400,
    double height = 1.3,
  }) => TextStyle(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: height,
    letterSpacing: 0,
  );
}
