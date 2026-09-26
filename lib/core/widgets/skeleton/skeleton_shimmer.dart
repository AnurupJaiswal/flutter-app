import 'package:flutter/material.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ShimmerScope — Inherited widget providing synchronized shimmer animation
/// and colors to all descendant skeleton elements.
/// ─────────────────────────────────────────────────────────────────────────────
class ShimmerScope extends InheritedWidget {
  final Animation<double> animation;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerScope({
    super.key,
    required this.animation,
    required this.baseColor,
    required this.highlightColor,
    required super.child,
  });

  static ShimmerScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShimmerScope>();
  }

  @override
  bool updateShouldNotify(ShimmerScope oldWidget) {
    return animation != oldWidget.animation ||
        baseColor != oldWidget.baseColor ||
        highlightColor != oldWidget.highlightColor;
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// SlidingGradientTransform — Shifts the linear gradient smoothly across bounds.
/// ─────────────────────────────────────────────────────────────────────────────
class SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const SlidingGradientTransform({
    required this.slidePercent,
  });

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

LinearGradient buildShimmerGradient({
  required double slidePercent,
  required Color baseColor,
  required Color highlightColor,
}) {
  return LinearGradient(
    begin: const Alignment(-1.0, -0.3),
    end: const Alignment(1.0, 0.3),
    colors: [
      baseColor,
      highlightColor,
      baseColor,
    ],
    stops: const [
      0.1,
      0.5,
      0.9,
    ],
    tileMode: TileMode.clamp,
    transform: SlidingGradientTransform(slidePercent: slidePercent),
  );
}

/// ─────────────────────────────────────────────────────────────────────────────
/// SkeletonShimmer — Centralized animated shimmer controller.
/// ─────────────────────────────────────────────────────────────────────────────
class SkeletonShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
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
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      return widget.child;
    }

    final base = widget.baseColor ?? CC.shimmerBase;
    final highlight = widget.highlightColor ?? CC.shimmerHighlight;

    return RepaintBoundary(
      child: ShimmerScope(
        animation: _controller,
        baseColor: base,
        highlightColor: highlight,
        child: widget.child,
      ),
    );
  }
}

