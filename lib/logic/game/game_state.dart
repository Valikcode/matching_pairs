import 'package:matching_pairs/data/models/game_card_model.dart';

class GameState {
  final List<GameCard> cards;
  final int moves;
  final int matches;
  final double timeLeft;
  final int secondsLeft;
  final bool completed;
  final bool loading;

  // scoring
  final int score;
  final int streak;
  final int multiplier;

  const GameState({
    this.cards = const [],
    this.moves = 0,
    this.matches = 0,
    this.timeLeft = 1.0,
    this.secondsLeft = 0,
    this.completed = false,
    this.loading = false,
    this.score = 0,
    this.streak = 0,
    this.multiplier = 1,
  });

  GameState copyWith({
    List<GameCard>? cards,
    int? moves,
    int? matches,
    double? timeLeft,
    int? secondsLeft,
    bool? completed,
    bool? loading,
    int? score,
    int? streak,
    int? multiplier,
  }) {
    return GameState(
      cards: cards ?? this.cards,
      moves: moves ?? this.moves,
      matches: matches ?? this.matches,
      timeLeft: timeLeft ?? this.timeLeft,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      completed: completed ?? this.completed,
      loading: loading ?? this.loading,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      multiplier: multiplier ?? this.multiplier,
    );
  }
}
