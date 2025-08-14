import 'package:flutter/material.dart';

class ShakingCountdownText extends StatefulWidget {
  final int secondsLeft;
  final double fraction; // 1.0 = full, 0.0 = empty

  const ShakingCountdownText({super.key, required this.secondsLeft, required this.fraction});

  @override
  State<ShakingCountdownText> createState() => _ShakingCountdownTextState();
}

class _ShakingCountdownTextState extends State<ShakingCountdownText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    final shouldShake = widget.fraction > 0 && widget.fraction <= (1 / 3);
    final maxShake = 6.0;
    final urgency = 1 - widget.fraction * 3;
    final shakeAmount = shouldShake ? urgency.clamp(0, 1) * maxShake : 0.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offsetX = shakeAmount * (_controller.value - 0.5) * 2;
        return Transform.translate(
          offset: Offset(offsetX, 0),
          child: Text(
            '${widget.secondsLeft} s',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: _colorForFraction(widget.fraction),
            ),
          ),
        );
      },
    );
  }
}
