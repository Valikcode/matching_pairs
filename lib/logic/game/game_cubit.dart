import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matching_pairs/core/constants/modes.dart'; // for getModeByName
import 'package:matching_pairs/data/models/game_card_model.dart';
import 'package:matching_pairs/data/models/mode_info.dart';
import 'package:matching_pairs/logic/game/game_state.dart';
import 'package:matching_pairs/logic/game_theme/theme_cubit.dart';

class GameCubit extends Cubit<GameState> {
  final ModeInfo mode;
  final ThemeCubit themeCubit;
  Timer? _timer;
  bool _busy = false;

  // ENDLESS helpers
  DateTime? _endAt;           // current timer "deadline"
  int _matchedSinceAdd = 0;   // pairs since we last injected new cards
  final _rng = Random();

  bool get _isEndless => mode.mode.toLowerCase() == 'endless';

  GameCubit({required this.mode, required this.themeCubit}) : super(const GameState());

  void startGame() {
    final themePack = themeCubit.state.selected;
    if (themePack == null || themePack.symbols.isEmpty) {
      emit(state.copyWith(loading: false));
      return;
    }

    final neededPairs = (mode.rows * mode.cols) ~/ 2;
    final base = List<String>.from(themePack.symbols)..shuffle(_rng);

    final chosenPairs = <String>[];
    chosenPairs.addAll(base.take(neededPairs));
    while (chosenPairs.length < neededPairs) {
      chosenPairs.add(base[_rng.nextInt(base.length)]);
    }

    final allCards = <GameCard>[];
    var id = 0;
    for (final sym in chosenPairs) {
      allCards.add(GameCard(id: id++, symbolId: sym));
      allCards.add(GameCard(id: id++, symbolId: sym));
    }
    allCards.shuffle(_rng);

    _timer?.cancel();
    _matchedSinceAdd = 0;

    // initial seconds: 30 for endless; else whatever the mode says
    final initialSeconds = _isEndless ? 30 : mode.time;

    emit(
      state.copyWith(
        cards: allCards,
        moves: 0,
        matches: 0,
        completed: false,
        endedByTime: false,
        loading: false,
        timeLeft: 1.0,
        secondsLeft: initialSeconds,
        score: 0,
        streak: 0,
        multiplier: 1,
        bestStreak: 0,
        gridCols: mode.cols,
      ),
    );

    if (initialSeconds > 0) _startTimer(initialSeconds);
  }

  void _startTimer(int seconds) {
    _endAt = DateTime.now().add(Duration(seconds: seconds));
    _timer?.cancel();

    emit(state.copyWith(secondsLeft: seconds, timeLeft: 1.0));

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final now = DateTime.now();
      final endAt = _endAt!;
      final remaining = endAt.isAfter(now) ? (endAt.difference(now).inMilliseconds / 1000).ceil() : 0;
      // note: in endless, this is only a rough bar (base on first span)
      final totalSpan = seconds;
      final fraction = totalSpan > 0 ? (remaining / totalSpan).clamp(0.0, 1.0) : 1.0;

      emit(state.copyWith(secondsLeft: remaining, timeLeft: fraction));

      if (remaining == 0) {
        timer.cancel();
        emit(state.copyWith(completed: true, endedByTime: true));
      }
    });
  }

  void _extendTimeBySeconds(int add) {
    if (_endAt == null) return;
    _endAt = _endAt!.add(Duration(seconds: add));
    final now = DateTime.now();
    final remaining = _endAt!.isAfter(now) ? (_endAt!.difference(now).inMilliseconds / 1000).ceil() : 0;
    emit(state.copyWith(secondsLeft: remaining));
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
      final newBest = newStreak > state.bestStreak ? newStreak : state.bestStreak;

      final newMultiplier = newStreak < 2 ? 1 : newStreak.clamp(2, 5);
      final add = 50 * newMultiplier;

      var newScore = state.score + add;
      bool completed = state.completed; // default carry-over

      if (_isEndless) {
        _extendTimeBySeconds(3);        // +3s per resolved pair
        _matchedSinceAdd += 1;

        if (_matchedSinceAdd >= 2) {
          _matchedSinceAdd = 0;
          _addPairs(cards, 2);          // re-add 2 pairs every 2 resolved
        }

        _maybeIncreaseGridByScore(newScore); // grow grid with score
        // in endless, "completed" only becomes true when timer hits 0
      } else {
        completed = matchesAfter == totalPairs;
        if (completed) {
          final timeBonus = state.secondsLeft * 2; // your chosen rule
          final gridBonus = totalPairs * 10;
          newScore += timeBonus + gridBonus;
          _timer?.cancel();
        }
      }

      emit(
        state.copyWith(
          cards: cards,
          matches: matchesAfter,
          moves: state.moves + 1,
          completed: completed,
          endedByTime: completed ? false : state.endedByTime,
          score: newScore,
          streak: newStreak,
          bestStreak: newBest,
          multiplier: newMultiplier,
        ),
      );
    } else {
      await Future.delayed(const Duration(milliseconds: 650));
      cards[idxA] = cards[idxA].hide();
      cards[idxB] = cards[idxB].hide();
      emit(state.copyWith(cards: cards, moves: state.moves + 1, streak: 0, multiplier: 1));
    }
    _busy = false;
  }

  void _addPairs(List<GameCard> cards, int pairCount) {
    final themePack = themeCubit.state.selected;
    if (themePack == null || themePack.symbols.isEmpty) return;

    for (int i = 0; i < pairCount; i++) {
      final sym = themePack.symbols[_rng.nextInt(themePack.symbols.length)];
      final nextId = (cards.isEmpty ? 0 : (cards.map((c) => c.id).reduce(max) + 1));
      cards.add(GameCard(id: nextId, symbolId: sym));
      cards.add(GameCard(id: nextId + 1, symbolId: sym));
    }
    cards.shuffle(_rng);
  }

  void _maybeIncreaseGridByScore(int score) {
    final easy = getModeByName('easy');    // ensure these keys match your modes.dart
    final medium = getModeByName('medium');
    final hard = getModeByName('hard');

    int targetCols;
    if (score >= 1000) {
      targetCols = hard.cols;
    } else if (score >= 500) {
      targetCols = medium.cols;
    } else {
      targetCols = easy.cols;
    }

    if (state.gridCols != targetCols) {
      emit(state.copyWith(gridCols: targetCols));
    }
  }

  List<GameCard> _revealedUnmatched(List<GameCard> cards) =>
      cards.where((c) => c.isRevealed && !c.isMatched).toList();

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
