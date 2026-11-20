import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/login_models.dart';
import '../theme/app_colors.dart';
import '../theme/week06_style.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/auth_field.dart';
import '../widgets/movielog_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _emailKey = 'movielog_remembered_email';
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AuthViewModel _auth;
  bool _remember = false;
  bool _emailTouched = false;
  bool _showError = false;
  bool _checkingEmail = true;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthViewModel>()..addListener(_scheduleExpiryNotice);
    _scheduleExpiryNotice();
    _readEmail();
  }

  Future<void> _readEmail() async {
    String? saved;
    try {
      saved = (await SharedPreferences.getInstance()).getString(_emailKey);
    } catch (_) {
      // The login request is still available if the optional preference fails.
    }
    if (!mounted) return;
    setState(() {
      _checkingEmail = false;
      if (saved != null && !_emailTouched) {
        _email.text = saved;
        _remember = true;
      }
    });
  }

  void _scheduleExpiryNotice() {
    if (!_auth.sessionExpired) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_auth.consumeSessionExpired()) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('세션이 만료됐어요. 다시 로그인해 주세요.')),
        );
    });
  }

  @override
  void dispose() {
    _auth.removeListener(_scheduleExpiryNotice);
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_auth.status != AuthStatus.signedOut) return;
    final email = _email.text.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email) ||
        _password.text.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    final request = LoginRequest(email: email, password: _password.text);
    FocusScope.of(context).unfocus();
    final remember = _remember;
    setState(() => _showError = false);
    final success = await _auth.login(request);
    if (success) {
      if (mounted) _password.clear();
      try {
        final preferences = await SharedPreferences.getInstance();
        if (remember) {
          await preferences.setString(_emailKey, email);
        } else {
          await preferences.remove(_emailKey);
        }
      } catch (_) {
        // Email storage is optional and does not change the session.
      }
    } else if (mounted) {
      setState(() => _showError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthViewModel, AuthStatus>(
      (auth) => auth.status,
    );
    final busy = status == AuthStatus.authenticating;
    final emailError =
        _showError &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.text.trim());
    return Scaffold(
      backgroundColor: Week06Style.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Week06Style.background,
        title: Text(
          '로그인',
          style: Week06Style.text(20, color: AppColors.violet),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              constraints.maxHeight * .12,
              24,
              24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        'assets/logos/movielog_logo.svg',
                        width: 72,
                        height: 72,
                        semanticsLabel: 'MovieLog 로고',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'MovieLog에 로그인',
                      textAlign: TextAlign.center,
                      style: Week06Style.text(24, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 30),
                    AuthField(
                      label: '이메일',
                      controller: _email,
                      enabled: !busy,
                      keyboardType: TextInputType.emailAddress,
                      error: emailError ? '이메일 형식을 확인해 주세요.' : null,
                      onChanged: (_) => setState(() {
                        _emailTouched = true;
                        _showError = false;
                      }),
                    ),
                    const SizedBox(height: 24),
                    AuthField(
                      label: '비밀번호',
                      controller: _password,
                      enabled: !busy,
                      obscure: true,
                      error: _showError && !emailError
                          ? (_password.text.isEmpty
                                ? '비밀번호를 입력해 주세요.'
                                : _auth.loginError)
                          : null,
                      onChanged: (_) => setState(() => _showError = false),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      value: _remember,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('이메일 저장'),
                      onChanged: busy || _checkingEmail
                          ? null
                          : (value) =>
                                setState(() => _remember = value ?? false),
                    ),
                    const SizedBox(height: 42),
                    MovieLogButton(
                      label: '로그인',
                      onPressed: _submit,
                      isLoading: busy,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '계정이 없나요?',
                          style: Week06Style.text(14, color: Week06Style.muted),
                        ),
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => context.push('/register'),
                          child: const Text('회원가입'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
