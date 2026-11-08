import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/week06_style.dart';

class StatItem extends StatelessWidget {
  const StatItem({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 87,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
        decoration: BoxDecoration(
          color: Week06Style.background,
          border: Border.all(color: const Color(0xFFE4DAF1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Week06Style.text(
                12,
                color: Week06Style.muted,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Week06Style.text(
                24,
                color: AppColors.violet,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
