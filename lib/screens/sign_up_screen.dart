import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/week06_style.dart';
import '../widgets/sign_up_header.dart';
import '../widgets/terms_agreement.dart';
import '../widgets/movielog_button.dart';
import '../view_models/sign_up_view_model.dart';
import '../data/services/sign_up_service.dart';
import '../data/models/sign_up_models.dart';
import '../data/session/learning_member_session.dart';

import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  late final SignUpViewModel _viewModel;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _viewModel = SignUpViewModel(context.read<SignUpService>())
      ..addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_refresh);
    _viewModel.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateNickname(String? value) {
    final nickname = value?.trim() ?? '';

    if (nickname.isEmpty) return '닉네임을 입력해 주세요.';
    if (nickname.length < 2 || nickname.length > 12) {
      return '닉네임은 2~12자로 입력해 주세요.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return '이메일을 입력해 주세요.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return '올바른 이메일 형식을 입력해 주세요.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) return '비밀번호를 입력해 주세요.';
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*]).{8,}$')
        .hasMatch(password)) {
      return '대문자, 소문자, 숫자, 특수문자를 포함해 8자 이상 입력해 주세요.';
    }

    return null;
  }

  bool get _canSubmit {
    return !_viewModel.isSubmitting &&
        _nicknameController.text.trim().length >= 2 &&
        _emailController.text.trim().contains('@') &&
        _validatePassword(_passwordController.text) == null &&
        _agreedToTerms &&
        _viewModel.nicknameCheckStatus == CheckStatus.available &&
        _viewModel.emailCheckStatus == CheckStatus.available;
  }

  InputDecoration _inputDecoration({
    required String hintText,
    String? helper,
    String? error,
    CheckStatus status = CheckStatus.idle,
  }) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Week06Style.outline),
    );

    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Week06Style.background,
      hintText: hintText,
      hintStyle: Week06Style.text(14, color: const Color(0xFF8A8391)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: Colors.red),
      ),
      helper: helper == null
          ? null
          : Transform.translate(
              offset: const Offset(-13, 0),
              child: Text(
                helper,
                style: Week06Style.text(
                  12,
                  color: status == CheckStatus.checking
                      ? const Color(0xFF1565C0)
                      : const Color(0xFF2E7D32),
                  weight: FontWeight.w700,
                ),
              ),
            ),
      errorText: error,
      errorMaxLines: 2,
      suffixIcon: status == CheckStatus.available
          ? const Icon(Icons.check_circle, color: AppColors.violet, size: 24)
          : null,
      suffixIconConstraints: const BoxConstraints(minWidth: 44),
    );
  }

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: Week06Style.text(14, weight: FontWeight.w700)),
  );

  Widget _checkField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required CheckStatus status,
    required String? error,
    required String? Function(String?) validator,
    required ValueChanged<String> onChanged,
    required VoidCallback? onPressed,
    TextInputType? keyboardType,
  }) {
    final helper = switch (status) {
      CheckStatus.available => '사용 가능한 $label입니다.',
      CheckStatus.checking =>
        label == '이메일' ? '이메일 사용 가능 여부를 확인 중입니다.' : '닉네임 사용 가능 여부를 확인 중입니다.',
      _ => ' ',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel(label),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                readOnly: _viewModel.isSubmitting,
                keyboardType: keyboardType,
                textInputAction: TextInputAction.next,
                style: Week06Style.text(14, color: const Color(0xFF8A8391)),
                decoration: _inputDecoration(
                  hintText: hint,
                  helper: helper,
                  error: error,
                  status: status,
                ),
                validator: validator,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 9),
            MovieLogButton(
              label: '중복 확인',
              width: 102,
              isLoading: status == CheckStatus.checking,
              onPressed: onPressed,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_canSubmit || !(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    FocusScope.of(context).unfocus();
    final result = await _viewModel.submit(
      CreateMemberRequest(
        nickname: _nicknameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
    if (!mounted) return;
    if (result != null) {
      context.read<LearningMemberSession>().setMemberId(result.memberId);
      context.go('/movies');
    } else if (_viewModel.snackbarMessage case final message?) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_viewModel.isSubmitting,
      child: Scaffold(
        backgroundColor: Week06Style.background,
        appBar: AppBar(
          backgroundColor: Week06Style.background,
          scrolledUnderElevation: 0,
          toolbarHeight: 64,
          leading: BackButton(
            onPressed: () {
              if (_viewModel.isSubmitting) return;
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/start');
              }
            },
          ),
          centerTitle: true,
          title: const Text(
            '회원가입',
            style: TextStyle(
              color: AppColors.violet,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxFormWidth = constraints.maxWidth >= 700
                  ? 560.0
                  : double.infinity;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxFormWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(17, 39, 17, 36),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SignUpHeader(),
                          const SizedBox(height: 27),
                          _checkField(
                            label: '닉네임',
                            hint: '닉네임을 입력해주세요',
                            controller: _nicknameController,
                            status: _viewModel.nicknameCheckStatus,
                            error: _viewModel.nicknameErrorText,
                            validator: _validateNickname,
                            onChanged: _viewModel.onNicknameChanged,
                            onPressed: _viewModel.canCheckNickname
                                ? () => _viewModel.checkNickname(
                                    _nicknameController.text,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 11),
                          _checkField(
                            label: '이메일',
                            hint: '이메일을 입력해주세요',
                            controller: _emailController,
                            status: _viewModel.emailCheckStatus,
                            error: _viewModel.emailErrorText,
                            validator: _validateEmail,
                            onChanged: _viewModel.onEmailChanged,
                            keyboardType: TextInputType.emailAddress,
                            onPressed: _viewModel.canCheckEmail
                                ? () => _viewModel.checkEmail(
                                    _emailController.text,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 11),
                          _fieldLabel('비밀번호'),
                          TextFormField(
                            controller: _passwordController,
                            readOnly: _viewModel.isSubmitting,
                            obscureText: true,
                            obscuringCharacter: '•',
                            style: Week06Style.text(
                              14,
                              color: const Color(0xFF8A8391),
                            ),
                            textInputAction: TextInputAction.done,
                            decoration: _inputDecoration(
                              hintText: '비밀번호를 입력해주세요',
                              error: _viewModel.passwordErrorText,
                            ),
                            validator: _validatePassword,
                            onChanged: (_) => _viewModel.clearSubmitErrors(),
                            focusNode: _passwordFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).unfocus();
                            },
                          ),
                          const SizedBox(height: 182),
                          TermsAgreement(
                            value: _agreedToTerms,
                            onChanged: (value) {
                              setState(() => _agreedToTerms = value);
                            },
                          ),
                          const SizedBox(height: 24),
                          MovieLogButton(
                            label: '가입하기',
                            isLoading: _viewModel.isSubmitting,
                            disabledColor: const Color(0xFFD3C6E2),
                            radius: 9,
                            width: double.infinity,
                            onPressed: _canSubmit ? _submit : null,
                          ),
                          const SizedBox(height: 53),
                          Padding(
                            padding: const EdgeInsets.only(left: 54),
                            child: Text.rich(
                              TextSpan(
                                text: '이미 계정이 있나요?    ',
                                style: const TextStyle(
                                  color: Week06Style.ink,
                                  fontSize: 14,
                                ),
                                children: const [
                                  TextSpan(
                                    text: '로그인',
                                    style: TextStyle(
                                      color: AppColors.violet,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
