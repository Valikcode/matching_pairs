import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:matching_pairs/core/constants/app_assets.dart';
import 'package:matching_pairs/core/constants/modes.dart';
import 'package:matching_pairs/data/local/highscore_store.dart';
import 'package:matching_pairs/logic/game/game_cubit.dart';
import 'package:matching_pairs/logic/game/game_state.dart';
import 'package:matching_pairs/logic/game_theme/theme_cubit.dart';
import 'package:matching_pairs/logic/game_theme/theme_state.dart';
import 'package:matching_pairs/ui/widgets/animated_time_bar.dart';
import 'package:matching_pairs/ui/widgets/countdown_text.dart';
import 'package:matching_pairs/ui/widgets/game_card_widget.dart';
import 'package:matching_pairs/ui/widgets/pre_game_countdown.dart';
import 'package:matching_pairs/ui/widgets/score_hud.dart';

import 'dart:math' as math;

class PlayScreen extends StatefulWidget {
  final String mode;

  const PlayScreen({super.key, required this.mode});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with TickerProviderStateMixin {
  late final GameCubit _cubit;
  late final _m = getModeByName(widget.mode);
  bool _dialogShown = false;
  bool _lastRunNewHigh = false;

  @override
  void initState() {
    super.initState();
    _cubit = GameCubit(mode: _m, themeCubit: context.read<ThemeCubit>());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showPreGameCountdown(context);
      if (!mounted) return;
      _cubit.startGame();
    });
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  bool _didWin(GameState s) => s.completed && !s.endedByTime;

  bool _didLose(GameState s) => s.completed && s.endedByTime;

  List<OverlayEntry> _spawnWinFireworks({int count = 8, double speed = 1.0}) {
    final overlay = Overlay.of(context);
    final size = MediaQuery.of(context).size;
    final rnd = math.Random();
    final entries = <OverlayEntry>[];

    final cx = size.width / 2;
    final cy = size.height / 2;
    final excludeW = 280.0;
    final excludeH = 220.0;
    final halfW = excludeW / 2;
    final halfH = excludeH / 2;

    double randX() {
      while (true) {
        final x = rnd.nextDouble() * size.width;
        if (x < cx - halfW - 40 || x > cx + halfW + 40) return x;
      }
    }

    double randY() {
      while (true) {
        final y = rnd.nextDouble() * size.height;
        if (y < cy - halfH - 40 || y > cy + halfH + 40) return y;
      }
    }

    for (int i = 0; i < count; i++) {
      final left = randX();
      final top = randY();
      final w = 120.0 + rnd.nextDouble() * 60.0;
      final h = w;

      final controller = AnimationController(vsync: this);

      late OverlayEntry entry;
      entry = OverlayEntry(
        builder:
            (_) => Positioned(
              left: left,
              top: top,
              width: w,
              height: h,
              child: IgnorePointer(
                child: Lottie.asset(
                  AppAssets.fireworkLottie,
                  controller: controller,
                  fit: BoxFit.cover,
                  onLoaded: (comp) {
                    controller.duration = comp.duration ~/ 1;
                    controller.forward(from: 0).whenComplete(() {
                      controller.dispose();

                      try {
                        entry.remove();
                      } catch (_) {}
                    });
                  },
                ),
              ),
            ),
      );

      overlay.insert(entry);
      entries.add(entry);
    }

    return entries;
  }

  Future<void> _showResultDialog(GameState s, {required bool isNewHigh}) async {
    final timeBonus = s.secondsLeft * 2;
    final timeBonusLine = s.secondsLeft > 0 ? '+$timeBonus points from time bonus' : null;

    final win = _didWin(s);
    final title = win ? 'You Win!' : 'You Lose';
    final timeText = win ? 'Time remaining: ${s.secondsLeft}s' : 'Time ran out';
    final scoreText = 'Score: ${s.score}';
    final streakText = 'Longest streak: ${s.bestStreak}';
    List<OverlayEntry> overlayFx = [];
    if (win) {
      overlayFx = _spawnWinFireworks(count: 10, speed: 1.8);
    }
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.secondsLeft > 0) Text(timeText),
                if (isNewHigh) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('New Highscore!', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
                if (timeBonusLine != null) Text(timeBonusLine, style: const TextStyle(color: Colors.green)),
                const SizedBox(height: 8),
                Text(scoreText),
                Text(streakText),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.pop(_lastRunNewHigh);
                },
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _dialogShown = false;
                  _cubit.startGame();
                },
                child: const Text('Play again'),
              ),
            ],
          );
        },
      );
    } finally {
      for (final e in overlayFx) {
        try {
          e.remove();
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameCubit>.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_m.title} Mode'),
          leading: BackButton(onPressed: () => context.pop(_lastRunNewHigh)),
        ),
        body: SafeArea(
          child: BlocListener<GameCubit, GameState>(
            listenWhen:
                (prev, curr) =>
                    prev.completed != curr.completed ||
                    prev.secondsLeft != curr.secondsLeft ||
                    prev.matches != curr.matches,
            listener: (context, s) async {
              if (_dialogShown) return;
              if (_didWin(s) || _didLose(s)) {
                _dialogShown = true;
                final isNewHigh = await HighscoreStore.instance.updateHighscoreIfBeats(_m.title, s.score);
                _lastRunNewHigh = isNewHigh;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _showResultDialog(s, isNewHigh: isNewHigh);
                });
              }
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: BlocBuilder<GameCubit, GameState>(
                    buildWhen: (p, c) => p.secondsLeft != c.secondsLeft || p.timeLeft != c.timeLeft,
                    builder: (context, state) {
                      if (state.secondsLeft <= 0) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ShakingCountdownText(secondsLeft: state.secondsLeft, fraction: state.timeLeft),
                          const SizedBox(height: 4),
                          AnimatedTimeBar(fraction: state.timeLeft),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BlocBuilder<GameCubit, GameState>(
                      builder: (context, gameState) {
                        return BlocBuilder<ThemeCubit, ThemeState>(
                          builder: (context, themeState) {

                            return LayoutBuilder(
                              builder: (context, box) {
                                final cards = gameState.cards;
                                if (cards.isEmpty) return const SizedBox.shrink();

                                final cols = gameState.gridCols > 0 ? gameState.gridCols : _m.cols;
                                const spacing = 8.0;


                                final rows = math.max(1, (cards.length / cols).ceil());
                                final totalH = box.maxHeight - spacing * (rows - 1);

                                final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
                                const maxHPortrait = 120.0;
                                final tileHRaw = totalH / rows;
                                final tileH = isPortrait ? math.min(tileHRaw, maxHPortrait) : tileHRaw;

                                final gridHeight = rows * tileH + spacing * (rows - 1);

                                return SizedBox(
                                  height: gridHeight,
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cols,
                                      crossAxisSpacing: spacing,
                                      mainAxisSpacing: spacing,
                                      mainAxisExtent: tileH,
                                    ),
                                    itemCount: cards.length,
                                    itemBuilder: (context, index) {
                                      final card = cards[index];
                                      final pack = context.read<ThemeCubit>().state.selected;
                                      final cardColor = pack?.cardColor ?? Theme.of(context).colorScheme.primary;
                                      final symbols = pack?.symbols ?? [];
                                      final backSymbol = pack?.cardSymbol ?? '🎴';
                                      final revealed = card.isRevealed || card.isMatched;
                                      final symbolChar = symbols.isNotEmpty ? card.symbolId : '';

                                      return GameCardWidget(
                                        revealed: revealed,
                                        matched: card.isMatched,
                                        front: Text(symbolChar, style: const TextStyle(fontSize: 28)),
                                        onTap: () => context.read<GameCubit>().flipCard(index),
                                        backColor: cardColor,
                                        backSymbol: backSymbol,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                BlocBuilder<GameCubit, GameState>(
                  builder:
                      (context, s) => SafeArea(
                        top: false,
                        child: Align(
                          alignment: Alignment.center,
                          child: ScoreHud(score: s.score, multiplier: s.multiplier),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
