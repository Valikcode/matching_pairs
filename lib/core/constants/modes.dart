import 'package:matching_pairs/data/models/mode_info.dart';

final List<ModeInfo> kGameModes = [
  ModeInfo(mode: 'easy', title: 'Easy', subtitle: '2×4 grid • 45s', rows: 2, cols: 4, time: 45),
  ModeInfo(mode: 'medium', title: 'Medium', subtitle: '3×4 grid • 60s', rows: 3, cols: 4, time: 60),
  ModeInfo(mode: 'hard', title: 'Hard', subtitle: '4×5 grid • 90s', rows: 4, cols: 5, time: 90),
  ModeInfo(mode: 'endless', title: 'Endless', subtitle: 'Starts 2×4 • stages', rows: 2, cols: 4, time: 30),
];

ModeInfo getModeByName(String name) {
  return kGameModes.firstWhere((m) => m.mode == name, orElse: () => kGameModes.first);
}
