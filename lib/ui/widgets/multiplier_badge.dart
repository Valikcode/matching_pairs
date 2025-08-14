import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MultiplierBadge extends StatelessWidget {
  final int multiplier;

  const MultiplierBadge({super.key, required this.multiplier});

  @override
  Widget build(BuildContext context) {
    final hasFire = multiplier >= 3;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (hasFire)
          SizedBox(width: 48, height: 48, child: Lottie.asset('assets/lottie/fire.json', repeat: true, animate: true)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: hasFire ? Colors.black.withOpacity(0.8) : Colors.black.withOpacity(0.05),
            border: Border.all(color: Colors.orange.withOpacity(0.45)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '×$multiplier',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.7), offset: const Offset(1, 1))],
            ),
          ),
        ),
      ],
    );
  }
}
