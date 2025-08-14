import 'package:flutter/material.dart';
import 'package:matching_pairs/data/local/highscore_store.dart';
import 'package:matching_pairs/data/models/mode_info.dart';
import 'dots_preview.dart';

class GameModeCard extends StatelessWidget {
  final ModeInfo info;
  final VoidCallback onTap;

  const GameModeCard({super.key, required this.info, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outline.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.grid_view_rounded, color: colors.primary),
                  const SizedBox(height: 0, width: 8),
                  Expanded(child: Text(info.title, style: theme.textTheme.titleLarge)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                info.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withOpacity(0.75)),
              ),

              const SizedBox(height: 8),

              Expanded(child: Center(child: DotsPreview(rows: info.rows, cols: info.cols))),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: onTap,
                  child: const Text('Play'),
                  style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary),
                ),
              ),
              const SizedBox(height: 6),

              FutureBuilder<int?>(
                future: HighscoreStore.instance.getHighscore(info.title),
                builder: (context, snapshot) {
                  final style = theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  );
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('High score: —', style: style);
                  }
                  final hs = snapshot.data;
                  return Text(hs == null ? 'High score: —' : 'High score: $hs', style: style);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
