import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeCubit extends Cubit<ThemeMode> {
  static const _key = 'theme_mode';
  final SharedPreferences prefs;
  final Brightness platformBrightness;

  ThemeModeCubit({required this.prefs, required this.platformBrightness}) : super(_initialFrom(prefs));

  static ThemeMode _initialFrom(SharedPreferences prefs) {
    final saved = prefs.getString(_key);
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> toggle() async {
    final effective =
        state == ThemeMode.system ? (platformBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light) : state;

    final next = effective == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(next);
    await prefs.setString(_key, next.name);
  }

  Future<void> setSystem() async {
    emit(ThemeMode.system);
    await prefs.setString(_key, 'system');
  }
}
