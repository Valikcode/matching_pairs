import 'package:flutter/material.dart';
import 'package:matching_pairs/data/models/theme_pack.dart';

class ThemeChoiceChip extends StatelessWidget {
  final ThemePack pack;
  final bool selected;
  final VoidCallback onSelect;

  const ThemeChoiceChip({
    super.key,
    required this.pack,
    required this.selected,
    required this.onSelect,
  });

  Color _onColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bg = selected
        ? pack.cardColor.withOpacity(0.25)
        : scheme.surfaceVariant.withOpacity(0.35);

    final border = selected
        ? pack.cardColor
        : scheme.outline.withOpacity(0.3);

    final labelColor = selected
        ? _onColor(context)
        : scheme.onSurface;

    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onSelect(),
      showCheckmark: false,
      backgroundColor: bg,
      selectedColor: bg,
      side: BorderSide(color: border),
      shape: const StadiumBorder(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(pack.cardSymbol, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            pack.title,
            style: TextStyle(
              color: labelColor,
              // keep the same weight so width doesn't shift
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
