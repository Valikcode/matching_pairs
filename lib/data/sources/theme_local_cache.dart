import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_pack.dart';

class ThemeLocalCache {
  static const _keyThemes = 'cached_themes';

  Future<void> saveThemes(List<ThemePack> themes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = themes.map((t) => t.toJson()).toList();
    await prefs.setString(_keyThemes, json.encode(jsonList));
  }

  Future<List<ThemePack>> getThemes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyThemes);
    if (jsonString == null) return [];
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => ThemePack.fromJson(e)).toList();
  }
}
