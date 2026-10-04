import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widget/common_app_bar.dart';
import 'package:movielog/widget/signup_input.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  bool agreedToTerms = false;

  String? validateNickname(String? value) {
    final nickname = value?.trim() ?? '';

    if (nickname.isEmpty) return '닉네임을 입력해주세요.';
    if (nickname.length < 2) return '닉네임은 두 글자 이상 입력해주세요.';
    return null;
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return '이메일을 입력해주세요.';

    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(email)) {
      return '올바른 이메일 형식이 아닙니다.';
    }

    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) return '비밀번호를 입력해주세요.';
    if (password.length < 8) {
      return '비밀번호는 8자 이상 입력해주세요.';
    }

    return null;
  }

  bool get canSignUp =>
      validateNickname(nicknameController.text) == null &&
      validateEmail(emailController.text) == null &&
      validatePassword(passwordController.text) == null &&
      agreedToTerms;

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('가입 조건을 모두 만족했습니다.')));

    context.go('/home');
  }

  @override
  void dispose() {
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    emailFocusNode.dispose();
    passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: CommonAppBar(title: '회원가입', onBack: () => context.pop()),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          const Text(
                            '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                SignupInput(
                                  label: '닉네임',
                                  hint: '닉네임을 입력해주세요',
                                  controller: nicknameController,
                                  validator: validateNickname,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) => setState(() {}),
                                  onFieldSubmitted: (_) =>
                                      emailFocusNode.requestFocus(),
                                ),
                                const SizedBox(height: 20),

                                SignupInput(
                                  label: '이메일',
                                  hint: '이메일 주소를 입력해주세요',
                                  controller: emailController,
                                  focusNode: emailFocusNode,
                                  validator: validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) => setState(() {}),
                                  onFieldSubmitted: (_) =>
                                      passwordFocusNode.requestFocus(),
                                ),
                                const SizedBox(height: 20),

                                SignupInput(
                                  label: '비밀번호',
                                  hint: '비밀번호를 입력해주세요',
                                  controller: passwordController,
                                  focusNode: passwordFocusNode,
                                  validator: validatePassword,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (_) => setState(() {}),
                                  onFieldSubmitted: (_) =>
                                      passwordFocusNode.unfocus(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CheckboxListTile(
                            value: agreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                agreedToTerms = value ?? false;
                              });
                            },
                            title: const Text('필수 약관에 동의합니다'),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.primary,
                          ),
                          const SizedBox(height: 8),

                          ElevatedButton(
                            onPressed: canSignUp ? submit : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.disabled,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('가입하기'),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('이미 계정이 있나요?'),
                              const SizedBox(width: 4),
                              TextButton(
                                onPressed: () => context.pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('로그인'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
