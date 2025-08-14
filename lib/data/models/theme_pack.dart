import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemePack extends Equatable {
  final String id;
  final String title;
  final String cardSymbol;
  final Color cardColor;
  final List<String> symbols;
  const ThemePack({
    required this.id,
    required this.title,
    required this.cardSymbol,
    required this.cardColor,
    required this.symbols,
  });

  factory ThemePack.fromJson(Map<String, dynamic> json) {
    // JSON uses keys: title, card_symbol, card_color{red,green,blue in 0..1}, symbols[]
    final title = (json['title'] as String?)?.trim() ?? 'Untitled';
    final color = _colorFromUnitRgb(json['card_color'] as Map<String, dynamic>?);

    return ThemePack(
      id: _slug(title),
      title: title,
      cardSymbol: (json['card_symbol'] as String?) ?? '',
      cardColor: color ?? const Color(0xFFCCCCCC),
      symbols: List<String>.from(json['symbols'] ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    final rgb = _unitRgbFromColor(cardColor);
    return {
      'title': title,
      'card_symbol': cardSymbol,
      'card_color': rgb,
      'symbols': symbols,
    };
  }

  static String _slug(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp('^-+|-+\$'), '');

  static Color? _colorFromUnitRgb(Map<String, dynamic>? m) {
    if (m == null) return null;
    double r = (m['red'] as num?)?.toDouble() ?? 0;
    double g = (m['green'] as num?)?.toDouble() ?? 0;
    double b = (m['blue'] as num?)?.toDouble() ?? 0;
    // clamp 0..1 then map to 0..255
    int ri = (r.clamp(0, 1) * 255).round();
    int gi = (g.clamp(0, 1) * 255).round();
    int bi = (b.clamp(0, 1) * 255).round();
    return Color.fromARGB(255, ri, gi, bi);
  }

  static Map<String, double> _unitRgbFromColor(Color c) {
    return {
      'red': c.red / 255.0,
      'green': c.green / 255.0,
      'blue': c.blue / 255.0,
    };
  }

  @override
  List<Object?> get props => [id, title, cardSymbol, cardColor, symbols];
}
