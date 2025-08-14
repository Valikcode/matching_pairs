import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matching_pairs/data/models/game_card_model.dart';
import 'package:matching_pairs/data/models/mode_info.dart';
import 'package:matching_pairs/logic/game/game_state.dart';
import 'package:matching_pairs/logic/game_theme/theme_cubit.dart';

class GameCubit extends Cubit<GameState> {
  final ModeInfo mode;
  final ThemeCubit themeCubit;
  Timer? _timer;
  bool _busy = false;

  GameCubit({required this.mode, required this.themeCubit}) : super(const GameState());

  void startGame() {
    final themePack = themeCubit.state.selected;
    if (themePack == null || themePack.symbols.isEmpty) {
      emit(state.copyWith(loading: false));
      return;
    }

    final rng = Random();
    final neededPairs = (mode.rows * mode.cols) ~/ 2;

    // 1) Shuffle the available symbols from the theme
    final base = List<String>.from(themePack.symbols)..shuffle(rng);

    // 2) Use each symbol at least once (up to neededPairs)
    final chosenPairs = <String>[];
    final takeUnique = base.take(neededPairs);
    chosenPairs.addAll(takeUnique);

    // 3) If we still need more pairs, repeat symbols with replacement
    while (chosenPairs.length < neededPairs) {
      chosenPairs.add(base[rng.nextInt(base.length)]);
    }

    // 4) Build the deck (pair per chosen symbol) and shuffle
    final allCards = <GameCard>[];
    var id = 0;
    for (final sym in chosenPairs) {
      allCards.add(GameCard(id: id++, symbolId: sym));
      allCards.add(GameCard(id: id++, symbolId: sym));
    }
    allCards.shuffle(rng);

    _timer?.cancel();
    emit(
      state.copyWith(
        cards: allCards,
        moves: 0,
        matches: 0,
        completed: false,
        loading: false,
        timeLeft: 1.0,
        secondsLeft: mode.time,
        score: 0,
        streak: 0,
        multiplier: 1,
      ),
    );

    if (mode.time > 0) _startTimer();
  }

  void _startTimer() {
    final total = mode.time;
    final endAt = DateTime.now().add(Duration(seconds: total));

    _timer?.cancel();

    emit(state.copyWith(secondsLeft: total, timeLeft: 1.0));

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final now = DateTime.now();
      final remaining = endAt.isAfter(now) ? (endAt.difference(now).inMilliseconds / 1000).ceil() : 0;

      final fraction = total > 0 ? remaining / total : 1.0;

      emit(state.copyWith(secondsLeft: remaining, timeLeft: fraction.clamp(0, 1)));

      if (remaining == 0) {
        timer.cancel();
        emit(state.copyWith(completed: true));
      }
    });
  }

  void flipCard(int index) {
    if (state.completed || _busy) return;

    final cards = List<GameCard>.from(state.cards);
    final card = cards[index];
    if (card.isMatched || card.isRevealed) return;

    cards[index] = card.reveal();
    emit(state.copyWith(cards: cards));

    final revealed = _revealedUnmatched(cards);
    if (revealed.length == 2) {
      _resolvePair(revealed[0], revealed[1]);
    }
  }

  Future<void> _resolvePair(GameCard a, GameCard b) async {
    _busy = true;
    final cards = List<GameCard>.from(state.cards);
    final idxA = cards.indexWhere((c) => c.id == a.id);
    final idxB = cards.indexWhere((c) => c.id == b.id);

    if (a.symbolId == b.symbolId) {
      cards[idxA] = cards[idxA].match();
      cards[idxB] = cards[idxB].match();

      final matchesAfter = state.matches + 1;
      final totalPairs = cards.length ~/ 2;

      final newStreak = state.streak + 1;

      final newMultiplier = newStreak < 2 ? 1 : newStreak.clamp(2, 5);
      final add = 50 * newMultiplier;

      final completed = matchesAfter == totalPairs;

      var newScore = state.score + add;

      if (completed) {
        // simple end bonuses
        final timeBonus = state.secondsLeft * 2;
        final gridBonus = totalPairs * 10;
        newScore += timeBonus + gridBonus;
      }

      emit(
        state.copyWith(
          cards: cards,
          matches: matchesAfter,
          moves: state.moves + 1,
          completed: completed,
          score: newScore,
          streak: newStreak,
          multiplier: newMultiplier,
        ),
      );

      if (completed) _timer?.cancel();
    } else {
      await Future.delayed(const Duration(milliseconds: 650));
      cards[idxA] = cards[idxA].hide();
      cards[idxB] = cards[idxB].hide();
      emit(state.copyWith(cards: cards, moves: state.moves + 1, streak: 0, multiplier: 1));
    }
    _busy = false;
  }

  List<GameCard> _revealedUnmatched(List<GameCard> cards) => cards.where((c) => c.isRevealed && !c.isMatched).toList();

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
