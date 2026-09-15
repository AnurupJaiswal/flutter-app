import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/analytics/views/analytics_view.dart';
import 'package:lala_ai/app/modules/connect_accounts/views/connect_accounts_view.dart';
import 'package:lala_ai/app/modules/profile/views/edit_profile_view.dart';
import 'package:lala_ai/app/modules/settings/views/settings_view.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (themeService) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            isNotHomepage: true,
            wantBackIcon: true,
            title: "Me & Profile",
            actions: [
              IconButton(
                icon: Icon(Icons.logout_rounded, color: CC.primary, size: 22),
                tooltip: "Log Out",
                onPressed: () => CW.showLogoutSheet(
                  context: context,
                  onConfirm: () {
                    // Call ApiService.logout to clear local storage and navigate to Auth
                    ApiService.logout();
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── User Profile Header Card ───────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CC.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CC.isDark
                              ? CC.black.withValues(alpha: 0.45)
                              : CC.black.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: CC.tealSubtle,
                            shape: BoxShape.circle,
                            border: Border.all(color: CC.primary.withValues(alpha: 0.25), width: 2),
                          ),
                          child: Center(
                            child: Text("A", style: TS.displayLarge(color: CC.primary, fontSize: 24)),
                          ),
                        ),
                        14.width,
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("Alex Rivers", style: TS.sectionTitle(color: CC.textPrimary)),
                                  6.width,
                                  Icon(Icons.verified_rounded, color: CC.primary, size: 15),
                                ],
                              ),
                              4.height,
                              Text("+1 (555) 019-2834 • Verified", style: TS.caption(color: CC.textSecondary)),
                              6.height,
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: CC.tealSubtle,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text("Pro Creator", style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 10)),
                                  ),
                                  8.width,
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: CC.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text("🔥 14 Day Streak", style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w600).copyWith(fontSize: 10)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Edit icon → navigates to full page
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EditProfileView()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: CC.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.edit_rounded, color: CC.textPrimary, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.height,

                  // ── Journey Statistics ─────────────────────────────────────
                  Text("Journey Statistics", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 14)),
                  10.height,
                  Row(
                    children: [
                      Expanded(child: _journeyStat("42", "Scripts Made", Icons.movie_creation_outlined)),
                      10.width,
                      Expanded(child: _journeyStat("18 hrs", "Time Saved", Icons.timer_outlined)),
                      10.width,
                      Expanded(child: _journeyStat("+24%", "Channel Growth", Icons.show_chart_rounded)),
                    ],
                  ),
                  16.height,

                  // ── Creator Tools & Account ────────────────────────────────
                  Text("Creator Tools & Account", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 14)),
                  10.height,
                  _actionTile("Channel Analytics & Audit", "Deep-dive performance, reach & engagement analytics", Icons.bar_chart_rounded, () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsView()));
                  }),
                  10.height,
                  _actionTile("Connect Channels", "Manage YouTube & Instagram accounts", Icons.link_rounded, () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ConnectAccountsView()));
                  }),
                  10.height,
                  _actionTile("App Settings & Preferences", "Theme, notifications, privacy & more", Icons.tune_rounded, () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        settings: const RouteSettings(name: 'SettingsView'),
                        builder: (_) => const SettingsView(),
                      ),
                    );
                  }),
                  24.height,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _journeyStat(String val, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: CC.textPrimary, size: 16),
          ),
          8.height,
          Text(val, style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16)),
          2.height,
          Text(label, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _actionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: CC.textPrimary, size: 20),
          ),
          title: Text(title, style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
          trailing: Icon(Icons.chevron_right_rounded, color: CC.textSecondary, size: 18),
          onTap: onTap,
        ),
      ),
    );
  }
}
