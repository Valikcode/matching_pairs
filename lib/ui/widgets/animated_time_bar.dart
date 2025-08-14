import 'package:flutter/material.dart';

class AnimatedTimeBar extends StatelessWidget {
  final double fraction;

  const AnimatedTimeBar({super.key, required this.fraction});

  Color _colorForFraction(double f) {
    if (f >= 0.5) {
      final t = (1 - f) * 2;
      return Color.lerp(Colors.green, Colors.yellow, t)!;
    } else {
      final t = (0.5 - f) * 2;
      return Color.lerp(Colors.yellow, Colors.red, t)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: fraction, end: fraction),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            valueColor: AlwaysStoppedAnimation<Color>(_colorForFraction(value)),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
        );
      },
    );
  }
}
