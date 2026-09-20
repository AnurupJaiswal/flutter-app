import 'package:flutter/material.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_box.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:lala_ai/core/widgets/skeleton/skeleton_text.dart';
import 'package:lala_ai/utils/extensions.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ScriptGeneratorSkeleton — Realistic script generation placeholder.
/// ─────────────────────────────────────────────────────────────────────────────
class ScriptGeneratorSkeleton extends StatelessWidget {
  const ScriptGeneratorSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Script Title Skeleton
          const SkeletonBox(width: 220, height: 16),
          12.height,
          const Divider(height: 16, thickness: 0.7),

          // 1. Hook (0-3s)
          const SkeletonBox(width: 90, height: 11),
          6.height,
          const SkeletonText(lines: 2, lineHeight: 12, spacing: 6),
          14.height,

          // 2. Body Storyline
          const SkeletonBox(width: 60, height: 11),
          6.height,
          const SkeletonText(lines: 4, lineHeight: 12, spacing: 6),
          14.height,

          // 3. Call to Action (CTA)
          const SkeletonBox(width: 130, height: 11),
          6.height,
          const SkeletonText(lines: 1, lineHeight: 12),
          14.height,

          // 4. Action Buttons Row
          Row(
            children: [
              const Expanded(
                child: SkeletonBox(height: 44, borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              10.width,
              const SkeletonBox(width: 44, height: 44, borderRadius: BorderRadius.all(Radius.circular(10))),
            ],
          ),
        ],
      ),
    );
  }
}
