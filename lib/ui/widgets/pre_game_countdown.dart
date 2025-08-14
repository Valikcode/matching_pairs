import 'dart:async';
import 'package:flutter/material.dart';

Future<void> showPreGameCountdown(BuildContext context) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'countdown',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) => const _CountdownDialog(),
  );
}

class _CountdownDialog extends StatefulWidget {
  const _CountdownDialog();

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  static const _steps = ['3', '2', '1', 'GO!'];
  int _index = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 800), (t) {
      if (!mounted) return;
      setState(() => _index++);
      if (_index >= _steps.length) {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _steps[_index.clamp(0, _steps.length - 1)];
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder:
              (child, anim) => ScaleTransition(
                scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                child: FadeTransition(opacity: anim, child: child),
              ),
          child: Container(
            key: ValueKey(text),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: scheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.primary.withOpacity(0.35)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12)],
            ),
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
