import 'package:flutter/material.dart';

import '../widgets/common_app_bar.dart';
import '../widgets/movie_log_text_form_field.dart';
import 'sign_in_prompt.dart';
import 'sign_up_header.dart';
import 'sign_up_submit_button.dart';
import 'sign_up_validators.dart';
import 'terms_agreement.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const wideBreakpoint = 700.0;
  static const maxFormWidth = 560.0;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _agreedToTerms = false;
  bool _submitted = false;
  final _touchedFields = <TextEditingController>{};

  bool get _canSubmit =>
      SignUpValidators.nickname(_nicknameController.text) == null &&
      SignUpValidators.email(_emailController.text) == null &&
      SignUpValidators.password(_passwordController.text) == null &&
      _agreedToTerms;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _showStatus(TextEditingController controller) =>
      _submitted || _touchedFields.contains(controller);

  void _markTouched(TextEditingController controller) {
    setState(() => _touchedFields.add(controller));
  }

  void _submit() {
    setState(() => _submitted = true);
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('회원가입 정보가 모두 확인되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    final isWideWindow =
        MediaQuery.sizeOf(context).width >= SignUpScreen.wideBreakpoint;

    return Scaffold(
      appBar: isWideWindow
          ? null
          : CommonAppBar(
              title: '회원가입',
              centerTitle: true,
              onBack: () => Navigator.of(context).maybePop(),
            ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= SignUpScreen.wideBreakpoint;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWide
                            ? SignUpScreen.maxFormWidth
                            : double.infinity,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                        child: _buildForm(isWide: isWide),
                      ),
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

  Widget _buildForm({required bool isWide}) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isWide) const Spacer(),
          SignUpHeader(showTitle: isWide),
          const SizedBox(height: 40),
          MovieLogTextFormField(
            label: '닉네임',
            hint: '닉네임을 입력해주세요',
            controller: _nicknameController,
            validator: SignUpValidators.nickname,
            showStatus: _showStatus(_nicknameController),
            textInputAction: TextInputAction.next,
            onChanged: (_) => _markTouched(_nicknameController),
            onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
          ),
          const SizedBox(height: 16),
          MovieLogTextFormField(
            label: '이메일',
            hint: '이메일 주소를 입력해주세요',
            controller: _emailController,
            focusNode: _emailFocusNode,
            validator: SignUpValidators.email,
            showStatus: _showStatus(_emailController),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _markTouched(_emailController),
            onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
          ),
          const SizedBox(height: 16),
          MovieLogTextFormField(
            label: '비밀번호',
            hint: '비밀번호를 입력해주세요',
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            validator: SignUpValidators.password,
            showStatus: _showStatus(_passwordController),
            isPassword: true,
            textInputAction: TextInputAction.done,
            onChanged: (_) => _markTouched(_passwordController),
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
          ),
          const SizedBox(height: 32),
          if (!isWide) const Spacer(),
          TermsAgreement(
            agreed: _agreedToTerms,
            onChanged: (value) => setState(() => _agreedToTerms = value),
          ),
          const SizedBox(height: 24),
          SignUpSubmitButton(onPressed: _canSubmit ? _submit : null),
          const SizedBox(height: 40),
          const SignInPrompt(),
          if (isWide) const Spacer(),
        ],
      ),
    );
  }
}
