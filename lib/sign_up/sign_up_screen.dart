import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/services/member_check_service.dart';
import '../theme/app_text_styles.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movie_log_text_form_field.dart';
import '../widgets/movielog_button.dart';
import 'sign_in_prompt.dart';
import 'sign_up_header.dart';
import 'sign_up_validators.dart';
import 'terms_agreement.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  static const wideBreakpoint = 700.0;
  static const maxFormWidth = 560.0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignUpViewModel(context.read<MemberCheckService>()),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _agreedToTerms = false;
  bool _submitted = false;
  final _touchedFields = <TextEditingController>{};

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

  bool _canSubmit(SignUpViewModel viewModel) {
    final localOk =
        SignUpValidators.nickname(_nicknameController.text) == null &&
        SignUpValidators.email(_emailController.text) == null &&
        SignUpValidators.password(_passwordController.text) == null;
    final checkedOk =
        viewModel.nicknameCheckStatus == CheckStatus.available &&
        viewModel.emailCheckStatus == CheckStatus.available;
    return localOk && checkedOk && _agreedToTerms;
  }

  void _submit(SignUpViewModel viewModel) {
    setState(() => _submitted = true);
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || !_canSubmit(viewModel)) return;

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('회원가입이 완료되었습니다.')),
    );
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isWideWindow =
        MediaQuery.sizeOf(context).width >= SignUpScreen.wideBreakpoint;

    return Scaffold(
      appBar: isWideWindow
          ? null
          : const CommonAppBar(title: '회원가입', centerTitle: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= SignUpScreen.wideBreakpoint;
            final horizontalPadding = isWide
                ? math.max(
                    24.0,
                    (constraints.maxWidth - SignUpScreen.maxFormWidth) / 2,
                  )
                : 24.0;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    32,
                  ),
                  child: _buildForm(isWide: isWide),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm({required bool isWide}) {
    return Consumer<SignUpViewModel>(
      builder: (context, viewModel, _) {
        return Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: isWide
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SignUpHeader(showTitle: isWide),
                  const SizedBox(height: 40),
                  MovieLogTextFormField(
                    label: '닉네임',
                    hint: '닉네임을 입력해주세요',
                    controller: _nicknameController,
                    errorText: viewModel.nicknameErrorText,
                    showStatus: _showStatus(_nicknameController),
                    showSuccessIcon:
                        viewModel.nicknameCheckStatus == CheckStatus.available,
                    textInputAction: TextInputAction.next,
                    validator: SignUpValidators.nickname,
                    onChanged: (value) {
                      _markTouched(_nicknameController);
                      viewModel.onNicknameChanged(value);
                    },
                    onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                    trailing: MovieLogButton(
                      label: '중복 확인',
                      isLoading:
                          viewModel.nicknameCheckStatus == CheckStatus.checking,
                      onPressed: viewModel.canCheckNickname
                          ? () => viewModel.checkNickname(
                              _nicknameController.text,
                            )
                          : null,
                    ),
                  ),
                  if (viewModel.nicknameCheckStatus == CheckStatus.available)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        '사용할 수 있는 닉네임입니다.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 16),
                  MovieLogTextFormField(
                    label: '이메일',
                    hint: '이메일 주소를 입력해주세요',
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    errorText: viewModel.emailErrorText,
                    showStatus: _showStatus(_emailController),
                    showSuccessIcon:
                        viewModel.emailCheckStatus == CheckStatus.available,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: SignUpValidators.email,
                    onChanged: (value) {
                      _markTouched(_emailController);
                      viewModel.onEmailChanged(value);
                    },
                    onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                    trailing: MovieLogButton(
                      label: '중복 확인',
                      isLoading:
                          viewModel.emailCheckStatus == CheckStatus.checking,
                      onPressed: viewModel.canCheckEmail
                          ? () => viewModel.checkEmail(_emailController.text)
                          : null,
                    ),
                  ),
                  if (viewModel.emailCheckStatus == CheckStatus.available)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        '사용할 수 있는 이메일입니다.',
                        style: AppTextStyles.bodySmall,
                      ),
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
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TermsAgreement(
                    agreed: _agreedToTerms,
                    onChanged: (value) =>
                        setState(() => _agreedToTerms = value),
                  ),
                  const SizedBox(height: 24),
                  MovieLogButton(
                    label: '가입하기',
                    width: double.infinity,
                    onPressed: _canSubmit(viewModel)
                        ? () => _submit(viewModel)
                        : null,
                  ),
                  const SizedBox(height: 40),
                  const SignInPrompt(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
