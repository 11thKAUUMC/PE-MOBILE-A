import 'package:flutter/foundation.dart';

import '../data/models/common_response.dart';
import '../data/models/login_models.dart';
import '../data/models/member_info.dart';
import '../data/services/auth_api_service.dart';
import '../data/services/member_api_service.dart';
import '../data/session/token_storage.dart';

enum AuthStatus {
  initializing,
  signedOut,
  authenticating,
  signedIn,
  retryRequired,
}

enum MemberLoadStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._storage, this._authApi, this._memberApi);

  final TokenStorage _storage;
  final AuthApiService _authApi;
  final MemberApiService _memberApi;
  AuthStatus status = AuthStatus.initializing;
  MemberLoadStatus memberStatus = MemberLoadStatus.idle;
  MemberInfo? member;
  String? loginError;
  String? restoreError;
  bool sessionExpired = false;
  String? _token;
  int _version = 0;
  bool _disposed = false;
  bool _clearing = false;
  bool _cleanupFailed = false;

  int get sessionVersion => _version;
  ({String? token, int version}) get credentials =>
      (token: _token, version: _version);

  bool isSignedIn(int version) =>
      _current(version) && status == AuthStatus.signedIn;
  bool _current(int version) => !_disposed && _version == version;

  Future<void> restoreSession() async {
    if (_disposed ||
        _clearing ||
        (status != AuthStatus.initializing &&
            status != AuthStatus.retryRequired)) {
      return;
    }
    if (_cleanupFailed) {
      await _clear(expired: sessionExpired);
      return;
    }
    final version = ++_version;
    _token = null;
    status = AuthStatus.initializing;
    restoreError = null;
    notifyListeners();

    try {
      final token = await _storage.read();
      if (!_current(version)) return;
      if (token == null || token.isEmpty) {
        status = AuthStatus.signedOut;
      } else {
        _token = token;
        final verified = await _memberApi.fetchMe();
        if (!_current(version)) return;
        member = verified;
        memberStatus = MemberLoadStatus.success;
        status = AuthStatus.signedIn;
      }
    } catch (_) {
      if (!_current(version)) return;
      status = AuthStatus.retryRequired;
      restoreError = '로그인 상태를 확인하지 못했어요. 다시 시도해 주세요.';
    }
    if (_current(version)) notifyListeners();
  }

  Future<bool> login(LoginRequest request) async {
    if (_disposed || _clearing || status != AuthStatus.signedOut) return false;
    final version = ++_version;
    status = AuthStatus.authenticating;
    loginError = null;
    notifyListeners();

    String? token;
    try {
      token = (await _authApi.login(request)).accessToken;
    } on MovieLogException catch (error) {
      loginError = switch (error.code) {
        'AUTH401_1' => '이메일 또는 비밀번호가 올바르지 않아요.',
        'COMMON400' => '이메일과 비밀번호 형식을 확인해 주세요.',
        _ => '로그인 요청에 실패했어요. 다시 시도해 주세요.',
      };
    } catch (_) {
      loginError = '로그인 응답을 확인하지 못했어요.';
    }
    if (!_current(version)) return false;

    if (token != null) {
      try {
        await _storage.write(token);
        if (!_current(version)) return false;
        _token = token;
        status = AuthStatus.signedIn;
        notifyListeners();
        return true;
      } catch (_) {
        if (!_current(version)) return false;
        loginError = '로그인 정보를 저장하지 못했어요. 다시 시도해 주세요.';
      }
    }
    status = AuthStatus.signedOut;
    notifyListeners();
    return false;
  }

  Future<void> loadMember({bool force = false}) async {
    final version = _version;
    if (!isSignedIn(version) ||
        memberStatus == MemberLoadStatus.loading ||
        (member != null && !force)) {
      return;
    }
    memberStatus = MemberLoadStatus.loading;
    notifyListeners();
    try {
      final result = await _memberApi.fetchMe();
      if (!isSignedIn(version)) return;
      member = result;
      memberStatus = MemberLoadStatus.success;
    } catch (_) {
      if (!isSignedIn(version)) return;
      memberStatus = MemberLoadStatus.error;
    }
    notifyListeners();
  }

  void updateMember(MemberInfo result, int version) {
    if (!isSignedIn(version)) return;
    member = result;
    memberStatus = MemberLoadStatus.success;
    notifyListeners();
  }

  Future<void> expireSession(int version) async {
    if (!_current(version) || _token == null) return;
    await _clear(expired: true);
  }

  Future<void> logout() async {
    if (status != AuthStatus.signedIn) return;
    await _clear(expired: false);
  }

  Future<void> _clear({required bool expired}) async {
    if (_clearing || _disposed) return;
    _clearing = true;
    final version = ++_version;
    _token = null;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    loginError = null;
    restoreError = null;
    sessionExpired = expired;
    status = AuthStatus.initializing;
    notifyListeners();

    try {
      await _storage.delete();
      _cleanupFailed = false;
      status = AuthStatus.signedOut;
    } catch (_) {
      _cleanupFailed = true;
      status = AuthStatus.retryRequired;
      restoreError = '로그인 정보를 지우지 못했어요. 다시 시도해 주세요.';
    } finally {
      _clearing = false;
    }
    if (_current(version)) notifyListeners();
  }

  bool consumeSessionExpired() {
    if (status != AuthStatus.signedOut || !sessionExpired) return false;
    sessionExpired = false;
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
