import 'package:matching_pairs/data/models/theme_pack.dart';

class ThemeState {
  final List<ThemePack> themes;
  final ThemePack? selected;
  final bool loading;

  ThemeState({this.themes = const [], this.selected, this.loading = false});

  ThemeState copyWith({List<ThemePack>? themes, ThemePack? selected, bool? loading}) {
    return ThemeState(
      themes: themes ?? this.themes,
      selected: selected ?? this.selected,
      loading: loading ?? this.loading,
    );
  }
}
