import 'package:flutter/material.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SkeletonShimmer — High-performance, centralized animated gradient shader.
///
/// Features:
/// - Isolated via [RepaintBoundary] to prevent parent layer repaints.
/// - Respects accessibility settings: disables shimmer if [MediaQuery.disableAnimations] is true.
/// - Dynamic Light/Dark mode colors driven by [CC.shimmerBase] and [CC.shimmerHighlight].
/// ─────────────────────────────────────────────────────────────────────────────
class SkeletonShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1300),
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accessibility: If user has reduced motion enabled, display static skeleton
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      return widget.child;
    }

    final base = widget.baseColor ?? CC.shimmerBase;
    final highlight = widget.highlightColor ?? CC.shimmerHighlight;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: const Alignment(-1.0, -0.3),
                end: const Alignment(1.0, 0.3),
                stops: [
                  (_controller.value - 0.3).clamp(0.0, 1.0),
                  _controller.value.clamp(0.0, 1.0),
                  (_controller.value + 0.3).clamp(0.0, 1.0),
                ],
                colors: [
                  base,
                  highlight,
                  base,
                ],
              ).createShader(bounds);
            },
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
