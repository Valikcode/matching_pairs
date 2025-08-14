import 'package:matching_pairs/data/models/game_card_model.dart';

class GameState {
  final List<GameCard> cards;
  final int moves;
  final int matches;
  final bool completed;      // game ended (either by time or by clearing)
  final bool loading;
  final double timeLeft;     // 0..1
  final int secondsLeft;     // whole seconds remaining
  final int score;
  final int streak;          // current streak
  final int multiplier;
  final int bestStreak;      // longest streak this run
  final int gridCols;        // dynamic grid cols (endless uses this)
  final bool endedByTime;    // true if timer hit 0, false if all pairs matched

  const GameState({
    this.cards = const [],
    this.moves = 0,
    this.matches = 0,
    this.completed = false,
    this.loading = true,
    this.timeLeft = 1.0,
    this.secondsLeft = 0,
    this.score = 0,
    this.streak = 0,
    this.multiplier = 1,
    this.bestStreak = 0,
    this.gridCols = 0,
    this.endedByTime = false,
  });

  GameState copyWith({
    List<GameCard>? cards,
    int? moves,
    int? matches,
    bool? completed,
    bool? loading,
    double? timeLeft,
    int? secondsLeft,
    int? score,
    int? streak,
    int? multiplier,
    int? bestStreak,
    int? gridCols,
    bool? endedByTime,
  }) {
    return GameState(
      cards: cards ?? this.cards,
      moves: moves ?? this.moves,
      matches: matches ?? this.matches,
      completed: completed ?? this.completed,
      loading: loading ?? this.loading,
      timeLeft: timeLeft ?? this.timeLeft,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      multiplier: multiplier ?? this.multiplier,
      bestStreak: bestStreak ?? this.bestStreak,
      gridCols: gridCols ?? this.gridCols,
      endedByTime: endedByTime ?? this.endedByTime,
    );
  }
}
