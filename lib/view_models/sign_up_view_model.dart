import 'package:flutter/foundation.dart';

import '../data/services/sign_up_service.dart';
import '../data/models/common_response.dart';
import '../data/models/sign_up_models.dart';

enum SubmitStatus { idle, submitting, success, error }

enum CheckStatus { idle, checking, available, duplicated, error }

class _CheckField {
  String current = '';
  String? duplicated;
  CheckStatus status = CheckStatus.idle;
  int version = 0;
}

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);
  final SignUpService _service;
  SubmitStatus submitStatus = SubmitStatus.idle;
  String? passwordErrorText;
  String? snackbarMessage;
  bool get isSubmitting => submitStatus == SubmitStatus.submitting;
  bool get isVerified =>
      _nickname.status == CheckStatus.available &&
      _email.status == CheckStatus.available;

  void clearSubmitErrors() {
    passwordErrorText = null;
    snackbarMessage = null;
    if (!_disposed) notifyListeners();
  }

  Future<SignUpResult?> submit(CreateMemberRequest request) async {
    if (_disposed ||
        isSubmitting ||
        !isVerified ||
        request.nickname.trim() != _nickname.current ||
        request.email.trim() != _email.current) {
      return null;
    }
    submitStatus = SubmitStatus.submitting;
    clearSubmitErrors();
    SignUpResult? result;
    try {
      result = await _service.signUp(request);
      if (!_disposed) submitStatus = SubmitStatus.success;
    } on MovieLogException catch (error) {
      if (_disposed) return null;
      submitStatus = SubmitStatus.error;
      if (error.status == 400 && error.message.contains('비밀번호')) {
        passwordErrorText = error.message;
      } else {
        if (error.status == 409) {
          final emailConflict = error.message.contains('이메일');
          final nicknameConflict = error.message.contains('닉네임');
          if (emailConflict || !nicknameConflict) _invalidateCheck(_email);
          if (nicknameConflict || !emailConflict) _invalidateCheck(_nickname);
        }
        snackbarMessage = error.message;
      }
    } catch (_) {
      if (_disposed) return null;
      submitStatus = SubmitStatus.error;
      snackbarMessage = '가입 응답을 확인할 수 없습니다.';
    }
    if (_disposed) return null;
    notifyListeners();
    return result;
  }

  void _invalidateCheck(_CheckField field) {
    field.version++;
    field.status = CheckStatus.idle;
  }

  final _nickname = _CheckField();
  final _email = _CheckField();
  bool _disposed = false;
  CheckStatus get nicknameCheckStatus => _nickname.status;
  CheckStatus get emailCheckStatus => _email.status;
  String? get nicknameErrorText => _error(_nickname, '닉네임');
  String? get emailErrorText => _error(_email, '이메일');
  bool get canCheckNickname =>
      _nickname.current.length >= 2 &&
      _nickname.current.length <= 12 &&
      _canCheck(_nickname);
  bool get canCheckEmail =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.current) &&
      _canCheck(_email);
  bool _canCheck(_CheckField field) =>
      !isSubmitting &&
      field.status != CheckStatus.checking &&
      field.status != CheckStatus.duplicated;
  String? _error(_CheckField field, String label) => switch (field.status) {
    CheckStatus.duplicated => '이미 사용 중인 $label입니다.',
    CheckStatus.error => '중복 확인에 실패했습니다. 다시 시도해 주세요.',
    _ => null,
  };
  void onNicknameChanged(String value) => _change(_nickname, value);
  void onEmailChanged(String value) => _change(_email, value);
  void _change(_CheckField field, String value) {
    if (isSubmitting) return;
    passwordErrorText = null;
    snackbarMessage = null;
    field.current = value.trim();
    field.version++;
    field.status = field.current == field.duplicated
        ? CheckStatus.duplicated
        : CheckStatus.idle;
    if (!_disposed) notifyListeners();
  }

  Future<void> checkNickname(String value) =>
      _check(_nickname, value, canCheckNickname, _service.checkNickname);
  Future<void> checkEmail(String value) =>
      _check(_email, value, canCheckEmail, _service.checkEmail);
  Future<void> _check(
    _CheckField field,
    String value,
    bool allowed,
    Future<bool> Function(String) request,
  ) async {
    if (_disposed || !allowed || value.trim() != field.current) return;
    final version = ++field.version;
    field.status = CheckStatus.checking;
    notifyListeners();
    try {
      final available = await request(field.current);
      if (_disposed || version != field.version) return;
      field.status = available ? CheckStatus.available : CheckStatus.duplicated;
      if (!available) field.duplicated = field.current;
    } catch (_) {
      if (_disposed || version != field.version) return;
      field.status = CheckStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _nickname.version++;
    _email.version++;
    super.dispose();
  }
}
