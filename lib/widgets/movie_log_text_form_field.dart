import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MovieLogTextFormField extends StatefulWidget {
  const MovieLogTextFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.showStatus = false,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.onChanged,
    this.onFieldSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  /// 오류·완료 아이콘과 오류 배경을 보여줄지 여부. 사용자가 입력했거나 제출을 시도한 뒤에 true로 둔다.
  final bool showStatus;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<MovieLogTextFormField> createState() => _MovieLogTextFormFieldState();
}

class _MovieLogTextFormFieldState extends State<MovieLogTextFormField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final errorText = widget.validator(widget.controller.text);
    final hasError = widget.showStatus && errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.isPassword && _obscured,
          autocorrect: !widget.isPassword,
          enableSuggestions: !widget.isPassword,
          decoration: InputDecoration(
            hintText: widget.hint,
            fillColor: hasError ? AppColors.errorContainer : null,
            suffixIcon: _buildSuffix(
              hasError: hasError,
              isValid: errorText == null,
            ),
          ),
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
        ),
      ],
    );
  }

  Widget? _buildSuffix({required bool hasError, required bool isValid}) {
    final statusIcon = hasError
        ? const Icon(Icons.error_outline, color: AppColors.error)
        : isValid
        ? const Icon(Icons.check_circle, color: AppColors.violet)
        : null;

    if (!widget.isPassword) return statusIcon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?statusIcon,
        IconButton(
          tooltip: _obscured ? '비밀번호 표시' : '비밀번호 숨기기',
          icon: Icon(
            _obscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.darkGray,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ],
    );
  }
}
