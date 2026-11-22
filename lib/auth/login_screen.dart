import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/storage/saved_email_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/movielog_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AuthViewModel _auth;
  bool _saveEmail = false;
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthViewModel>();
    _auth.addListener(_showSessionExpired);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSessionExpired();
      _loadSavedEmail();
    });
  }

  Future<void> _loadSavedEmail() async {
    final store = context.read<SavedEmailStore>();
    final enabled = await store.isEnabled();
    final email = await store.readEmail();
    if (!mounted) return;
    setState(() {
      _saveEmail = enabled;
      if (email != null && email.isNotEmpty) {
        _email.text = email;
      }
      _prefsLoaded = true;
    });
  }

  void _showSessionExpired() {
    if (!mounted || !_auth.sessionExpired) return;
    _auth.consumeSessionExpired();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('로그인이 만료됐어요. 다시 로그인해 주세요.')),
      );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim();
    await context.read<SavedEmailStore>().save(
      enabled: _saveEmail,
      email: email,
    );
    await _auth.login(email, _password.text);
  }

  @override
  void dispose() {
    _auth.removeListener(_showSessionExpired);
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final loading = auth.status == AuthStatus.authenticating;
    final enabled = !loading && !auth.storageCleanupInProgress && _prefsLoaded;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('로그인'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 64),
              SvgPicture.asset(
                'assets/logos/movielog_logo.svg',
                width: 84,
                height: 84,
                semanticsLabel: 'MovieLog 로고',
              ),
              const SizedBox(height: 24),
              const Text('MovieLog에 로그인', style: AppTextStyles.titleMedium),
              const SizedBox(height: 48),
              TextFormField(
                controller: _email,
                enabled: enabled,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: '이메일'),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? '이메일을 입력해 주세요.'
                    : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _password,
                enabled: enabled,
                obscureText: true,
                decoration: const InputDecoration(labelText: '비밀번호'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? '비밀번호를 입력해 주세요.' : null,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  '이메일 저장',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.black,
                  ),
                ),
                value: _saveEmail,
                onChanged: enabled
                    ? (value) => setState(() => _saveEmail = value ?? false)
                    : null,
              ),
              if (auth.message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    auth.message!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              const SizedBox(height: 32),
              MovieLogButton(
                label: '로그인',
                width: double.infinity,
                isLoading: loading,
                onPressed: enabled ? _submit : null,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: enabled ? () => context.push('/register') : null,
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
