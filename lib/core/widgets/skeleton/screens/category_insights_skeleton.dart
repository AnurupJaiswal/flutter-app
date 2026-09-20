import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_box.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_card.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:lala_ai/utils/extensions.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// CategoryInsightsSkeleton — Zero-layout-shift placeholder for Category Insights.
/// ─────────────────────────────────────────────────────────────────────────────
class CategoryInsightsSkeleton extends StatelessWidget {
  const CategoryInsightsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Category Switcher Chips ──────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              separatorBuilder: (_, __) => 8.width,
              itemBuilder: (_, index) => SkeletonBox(
                width: index == 0 ? 80 : 65,
                height: 36,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          16.height,

          // ── 2. Trending Now Chips ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 120, height: 13),
                10.height,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    SkeletonBox(width: 130, height: 30, borderRadius: BorderRadius.all(Radius.circular(15))),
                    SkeletonBox(width: 100, height: 30, borderRadius: BorderRadius.all(Radius.circular(15))),
                    SkeletonBox(width: 140, height: 30, borderRadius: BorderRadius.all(Radius.circular(15))),
                  ],
                ),
              ],
            ),
          ),
          20.height,

          // ── 3. Shared Insights Cards ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 140, height: 13),
                12.height,
                for (int i = 0; i < 3; i++) ...[
                  _sharedInsightCardSkeleton(),
                  if (i < 2) 12.height,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sharedInsightCardSkeleton() {
    return SkeletonCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonBox(width: 80, height: 20, borderRadius: BorderRadius.all(Radius.circular(6))),
              SkeletonBox(width: 40, height: 12),
            ],
          ),
          10.height,
          const SkeletonBox(width: 180, height: 15),
          8.height,
          const SkeletonBox(width: double.infinity, height: 11),
          4.height,
          const SkeletonBox(width: 220, height: 11),
        ],
      ),
    );
  }
}
