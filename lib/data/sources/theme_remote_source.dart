import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:matching_pairs/data/models/theme_pack.dart';

class ThemeRemoteSource {
  static const String themesUrl =
      'https://firebasestorage.googleapis.com/v0/b/concentrationgame-20753.appspot.com/o/themes.json?alt=media&token=6898245a-0586-4fed-b30e-5078faeba078';

  Future<List<ThemePack>> fetchThemes() async {
    final resp = await http.get(Uri.parse(themesUrl));
    if (resp.statusCode != 200) throw Exception('Failed to load themes');
    final List<dynamic> data = json.decode(resp.body);
    return data.map((e) => ThemePack.fromJson(e)).toList();
  }
}
