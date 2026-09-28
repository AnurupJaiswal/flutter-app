import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SkeletonCircle — Primitive circular skeleton placeholder for avatars and icons.
/// ─────────────────────────────────────────────────────────────────────────────
class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BoxBorder? border;

  const SkeletonCircle({
    super.key,
    this.size = 44,
    this.margin,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final scope = ShimmerScope.of(context);
    final base = color ?? scope?.baseColor ?? CC.shimmerBase;
    final highlight = scope?.highlightColor ?? CC.shimmerHighlight;

    if (scope == null) {
      return Container(
        width: size,
        height: size,
        margin: margin,
        decoration: BoxDecoration(
          color: base,
          shape: BoxShape.circle,
          border: border,
        ),
      );
    }

    return AnimatedBuilder(
      animation: scope.animation,
      builder: (context, _) {
        return Container(
          width: size,
          height: size,
          margin: margin,
          decoration: BoxDecoration(
            gradient: buildShimmerGradient(
              slidePercent: scope.animation.value,
              baseColor: base,
              highlightColor: highlight,
            ),
            shape: BoxShape.circle,
            border: border,
          ),
        );
      },
    );
  }
}
