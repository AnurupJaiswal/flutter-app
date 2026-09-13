import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class ConnectAccountsView extends StatefulWidget {
  const ConnectAccountsView({super.key});

  @override
  State<ConnectAccountsView> createState() => _ConnectAccountsViewState();
}

class _ConnectAccountsViewState extends State<ConnectAccountsView> {
  bool isYtConnected = true;
  bool isIgConnected = true;

  @override
  Widget build(BuildContext context) {
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
                    handle: "@alexcreators",
                    brandIcon: CW.youtubeIcon(size: 40),
                    status: isYtConnected ? "Connected" : "Disconnected",
                    statusColor: isYtConnected ? CC.success : CC.error,
                    isConnected: isYtConnected,
                    onToggle: () => setState(() => isYtConnected = !isYtConnected),
                  ),
                  12.height,

                  // Instagram Connection Card
                  _platformCard(
                    platform: "Instagram",
                    handle: "@alex_reels",
                    brandIcon: CW.instagramIcon(size: 40),
                    status: isIgConnected ? "Connected" : "Re-auth Required",
                    statusColor: isIgConnected ? CC.success : CC.insightful,
                    isConnected: isIgConnected,
                    onToggle: () => setState(() => isIgConnected = !isIgConnected),
                  ),
                  24.height,

                  // Coming Soon Platforms
                  Text("Coming Soon Platforms", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 14)),
                  10.height,
                  _comingSoonTile("TikTok", "Short-form video trends", Icons.music_note_rounded),
                  10.height,
                  _comingSoonTile("LinkedIn", "Professional thought leadership", Icons.business_center_rounded),
                  10.height,
                  _comingSoonTile("X / Twitter", "Viral thread generation", Icons.alternate_email_rounded),
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
    required VoidCallback onToggle,
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
            color: CC.isDark ? Colors.black.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.08),
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
                    Text(isConnected ? handle : "Not connected", style: TS.caption(color: CC.textSecondary)),
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
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    6.width,
                    Text(status, style: TS.caption(color: statusColor, fontWeight: FontWeight.w700).copyWith(fontSize: 10)),
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
                  title: isConnected ? "Sync Now" : "Connect Account",
                  isOutlined: true,
                  onTap: () {
                    AppToast.info("Syncing channel analytics with Lala AI...");
                  },
                ),
              ),
              if (isConnected) ...[
                10.width,
                TextButton(
                  onPressed: onToggle,
                  child: Text("Disconnect", style: TS.caption(color: CC.error, fontWeight: FontWeight.w600)),
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
            color: CC.isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.08),
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
