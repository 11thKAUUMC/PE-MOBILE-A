import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/common_response.dart';
import '../data/models/member_info.dart';
import '../data/services/member_api_service.dart';
import '../theme/app_colors.dart';
import '../theme/week06_style.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/auth_field.dart';
import '../widgets/movielog_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.member});

  final MemberInfo member;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _nickname = TextEditingController(text: widget.member.nickname);
  bool _saving = false;
  bool _asking = false;
  String? _error;

  bool get _changed => _nickname.text.trim() != widget.member.nickname;

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/my');
    }
  }

  Future<void> _back() async {
    if (_saving || _asking) return;
    if (!_changed) {
      _leave();
      return;
    }
    _asking = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('변경 내용을 버릴까요?', textAlign: TextAlign.center),
        content: const Text('저장하지 않은 내용은 사라집니다.', textAlign: TextAlign.center),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFEFE9F8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('계속 수정'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MovieLogButton(
                  label: '나가기',
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    _asking = false;
    if (mounted && discard == true) _leave();
  }

  Future<void> _save() async {
    if (_saving) return;
    final nickname = _nickname.text.trim();
    if (nickname.characters.length < 2 || nickname.characters.length > 12) {
      setState(() => _error = '닉네임은 2~12자로 입력해 주세요.');
      return;
    }
    if (!_changed) {
      _leave();
      return;
    }
    final auth = context.read<AuthViewModel>();
    final api = context.read<MemberApiService>();
    final version = auth.sessionVersion;
    final messenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    String? notice;
    try {
      final result = await api.updateNickname(nickname);
      if (!mounted || !auth.isSignedIn(version)) return;
      auth.updateMember(result, version);
      messenger.showSnackBar(const SnackBar(content: Text('프로필을 수정했어요.')));
      _leave();
      return;
    } on MovieLogException catch (error) {
      if (!mounted || !auth.isSignedIn(version)) return;
      switch (error.code) {
        case 'MEMBER409_1':
          _error = '이미 사용 중인 닉네임이에요.';
        case 'COMMON400':
          _error = error.message;
        case 'MEMBER404_1':
          notice = '회원 정보를 찾을 수 없어요.';
          await auth.loadMember(force: true);
        default:
          notice = '프로필을 저장하지 못했어요. 다시 시도해 주세요.';
      }
    } catch (_) {
      notice = '프로필 응답을 확인하지 못했어요.';
    }
    if (!mounted || !auth.isSignedIn(version)) return;
    setState(() => _saving = false);
    if (notice != null) messenger.showSnackBar(SnackBar(content: Text(notice)));
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_changed && !_saving,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && _changed) _back();
    },
    child: Scaffold(
      backgroundColor: Week06Style.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Week06Style.background,
        leading: BackButton(onPressed: _saving ? () {} : _back),
        title: Text(
          '프로필 수정',
          style: Week06Style.text(20, color: AppColors.violet),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
                children: [
                  AuthField(
                    label: '이메일 (변경할 수 없습니다)',
                    initialValue: widget.member.email,
                    enabled: false,
                  ),
                  const SizedBox(height: 36),
                  AuthField(
                    label: '닉네임',
                    controller: _nickname,
                    maxLength: 12,
                    enabled: !_saving,
                    error: _error,
                    onChanged: (_) => setState(() => _error = null),
                    onSubmitted: (_) => _save(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
              child: MovieLogButton(
                label: '저장',
                width: double.infinity,
                isLoading: _saving,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
