import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_box.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_card.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:lala_ai/utils/extensions.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TrendSkeleton — Zero-layout-shift placeholder for Trend Discovery screen.
/// ─────────────────────────────────────────────────────────────────────────────
class TrendSkeleton extends StatelessWidget {
  final int itemCount;

  const TrendSkeleton({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < itemCount; i++) ...[
            _trendCardSkeleton(rank: i + 1),
            if (i < itemCount - 1) 12.height,
          ],
        ],
      ),
    );
  }

  Widget _trendCardSkeleton({required int rank}) {
    return SkeletonCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rank Badge
              const SkeletonBox(width: 28, height: 28, borderRadius: BorderRadius.all(Radius.circular(8))),
              12.width,
              // Title + Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: double.infinity, height: 15),
                    6.height,
                    const SkeletonBox(width: 140, height: 10),
                  ],
                ),
              ),
              12.width,
              // Velocity Badge
              const SkeletonBox(width: 55, height: 22, borderRadius: BorderRadius.all(Radius.circular(11))),
            ],
          ),
          14.height,
          // Tags & Mini Graph Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SkeletonBox(width: 60, height: 20, borderRadius: BorderRadius.all(Radius.circular(6))),
                  6.width,
                  const SkeletonBox(width: 70, height: 20, borderRadius: BorderRadius.all(Radius.circular(6))),
                ],
              ),
              const SkeletonBox(width: 70, height: 18, borderRadius: BorderRadius.all(Radius.circular(4))),
            ],
          ),
        ],
      ),
    );
  }
}
