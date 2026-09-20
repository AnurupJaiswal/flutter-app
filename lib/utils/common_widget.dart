import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class CW {
  static PreferredSizeWidget commonAppbar({
    bool isNotHomepage = true,
    Widget? leadingWidget,
    Widget? titleWidget,
    Widget? lastWidget,
    List<Widget>? actions,
    double height = 56,
    String title = "",
    Color? themeColor,
    Color? backgroundColor,
    bool wantBackIcon = true,
    VoidCallback? onBackTap,
  }) {
    final isDark = CC.isDark;
    return PreferredSize(
      preferredSize: Size(double.infinity, height),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        child: SafeArea(
          bottom: false,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: backgroundColor ?? CC.background,
              border: Border(
                bottom: BorderSide(
                  color: CC.stroke.withValues(alpha: isDark ? 0.35 : 0.6),
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? CC.black.withValues(alpha: 0.75)
                      : CC.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: isDark
                      ? CC.black.withValues(alpha: 0.45)
                      : CC.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Leading
                if (leadingWidget != null)
                  leadingWidget
                else if (wantBackIcon && isNotHomepage)
                  Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: onBackTap ?? () {
                        if (Navigator.of(ctx).canPop()) {
                          Navigator.of(ctx).pop();
                        } else {
                          Get.back();
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? CC.whiteText.withValues(alpha: 0.08)
                              : CC.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 18,
                            color: CC.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 8),

                // Title
                Expanded(
                  child: titleWidget ??
                      Text(
                        title,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TS.sectionTitle(
                          color: themeColor ?? CC.textPrimary,
                          fontSize: 16,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                ),

                // Actions
                if (actions != null)
                  ...actions
                else if (lastWidget != null)
                  lastWidget,

                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }


  /// Standardized Card Component for Lala AI Design System
  static Widget commonCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 14,
    VoidCallback? onTap,
  }) {
    final cardChild = Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? CC.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark ? CC.black.withValues(alpha: 0.45) : CC.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: CC.isDark ? CC.black.withValues(alpha: 0.25) : CC.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardChild,
        ),
      );
    }
    return cardChild;
  }

  /// Standardized AI Tip / Insight Card Component
  static Widget aiTipCard({
    required String title,
    required String message,
    IconData icon = Icons.lightbulb_outline_rounded,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CC.tealSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CC.primary.withValues(alpha: 0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: CC.isDark ? CC.black.withValues(alpha: 0.35) : CC.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: CC.textPrimary, size: 20),
          ),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 12)),
                4.height,
                Text(
                  message,
                  style: TS.bodySmall(color: CC.textPrimary).copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Refined Common Button
  static Widget commonBtn({
    required String title,
    required VoidCallback? onTap,
    Color? color,
    Color? textColor,
    Color? borderColor,
    double height = 48,
    double? width,
    bool isLoading = false,
    Widget? leadingImage,
    Widget? lastWidget,
    bool isOutlined = false,
  }) {
    final bg = isOutlined ? CC.surface : (color ?? CC.primary);
    final border = isOutlined ? (borderColor ?? CC.stroke) : Colors.transparent;
    final fg = textColor ?? (isOutlined ? CC.textPrimary : CC.whiteText);

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isLoading ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: isOutlined ? 1 : 0),
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(fg),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leadingImage != null) ...[
                        leadingImage,
                        8.width,
                      ],
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TS.button(color: fg),
                        ),
                      ),
                      if (lastWidget != null) ...[
                        8.width,
                        lastWidget,
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Refined Common Text Form Field
  static Widget commonTextFormField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    String? labelText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
    void Function(String)? onChanged,
    FocusNode? focusNode,
    bool autoFocus = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText,
            style: TS.bodySmall(color: CC.textSecondary, fontWeight: FontWeight.w600),
          ),
          6.height,
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          focusNode: focusNode,
          autofocus: autoFocus,
          onChanged: onChanged,
          style: TS.body(color: CC.textPrimary),
          cursorColor: CC.primary,
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: TS.body(color: CC.grey),
            filled: true,
            fillColor: CC.inputBackground,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: CC.grey)
                : null,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: CC.stroke, width: 0.7),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: CC.borderFocused, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: CC.error, width: 0.7),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: CC.error, width: 1.5),
            ),
            errorStyle: TS.caption(color: CC.errorText),
          ),
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }

  /// Refined Search Input Field
  static Widget commonSearchField({
    TextEditingController? controller,
    String hintText = "Search...",
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      style: TS.bodySmall(color: CC.textPrimary),
      cursorColor: CC.primary,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: TS.bodySmall(color: CC.grey),
        filled: true,
        fillColor: CC.searchBackground,
        prefixIcon: prefixIcon ??
            Icon(Icons.search_rounded, size: 16, color: CC.grey),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: CC.stroke, width: 0.7),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: CC.borderFocused, width: 1.2),
        ),
      ),
    );
  }

  /// Minimal Avatar Icon
  static Widget aiAvatar({
    double size = 28,
    bool isAssistant = true,
    String? userInitial,
  }) {
    if (isAssistant) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: CC.tealSubtle,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: CC.primary.withValues(alpha: 0.3), width: 0.7),
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
          color: CC.primary,
          size: size * 0.54,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CC.stroke, width: 0.7),
      ),
      child: Center(
        child: Text(
          (userInitial != null && userInitial.isNotEmpty) ? userInitial[0].toUpperCase() : "U",
          style: TS.caption(color: CC.textSecondary, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  /// Universal and safe BottomSheet dismissal helper.
  /// Guarantees that only the currently active BottomSheet is dismissed,
  /// without popping or corrupting the underlying screen route stack.
  static void dismissBottomSheet([BuildContext? sheetContext]) {
    if (sheetContext != null && sheetContext.mounted) {
      final modalRoute = ModalRoute.of(sheetContext);
      if (modalRoute != null && modalRoute.isCurrent) {
        Navigator.of(sheetContext).pop();
        return;
      }
      final nav = Navigator.of(sheetContext, rootNavigator: false);
      if (nav.canPop()) {
        nav.pop();
        return;
      }
    }
    // Fallback if no context was provided or if context method failed
    Get.back();
  }

  /// Custom BottomSheet System matching Manage Categories design standard
  static Future<T?> showCustomBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    IconData? titleIcon,
    String? subtitle,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Material(
            color: CC.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: CC.stroke,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header Bar (Surgically aligned to Manage Categories standard)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (titleIcon != null) ...[
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: CC.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(titleIcon, color: CC.textPrimary, size: 18),
                              ),
                              10.width,
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TS.sectionTitle(
                                      color: CC.textPrimary,
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (subtitle != null && subtitle.isNotEmpty) ...[
                                    4.height,
                                    Text(
                                      subtitle,
                                      style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      12.width,
                      GestureDetector(
                        onTap: () => dismissBottomSheet(sheetContext),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: CC.isDark
                                ? CC.whiteText.withValues(alpha: 0.1)
                                : CC.black.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: CC.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  16.height,

                  ...children,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Reusable Logout Confirmation Bottom Sheet
  static Future<T?> showLogoutSheet<T>({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Material(
            color: CC.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: CC.stroke,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Icon
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: CC.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.logout_rounded, color: CC.primary, size: 32),
                  ),
                  20.height,
                  Text(
                    "Log Out?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: CC.textPrimary,
                    ),
                  ),
                  10.height,
                  Text(
                    "Are you sure you want to log out?\nYou'll need to sign in again to access your account.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: CC.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  28.height,
                  Row(
                    children: [
                      Expanded(
                        child: CW.commonBtn(
                          title: "Cancel",
                          isOutlined: true,
                          height: 48,
                          onTap: () => dismissBottomSheet(sheetContext),
                        ),
                      ),
                      12.width,
                      Expanded(
                        child: CW.commonBtn(
                          title: "Log Out",
                          height: 48,
                          color: CC.primary,
                          onTap: () {
                            dismissBottomSheet(sheetContext);
                            onConfirm();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Official Instagram Brand Icon
  static Widget instagramIcon({double size = 26}) {
    return Image.asset(
      'assets/icons/img_instagram.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  /// Official YouTube Brand Icon
  static Widget youtubeIcon({double size = 26}) {
    return Image.asset(
      'assets/icons/img_youtube.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  /// Memory-optimized Network Image loader that downsamples images to exact rendered physical dimensions
  static Widget networkImage({
    required String url,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
    double? devicePixelRatio,
  }) {
    if (url.trim().isEmpty || !url.startsWith("http")) {
      return errorWidget ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: CC.surface,
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
            child: Icon(Icons.broken_image_rounded, size: width * 0.4, color: CC.grey),
          );
    }

    return Builder(
      builder: (context) {
        final dpr = devicePixelRatio ?? (MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0);
        final int targetCacheWidth = (width * dpr).round().clamp(1, 2048);
        final int targetCacheHeight = (height * dpr).round().clamp(1, 2048);

        Widget imageWidget = Image.network(
          url,
          width: width,
          height: height,
          fit: fit,
          cacheWidth: targetCacheWidth,
          cacheHeight: targetCacheHeight,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return child;
            }
            return placeholder ??
                skeletonBox(
                  width: width,
                  height: height,
                  borderRadius: borderRadius ?? BorderRadius.circular(8),
                );
          },
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ??
                Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: CC.surface,
                    borderRadius: borderRadius ?? BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.broken_image_rounded, size: width * 0.4, color: CC.grey),
                );
          },
        );

        if (borderRadius != null) {
          return ClipRRect(
            borderRadius: borderRadius,
            child: imageWidget,
          );
        }
        return imageWidget;
      },
    );
  }

  /// Lightweight Shimmer container using single controller and RepaintBoundary to avoid parent repaints
  static Widget shimmer({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return RepaintBoundary(
      child: _ShimmerWidget(
        duration: duration,
        child: child,
      ),
    );
  }

  /// Generic Skeleton Box placeholder
  static Widget skeletonBox({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: CC.shimmerBase,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }

  /// Standard Skeleton Card matching Lala AI surface style
  static Widget skeletonCard({
    double height = 90,
    double? width,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          skeletonBox(width: 44, height: 44, borderRadius: BorderRadius.circular(10)),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                skeletonBox(width: double.infinity, height: 14, borderRadius: BorderRadius.circular(4)),
                8.height,
                skeletonBox(width: 120, height: 10, borderRadius: BorderRadius.circular(4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton List for instant, non-jank initial screen loading
  static Widget skeletonList({
    int itemCount = 4,
    double itemHeight = 90,
    EdgeInsetsGeometry? padding,
  }) {
    return shimmer(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding ?? const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (_, __) => skeletonCard(height: itemHeight),
      ),
    );
  }
}

/// Lightweight Animated Shimmer Widget
class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _ShimmerWidget({
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
                CC.shimmerBase,
                CC.shimmerHighlight,
                CC.shimmerBase,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Generic Debouncer utility to avoid firing costly computations / network queries on every keystroke
class Debouncer {
  final Duration delay;
  void Function()? _action;
  bool _disposed = false;

  Debouncer({this.delay = const Duration(milliseconds: 350)});

  void run(void Function() action) {
    _action = action;
    Future.delayed(delay, () {
      if (!_disposed && _action != null) {
        _action!();
        _action = null;
      }
    });
  }

  void cancel() {
    _action = null;
  }

  void dispose() {
    _disposed = true;
    _action = null;
  }
}

