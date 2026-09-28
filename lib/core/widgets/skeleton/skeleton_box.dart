import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SkeletonBox — Primitive rectangular/rounded placeholder box.
/// ─────────────────────────────────────────────────────────────────────────────
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BoxBorder? border;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final scope = ShimmerScope.of(context);
    final base = color ?? scope?.baseColor ?? CC.shimmerBase;
    final highlight = scope?.highlightColor ?? CC.shimmerHighlight;
    final radius = borderRadius ?? BorderRadius.circular(8);

    if (scope == null) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: base,
          borderRadius: radius,
          border: border,
        ),
      );
    }

    return AnimatedBuilder(
      animation: scope.animation,
      builder: (context, _) {
        return Container(
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            gradient: buildShimmerGradient(
              slidePercent: scope.animation.value,
              baseColor: base,
              highlightColor: highlight,
            ),
            borderRadius: radius,
            border: border,
          ),
        );
      },
    );
  }
}
