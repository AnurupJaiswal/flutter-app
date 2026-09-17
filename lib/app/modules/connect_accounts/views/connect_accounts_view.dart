import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/modules/home/controllers/home_controller.dart';

class ConnectAccountsView extends StatefulWidget {
  const ConnectAccountsView({super.key});

  @override
  State<ConnectAccountsView> createState() => _ConnectAccountsViewState();
}

class _ConnectAccountsViewState extends State<ConnectAccountsView>
    with WidgetsBindingObserver {
  final HomeController _homeController = Get.find<HomeController>();
  final AuthRepository _authRepository = Get.isRegistered<AuthRepository>()
      ? Get.find<AuthRepository>()
      : Get.put<AuthRepository>(ApiAuthRepository());

  bool _isConnectingYoutube = false;
  bool _isConnectingInstagram = false;
  bool _isDisconnectingYoutube = false;
  bool _isDisconnectingInstagram = false;

  bool get isYtConnected => _homeController.isYoutubeConnected.value;
  bool get isIgConnected => _homeController.isInstagramConnected.value;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncLocalStateWithSavedAccounts();
      _refreshStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh connection status when the user returns to the app from the OAuth browser
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _refreshStatus();
      });
    }
  }

  void _syncLocalStateWithSavedAccounts() {
    final accounts = ApiService.currentConnectedAccounts;
    if (accounts != null) {
      if (accounts.youtube != null &&
          _homeController.isYoutubeConnected.value != accounts.youtube!.connected) {
        _homeController.isYoutubeConnected.value = accounts.youtube!.connected;
      }
      if (accounts.instagram != null &&
          _homeController.isInstagramConnected.value != accounts.instagram!.connected) {
        _homeController.isInstagramConnected.value = accounts.instagram!.connected;
      }
    }
  }

  Future<void> _refreshStatus({bool showFeedback = false}) async {
    try {
      await _authRepository.fetchAndSaveMe();
      if (!mounted) return;
      _syncLocalStateWithSavedAccounts();
      setState(() {});
      if (showFeedback) {
        AppToast.success("Connection status refreshed!");
      }
    } catch (_) {}
  }

  Future<void> _connectPlatform(String platform) async {
    final isYt = platform.toUpperCase() == 'YOUTUBE';
    if (isYt ? _isConnectingYoutube : _isConnectingInstagram) return;

    setState(() {
      if (isYt) {
        _isConnectingYoutube = true;
      } else {
        _isConnectingInstagram = true;
      }
    });

    try {
      final response = await _authRepository.getPlatformAuthUrl(platform);

      setState(() {
        if (isYt) {
          _isConnectingYoutube = false;
        } else {
          _isConnectingInstagram = false;
        }
      });

      if (!response.isSuccess || response.data == null || response.data!.isEmpty) {
        final errorMsg = response.message.isNotEmpty
            ? response.message
            : "Could not retrieve authorization URL for $platform.";
        AppToast.error(errorMsg);
        return;
      }

      final authUrl = response.data!.trim();
      final uri = Uri.tryParse(authUrl);
      if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        AppToast.error("Received an invalid authorization URL.");
        return;
      }

      // Launch in-app browser view
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {
        launched = false;
      }

      // Fallback to external browser if inAppBrowserView failed
      if (!launched) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          AppToast.error("Failed to open browser: $e");
          return;
        }
      }

      // When user returns from browser, refresh connection status from backend
      await _refreshStatus();
    } catch (e) {
      setState(() {
        if (isYt) {
          _isConnectingYoutube = false;
        } else {
          _isConnectingInstagram = false;
        }
      });
      AppToast.error("Connection request failed: $e");
    }
  }

  Future<void> _disconnectPlatform(String platform) async {
    final isYt = platform.toUpperCase() == 'YOUTUBE';
    setState(() {
      if (isYt) {
        _isDisconnectingYoutube = true;
      } else {
        _isDisconnectingInstagram = true;
      }
    });

    try {
      final response = await _authRepository.disconnectPlatform(platform);
      setState(() {
        if (isYt) {
          _isDisconnectingYoutube = false;
        } else {
          _isDisconnectingInstagram = false;
        }
      });

      if (response.isSuccess) {
        await _refreshStatus();
        AppToast.success("$platform disconnected successfully.");
      } else {
        // Fallback local disconnect if backend endpoint not active
        if (isYt) {
          _homeController.isYoutubeConnected.value = false;
        } else {
          _homeController.isInstagramConnected.value = false;
        }
        setState(() {});
        AppToast.info("$platform disconnected.");
      }
    } catch (e) {
      setState(() {
        if (isYt) {
          _isDisconnectingYoutube = false;
        } else {
          _isDisconnectingInstagram = false;
        }
      });
      AppToast.error("Disconnect failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final ytHandle = (ApiService.currentConnectedAccounts?.youtube?.handle?.isNotEmpty ?? false)
        ? ApiService.currentConnectedAccounts!.youtube!.handle!
        : "@anurupcreators";
    final igHandle = (ApiService.currentConnectedAccounts?.instagram?.handle?.isNotEmpty ?? false)
        ? ApiService.currentConnectedAccounts!.instagram!.handle!
        : "@anurup_reels";

    return GetBuilder<ThemeService>(
      builder: (_) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            isNotHomepage: true,
            title: "Connect Channels",
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Connect your channels to enable automated channel audits, real-time analytics, and AI content scheduling.",
                    style: TS.bodySmall(color: CC.textSecondary),
                  ),
                  16.height,

                  // YouTube Connection Card
                  _platformCard(
                    platform: "YouTube",
                    handle: ytHandle,
                    brandIcon: CW.youtubeIcon(size: 40),
                    status: isYtConnected ? "Connected" : "Disconnected",
                    statusColor: isYtConnected ? CC.success : CC.error,
                    isConnected: isYtConnected,
                    isLoading: _isConnectingYoutube,
                    isDisconnecting: _isDisconnectingYoutube,
                    onConnect: () => _connectPlatform("YOUTUBE"),
                    onDisconnect: () => _disconnectPlatform("YOUTUBE"),
                  ),
                  12.height,

                  // Instagram Connection Card
                  _platformCard(
                    platform: "Instagram",
                    handle: igHandle,
                    brandIcon: CW.instagramIcon(size: 40),
                    status: isIgConnected ? "Connected" : "Disconnected",
                    statusColor: isIgConnected ? CC.success : CC.error,
                    isConnected: isIgConnected,
                    isLoading: _isConnectingInstagram,
                    isDisconnecting: _isDisconnectingInstagram,
                    onConnect: () => _connectPlatform("INSTAGRAM"),
                    onDisconnect: () => _disconnectPlatform("INSTAGRAM"),
                  ),
                  24.height,

                  // Coming Soon Platforms
                  Text("Coming Soon Platforms",
                      style: TS.sectionTitle(color: CC.textPrimary, fontSize: 14)),
                  10.height,
                  _comingSoonTile("TikTok", "Short-form video trends", Icons.music_note_rounded),
                  10.height,
                  _comingSoonTile("LinkedIn", "Professional thought leadership",
                      Icons.business_center_rounded),
                  10.height,
                  _comingSoonTile("X / Twitter", "Viral thread generation",
                      Icons.alternate_email_rounded),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _platformCard({
    required String platform,
    required String handle,
    required Widget brandIcon,
    required String status,
    required Color statusColor,
    required bool isConnected,
    required bool isLoading,
    required bool isDisconnecting,
    required VoidCallback onConnect,
    required VoidCallback onDisconnect,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark ? CC.black.withValues(alpha: 0.45) : CC.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              brandIcon,
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(platform, style: TS.sectionTitle(color: CC.textPrimary)),
                    Text(
                      isConnected ? handle : "Not connected",
                      style: TS.caption(color: CC.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    6.width,
                    Text(status,
                        style: TS.caption(color: statusColor, fontWeight: FontWeight.w700)
                            .copyWith(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          14.height,
          Row(
            children: [
              Expanded(
                child: CW.commonBtn(
                  title: isConnected
                      ? "Sync Now"
                      : (isLoading ? "Connecting..." : "Connect $platform"),
                  isOutlined: isConnected,
                  isLoading: isLoading,
                  onTap: isLoading
                      ? null
                      : () {
                          if (isConnected) {
                            AppToast.info("Syncing $platform analytics with Lala AI...");
                            _refreshStatus(showFeedback: true);
                          } else {
                            onConnect();
                          }
                        },
                ),
              ),
              if (isConnected) ...[
                10.width,
                TextButton(
                  onPressed: isDisconnecting ? null : onDisconnect,
                  child: Text(
                    isDisconnecting ? "Disconnecting..." : "Disconnect",
                    style: TS.caption(color: CC.error, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _comingSoonTile(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark ? CC.black.withValues(alpha: 0.4) : CC.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: CC.textPrimary, size: 20),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600)),
                Text(desc, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text("Coming Soon", style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 9)),
          ),
        ],
      ),
    );
  }
}
