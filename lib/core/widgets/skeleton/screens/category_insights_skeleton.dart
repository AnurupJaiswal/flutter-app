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
          for (int i = 0; i < 6; i++) ...[
            _categoryCardSkeleton(),
            if (i < 5) 10.height,
          ],
        ],
      ),
    );
  }

  Widget _categoryCardSkeleton() {
    return SkeletonCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Row(
        children: [
          const SkeletonBox(
            width: 44,
            height: 44,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 160, height: 15),
                8.height,
                const SkeletonBox(width: double.infinity, height: 11),
              ],
            ),
          ),
          12.width,
          const SkeletonBox(
            width: 24,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ],
      ),
    );
  }
}

