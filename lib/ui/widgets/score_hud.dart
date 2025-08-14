import 'package:flutter/material.dart';
import 'package:matching_pairs/ui/widgets/multiplier_badge.dart';
import 'package:matching_pairs/ui/widgets/animated_score_text.dart';

class ScoreHud extends StatelessWidget {
  final int score;
  final int multiplier;

  const ScoreHud({super.key, required this.score, required this.multiplier});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 40);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScoreText(value: score, style: textStyle, duration: const Duration(milliseconds: 450)),
          if (multiplier >= 2) ...[
            const SizedBox(width: 8),
            Align(alignment: Alignment.bottomCenter, child: MultiplierBadge(multiplier: multiplier)),
          ],
        ],
      ),
    );
  }
}
