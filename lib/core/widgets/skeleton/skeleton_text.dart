import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_box.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SkeletonText — Realistic multi-line text simulation with natural varied line lengths.
/// ─────────────────────────────────────────────────────────────────────────────
class SkeletonText extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;
  final double? width;
  final BorderRadiusGeometry? borderRadius;

  const SkeletonText({
    super.key,
    this.lines = 2,
    this.lineHeight = 12,
    this.spacing = 6,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(4);

    if (lines == 1) {
      return SkeletonBox(
        width: width ?? double.infinity,
        height: lineHeight,
        borderRadius: radius,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lines, (index) {
        double factor = 1.0;
        if (index == lines - 1 && lines > 1) {
          factor = 0.55;
        } else if (index % 2 == 1) {
          factor = 0.85;
        }

        final isLast = index == lines - 1;

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
          child: FractionallySizedBox(
            widthFactor: width != null ? null : factor,
            child: SkeletonBox(
              width: width != null ? width! * factor : double.infinity,
              height: lineHeight,
              borderRadius: radius,
            ),
          ),
        );
      }),
    );
  }
}
