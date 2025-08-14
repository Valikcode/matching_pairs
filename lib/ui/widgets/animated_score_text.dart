import 'package:flutter/material.dart';

class AnimatedScoreText extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const AnimatedScoreText({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedScoreText> createState() => _AnimatedScoreTextState();
}

class _AnimatedScoreTextState extends State<AnimatedScoreText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  int _from = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _controller, curve: widget.curve);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedScoreText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _from = oldWidget.value;
      _controller
        ..duration = widget.duration
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.value;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final current = (_from + (target - _from) * _anim.value).round();
        return Text('$current', style: widget.style);
      },
    );
  }
}
