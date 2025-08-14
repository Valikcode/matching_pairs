import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:matching_pairs/core/constants/app_assets.dart';
import 'package:matching_pairs/core/router/routes.dart';
import 'package:matching_pairs/logic/app_theme/theme_mode_cubit.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(context.watch<ThemeModeCubit>().state == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => context.read<ThemeModeCubit>().toggle(),
          ),
        ],
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            if (!isLandscape) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Expanded(
                      child: Semantics(
                        label: 'Matching Pairs logo',
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 360),
                            child: Image.asset(AppAssets.logo, fit: BoxFit.contain, color: colors.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          textStyle: theme.textTheme.titleMedium,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => context.pushNamed(Routes.modes.name),
                        child: const Text('Play now!'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Semantics(
                        label: 'Matching Pairs logo',
                        child: LayoutBuilder(
                          builder: (context, c) {
                            final maxSide = c.biggest.shortestSide.clamp(200.0, 420.0);
                            return ConstrainedBox(
                              constraints: BoxConstraints.tightFor(width: maxSide, height: maxSide),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Image.asset(AppAssets.logo, color: colors.primary),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Matching Pairs',
                              style: theme.textTheme.headlineSmall?.copyWith(color: colors.primary),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  textStyle: theme.textTheme.titleMedium,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () => context.pushNamed(Routes.modes.name),
                                child: const Text('Play now!'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
