import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matching_pairs/logic/game_theme/theme_state.dart';
import '../../data/models/theme_pack.dart';
import '../../data/repositories/theme_repository.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeRepository repo;
  bool _fetchedOnce = false;

  ThemeCubit(this.repo) : super(ThemeState());

  Future<void> ensureLoaded() async {
    if (_fetchedOnce) return;
    _fetchedOnce = true;
    await refresh();
  }

  Future<void> refresh() async {
    emit(state.copyWith(loading: true));
    final themes = await repo.getThemes(forceRefresh: true);
    emit(
      state.copyWith(
        themes: themes,
        selected: state.selected ?? (themes.isNotEmpty ? themes.first : null),
        loading: false,
      ),
    );
  }

  Future<void> loadFromCacheFirst() async {
    emit(state.copyWith(loading: true));
    final themes = await repo.getThemes(forceRefresh: false);
    emit(
      state.copyWith(
        themes: themes,
        selected: state.selected ?? (themes.isNotEmpty ? themes.first : null),
        loading: false,
      ),
    );
  }

  void select(ThemePack t) => emit(state.copyWith(selected: t));
}
