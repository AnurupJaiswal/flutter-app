import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/app/data/repositories/dashboard_repository.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/modules/home/controllers/home_controller.dart';
import 'package:lala_ai/core/widgets/skeleton/app_skeleton.dart';

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
  final DashboardRepository _dashboardRepository =
      Get.isRegistered<DashboardRepository>()
          ? Get.find<DashboardRepository>()
          : Get.put<DashboardRepository>(ApiDashboardRepository());

  bool _isLoading = true;
  final Set<String> _connectingPlatforms = {};
  final Set<dynamic> _reconnectingAccountIds = {};
  final Set<dynamic> _disconnectingAccountIds = {};

  List<ChannelConnection> _connections = [];
  Map<String, PlatformEntitlement> _entitlements = {};

  bool get isYtActive =>
      _connections.any((c) => c.platform == 'YOUTUBE' && c.isActive) ||
      _homeController.isYoutubeConnected.value;

  bool get isIgActive =>
      _connections.any((c) => c.platform == 'INSTAGRAM' && c.isActive) ||
      _homeController.isInstagramConnected.value;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _refreshStatus();
      });
    }
  }

  Future<void> _refreshStatus({bool showFeedback = false}) async {
    try {
      // 1. PRIMARY: Query GET /api/v1/creators/me/connections as the sole required endpoint
      final res = await _dashboardRepository.getConnectionsWithEntitlements();
      if (!mounted) return;

      if (res != null) {
        setState(() {
          _connections = res.connections;
          _entitlements = res.entitlements;
          _isLoading = false;
        });

        // 2. Sync HomeController channels in-memory without extra API calls
        if (res.connections.isNotEmpty) {
          _homeController.connectedChannels.assignAll(res.connections);
          final options = res.connections.map((c) => ChannelOption(
            id: c.id,
            platform: c.platform,
            handle: c.platformAccountName.isNotEmpty ? c.platformAccountName : c.platform,
            name: c.platformAccountName.isNotEmpty ? c.platformAccountName : c.platform,
            status: c.status,
          )).toList();
          _homeController.availableChannels.assignAll(options);
        } else {
          _homeController.connectedChannels.clear();
          _homeController.availableChannels.clear();
        }

        // 3. Notify the global guard in MainContainerView reactively.
        // connectedChannels.refresh() triggers Obx listeners that depend on hasActiveConnection.
        _homeController.connectedChannels.refresh();

        if (showFeedback) {
          AppToast.success("Connection status refreshed!");
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (showFeedback) {
          AppToast.error("Unable to refresh connection status. Server error (502).");
        }
      }
    } catch (e) {
      debugPrint("ConnectAccountsView _refreshStatus error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (showFeedback) {
          AppToast.error("Unable to refresh connection status. Please try again.");
        }
      }
    } finally {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _connectPlatform({
    required String platform,
    dynamic accountId,
  }) async {
    final platformKey = platform.toUpperCase();
    if (accountId != null) {
      if (_reconnectingAccountIds.contains(accountId)) return;
      setState(() {
        _reconnectingAccountIds.add(accountId);
      });
    } else {
      if (_connectingPlatforms.contains(platformKey)) return;
      setState(() {
        _connectingPlatforms.add(platformKey);
      });
    }

    try {
      final response = await _authRepository.getPlatformAuthUrl(platform);

      if (mounted) {
        setState(() {
          if (accountId != null) {
            _reconnectingAccountIds.remove(accountId);
          } else {
            _connectingPlatforms.remove(platformKey);
          }
        });
      }

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

      debugPrint("══════════════════════════════════════════════════════════");
      debugPrint("[OAuth Connect] Opening Auth URL for $platform:");
      debugPrint("[OAuth Connect] URL: $authUrl");
      debugPrint("[OAuth Connect] Scheme: ${uri.scheme} | Host: ${uri.host}");
      debugPrint("[OAuth Connect] Query Params: ${uri.queryParameters}");
      debugPrint("══════════════════════════════════════════════════════════");

      bool launched = false;
      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        launched = false;
        debugPrint("[OAuth Connect] Error launching external browser: $e");
      }

      if (!launched) {
        AppToast.error("Could not open web browser for authorization.");
        return;
      }

      // When user returns from browser, refresh connection status from backend
      await _refreshStatus();
    } catch (e) {
      if (mounted) {
        setState(() {
          if (accountId != null) {
            _reconnectingAccountIds.remove(accountId);
          } else {
            _connectingPlatforms.remove(platformKey);
          }
        });
      }
      AppToast.error("Connection request failed: $e");
    }
  }

  Future<void> _disconnectSpecificAccount({
    required dynamic accountId,
    required String platform,
  }) async {
    setState(() {
      _disconnectingAccountIds.add(accountId);
    });

    try {
      if (accountId != null) {
        final response = await ApiService.delete(
          ApiEndpoints.disconnectConnectionAccount(accountId),
        );
        if (response.isSuccess) {
          AppToast.success("$platform channel removed successfully.");
        } else {
          // Fallback to platform disconnect
          await _authRepository.disconnectPlatform(platform);
          AppToast.info("$platform channel removed.");
        }
      } else {
        await _authRepository.disconnectPlatform(platform);
        AppToast.info("$platform channel removed.");
      }

      await _refreshStatus();
    } catch (e) {
      AppToast.error("Action failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _disconnectingAccountIds.remove(accountId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: CC.background,
        appBar: CW.commonAppbar(
          isNotHomepage: true,
          title: "Connect Channels",
        ),
        body: const ConnectedAccountsSkeleton(),
      );
    }

    final ytConnections = _connections.where((c) => c.platform == 'YOUTUBE').toList();
    final igConnections = _connections.where((c) => c.platform == 'INSTAGRAM').toList();

    final ytEntitlement = _entitlements['youtube'];
    final igEntitlement = _entitlements['instagram'];

    final totalActiveConnections = _connections.where((c) => c.isActive).length;

    // Dynamically calculate total allowed limit across all platforms
    int dynamicTotalLimit = 0;
    if (_entitlements.isNotEmpty) {
      for (final ent in _entitlements.values) {
        dynamicTotalLimit += ent.limit;
      }
    } else {
      dynamicTotalLimit = (ytConnections.length + igConnections.length > 0)
          ? (ytConnections.length + igConnections.length)
          : 2;
    }
    if (dynamicTotalLimit < 1) dynamicTotalLimit = 1;

    final bool allSlotsConnected = totalActiveConnections >= dynamicTotalLimit;
    final int availableSlots = (dynamicTotalLimit - totalActiveConnections) > 0
        ? (dynamicTotalLimit - totalActiveConnections)
        : 0;

    return GetBuilder<ThemeService>(
      builder: (_) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            isNotHomepage: true,
            title: "Connect Channels",
          ),
          body: RefreshIndicator(
            onRefresh: () => _refreshStatus(showFeedback: true),
            color: CC.primary,
            backgroundColor: CC.surface,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Connect and manage your social channels to enable automated audits, real-time analytics, and AI content scheduling.",
                          style: TS.bodySmall(color: CC.textSecondary).copyWith(fontSize: 13, height: 1.4),
                        ),
                        14.height,

                        // --- TOP SUMMARY BANNER CARD (DYNAMIC LIMITS & PROGRESS) ---
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: CC.isDark
                                  ? CC.primary.withValues(alpha: 0.1)
                                  : const Color(0xFFF0F7FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: CC.isDark
                                    ? CC.primary.withValues(alpha: 0.25)
                                    : const Color(0xFFD8EAFF),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0084FF).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.groups_rounded, size: 22, color: Color(0xFF0084FF)),
                                      ),
                                    ),
                                    14.width,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "$totalActiveConnections of $dynamicTotalLimit ${dynamicTotalLimit == 1 ? 'channel' : 'channels'} connected",
                                            style: TS.sectionTitle(color: CC.textPrimary, fontSize: 14),
                                          ),
                                          3.height,
                                          Text(
                                            allSlotsConnected
                                                ? "All active channel slots under your plan limit are currently connected."
                                                : "$availableSlots channel slot${availableSlots == 1 ? '' : 's'} available to connect.",
                                            style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                12.height,
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: dynamicTotalLimit > 0
                                        ? (totalActiveConnections / dynamicTotalLimit).clamp(0.0, 1.0)
                                        : 0,
                                    backgroundColor: CC.isDark ? Colors.white12 : const Color(0xFFDCEBFA),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      allSlotsConnected ? const Color(0xFF22C55E) : const Color(0xFF0084FF),
                                    ),
                                    minHeight: 5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          16.height,

                          // --- YOUTUBE SECTION ---
                          _buildPlatformSection(
                            platform: "YouTube",
                            brandIcon: CW.youtubeIcon(size: 32),
                            connections: ytConnections,
                            entitlement: ytEntitlement,
                          ),
                          16.height,

                          // --- INSTAGRAM SECTION ---
                          _buildPlatformSection(
                            platform: "Instagram",
                            brandIcon: CW.instagramIcon(size: 32),
                            connections: igConnections,
                            entitlement: igEntitlement,
                          ),
                          20.height,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    }

  Widget _buildPlatformSection({
    required String platform,
    required Widget brandIcon,
    required List<ChannelConnection> connections,
    required PlatformEntitlement? entitlement,
  }) {
    final isYt = platform.toUpperCase() == 'YOUTUBE';
    final isPlatformConnecting = _connectingPlatforms.contains(platform.toUpperCase());
    final activeCount = connections.where((c) => c.isActive).length;
    
    // Dynamic entitlement limit, remaining, and limit-reached status
    final limit = entitlement?.limit ?? 1;
    final remaining = entitlement?.remaining ?? ((limit - activeCount) > 0 ? (limit - activeCount) : 0);
    final isLimitReached = activeCount >= limit;
    final isExceeded = (entitlement?.entitlementExceeded ?? 0) > 0 || activeCount > limit;

    final btnColor = isYt ? const Color(0xFFFF3B30) : const Color(0xFFA855F7);
    final btnBg = isYt ? const Color(0xFFFFF5F5) : const Color(0xFFFAF5FF);

    return Container(
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CC.isDark
              ? CC.stroke.withValues(alpha: 0.35)
              : (isYt ? const Color(0xFFFFEAEA) : const Color(0xFFF6E8FF)),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark ? CC.black.withValues(alpha: 0.45) : CC.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              brandIcon,
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platform,
                      style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16),
                    ),
                    2.height,
                    Text(
                      "$activeCount of $limit ${isYt ? (limit == 1 ? 'channel' : 'channels') : (limit == 1 ? 'account' : 'accounts')} active • ${isLimitReached ? 'Plan limit reached' : '$remaining slot${remaining == 1 ? '' : 's'} available'}",
                      style: TS.caption(
                        color: isLimitReached ? const Color(0xFFF59E0B) : CC.textSecondary,
                      ).copyWith(
                        fontSize: 11,
                        fontWeight: isLimitReached ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Action Button / Limit Reached Badge
              GestureDetector(
                onTap: isPlatformConnecting
                    ? null
                    : () {
                        if (isLimitReached) {
                          _showLimitReachedBottomSheet(
                            context: context,
                            platform: platform,
                            limit: limit,
                            activeCount: activeCount,
                          );
                        } else {
                          _connectPlatform(platform: platform);
                        }
                      },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLimitReached
                        ? (CC.isDark ? Colors.white10 : const Color(0xFFF3F4F6))
                        : (CC.isDark ? btnColor.withValues(alpha: 0.12) : btnBg),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLimitReached
                          ? (CC.isDark ? Colors.white24 : const Color(0xFFD1D5DB))
                          : btnColor,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPlatformConnecting) ...[
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: btnColor,
                          ),
                        ),
                        6.width,
                        Text(
                          "Connecting...",
                          style: TextStyle(
                            color: btnColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ] else if (isLimitReached) ...[
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 13,
                          color: CC.isDark ? Colors.white70 : const Color(0xFF6B7280),
                        ),
                        4.width,
                        Text(
                          "Limit Reached",
                          style: TextStyle(
                            color: CC.isDark ? Colors.white70 : const Color(0xFF4B5563),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        Icon(Icons.add_rounded, size: 15, color: btnColor),
                        4.width,
                        Text(
                          connections.isEmpty
                              ? "Connect"
                              : (isYt ? "Add Channel" : "Add Account"),
                          style: TextStyle(
                            color: btnColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Plan Limit Exceeded Alert Banner
          if (isExceeded) ...[
            12.height,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 18),
                  8.width,
                  Expanded(
                    child: Text(
                      "Plan limit exceeded ($activeCount active / $limit allowed). Please disconnect inactive channels.",
                      style: const TextStyle(
                        color: Color(0xFF991B1B),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // If connections are present, list them cleanly
          if (connections.isNotEmpty) ...[
            14.height,
            ...connections.map((conn) {
              final isDisconnecting = _disconnectingAccountIds.contains(conn.id);
              final isReconnecting = _reconnectingAccountIds.contains(conn.id);
              final handleDisplay = conn.platformAccountName.isNotEmpty
                  ? (conn.platformAccountName.startsWith('@')
                      ? conn.platformAccountName
                      : "@${conn.platformAccountName}")
                  : platform;

              final isActive = conn.isActive;
              final isReauth = conn.isReauthRequired;
              final isDisconnected = conn.isDisconnected;

              final initialLetter = (handleDisplay.isNotEmpty
                      ? (handleDisplay.startsWith('@') ? handleDisplay.substring(1) : handleDisplay)
                      : "A")
                  .substring(0, 1)
                  .toUpperCase();

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CC.isDark ? CC.darkBg2 : const Color(0xFFFAFBFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDisconnected
                        ? (CC.isDark ? const Color(0xFFEF4444).withValues(alpha: 0.3) : const Color(0xFFFFD1D1))
                        : (isReauth
                            ? (CC.isDark ? const Color(0xFFF59E0B).withValues(alpha: 0.3) : const Color(0xFFFDE68A))
                            : (CC.isDark ? CC.stroke.withValues(alpha: 0.35) : const Color(0xFFEFF2F6))),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar with small green online indicator dot when active
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: isDisconnected
                                  ? (CC.isDark ? const Color(0xFFEF4444).withValues(alpha: 0.15) : const Color(0xFFFFE5E5))
                                  : (isYt
                                      ? (CC.isDark ? const Color(0xFF0084FF).withValues(alpha: 0.15) : const Color(0xFFE8F1FF))
                                      : (CC.isDark ? const Color(0xFFA855F7).withValues(alpha: 0.15) : const Color(0xFFFDF2F8))),
                              child: Text(
                                initialLetter,
                                style: TextStyle(
                                  color: isDisconnected
                                      ? (CC.isDark ? const Color(0xFFFF6B6B) : const Color(0xFFEF4444))
                                      : (isYt ? const Color(0xFF0084FF) : const Color(0xFFA855F7)),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isActive)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: CC.isDark ? CC.darkBg2 : Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        12.width,
                        // Account Info Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                handleDisplay,
                                style: TS.bodySmall(
                                  color: CC.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ).copyWith(fontSize: 14),
                              ),
                              2.height,
                              if (isDisconnected) ...[
                                const Text(
                                  "Channel disconnected",
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ] else if (isReauth) ...[
                                const Text(
                                  "Session expired • Reconnect required",
                                  style: TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  conn.platformAccountName.isNotEmpty ? conn.platformAccountName : platform,
                                  style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11),
                                ),
                                1.height,
                                Text(
                                  conn.lastSyncedAt != null && conn.lastSyncedAt!.isNotEmpty
                                      ? "Last synced ${conn.lastSyncedAt!.formatSyncDate}"
                                      : "Connected channel",
                                  style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Pill Badge (Active / Disconnected / Reauth)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDisconnected
                                ? (CC.isDark ? const Color(0xFFEF4444).withValues(alpha: 0.15) : const Color(0xFFFFECEC))
                                : isReauth
                                    ? (CC.isDark ? const Color(0xFFF59E0B).withValues(alpha: 0.15) : const Color(0xFFFEF3C7))
                                    : (CC.isDark ? const Color(0xFF22C55E).withValues(alpha: 0.15) : const Color(0xFFDCFCE7)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDisconnected
                                  ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                                  : isReauth
                                      ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                                      : const Color(0xFF22C55E).withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              5.width,
                              Text(
                                isDisconnected
                                    ? "Disconnected"
                                    : isReauth
                                        ? "Reauth"
                                        : "Active",
                                style: TextStyle(
                                  color: isDisconnected
                                      ? (CC.isDark ? const Color(0xFFFF6B6B) : const Color(0xFFDC2626))
                                      : isReauth
                                          ? (CC.isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))
                                          : (CC.isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D)),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Action button for active accounts: Outlined Disconnect button
                    if (isActive) ...[
                      10.height,
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: const Color(0xFFEF4444).withValues(alpha: CC.isDark ? 0.3 : 0.35),
                              width: 1,
                            ),
                            backgroundColor: CC.isDark
                                ? const Color(0xFFEF4444).withValues(alpha: 0.08)
                                : const Color(0xFFFFF5F5),
                            foregroundColor: CC.isDark ? const Color(0xFFFF6B6B) : const Color(0xFFDC2626),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          icon: isDisconnecting
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: CC.isDark ? const Color(0xFFFF6B6B) : const Color(0xFFDC2626),
                                  ),
                                )
                              : Icon(
                                  Icons.link_off_rounded,
                                  size: 15,
                                  color: CC.isDark ? const Color(0xFFFF6B6B) : const Color(0xFFDC2626),
                                ),
                          label: Text(
                            isDisconnecting ? "Disconnecting..." : "Disconnect",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: CC.isDark ? const Color(0xFFFF6B6B) : const Color(0xFFDC2626),
                            ),
                          ),
                          onPressed: isDisconnecting
                              ? null
                              : () => _showDisconnectConfirmationBottomSheet(context, conn, platform),
                        ),
                      ),
                    ],

                    // Actions row exclusively for disconnected / reauth accounts: only Reconnect
                    if (isDisconnected || isReauth) ...[
                      12.height,
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4B4B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          icon: isReconnecting
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                          label: Text(
                            isReconnecting
                                ? (isReauth ? "Re-authenticating..." : "Reconnecting...")
                                : "Reconnect",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          onPressed: isReconnecting
                              ? null
                              : () => _connectPlatform(platform: platform, accountId: conn.id),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _showDisconnectConfirmationBottomSheet(
    BuildContext context,
    ChannelConnection conn,
    String platform,
  ) {
    final handleDisplay = conn.platformAccountName.isNotEmpty
        ? (conn.platformAccountName.startsWith('@')
            ? conn.platformAccountName
            : "@${conn.platformAccountName}")
        : platform;

    showModalBottomSheet(
      context: context,
      backgroundColor: CC.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CC.stroke,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                20.height,
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFECEC),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.link_off_rounded,
                      color: Color(0xFFDC2626),
                      size: 28,
                    ),
                  ),
                ),
                16.height,
                Text(
                  "Disconnect $handleDisplay?",
                  style: TS.sectionTitle(color: CC.textPrimary, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                8.height,
                Text(
                  "Disconnecting this channel will stop automated audits and remove its performance metrics from your dashboard. You can reconnect it anytime.",
                  textAlign: TextAlign.center,
                  style: TS.bodySmall(color: CC.textSecondary).copyWith(height: 1.4),
                ),
                24.height,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: CC.stroke),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          "Cancel",
                          style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _disconnectSpecificAccount(accountId: conn.id, platform: platform);
                        },
                        child: const Text(
                          "Disconnect",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLimitReachedBottomSheet({
    required BuildContext context,
    required String platform,
    required int limit,
    required int activeCount,
  }) {
    final isYt = platform.toUpperCase() == 'YOUTUBE';
    showModalBottomSheet(
      context: context,
      backgroundColor: CC.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CC.stroke,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                20.height,
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFFD97706),
                      size: 28,
                    ),
                  ),
                ),
                16.height,
                Text(
                  "Channel Limit Reached",
                  style: TS.sectionTitle(color: CC.textPrimary, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                8.height,
                Text(
                  "Your current plan allows up to $limit active $platform ${isYt ? (limit == 1 ? 'channel' : 'channels') : (limit == 1 ? 'account' : 'accounts')} (currently using $activeCount of $limit slots).\n\nTo connect a different account, please disconnect your current active channel first.",
                  textAlign: TextAlign.center,
                  style: TS.bodySmall(color: CC.textSecondary).copyWith(height: 1.4),
                ),
                 24.height,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CC.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      "Got It",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

