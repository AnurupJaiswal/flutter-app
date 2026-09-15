import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/profile/views/edit_profile_view.dart';
import 'package:lala_ai/app/modules/settings/controllers/settings_controller.dart';
import 'package:lala_ai/app/modules/settings/views/about_lala_ai_view.dart';
import 'package:lala_ai/app/modules/settings/views/change_password_view.dart';
import 'package:lala_ai/app/modules/settings/views/faq_view.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/services/app_review_service.dart';
import 'package:lala_ai/app/navigation/app_navigation_service.dart';
import 'package:lala_ai/utils/common_methods.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (_) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            isNotHomepage: true,
            title: "Settings",
            actions: [
              IconButton(
                icon: Icon(Icons.logout_rounded, color: CC.textPrimary, size: 22),
                tooltip: "Log Out",
                onPressed: () => CW.showLogoutSheet(
                  context: context,
                onConfirm: () {
                  // Actually trigger the logout process which clears the token
                  controller.logout();
                },
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── APPEARANCE ────────────────────────────────────────────────
                _sectionLabel("Appearance"),
                _settingsGroup([
                  _themeTile(context),
                  _divider(),
                  Obx(() => _switchTile(
                    icon: Icons.notifications_none_rounded,
                    title: "Push Notifications",
                    subtitle: "Alerts on trend surges & posts",
                    value: controller.notificationsEnabled.value,
                    onChanged: (v) => controller.toggleNotifications(v),
                  )),
                ]),

                // ── ACCOUNT ───────────────────────────────────────────────────
                _sectionLabel("Account"),
                _settingsGroup([
                  _navTile(
                    icon: Icons.person_outline_rounded,
                    title: "Edit Profile",
                    subtitle: "Update personal details & creator bio",
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfileView(),
                      ),
                    ),
                  ),
                  _divider(),
                  _navTile(
                    icon: Icons.workspace_premium_rounded,
                    title: "Subscription Details",
                    subtitle: "View current plan & active benefits",
                    onTap: () => _showPlanDetailsBottomSheet(context),
                  ),
                  _divider(),
                  _navTile(
                    icon: Icons.lock_outline_rounded,
                    title: "Change Password",
                    subtitle: "Update your account password securely",
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordView(),
                      ),
                    ),
                  ),
                ]),

                // ── SUPPORT & LEGAL ───────────────────────────────────────────
                _sectionLabel("Support & Legal"),
                _settingsGroup([
                  _navTile(
                    icon: Icons.help_outline_rounded,
                    title: "FAQ & Help Center",
                    subtitle: "Guides & optimization tips",
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FaqView(),
                      ),
                    ),
                  ),
                  _divider(),
                  _navTile(
                    icon: Icons.support_agent_rounded,
                    title: "Contact Support",
                    subtitle: "24/7 creator support desk",
                    onTap: () => _showContactSupportBottomSheet(context),
                  ),
                  _divider(),
                  _navTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: "WhatsApp Assistance",
                    subtitle: "Direct chat with team",
                    onTap: () => controller.openWhatsAppSupport(),
                  ),
                  _divider(),
                  _navTile(
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy Policy",
                    subtitle: "Data privacy & security practices",
                    onTap: () => Get.toNamed(Routes.PRIVACY_POLICY),
                  ),
                  _divider(),
                  _navTile(
                    icon: Icons.description_outlined,
                    title: "Terms & Conditions",
                    subtitle: "User agreement & service terms",
                    onTap: () => Get.toNamed(Routes.TERMS_CONDITIONS),
                  ),
                ]),

                // ── APP INFO ──────────────────────────────────────────────────
                _sectionLabel("About"),
                _settingsGroup([
                  _navTile(
                    icon: Icons.info_outline_rounded,
                    title: "About Lala AI",
                    subtitle: "Our Mission • Features & More",
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AboutLalaAiView(),
                      ),
                    ),
                  ),
                  _divider(),
                  _navTile(
                    icon: Icons.star_outline_rounded,
                    title: "Rate Lala AI",
                    subtitle: "Share your experience with us",
                    onTap: () => AppReviewService.requestReview(),
                  ),
                  _divider(),
                  _infoTile(icon: Icons.info_outline_rounded, title: "App Version", trailing: "1.0.0"),
                ]),


                12.height,
                Center(
                  child: TextButton(
                    onPressed: () => _showDeleteAccountBottomSheet(context),
                    child: Text(
                      "Delete Account",
                      style: TS.caption(color: CC.textSecondary).copyWith(
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        decorationColor: CC.textSecondary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                24.height,
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Section Label (like Android category header) ─────────────────────────
  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: TS.caption(
          color: CC.primary,
          fontWeight: FontWeight.w700,
        ).copyWith(fontSize: 11, letterSpacing: 1.2),
      ),
    );
  }

  // ─── Section Group Card (one card per section, like Android Settings) ─────
  Widget _settingsGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }

  // ─── Thin divider between rows ────────────────────────────────────────────
  Widget _divider() => Divider(
        height: 1,
        thickness: 0.6,
        color: CC.stroke,
        indent: 60,
        endIndent: 0,
      );

  // ─── Navigation Tile ──────────────────────────────────────────────────────
  Widget _navTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? tileColor,
  }) {
    final iconColor = tileColor ?? CC.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (tileColor ?? CC.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            14.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TS.bodySmall(color: tileColor ?? CC.textPrimary, fontWeight: FontWeight.w600)),
                  2.height,
                  Text(subtitle, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: CC.grey, size: 18),
          ],
        ),
      ),
    );
  }

  // ─── Switch Tile ──────────────────────────────────────────────────────────
  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: CC.textPrimary, size: 18),
          ),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600)),
                2.height,
                Text(subtitle, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeThumbColor: CC.primary,
              activeTrackColor: CC.primary.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Info Tile (no chevron, no tap) ──────────────────────────────────────
  Widget _infoTile({
    required IconData icon,
    required String title,
    required String trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: CC.textPrimary, size: 18),
          ),
          14.width,
          Expanded(child: Text(title, style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600))),
          Text(trailing, style: TS.caption(color: CC.textSecondary)),
        ],
      ),
    );
  }

  // ─── Theme Tile ───────────────────────────────────────────────────────────
  Widget _themeTile(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    return InkWell(
      onTap: () => _showThemeBottomSheet(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CC.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.palette_outlined, color: CC.textPrimary, size: 18),
            ),
            14.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Theme", style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600)),
                  2.height,
                  Obx(() {
                    final s = themeService.currentThemeSetting;
                    final label = s == ThemeService.themeDark
                        ? "Dark"
                        : s == ThemeService.themeLight
                            ? "Light"
                            : "System Default";
                    return Text(label, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11));
                  }),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: CC.grey, size: 18),
          ],
        ),
      ),
    );
  }


  // ─── Bottom Sheets & Dialogs ──────────────────────────────────────────────

  void _showThemeBottomSheet(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    String selectedThemeKey = themeService.currentThemeSetting;

    CW.showCustomBottomSheet(
      context: context,
      title: "Appearance Theme",
      subtitle: "Choose your preferred visual appearance mode",
      titleIcon: Icons.palette_outlined,
      children: [
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                _themeOptionCard(
                  title: "Light Mode",
                  subtitle: "Bright & high contrast UI for daytime focus",
                  icon: Icons.light_mode_rounded,
                  themeKey: ThemeService.themeLight,
                  selectedThemeKey: selectedThemeKey,
                  themeService: themeService,
                  onSelect: (key) {
                    setState(() {
                      selectedThemeKey = key;
                    });
                  },
                ),
                _themeOptionCard(
                  title: "Dark Mode",
                  subtitle: "Sleek obsidian theme for low-light comfort",
                  icon: Icons.dark_mode_rounded,
                  themeKey: ThemeService.themeDark,
                  selectedThemeKey: selectedThemeKey,
                  themeService: themeService,
                  onSelect: (key) {
                    setState(() {
                      selectedThemeKey = key;
                    });
                  },
                ),
                _themeOptionCard(
                  title: "System Default",
                  subtitle: "Automatically matches your device system settings",
                  icon: Icons.brightness_auto_rounded,
                  themeKey: ThemeService.themeSystem,
                  selectedThemeKey: selectedThemeKey,
                  themeService: themeService,
                  onSelect: (key) {
                    setState(() {
                      selectedThemeKey = key;
                    });
                  },
                ),
                16.height,
                Row(
                  children: [
                    Expanded(
                      child: CW.commonBtn(
                        title: "Cancel",
                        isOutlined: true,
                        onTap: () => CW.dismissBottomSheet(),
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: CW.commonBtn(
                        title: "Apply Theme",
                        color: CC.primary,
                        onTap: () {
                          themeService.setThemeMode(selectedThemeKey);
                          CW.dismissBottomSheet();
                        },
                      ),
                    ),
                  ],
                ),
                10.height,
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _themeOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String themeKey,
    required String selectedThemeKey,
    required ThemeService themeService,
    required ValueChanged<String> onSelect,
  }) {
    final isSelected = selectedThemeKey == themeKey;
    final isCurrentActive = themeService.currentThemeSetting == themeKey;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? (CC.isDark
                ? CC.primary.withValues(alpha: 0.16)
                : CC.primary.withValues(alpha: 0.07))
            : CC.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? CC.primary
              : CC.stroke.withValues(alpha: CC.isDark ? 0.5 : 0.7),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onSelect(themeKey),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CC.primary
                        : CC.primary.withValues(alpha: CC.isDark ? 0.15 : 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? CC.whiteText : CC.primary,
                    size: 22,
                  ),
                ),
                14.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TS.sectionTitle(
                              color: CC.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                          if (isCurrentActive) ...[
                            8.width,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: CC.primary.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: CC.primary.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "Active",
                                style: TS.caption(
                                  color: CC.primary,
                                  fontWeight: FontWeight.w700,
                                ).copyWith(fontSize: 10),
                              ),
                            ),
                          ] else if (isSelected) ...[
                            8.width,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: CC.primary.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: CC.primary.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "Selected",
                                style: TS.caption(
                                  color: CC.primary,
                                  fontWeight: FontWeight.w700,
                                ).copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ],
                      ),
                      4.height,
                      Text(
                        subtitle,
                        style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                10.width,
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? CC.primary : CC.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: CC.primary,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPlanDetailsBottomSheet(BuildContext context) {
    CW.showCustomBottomSheet(
      context: context,
      title: "Current Subscription",
      titleIcon: Icons.workspace_premium_rounded,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CC.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: CC.primary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CC.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: CC.whiteText,
                  size: 22,
                ),
              ),
              14.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      controller.currentPlan.value,
                      style: TS.sectionTitle(
                        color: CC.textPrimary,
                        fontSize: 16,
                      ),
                    )),
                    4.height,
                    Text(
                      "Active • Renews Oct 1, 2026",
                      style: TS.caption(color: CC.textSecondary).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        16.height,
        Text(
          "Included Benefits",
          style: TS.bodySmall(
            color: CC.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        10.height,
        _benefitRow("Unlimited AI generation and script tools"),
        _benefitRow("Advanced competitor analytics & trend tracking"),
        _benefitRow("Priority 24/7 creator support desk"),
        _benefitRow("High-resolution video script exporter"),
        20.height,
      ],
    );
  }

  Widget _benefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: CC.primary, size: 16),
          10.width,
          Expanded(
            child: Text(
              text,
              style: TS.bodySmall(color: CC.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountBottomSheet(BuildContext context) {
    bool isConfirmed = false;

    CW.showCustomBottomSheet(
      context: context,
      title: "Delete Account?",
      titleIcon: Icons.warning_amber_rounded,
      children: [
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "By deleting your account, please note the following:",
                  style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600),
                ),
                10.height,
                _deleteBulletPoint("Account deletion is permanent and cannot be undone."),
                _deleteBulletPoint("All saved scripts, AI generation history, and channel analytics will be erased."),
                _deleteBulletPoint("Your data CANNOT be restored under any circumstances."),
                _deleteBulletPoint("Your active subscription plan will be immediately cancelled with no refund."),
                14.height,

                // Checkbox Row
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      isConfirmed = !isConfirmed;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: isConfirmed,
                            activeColor: CC.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (val) {
                              setState(() {
                                isConfirmed = val ?? false;
                              });
                            },
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: Text(
                            "I understand that my data cannot be restored and my subscription plan will be cancelled immediately.",
                            style: TS.caption(color: CC.textPrimary).copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                20.height,

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: CW.commonBtn(
                        title: "Cancel",
                        isOutlined: true,
                        onTap: () => CW.dismissBottomSheet(),
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: CW.commonBtn(
                        title: "Delete Account",
                        color: isConfirmed ? CC.primary : CC.primary.withValues(alpha: 0.35),
                        textColor: isConfirmed ? CC.whiteText : CC.whiteText.withValues(alpha: 0.6),
                        onTap: isConfirmed
                            ? () {
                                CW.dismissBottomSheet();
                                controller.deleteAccount();
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
                10.height,
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _deleteBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TS.bodySmall(color: CC.primary, fontWeight: FontWeight.w700)),
          Expanded(
            child: Text(
              text,
              style: TS.caption(color: CC.textSecondary).copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }



  void _showContactSupportBottomSheet(BuildContext context) {
    final msgController = TextEditingController();
    CW.showCustomBottomSheet(
      context: context,
      title: "Contact 24/7 Support",
      titleIcon: Icons.support_agent_rounded,
      children: [
        Text("Our creator support team typically responds within 1 hour.", style: TS.caption(color: CC.textSecondary)),
        12.height,
        CW.commonTextFormField(
          controller: msgController,
          hintText: "Describe your issue or question...",
          labelText: "Your Message",
        ),
        16.height,
        CW.commonBtn(
          title: "Send Message",
          onTap: () {
            CW.dismissBottomSheet();
            CM.showToast("Support ticket created! We'll reply shortly.");
          },
        ),
      ],
    ).then((_) => msgController.dispose());
  }
}
