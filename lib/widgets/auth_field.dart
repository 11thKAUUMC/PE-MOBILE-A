import 'package:flutter/material.dart';

import '../theme/week06_style.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.error,
    this.enabled = true,
    this.obscure = false,
    this.keyboardType,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? error;
  final bool enabled;
  final bool obscure;
  final TextInputType? keyboardType;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Week06Style.outline),
    );
    final errorBorder = border.copyWith(
      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Week06Style.text(14, color: Week06Style.muted)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          enabled: enabled,
          obscureText: obscure,
          autocorrect: !obscure,
          enableSuggestions: !obscure,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: Week06Style.text(14),
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFEFECF2),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            border: border,
            enabledBorder: border,
            disabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
            errorText: error,
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
