import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/Models/connected_accounts_model.dart';
import 'package:lala_ai/app/modules/analytics/views/analytics_view.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/modules/connect_accounts/views/connect_accounts_view.dart';
import 'package:lala_ai/app/modules/profile/views/edit_profile_view.dart';
import 'package:lala_ai/app/modules/settings/views/settings_view.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    _refreshProfileData();
  }

  Future<void> _refreshProfileData() async {
    try {
      final authRepo = Get.isRegistered<AuthRepository>()
          ? Get.find<AuthRepository>()
          : Get.put<AuthRepository>(ApiAuthRepository());
      await authRepo.fetchAndSaveMe();
      if (mounted) setState(() {});
    } catch (_) {}
  }
  @override
  Widget build(BuildContext context) {
    final userName = ApiService.effectiveDisplayName;
    final userEmail = ApiService.currentUser?.email.isNotEmpty == true
        ? ApiService.currentUser!.email
        : (ApiService.userEmail?.isNotEmpty == true ? ApiService.userEmail! : "creator@lala.ai");
    final userInitial = userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : "C";
    final planTier = ApiService.currentSubscription?.planTier ?? "PRO";
    final niche = ApiService.currentCreatorProfile?.niche?.isNotEmpty == true
        ? ApiService.currentCreatorProfile!.niche!
        : null;
    final streakDays = ApiService.currentCreatorProfile?.streakDays;
    final streakLabel = (streakDays != null && streakDays > 0)
        ? "🔥 ${streakDays}d Active"
        : "🔥 Active";

    final connectedAccounts = ApiService.currentConnectedAccounts;
    final stats = ApiService.currentStats;
    final scriptsMade = stats != null ? "${stats.scriptsMade}" : "42";
    final timeSaved = stats != null ? "${stats.timeSavedHours} hrs" : "18 hrs";
    final channelGrowth = stats != null ? "+${stats.channelGrowth}%" : "+24%";

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                                child: Text(userInitial, style: TS.displayLarge(color: CC.primary, fontSize: 24)),
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
                                      Flexible(
                                        child: Text(userName, style: TS.sectionTitle(color: CC.textPrimary), overflow: TextOverflow.ellipsis),
                                      ),
                                      6.width,
                                      Icon(Icons.verified_rounded, color: CC.primary, size: 15),
                                    ],
                                  ),
                                  4.height,
                                  Text(userEmail, style: TS.caption(color: CC.textSecondary), overflow: TextOverflow.ellipsis),
                                  6.height,
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: CC.tealSubtle,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            niche != null ? "$niche • $planTier" : "$planTier Creator",
                                            style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 10),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      6.width,
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: CC.primary.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(streakLabel, style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w600).copyWith(fontSize: 10)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            8.width,
                            // Edit icon → navigates to full page
                            GestureDetector(
                              onTap: () async {
                                final updated = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(builder: (_) => const EditProfileView()),
                                );
                                if (updated == true && mounted) {
                                  _refreshProfileData();
                                }
                              },
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
                        14.height,
                        Divider(
                          height: 1,
                          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                        ),
                        12.height,
                        // ── Social Media Handles (Clickable to manage) ────────
                        InkWell(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ConnectAccountsView()),
                            );
                            _refreshProfileData();
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: _buildSocialHandlesList(connectedAccounts),
                                  ),
                                ),
                                8.width,
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Manage",
                                      style: TS.caption(color: CC.primary, fontWeight: FontWeight.w600).copyWith(fontSize: 11),
                                    ),
                                    2.width,
                                    Icon(Icons.chevron_right_rounded, size: 16, color: CC.primary),
                                  ],
                                ),
                              ],
                            ),
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
                      Expanded(child: _journeyStat(scriptsMade, "Scripts Made", Icons.movie_creation_outlined)),
                      10.width,
                      Expanded(child: _journeyStat(timeSaved, "Time Saved", Icons.timer_outlined)),
                      10.width,
                      Expanded(child: _journeyStat(channelGrowth, "Channel Growth", Icons.show_chart_rounded)),
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

  Widget _socialHandleChip({
    required Widget icon,
    required String handle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: CC.isDark
              ? Colors.white.withValues(alpha: 0.05)
              : CC.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            6.width,
            Text(
              handle,
              style: TS.caption(
                color: CC.textPrimary,
                fontWeight: FontWeight.w600,
              ).copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialHandlesList(ConnectedAccountsModel? accounts) {
    final List<Widget> chips = [];

    if (accounts?.youtube?.connected == true && (accounts?.youtube?.handle?.isNotEmpty ?? false)) {
      chips.add(
        _socialHandleChip(
          icon: CW.youtubeIcon(size: 16),
          handle: accounts!.youtube!.handle!,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConnectAccountsView()),
            );
            _refreshProfileData();
          },
        ),
      );
    }

    if (accounts?.instagram?.connected == true && (accounts?.instagram?.handle?.isNotEmpty ?? false)) {
      if (chips.isNotEmpty) chips.add(8.width);
      chips.add(
        _socialHandleChip(
          icon: CW.instagramIcon(size: 16),
          handle: accounts!.instagram!.handle!,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConnectAccountsView()),
            );
            _refreshProfileData();
          },
        ),
      );
    }

    if (accounts?.tiktok?.connected == true && (accounts?.tiktok?.handle?.isNotEmpty ?? false)) {
      if (chips.isNotEmpty) chips.add(8.width);
      chips.add(
        _socialHandleChip(
          icon: Icon(Icons.music_note_rounded, size: 16, color: CC.textPrimary),
          handle: accounts!.tiktok!.handle!,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConnectAccountsView()),
            );
            _refreshProfileData();
          },
        ),
      );
    }

    if (chips.isEmpty) {
      chips.add(
        _socialHandleChip(
          icon: Icon(Icons.add_link_rounded, size: 16, color: CC.primary),
          handle: "Connect Channels",
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConnectAccountsView()),
            );
            _refreshProfileData();
          },
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: chips,
    );
  }
}
