import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matching_pairs/core/constants/modes.dart';
import 'package:matching_pairs/logic/game/game_cubit.dart';
import 'package:matching_pairs/logic/game/game_state.dart';
import 'package:matching_pairs/logic/game_theme/theme_cubit.dart';
import 'package:matching_pairs/logic/game_theme/theme_state.dart';
import 'package:matching_pairs/ui/widgets/animated_time_bar.dart';
import 'package:matching_pairs/ui/widgets/countdown_text.dart';
import 'package:matching_pairs/ui/widgets/game_card_widget.dart';
import 'package:matching_pairs/ui/widgets/pre_game_countdown.dart';
import 'package:matching_pairs/ui/widgets/score_hud.dart';

class PlayScreen extends StatefulWidget {
  final String mode;

  const PlayScreen({super.key, required this.mode});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final GameCubit _cubit;
  late final _m = getModeByName(widget.mode);

  @override
  void initState() {
    super.initState();
    _cubit = GameCubit(mode: _m, themeCubit: context.read<ThemeCubit>());

    // Show 3..2..1..GO! then start the game on the same cubit instance
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameCubit>.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_m.title} Mode'),
          leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (_m.time > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: BlocBuilder<GameCubit, GameState>(
                    builder:
                        (context, state) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ShakingCountdownText(secondsLeft: state.secondsLeft, fraction: state.timeLeft),
                            const SizedBox(height: 4),
                            AnimatedTimeBar(fraction: state.timeLeft),
                          ],
                        ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BlocBuilder<GameCubit, GameState>(
                    builder: (context, gameState) {
                      return BlocBuilder<ThemeCubit, ThemeState>(
                        builder: (context, themeState) {
                          final pack = themeState.selected;
                          final cardColor = pack?.cardColor ?? Theme.of(context).colorScheme.primary;
                          final symbols = pack?.symbols ?? [];
                          final backSymbol = pack?.cardSymbol ?? '🎴';

                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _m.cols,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: gameState.cards.length,
                            itemBuilder: (context, index) {
                              final card = gameState.cards[index];
                              final revealed = card.isRevealed || card.isMatched;
                              final symbolChar = symbols.isNotEmpty ? card.symbolId : '';
                              return GameCardWidget(
                                revealed: revealed,
                                matched: card.isMatched,
                                front: Text(symbolChar, style: const TextStyle(fontSize: 28)),
                                onTap: () => context.read<GameCubit>().flipCard(index),
                                backColor: cardColor,
                                backSymbol: backSymbol,
                                aspectRatio: 0.72,
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
                    (context, s) => SafeArea(top: false, child: ScoreHud(score: s.score, multiplier: s.multiplier)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
