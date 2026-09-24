import 'package:flutter/material.dart';
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
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? CC.shimmerBase,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: border,
      ),
    );
  }
}
