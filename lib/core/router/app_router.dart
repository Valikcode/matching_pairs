import 'package:go_router/go_router.dart';
import 'package:matching_pairs/core/router/routes.dart';
import 'package:matching_pairs/ui/screens/welcome_screen.dart';
import 'package:matching_pairs/ui/screens/choose_mode_screen.dart';
import 'package:matching_pairs/ui/screens/play_screen.dart';
import 'package:matching_pairs/ui/screens/results_screen.dart';

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  routes: [
    GoRoute(name: Routes.home.routeName, path: Routes.home.path, builder: (ctx, st) => const WelcomeScreen()),
    GoRoute(name: Routes.modes.routeName, path: Routes.modes.path, builder: (ctx, st) => const ChooseModeScreen()),
    GoRoute(
      name: Routes.play.routeName,
      path: Routes.play.path,
      builder: (ctx, st) {
        final mode = st.uri.queryParameters['mode'] ?? 'easy';
        return PlayScreen(mode: mode);
      },
    ),
    GoRoute(name: Routes.results.routeName, path: Routes.results.path, builder: (ctx, st) => ResultsScreen()),
  ],
);
