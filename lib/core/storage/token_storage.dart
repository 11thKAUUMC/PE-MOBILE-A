import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> readAccessToken();
  Future<void> deleteAccessToken();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);

  static const _accessTokenKey = 'movielog.access_token';
  final FlutterSecureStorage _storage;

  @override
  Future<void> saveAccessToken(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<void> deleteAccessToken() {
    return _storage.delete(key: _accessTokenKey);
  }
}

/// 테스트용 인메모리 토큰 저장소.
class InMemoryTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<void> saveAccessToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> readAccessToken() async => _token;

  @override
  Future<void> deleteAccessToken() async {
    _token = null;
  }
}
