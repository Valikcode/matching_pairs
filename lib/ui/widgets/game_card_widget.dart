import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:matching_pairs/core/constants/app_assets.dart';

class GameCardWidget extends StatefulWidget {
  final bool revealed;
  final bool matched;
  final Widget front;
  final VoidCallback onTap;
  final Color backColor;
  final String backSymbol;

  const GameCardWidget({
    super.key,
    required this.revealed,
    required this.matched,
    required this.front,
    required this.onTap,
    required this.backColor,
    required this.backSymbol,
  });

  @override
  State<GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<GameCardWidget> with TickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _flip;

  AnimationController? _fw;
  bool _showFirework = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _flip = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    if (widget.revealed) _c.value = 1;
  }

  @override
  void didUpdateWidget(covariant GameCardWidget old) {
    super.didUpdateWidget(old);
    if (widget.revealed && !_c.isCompleted) _c.forward();
    if (!widget.revealed && !_c.isDismissed) _c.reverse();

    if (!old.matched && widget.matched) {
      _playFireworkOnce();
    }
  }

  void _playFireworkOnce() {
    _fw?.dispose();
    _fw = AnimationController(vsync: this);
    setState(() => _showFirework = true);
  }

  @override
  void dispose() {
    _c.dispose();
    _fw?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: GestureDetector(
        onTap: widget.matched ? null : widget.onTap,
        child: AnimatedBuilder(
          animation: _flip,
          builder: (context, _) {
            final angle = _flip.value * math.pi;
            final isFront = angle > math.pi / 2;

            final card = Transform(
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
              alignment: Alignment.center,
              child:
                  isFront
                      ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: _CardFace(
                          matched: widget.matched,
                          borderColor: Theme.of(context).colorScheme.outlineVariant,
                          background: Theme.of(context).colorScheme.surface,
                          child: widget.front,
                        ),
                      )
                      : _CardFace(
                        matched: widget.matched,
                        borderColor: widget.backColor,
                        background: widget.backColor.withOpacity(0.18),
                        child: _CardBack(symbol: widget.backSymbol, color: widget.backColor),
                      ),
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                card,
                if (_showFirework)
                  IgnorePointer(
                    child: Lottie.asset(
                      AppAssets.fireworkLottie,
                      controller: _fw,
                      fit: BoxFit.cover,
                      onLoaded: (comp) {
                        _fw?.duration = comp.duration * (1 / 2);
                        _fw?.forward(from: 0).whenComplete(() {
                          if (mounted) setState(() => _showFirework = false);
                        });
                      },
                    ),
                  ),
              ],
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
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
      child: Padding(padding: const EdgeInsets.all(6), child: Text(symbol, style: const TextStyle(fontSize: 28))),
    );
  }
}
