import 'package:flutter/material.dart';
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
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? CC.shimmerBase,
        shape: BoxShape.circle,
        border: border,
      ),
    );
  }
}
