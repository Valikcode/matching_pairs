import 'package:shared_preferences/shared_preferences.dart';

class HighscoreStore {
  HighscoreStore._();

  static final HighscoreStore instance = HighscoreStore._();

  String _keyFor(String modeKey) => 'highscore_$modeKey';

  Future<int?> getHighscore(String modeKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyFor(modeKey));
  }

  Future<bool> updateHighscoreIfBeats(String modeKey, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(modeKey);
    final current = prefs.getInt(key);
    if (current == null || score > current) {
      await prefs.setInt(key, score);
      return true;
    }
    return false;
  }
}
