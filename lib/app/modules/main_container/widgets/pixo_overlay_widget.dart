import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/navigation/app_navigation_service.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';


class PixoOverlayWidget extends StatelessWidget {
  const PixoOverlayWidget({super.key});

  void _openChat() {
    Get.toNamed(Routes.CHAT_HOME);
  }

  @override
  Widget build(BuildContext context) {
    // Hide the tab if there are other overlays open (like bottom sheets or dialogs)
    final hasActiveOverlays = (Get.isBottomSheetOpen == true ||
        Get.isDialogOpen == true ||
        (Get.isRegistered<AppNavigationService>() &&
            AppNavigationService.to.isOverlayOpen.value));

    if (hasActiveOverlays) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: GestureDetector(
          onTap: _openChat,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: CC.surface,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(26)),
              boxShadow: [
                BoxShadow(
                  color: CC.primary.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(-2, 0),
                ),
              ],
              border: Border.all(color: CC.stroke, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, color: CC.primary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
