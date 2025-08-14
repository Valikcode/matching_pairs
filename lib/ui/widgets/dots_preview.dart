import 'package:flutter/material.dart';

class DotsPreview extends StatelessWidget {
  final int rows;
  final int cols;
  final double maxHeight;

  const DotsPreview({super.key, required this.rows, required this.cols, this.maxHeight = 70});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, c) {
        final capH = maxHeight.clamp(0, c.maxHeight.isFinite ? c.maxHeight : maxHeight);
        final maxW = c.maxWidth;
        const gap = 4.0;

        final dotW = (maxW - (gap * (cols - 1))) / cols;
        final dotH = (capH - (gap * (rows - 1))) / rows;
        final size = dotW < dotH ? dotW : dotH;

        final totalW = (size * cols) + (gap * (cols - 1));
        final totalH = (size * rows) + (gap * (rows - 1));

        return SizedBox(
          width: totalW,
          height: totalH,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(rows, (r) {
              return Padding(
                padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : gap),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(cols, (c) {
                    return Padding(
                      padding: EdgeInsets.only(right: c == cols - 1 ? 0 : gap),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.08),
                          border: Border.all(color: colors.primary.withOpacity(0.25)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
