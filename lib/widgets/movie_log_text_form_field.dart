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
    this.showSuccessIcon = true,
    this.errorText,
    this.trailing,
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

  /// true면 로컬 검증 통과 시 초록 체크를 보여준다.
  /// 중복 확인 필드는 서버 available일 때만 true로 둔다.
  final bool showSuccessIcon;

  /// ViewModel 등에서 내려주는 서버 검증 에러. validator와 함께 표시된다.
  final String? errorText;

  /// 입력창 오른쪽(예: 중복 확인 버튼). 라벨 아래 Row에 배치한다.
  final Widget? trailing;
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
    final localError = widget.validator(widget.controller.text);
    final combinedError = localError ?? widget.errorText;
    final hasError = widget.showStatus && combinedError != null;

    final field = TextFormField(
      // 서버 확인 상태가 바뀌면 FormField 검증 표시를 처음부터 다시 그린다.
      key: ValueKey<String>(
        '${widget.errorText ?? ''}_${widget.showSuccessIcon}_$hasError',
      ),
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
          isValid: combinedError == null && widget.showSuccessIcon,
        ),
      ),
      validator: (value) {
        final local = widget.validator(value);
        if (local != null) return local;
        return widget.errorText;
      },
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        if (widget.trailing == null)
          field
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: field),
              const SizedBox(width: 8),
              widget.trailing!,
            ],
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
