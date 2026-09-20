import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_box.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_card.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_image.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:lala_ai/utils/extensions.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ContentListSkeleton — Zero-layout-shift placeholder for Top/Recent Content cards.
/// ─────────────────────────────────────────────────────────────────────────────
class ContentListSkeleton extends StatelessWidget {
  final int itemCount;

  const ContentListSkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < itemCount; i++) ...[
            _contentCardSkeleton(),
            if (i < itemCount - 1) 12.height,
          ],
        ],
      ),
    );
  }

  Widget _contentCardSkeleton() {
    return SkeletonCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 16:9 Thumbnail Skeleton
          const SizedBox(
            width: 100,
            child: SkeletonImage(aspectRatio: 16 / 9),
          ),
          12.width,
          // Content Metadata Skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: double.infinity, height: 13),
                6.height,
                const SkeletonBox(width: 140, height: 10),
                10.height,
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 60, height: 10),
                    SkeletonBox(width: 45, height: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
