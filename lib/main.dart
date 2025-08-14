import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matching_pairs/logic/app_theme/theme_mode_cubit.dart';
import 'package:matching_pairs/logic/game_theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/theme_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final themeRepo = ThemeRepository();
  final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;

  runApp(MyApp(themeRepository: themeRepo, prefs: prefs, platformBrightness: platformBrightness));
}

class MyApp extends StatelessWidget {
  final ThemeRepository themeRepository;
  final SharedPreferences prefs;
  final Brightness platformBrightness;

  const MyApp({super.key, required this.themeRepository, required this.prefs, required this.platformBrightness});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider.value(value: themeRepository),
        BlocProvider(create: (_) => ThemeCubit(themeRepository)..loadFromCacheFirst()),
        BlocProvider(create: (_) => ThemeModeCubit(prefs: prefs, platformBrightness: platformBrightness)),
      ],
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
