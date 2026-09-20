import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_box.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_card.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_circle.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_image.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:lala_ai/utils/extensions.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// DashboardSkeleton — Zero-layout-shift placeholder for Home/Dashboard screen.
/// ─────────────────────────────────────────────────────────────────────────────
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Header Creator Greeting & Channel Selector ──────────────
            const SkeletonBox(width: 170, height: 24),
            8.height,
            const SkeletonBox(width: 140, height: 28, borderRadius: BorderRadius.all(Radius.circular(20))),
            24.height,

            // ── 2. Channel Health Score Card Skeleton ──────────────────────
            SkeletonCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SkeletonCircle(size: 72),
                      16.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SkeletonBox(width: 140, height: 16),
                            6.height,
                            const SkeletonBox(width: double.infinity, height: 11),
                            4.height,
                            const SkeletonBox(width: 160, height: 11),
                          ],
                        ),
                      ),
                    ],
                  ),
                  16.height,
                  const Divider(height: 1, thickness: 0.8),
                  14.height,
                  // 4 Sub-Scores Grid
                  Row(
                    children: [
                      Expanded(child: _subScoreBox()),
                      10.width,
                      Expanded(child: _subScoreBox()),
                    ],
                  ),
                  10.height,
                  Row(
                    children: [
                      Expanded(child: _subScoreBox()),
                      10.width,
                      Expanded(child: _subScoreBox()),
                    ],
                  ),
                ],
              ),
            ),
            24.height,

            // ── 3. SWOT Audit Section Skeleton ─────────────────────────────
            const SkeletonBox(width: 150, height: 14),
            12.height,
            Row(
              children: [
                for (int i = 0; i < 4; i++) ...[
                  Expanded(
                    child: SkeletonBox(
                      height: 32,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  if (i < 3) 6.width,
                ],
              ],
            ),
            12.height,
            SkeletonCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      SkeletonCircle(size: 16),
                      SizedBox(width: 8),
                      SkeletonBox(width: 100, height: 14),
                    ],
                  ),
                  12.height,
                  const SkeletonBox(width: double.infinity, height: 12),
                  6.height,
                  const SkeletonBox(width: 220, height: 12),
                ],
              ),
            ),
            24.height,

            // ── 4. Actionable To-Dos Section Skeleton ────────────────────────
            const SkeletonBox(width: 160, height: 14),
            12.height,
            SkeletonCard(
              height: 76,
              child: Row(
                children: [
                  const SkeletonBox(width: 36, height: 36, borderRadius: BorderRadius.all(Radius.circular(10))),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SkeletonBox(width: 140, height: 13),
                        6.height,
                        const SkeletonBox(width: 180, height: 10),
                      ],
                    ),
                  ),
                  const SkeletonBox(width: 24, height: 24, borderRadius: BorderRadius.all(Radius.circular(6))),
                ],
              ),
            ),
            10.height,
            SkeletonCard(
              height: 76,
              child: Row(
                children: [
                  const SkeletonBox(width: 36, height: 36, borderRadius: BorderRadius.all(Radius.circular(10))),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SkeletonBox(width: 160, height: 13),
                        6.height,
                        const SkeletonBox(width: 140, height: 10),
                      ],
                    ),
                  ),
                  const SkeletonBox(width: 24, height: 24, borderRadius: BorderRadius.all(Radius.circular(6))),
                ],
              ),
            ),
            24.height,

            // ── 5. Recent Content Section Skeleton ─────────────────────────
            const SkeletonBox(width: 130, height: 14),
            12.height,
            SkeletonCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 90,
                    child: SkeletonImage(aspectRatio: 16 / 9),
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SkeletonBox(width: double.infinity, height: 12),
                        6.height,
                        const SkeletonBox(width: 110, height: 10),
                        8.height,
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SkeletonBox(width: 50, height: 10),
                            SkeletonBox(width: 40, height: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            32.height,
          ],
        ),
      ),
    );
  }

  Widget _subScoreBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 60, height: 10),
              SkeletonBox(width: 25, height: 11),
            ],
          ),
          6.height,
          const SkeletonBox(width: double.infinity, height: 4, borderRadius: BorderRadius.all(Radius.circular(2))),
        ],
      ),
    );
  }
}
