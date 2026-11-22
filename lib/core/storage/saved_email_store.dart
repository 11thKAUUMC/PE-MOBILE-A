import 'package:shared_preferences/shared_preferences.dart';

/// Challenge: 이메일만 SharedPreferences에 저장. 비밀번호·토큰은 저장하지 않습니다.
class SavedEmailStore {
  SavedEmailStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _emailKey = 'movielog.saved_email';
  static const _enabledKey = 'movielog.save_email_enabled';

  final SharedPreferencesAsync _preferences;

  Future<String?> readEmail() async {
    final enabled = await _preferences.getBool(_enabledKey) ?? false;
    if (!enabled) return null;
    return _preferences.getString(_emailKey);
  }

  Future<bool> isEnabled() async {
    return await _preferences.getBool(_enabledKey) ?? false;
  }

  Future<void> save({required bool enabled, required String email}) async {
    await _preferences.setBool(_enabledKey, enabled);
    if (enabled) {
      await _preferences.setString(_emailKey, email.trim());
    } else {
      await _preferences.remove(_emailKey);
    }
  }
}
