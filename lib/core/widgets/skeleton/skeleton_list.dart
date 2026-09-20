import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_card.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_shimmer.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SkeletonList — Vertical list skeleton builder for standard cards.
/// ─────────────────────────────────────────────────────────────────────────────
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int)? itemBuilder;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const SkeletonList({
    super.key,
    this.itemCount = 4,
    this.itemBuilder,
    this.padding,
    this.spacing = 12,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding ?? EdgeInsets.zero,
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: spacing),
        itemBuilder: itemBuilder ?? (_, __) => const SkeletonCard(height: 86),
      ),
    );
  }
}
