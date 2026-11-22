import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../widgets/movielog_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _controller;
  late final String _initialNickname;

  @override
  void initState() {
    super.initState();
    final member = context.read<AuthViewModel>().member;
    _initialNickname = member?.nickname ?? '';
    _controller = TextEditingController(text: _initialNickname);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasChanges => _controller.text.trim() != _initialNickname;

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('변경 내용을 버릴까요?'),
        content: const Text('저장하지 않은 변경 내용이 사라집니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('계속 수정'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('나가기'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _submit() async {
    final viewModel = context.read<EditProfileViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final success = await viewModel.save(_controller.text);
    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('프로필을 수정했어요.')),
      );
      router.pop();
    } else if (viewModel.message != null) {
      messenger.showSnackBar(SnackBar(content: Text(viewModel.message!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthViewModel, String?>(
      (a) => a.member?.email,
    );

    return Consumer<EditProfileViewModel>(
      builder: (context, viewModel, child) {
        final saving = viewModel.status == EditProfileStatus.saving;
        return PopScope(
          canPop: !saving && !_hasChanges,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop || saving) return;
            final discard = await _confirmDiscard();
            if (discard && context.mounted) {
              GoRouter.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('프로필 수정'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: email,
                    enabled: false,
                    decoration: const InputDecoration(labelText: '이메일'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    enabled: !saving,
                    maxLength: 12,
                    decoration: InputDecoration(
                      labelText: '닉네임',
                      errorText: viewModel.nicknameError,
                    ),
                  ),
                  const Spacer(),
                  MovieLogButton(
                    label: '저장',
                    width: double.infinity,
                    isLoading: saving,
                    onPressed: saving ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
