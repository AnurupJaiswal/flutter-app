import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_box.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_card.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_circle.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:lala_ai/utils/extensions.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ProfileSkeleton — Zero-layout-shift placeholder for Creator Profile screen.
/// ─────────────────────────────────────────────────────────────────────────────
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // ── 1. Avatar + Name + Bio Header ──────────────────────────────
            const SkeletonCircle(size: 76),
            14.height,
            const SkeletonBox(width: 150, height: 18),
            6.height,
            const SkeletonBox(width: 180, height: 12),
            10.height,
            const SkeletonBox(width: 90, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
            20.height,

            // ── 2. 4-Card Quick Metrics ─────────────────────────────────────
            Row(
              children: [
                Expanded(child: _metricPillSkeleton()),
                8.width,
                Expanded(child: _metricPillSkeleton()),
              ],
            ),
            8.height,
            Row(
              children: [
                Expanded(child: _metricPillSkeleton()),
                8.width,
                Expanded(child: _metricPillSkeleton()),
              ],
            ),
            22.height,

            // ── 3. Connected Accounts Card ──────────────────────────────────
            SkeletonCard(
              height: 110,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SkeletonCircle(size: 42),
                  14.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SkeletonBox(width: 140, height: 14),
                        6.height,
                        const SkeletonBox(width: 90, height: 11),
                      ],
                    ),
                  ),
                  const SkeletonBox(width: 70, height: 28, borderRadius: BorderRadius.all(Radius.circular(8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricPillSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const SkeletonBox(width: 45, height: 18),
          6.height,
          const SkeletonBox(width: 70, height: 10),
        ],
      ),
    );
  }
}
