import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/connect_accounts/views/connect_accounts_view.dart';
import 'package:lala_ai/app/modules/connect_accounts/widgets/connect_account_hero_widget.dart';
import 'package:lala_ai/app/modules/home/controllers/home_controller.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

/// Global full-screen "Connect Account" state.
///
/// Displayed by [MainContainerView] when [HomeController.hasActiveConnection]
/// is false (i.e., no YouTube or Instagram channel with ACTIVE status exists).
///
/// Uses the existing [ConnectAccountHeroWidget] for UI consistency and routes
/// to [ConnectAccountsView] for the actual connection flow — no duplicate logic.
class ConnectAccountFullScreen extends StatelessWidget {
  const ConnectAccountFullScreen({super.key});

  /// Navigates to the existing ConnectAccountsView (full management page).
  /// After returning, HomeController.refreshConnectionState() is called to
  /// ensure the global guard reacts immediately if a connection was made.
  static Future<void> _openConnectFlow() async {
    await Get.to(() => const ConnectAccountsView());

    // After returning from ConnectAccountsView, refresh the global connection state
    // so the MainContainerView guard reacts immediately.
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().refreshConnectionState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (_) => Scaffold(
        backgroundColor: CC.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ConnectAccountHeroWidget(
                        onConnectAccountTap: () =>
                            ConnectAccountHeroWidget.showPlatformSelectionSheet(
                          context: context,
                          onSelectPlatform: (platform) => _openConnectFlow(),
                        ),
                        onConnectPlatform: (platform) => _openConnectFlow(),
                        onConnectInstagram: () => _openConnectFlow(),
                        onConnectYouTube: () => _openConnectFlow(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
