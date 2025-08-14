enum Difficulty { easy, medium, hard, endless }

extension DifficultyX on Difficulty {
  String get name {
    switch (this) {
      case Difficulty.easy:
        return 'easy';
      case Difficulty.medium:
        return 'medium';
      case Difficulty.hard:
        return 'hard';
      case Difficulty.endless:
        return 'endless';
    }
  }
}

Difficulty difficultyFromString(String value) {
  switch (value.toLowerCase()) {
    case 'easy':
      return Difficulty.easy;
    case 'medium':
      return Difficulty.medium;
    case 'hard':
      return Difficulty.hard;
    case 'endless':
      return Difficulty.endless;
    default:
      return Difficulty.easy;
  }
}
