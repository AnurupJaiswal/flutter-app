import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_box.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_card.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:lala_ai/utils/extensions.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// CalendarSkeleton — Zero-layout-shift placeholder for Content Calendar view.
/// ─────────────────────────────────────────────────────────────────────────────
class CalendarSkeleton extends StatelessWidget {
  final int postCount;

  const CalendarSkeleton({
    super.key,
    this.postCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const SkeletonBox(width: 140, height: 14),
          12.height,

          // Scheduled Post Cards List
          for (int i = 0; i < postCount; i++) ...[
            _calendarPostCardSkeleton(),
            if (i < postCount - 1) 10.height,
          ],
        ],
      ),
    );
  }

  Widget _calendarPostCardSkeleton() {
    return SkeletonCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Thumbnail / Media Placeholder
          const SkeletonBox(width: 68, height: 68, borderRadius: BorderRadius.all(Radius.circular(10))),
          12.width,
          // Post Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 55, height: 18, borderRadius: BorderRadius.all(Radius.circular(4))),
                    SkeletonBox(width: 60, height: 11),
                  ],
                ),
                8.height,
                const SkeletonBox(width: double.infinity, height: 13),
                6.height,
                const SkeletonBox(width: 130, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
