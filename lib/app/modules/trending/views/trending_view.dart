import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/profile/views/profile_view.dart';
import 'package:lala_ai/app/data/models/trend_model.dart';
import 'package:lala_ai/app/modules/main_container/controllers/main_container_controller.dart';
import 'package:lala_ai/app/modules/trending/controllers/trending_controller.dart';
import 'package:lala_ai/app/navigation/app_navigation_service.dart';
import 'package:lala_ai/core/widgets/skeleton/app_skeleton.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

import 'package:lala_ai/utils/theme/theme_service.dart';

class TrendingView extends GetView<TrendingController> {
  const TrendingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (_) {
        return Scaffold(
      backgroundColor: CC.background,
      appBar: CW.commonAppbar(
        isNotHomepage: false,
        wantBackIcon: false,
        title: "Trend Discovery & Alerts",
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline_rounded, color: CC.textPrimary, size: 22),
            splashRadius: 20,
            onPressed: () => Get.to(() => const ProfileView()),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadTrends,
          color: CC.primary,
          backgroundColor: CC.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tab Switcher (Discover vs Alerts)
                Obx(() => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: CC.isDark ? CC.darkBg2 : CC.surface,
                    borderRadius: BorderRadius.circular(12),
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
                      Expanded(child: _topTab("Discover Trends", 0)),
                      Expanded(child: _topTab("My Trend Alerts", 1)),
                    ],
                  ),
                )),
                16.height,

                // Dynamic Tab Output
                Obx(() {
                  if (controller.activeTab.value == 0) {
                    return _buildDiscoverTab(context);
                  } else {
                    return _buildAlertsTab(context);
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _topTab(String title, int index) {
    final isSelected = controller.activeTab.value == index;
    return GestureDetector(
      onTap: () => controller.activeTab.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? CC.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TS.caption(
            color: isSelected ? CC.whiteText : CC.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DISCOVER TAB
  // ===========================================================================
  Widget _buildDiscoverTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search & Filters Bar
        CW.commonSearchField(
          hintText: "Search viral topics, hashtags, creators...",
          onChanged: (val) {},
        ),
        12.height,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip("Platform: YouTube", Icons.play_circle_fill_rounded),
              8.width,
              _filterChip("Niche: Tech & AI", Icons.category_rounded),
              8.width,
              _filterChip("Scope: Global", Icons.public_rounded),
            ],
          ),
        ),
        14.height,

        // Last updated & Refresh header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Text("Last updated ${controller.lastUpdated.value}", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11))),
            TextButton.icon(
              onPressed: controller.loadTrends,
              icon: Icon(Icons.refresh_rounded, size: 14, color: CC.primary),
              label: Text("Refresh", style: TS.caption(color: CC.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        10.height,

        // Trend Cards List
        Obx(() {
          if (controller.isLoading.value) {
            return const TrendSkeleton(itemCount: 4);
          }

          final list = controller.trends;
          return Column(
            children: [
              for (int i = 0; i < list.length; i++) ...[
                _trendCard(
                  key: ValueKey('trend_${list[i].id}_$i'),
                  context: context,
                  rank: i + 1,
                  trend: list[i],
                ),
                if (i < list.length - 1) 12.height,
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _filterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark ? CC.black.withValues(alpha: 0.3) : CC.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: CC.textPrimary),
          6.width,
          Text(label, style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _trendCard({Key? key, required BuildContext context, required int rank, required TrendModel trend}) {
    return Container(
      key: key,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text("#$rank", style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700)),
              ),
              10.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trend.title, style: TS.sectionTitle(color: CC.textPrimary, fontSize: 14)),
                    2.height,
                    Text("${trend.category} • +${trend.changePercentage}% surge", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          10.height,
          Text(trend.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: TS.bodySmall(color: CC.textSecondary)),
          12.height,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text("Source: ${trend.source}", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10)),
          ),
          12.height,
          Row(
            children: [
              Expanded(
                child: CW.commonBtn(
                  title: "Use in Studio",
                  onTap: () => Get.find<MainContainerController>().changeTab(AppNavigationService.tabStudio),
                ),
              ),
              8.width,
              IconButton(
                icon: Icon(Icons.notifications_active_outlined, color: CC.textPrimary, size: 18),
                tooltip: "Save as Alert",
                onPressed: () => _showCreateAlertSheet(context, initialTopic: trend.title),
              ),
              IconButton(
                icon: Icon(Icons.copy_rounded, color: CC.textSecondary, size: 18),
                tooltip: "Copy Details",
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: "${trend.title}\n${trend.summary}"));
                  AppToast.success("Trend details copied!");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ALERTS TAB
  // ===========================================================================
  Widget _buildAlertsTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Active Trend Monitors", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 14)),
            TextButton.icon(
              onPressed: () => _showCreateAlertSheet(context),
              icon: Icon(Icons.add_rounded, size: 14, color: CC.primary),
              label: Text("New Alert", style: TS.caption(color: CC.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        10.height,

        Obx(() {
          final list = controller.alerts;
          return Column(
            children: [
              for (int index = 0; index < list.length; index++) ...[
                _buildAlertCard(context, index, list[index]),
                if (index < list.length - 1) 12.height,
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildAlertCard(BuildContext context, int index, Map<String, dynamic> alert) {
    final bool isEnabled = alert["enabled"] as bool? ?? true;
    return Container(
      key: ValueKey('alert_${alert["title"]}_$index'),
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
            color: CC.isDark ? CC.black.withValues(alpha: 0.45) : CC.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          if (alert["unread"] == true)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(color: CC.notification, shape: BoxShape.circle),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert["title"] as String? ?? "",
                  style: TS.bodySmall(
                    color: CC.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                4.height,
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: CC.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        alert["type"] as String? ?? "Keyword",
                        style: TS.caption(
                          color: CC.primary,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 10),
                      ),
                    ),
                    if (alert["sensitivity"] != null) ...[
                      6.width,
                      Text(
                        "• ${alert["sensitivity"]}",
                        style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          10.width,
          _buildCustomToggleSwitch(
            value: isEnabled,
            onChanged: (val) => controller.toggleAlert(index),
          ),
          4.width,
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 20, color: CC.error.withValues(alpha: 0.8)),
            onPressed: () => controller.deleteAlert(index),
          ),
        ],
      ),
    );
  }


  /// Custom Sleek Animated Toggle Switch
  Widget _buildCustomToggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value
              ? CC.primary
              : (CC.isDark
                  ? CC.whiteText.withValues(alpha: 0.16)
                  : CC.black.withValues(alpha: 0.12)),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: CC.primary.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CC.whiteText,
              boxShadow: [
                BoxShadow(
                  color: CC.black.withValues(alpha: 0.26),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Prompt modal asking user for details when adding/saving a trend alert
  void _showCreateAlertSheet(BuildContext context, {String initialTopic = ""}) {
    final titleCtrl = TextEditingController(text: initialTopic);
    final selectedType = "Keyword".obs;
    final selectedSensitivity = "Instant (+30%)".obs;

    CW.showCustomBottomSheet(
      context: context,
      title: "Create Trend Alert",
      titleIcon: Icons.add_alert_rounded,
      children: [
        CW.commonTextFormField(
          controller: titleCtrl,
          hintText: "e.g. AI Video Generators, #PixoAI...",
          labelText: "Topic or Keyword",
        ),
        14.height,
        Text("Alert Category", style: TS.caption(color: CC.textSecondary, fontWeight: FontWeight.w600)),
        6.height,
        Obx(() => Row(
              children: ["Keyword", "Niche", "Global"].map((type) {
                final isSelected = selectedType.value == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => selectedType.value = type,
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? CC.primary : CC.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? CC.primary : CC.stroke.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        type,
                        textAlign: TextAlign.center,
                        style: TS.caption(
                          color: isSelected ? CC.whiteText : CC.textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
        14.height,
        Text("Surge Sensitivity", style: TS.caption(color: CC.textSecondary, fontWeight: FontWeight.w600)),
        6.height,
        Obx(() => Row(
              children: ["Instant (+30%)", "High (+100%)", "Daily Digest"].map((sens) {
                final isSelected = selectedSensitivity.value == sens;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => selectedSensitivity.value = sens,
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? CC.primary.withValues(alpha: 0.15) : CC.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? CC.primary : CC.stroke.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        sens,
                        textAlign: TextAlign.center,
                        style: TS.caption(
                          color: isSelected ? CC.primary : CC.textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ).copyWith(fontSize: 11),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
        20.height,
        CW.commonBtn(
          title: "Save Trend Alert",
          onTap: () {
            final text = titleCtrl.text.trim();
            if (text.isEmpty) {
              AppToast.error("Please enter a topic or keyword");
              return;
            }
            controller.addAlert(
              title: text,
              type: selectedType.value,
              sensitivity: selectedSensitivity.value,
            );
            CW.dismissBottomSheet();
          },
        ),
      ],
    ).then((_) => titleCtrl.dispose());
  }
}
