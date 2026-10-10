import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie_sort.dart';

class SortPreference {
  final _preferences = SharedPreferencesAsync();

  static const key = 'selected_sort';

  Future<MovieSort> read() async {
    final saved = await _preferences.getString(key);
    return MovieSort.values.firstWhere(
      (sort) => sort.name == saved,
      orElse: () => MovieSort.original,
    );
  }

  Future<void> save(MovieSort sort) async {
    await _preferences.setString(key, sort.name);
  }
}
