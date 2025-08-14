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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Semantics(
                label: 'Matching Pairs logo',
                child: Image.asset(AppAssets.logo, height: 300, fit: BoxFit.contain, color: colors.primary),
              ),
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
        ),
      ),
    );
  }
}
