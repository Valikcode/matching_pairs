import 'dart:math' as math;
import 'package:flutter/material.dart';

class GameCardWidget extends StatefulWidget {
  final bool revealed;
  final bool matched;
  final Widget front;
  final VoidCallback onTap;
  final Color backColor;
  final String backSymbol;
  final double aspectRatio;

  const GameCardWidget({
    super.key,
    required this.revealed,
    required this.matched,
    required this.front,
    required this.onTap,
    required this.backColor,
    required this.backSymbol,
    this.aspectRatio = 0.72,
  });

  @override
  State<GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<GameCardWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _flip;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _flip = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant GameCardWidget old) {
    super.didUpdateWidget(old);
    if (widget.revealed && !_c.isCompleted) _c.forward();
    if (!widget.revealed && !_c.isDismissed) _c.reverse();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio, // < 1.0 ⇒ taller
      child: GestureDetector(
        onTap: widget.matched ? null : widget.onTap,
        child: AnimatedBuilder(
          animation: _flip,
          builder: (context, _) {
            final angle = _flip.value * math.pi;
            final isFront = angle > math.pi / 2;

            return Transform(
              transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
              alignment: Alignment.center,
              child: isFront
                  ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: _CardFace(
                  matched: widget.matched,
                  child: widget.front,
                  borderColor: Theme.of(context).colorScheme.outlineVariant,
                  background: Theme.of(context).colorScheme.surface,
                ),
              )
                  : _CardFace(
                matched: widget.matched,
                borderColor: widget.backColor,
                background: widget.backColor.withOpacity(0.18),
                child: _CardBack(symbol: widget.backSymbol, color: widget.backColor),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final Widget child;
  final bool matched;
  final Color borderColor;
  final Color background;

  const _CardFace({required this.child, required this.matched, required this.borderColor, required this.background});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: matched ? 0.45 : 1,
      duration: const Duration(milliseconds: 180),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final String symbol;
  final Color color;

  const _CardBack({required this.symbol, required this.color});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Text(symbol, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}
