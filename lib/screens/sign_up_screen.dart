import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/sign_up_header.dart';
import '../widgets/terms_agreement.dart';
import '../widgets/sign_up_submit_button.dart';

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

  // 디자인 예시의 선택 상태를 우선 반영합니다.
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateNickname(String? value) {
    final nickname = value?.trim() ?? '';

    if (nickname.isEmpty) return '닉네임을 입력해 주세요.';
    if (nickname.length < 2) return '닉네임은 두 글자 이상 입력해 주세요.';

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return '이메일을 입력해 주세요.';
    if (!email.contains('@')) return '올바른 이메일 형식을 입력해 주세요.';

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) return '비밀번호를 입력해 주세요.';
    if (password.length < 8) return '비밀번호는 8자 이상 입력해 주세요.';

    return null;
  }

  bool get _canSubmit {
    return _nicknameController.text.trim().length >= 2 &&
        _emailController.text.trim().contains('@') &&
        _passwordController.text.length >= 8 &&
        _agreedToTerms;
  }

  InputDecoration _inputDecoration({required String hintText}) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: Color(0xFFD0C8D8)),
    );

    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF5F3F0),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF8A8494), fontSize: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.violet, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    FocusScope.of(context).unfocus();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: AppColors.violet,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxFormWidth =
                constraints.maxWidth >= 700 ? 560.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxFormWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 36),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SignUpHeader(),       // 회원가입 화면 상단의 환영 안내 문구
                        const SizedBox(height: 48),
                        _fieldLabel('닉네임'),
                        TextFormField(
                          controller: _nicknameController,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(hintText: '닉네임을 입력해주세요'),
                          validator: _validateNickname,
                          onChanged: (_) => setState(() {}),
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        const SizedBox(height: 18),
                        _fieldLabel('이메일'),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            hintText: '이메일 주소를 입력해주세요',
                          ),
                          validator: _validateEmail,
                          onChanged: (_) => setState(() {}),
                          onFieldSubmitted: (_) {
                            _passwordFocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 18),
                        _fieldLabel('비밀번호'),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          decoration: _inputDecoration(
                            hintText: '비밀번호를 입력해주세요',
                          ),
                          validator: _validatePassword,
                          onChanged: (_) => setState(() {}),
                          focusNode: _passwordFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                        const SizedBox(height: 196),
                        TermsAgreement(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() => _agreedToTerms = value);
                          },
                        ),
                        const SizedBox(height: 20),
                        SignUpSubmitButton(
                          enabled: _canSubmit,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: '이미 계정이 있나요? ',
                              style: const TextStyle(
                                color: Color(0xFF494551),
                                fontSize: 16,
                              ),
                              children: const [
                                TextSpan(
                                  text: '로그인',
                                  style: TextStyle(
                                    color: AppColors.violet,
                                    fontSize: 16,
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
    );
  }
}
