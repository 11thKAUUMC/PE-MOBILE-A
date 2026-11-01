import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

class SignupInput extends StatefulWidget {
  const SignupInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    required this.onChanged,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.obscureText = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool obscureText;

  @override
  State<SignupInput> createState() => _SignupInputState();
}

class _SignupInputState extends State<SignupInput> {
  bool _hasEdited = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final hasError = _hasEdited && widget.validator(text) != null;
    final isValid = widget.validator(text) == null;

    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),

        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,

          errorBuilder: (context, errorText) {
            return Transform.translate(
              offset: const Offset(-12, 0),
              child: Text(
                errorText,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            );
          },

          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText,
          onFieldSubmitted: widget.onFieldSubmitted,
          onChanged: (value) {
            setState(() {
              _hasEdited = true;
            });

            widget.onChanged(value);
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            filled: true,
            fillColor: hasError
                ? AppColors.errorBackground
                : AppColors.darkWhite,

            enabledBorder: border(AppColors.disabled),
            focusedBorder: border(AppColors.primary, width: 2),

            errorBorder: border(AppColors.error),
            focusedErrorBorder: border(AppColors.error, width: 2),

            suffixIcon: _hasEdited
                ? Icon(
                    isValid ? Icons.check_circle : Icons.error_outline,
                    color: isValid ? AppColors.primary : AppColors.error,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
