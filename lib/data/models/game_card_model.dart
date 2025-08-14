import 'package:equatable/equatable.dart';

class GameCard extends Equatable {
  final int id;
  final String symbolId;
  final bool isRevealed;
  final bool isMatched;

  const GameCard({
    required this.id,
    required this.symbolId,
    this.isRevealed = false,
    this.isMatched = false,
  });

  GameCard reveal() => copyWith(isRevealed: true);
  GameCard hide() => copyWith(isRevealed: false);
  GameCard match() => copyWith(isMatched: true);

  GameCard copyWith({int? id, String? symbolId, bool? isRevealed, bool? isMatched}) {
    return GameCard(
      id: id ?? this.id,
      symbolId: symbolId ?? this.symbolId,
      isRevealed: isRevealed ?? this.isRevealed,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  @override
  List<Object?> get props => [id, symbolId, isRevealed, isMatched];
}
