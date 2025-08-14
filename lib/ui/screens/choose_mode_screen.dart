import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:matching_pairs/core/constants/modes.dart';
import 'package:matching_pairs/core/router/routes.dart';
import 'package:matching_pairs/logic/game_theme/theme_cubit.dart';
import 'package:matching_pairs/logic/game_theme/theme_state.dart';
import 'package:matching_pairs/ui/widgets/game_mode_card.dart';
import 'package:matching_pairs/ui/widgets/theme_choice_chip.dart';

class ChooseModeScreen extends StatefulWidget {
  const ChooseModeScreen({super.key});

  @override
  State<ChooseModeScreen> createState() => _ChooseModeScreenState();
}

class _ChooseModeScreenState extends State<ChooseModeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ThemeCubit>().ensureLoaded());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose mode'), leading: BackButton(onPressed: () => context.pop())),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 72,
                      child: BlocBuilder<ThemeCubit, ThemeState>(
                        builder: (context, state) {
                          if (state.loading && state.themes.isEmpty) {
                            return const Center(
                              child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                            );
                          }
                          if (state.themes.isEmpty) {
                            return const Center(
                              child: Padding(padding: EdgeInsets.all(16), child: Text('No themes available')),
                            );
                          }
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.themes.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final t = state.themes[i];
                              final selected = state.selected?.id == t.id;
                              return ThemeChoiceChip(
                                pack: t,
                                selected: selected,
                                onSelect: () => context.read<ThemeCubit>().select(t),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, state) {
                      return IconButton(
                        tooltip: 'Refresh themes',
                        onPressed: state.loading ? null : () => context.read<ThemeCubit>().refresh(),
                        icon:
                            state.loading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                : const Icon(Icons.refresh),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 640;
                    final crossAxisCount = isWide ? 4 : 2;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: isWide ? 1.05 : 0.82,
                      ),
                      itemCount: kGameModes.length,
                      itemBuilder: (context, index) {
                        final m = kGameModes[index];
                        // inside itemBuilder:
                        return GameModeCard(
                          info: m,
                          onTap: () async {
                            final updated = await context.pushNamed(
                              Routes.play.name,
                              queryParameters: {'mode': m.mode},
                            );
                            if (mounted && updated == true) setState(() {});
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Pick a mode to start playing',
                style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
