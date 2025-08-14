import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.black,
      brightness: Brightness.light,
      onPrimary: Colors.white,
      primary: Colors.black,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      textTheme: _buildTextTheme(Colors.black),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
      onPrimary: Colors.black,
      primary: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      textTheme: _buildTextTheme(Colors.white),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(color: color),
      displayMedium: TextStyle(color: color),
      displaySmall: TextStyle(color: color),
      headlineLarge: TextStyle(color: color),
      headlineMedium: TextStyle(color: color),
      headlineSmall: TextStyle(color: color),
      titleLarge: TextStyle(color: color),
      titleMedium: TextStyle(color: color),
      titleSmall: TextStyle(color: color),
      bodyLarge: TextStyle(color: color),
      bodyMedium: TextStyle(color: color),
      bodySmall: TextStyle(color: color),
      labelLarge: TextStyle(color: color),
      labelMedium: TextStyle(color: color),
      labelSmall: TextStyle(color: color),
    );
  }
}
