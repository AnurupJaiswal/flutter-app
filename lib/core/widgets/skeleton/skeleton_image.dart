import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_box.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SkeletonImage — Aspect-ratio preserving placeholder for network and cached images.
/// ─────────────────────────────────────────────────────────────────────────────
class SkeletonImage extends StatelessWidget {
  final double? width;
  final double? height;
  final double aspectRatio;
  final BorderRadiusGeometry? borderRadius;

  const SkeletonImage({
    super.key,
    this.width,
    this.height,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
  });

  const SkeletonImage.square({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  }) : aspectRatio = 1.0;

  const SkeletonImage.vertical({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  }) : aspectRatio = 9 / 16;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);

    if (height != null && width != null) {
      return SkeletonBox(
        width: width,
        height: height,
        borderRadius: radius,
      );
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: SkeletonBox(
        width: width ?? double.infinity,
        height: height,
        borderRadius: radius,
      ),
    );
  }
}
