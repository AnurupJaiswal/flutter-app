import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

/// Toast type — only the icon and accent color change; base UI stays identical.
enum ToastType { success, error, warning, info }

/// ─────────────────────────────────────────────────────────────────────────────
/// AppToast — Premium top floating toast notification component for Lala AI.
/// ─────────────────────────────────────────────────────────────────────────────
class AppToast {
  AppToast._();

  // ── Public API ──────────────────────────────────────────────────────────────

  static void success(String message) => _show(message, ToastType.success);
  static void error(String message) => _show(message, ToastType.error);
  static void warning(String message) => _show(message, ToastType.warning);
  static void info(String message) => _show(message, ToastType.info);

  // ── Core ────────────────────────────────────────────────────────────────────

  static void _show(String message, ToastType type) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    final config = _ToastConfig._of(type);

    Get.rawSnackbar(
      messageText: _ToastWidget(message: message, config: config),
      backgroundColor: Colors.transparent,
      boxShadows: const [],
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 240),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      isDismissible: true,
      dismissDirection: DismissDirection.up,
    );
  }
}

// ── Internal config for each type ────────────────────────────────────────────

class _ToastConfig {
  final IconData icon;
  final Color color;

  const _ToastConfig({required this.icon, required this.color});

  factory _ToastConfig._of(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          icon: Icons.check_rounded,
          color: CC.success,
        );
      case ToastType.error:
        return _ToastConfig(
          icon: Icons.close_rounded,
          color: CC.error,
        );
      case ToastType.warning:
        return _ToastConfig(
          icon: Icons.priority_high_rounded,
          color: CC.warning,
        );
      case ToastType.info:
        return _ToastConfig(
          icon: Icons.info_outline_rounded,
          color: CC.primary,
        );
    }
  }
}

// ── Toast Widget — sleek pill notification UI ───────────────────────────────

class _ToastWidget extends StatelessWidget {
  final String message;
  final _ToastConfig config;

  const _ToastWidget({required this.message, required this.config});

  @override
  Widget build(BuildContext context) {
    final isDark = CC.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E26) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: config.color.withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular icon badge
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                config.icon,
                size: 15,
                color: config.color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Message text
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TS.bodySmall(
                color: CC.textPrimary,
                fontWeight: FontWeight.w500,
              ).copyWith(
                height: 1.3,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
