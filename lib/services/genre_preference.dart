import 'package:shared_preferences/shared_preferences.dart';

class GenrePreference {
  final _preferences = SharedPreferencesAsync();

  static const key = 'selected_genre';

  Future<String> read() async {
    return await _preferences.getString(key) ?? '전체';
  }

  Future<void> save(String genre) async {
    await _preferences.setString(key, genre);
  }
}
