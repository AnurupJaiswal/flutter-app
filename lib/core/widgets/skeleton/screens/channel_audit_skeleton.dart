import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_box.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_card.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_circle.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:lala_ai/utils/extensions.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ChannelAuditSkeleton — Zero-layout-shift placeholder for Analytics & Channel Audit.
/// ─────────────────────────────────────────────────────────────────────────────
class ChannelAuditSkeleton extends StatelessWidget {
  const ChannelAuditSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Header with Run Audit Button ─────────────────────────────
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 170, height: 14),
                SkeletonBox(width: 85, height: 26, borderRadius: BorderRadius.all(Radius.circular(8))),
              ],
            ),
            8.height,

            // ── 2. Health Score Meter + 4 Pillars Grid ───────────────────────
            SkeletonCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Radial Score Gauge Skeleton
                      const SkeletonCircle(size: 72),
                      16.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SkeletonBox(width: 120, height: 16),
                            8.height,
                            const SkeletonBox(width: double.infinity, height: 11),
                            4.height,
                            const SkeletonBox(width: 150, height: 11),
                          ],
                        ),
                      ),
                    ],
                  ),
                  16.height,
                  const Divider(height: 1, thickness: 0.8),
                  14.height,
                  // 4 Pillars 2x2 Grid
                  Row(
                    children: [
                      Expanded(child: _pillarBoxSkeleton()),
                      10.width,
                      Expanded(child: _pillarBoxSkeleton()),
                    ],
                  ),
                  10.height,
                  Row(
                    children: [
                      Expanded(child: _pillarBoxSkeleton()),
                      10.width,
                      Expanded(child: _pillarBoxSkeleton()),
                    ],
                  ),
                ],
              ),
            ),
            20.height,

            // ── 3. SWOT Matrix Section ──────────────────────────────────────
            const SkeletonBox(width: 130, height: 14),
            8.height,
            Row(
              children: [
                Expanded(child: _swotCardSkeleton()),
                10.width,
                Expanded(child: _swotCardSkeleton()),
              ],
            ),
            10.height,
            Row(
              children: [
                Expanded(child: _swotCardSkeleton()),
                10.width,
                Expanded(child: _swotCardSkeleton()),
              ],
            ),
            20.height,

            // ── 4. Action Recommendations Section ───────────────────────────
            const SkeletonBox(width: 180, height: 14),
            8.height,
            SkeletonCard(
              height: 96,
              child: Row(
                children: [
                  const SkeletonBox(width: 42, height: 42, borderRadius: BorderRadius.all(Radius.circular(10))),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SkeletonBox(width: 160, height: 14),
                        6.height,
                        const SkeletonBox(width: double.infinity, height: 11),
                        4.height,
                        const SkeletonBox(width: 120, height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillarBoxSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 65, height: 10),
              SkeletonBox(width: 30, height: 12),
            ],
          ),
          8.height,
          const SkeletonBox(width: double.infinity, height: 5, borderRadius: BorderRadius.all(Radius.circular(3))),
        ],
      ),
    );
  }

  Widget _swotCardSkeleton() {
    return SkeletonCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonCircle(size: 14),
              6.width,
              const SkeletonBox(width: 70, height: 12),
            ],
          ),
          10.height,
          const SkeletonBox(width: double.infinity, height: 10),
          4.height,
          const SkeletonBox(width: 80, height: 9),
        ],
      ),
    );
  }
}
