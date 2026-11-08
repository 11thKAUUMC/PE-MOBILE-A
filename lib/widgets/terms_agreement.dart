import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/week06_style.dart';

class TermsAgreement extends StatelessWidget {
  const TermsAgreement({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: value ? AppColors.violet : Colors.transparent,
                border: Border.all(
                  color: value ? AppColors.violet : Week06Style.muted,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: value
                  ? const Icon(Icons.check, color: Colors.white, size: 23)
                  : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '필수 약관에 동의합니다',
                style: Week06Style.text(14, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
