import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie_sort.dart';

class MoviePreference {
  MoviePreference({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const allGenre = '전체';
  static const selectedGenreKey = 'selected_genre';
  static const selectedSortKey = 'selected_sort';

  final SharedPreferencesAsync _preferences;

  Future<String> readGenre() async {
    return await _preferences.getString(selectedGenreKey) ?? allGenre;
  }

  Future<void> saveGenre(String genre) async {
    await _preferences.setString(selectedGenreKey, genre);
  }

  Future<MovieSort> readSort() async {
    return MovieSort.fromName(await _preferences.getString(selectedSortKey));
  }

  Future<void> saveSort(MovieSort sort) async {
    await _preferences.setString(selectedSortKey, sort.name);
  }

  Future<void> clear() async {
    await _preferences.remove(selectedGenreKey);
    await _preferences.remove(selectedSortKey);
  }
}
