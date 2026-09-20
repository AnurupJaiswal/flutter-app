import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_box.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_card.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_circle.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:lala_ai/utils/extensions.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ConnectedAccountsSkeleton — Zero-layout-shift placeholder for Connect Channels screen.
/// ─────────────────────────────────────────────────────────────────────────────
class ConnectedAccountsSkeleton extends StatelessWidget {
  const ConnectedAccountsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Hero Quota Card ──────────────────────────────────────────
            SkeletonCard(
              height: 140,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SkeletonBox(width: 130, height: 14),
                        10.height,
                        const SkeletonBox(width: 180, height: 26, borderRadius: BorderRadius.all(Radius.circular(6))),
                        8.height,
                        const SkeletonBox(width: 220, height: 11),
                      ],
                    ),
                  ),
                  const SkeletonCircle(size: 64),
                ],
              ),
            ),
            20.height,

            // ── 2. Section Title ───────────────────────────────────────────
            const SkeletonBox(width: 160, height: 14),
            12.height,

            // ── 3. YouTube Channel Card Skeleton ────────────────────────────
            _buildChannelCardSkeleton(isYouTube: true),
            14.height,

            // ── 4. Instagram Account Card Skeleton ──────────────────────────
            _buildChannelCardSkeleton(isYouTube: false),
            20.height,

            // ── 5. Add Channels Section ────────────────────────────────────
            const SkeletonBox(width: 140, height: 14),
            12.height,
            SkeletonCard(
              height: 80,
              child: Row(
                children: [
                  const SkeletonCircle(size: 40),
                  14.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SkeletonBox(width: 120, height: 13),
                        6.height,
                        const SkeletonBox(width: 180, height: 10),
                      ],
                    ),
                  ),
                  const SkeletonBox(width: 80, height: 32, borderRadius: BorderRadius.all(Radius.circular(8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelCardSkeleton({required bool isYouTube}) {
    return SkeletonCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonCircle(size: 46),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: 140, height: 14),
                    6.height,
                    const SkeletonBox(width: 90, height: 10),
                  ],
                ),
              ),
              const SkeletonBox(width: 60, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
            ],
          ),
          14.height,
          const Divider(height: 1, thickness: 0.8),
          12.height,
          // 3 Metric Pills
          Row(
            children: [
              Expanded(child: _metricBox()),
              8.width,
              Expanded(child: _metricBox()),
              8.width,
              Expanded(child: _metricBox()),
            ],
          ),
          14.height,
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SkeletonBox(width: 100, height: 34, borderRadius: BorderRadius.all(Radius.circular(8))),
              SizedBox(width: 10),
              SkeletonBox(width: 90, height: 34, borderRadius: BorderRadius.all(Radius.circular(8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricBox() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const SkeletonBox(width: 40, height: 9),
          4.height,
          const SkeletonBox(width: 55, height: 12),
        ],
      ),
    );
  }
}
