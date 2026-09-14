import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/app/modules/analytics/views/analytics_view.dart';
import 'package:lala_ai/app/modules/home/controllers/home_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:lala_ai/app/modules/connect_accounts/views/connect_accounts_view.dart';
import 'package:lala_ai/app/modules/profile/views/profile_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (themeService) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            isNotHomepage: false,
            wantBackIcon: false,
            titleWidget: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CC.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.auto_awesome_rounded, color: CC.textPrimary, size: 16),
                ),
                8.width,
                Text("Lala Ai", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16)),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_none_rounded, color: CC.textPrimary, size: 22),
                splashRadius: 20,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.person_outline_rounded, color: CC.textPrimary, size: 22),
                splashRadius: 20,
                onPressed: () => Get.to(() => const ProfileView()),
              ),
            ],
          ),
          body: SafeArea(
            child: Obx(() {
              final isNoneConnected = !controller.isInstagramConnected.value && !controller.isYoutubeConnected.value;

              if (isNoneConnected) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: _buildInitialEmptyState(),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    24.height,
                    _buildChannelsSection(),
                    24.height,
                    _buildHealthScoreSection(),
                    24.height,
                    _buildSwotAuditSection(),
                    24.height,
                    _buildActionableToDosSection(),
                    24.height,
                    _buildRecentContentSection(),
                    24.height,
                    _buildCreatorTipSection(),
                    100.height, // padding so floating bubble doesn't overlap
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CC.isDark ? const Color(0xFF101010) : CC.surface,
        borderRadius: BorderRadius.circular(12),
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
          Expanded(child: _stateTabItem("Overview", DashboardTab.overview)),
          Expanded(child: _stateTabItem("Connect", DashboardTab.connect)),
        ],
      ),
    );
  }

  Widget _stateTabItem(String title, DashboardTab state) {
    final isSelected = controller.activeTab.value == state;
    return GestureDetector(
      onTap: () {
        controller.activeTab.value = state;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CC.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TS.caption(
            color: isSelected ? Colors.white : CC.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Hey, Alex 👋", style: TS.displayLarge(fontSize: 22, fontWeight: FontWeight.w700)),
        2.height,
        Text("Manage your channels and get AI-powered insights.", style: TS.bodySmall(color: CC.textSecondary).copyWith(fontSize: 11)),
      ],
    );
  }

  // Brand icon widgets
  static Widget _youtubeLogo({double size = 40}) {
    return CW.youtubeIcon(size: size);
  }

  static Widget _instagramLogo({double size = 40}) {
    return CW.instagramIcon(size: size);
  }

  Widget _buildChannelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Your Channels", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16)),
        12.height,
        _buildPlatformCard(
          platform: "YouTube",
          brandIcon: _youtubeLogo(size: 40),
          iconBg: const Color(0xFFFF0000),
          isConnected: controller.isYoutubeConnected.value,
          handle: "@alexcreators",
          onAction: () => Get.to(() => const ConnectAccountsView()),
        ),
        10.height,
        _buildPlatformCard(
          platform: "Instagram",
          brandIcon: _instagramLogo(size: 40),
          iconBg: const Color(0xFFE1306C),
          isConnected: controller.isInstagramConnected.value,
          handle: "@alex_reels",
          onAction: () => Get.to(() => const ConnectAccountsView()),
        ),
      ],
    );
  }

  Widget _buildPlatformCard({
    required String platform,
    required Widget brandIcon,
    required Color iconBg,
    required bool isConnected,
    required String handle,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        children: [
          // Platform icon
          brandIcon,
          14.width,
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(platform, style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w700)),
                4.height,
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: isConnected ? CC.success : CC.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    6.width,
                    Text(
                      isConnected ? handle : "Not connected",
                      style: TS.caption(color: CC.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          12.width,
          // Action button
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isConnected
                      ? Colors.transparent
                      : CC.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: isConnected
                      ? Border.all(color: CC.primary, width: 1.2)
                      : null,
                ),
                child: Text(
                  isConnected ? "Manage" : "Connect",
                  style: TS.caption(
                    color: isConnected ? CC.primary : Colors.white,
                    fontWeight: FontWeight.w600,
                  ).copyWith(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Health Score & Statistics Section ─────────────────────────────────────
  Widget _buildHealthScoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Channel Health Audit", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16)),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsView())),
                  child: Row(
                    children: [
                      Text("View Analytics", style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700)),
                      4.width,
                      Icon(Icons.arrow_forward_ios_rounded, size: 11, color: CC.primary),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
        12.height,
        Builder(
          builder: (context) {
            return InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsView())),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: CC.surface,
                  borderRadius: BorderRadius.circular(16),
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
                        // Circular score meter
                        Obx(() => Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 72,
                              height: 72,
                              child: CircularProgressIndicator(
                                value: controller.healthScore.value / 100,
                                strokeWidth: 7,
                                backgroundColor: CC.primary.withValues(alpha: 0.12),
                                color: CC.primary,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${controller.healthScore.value}",
                                  style: TS.sectionTitle(color: CC.textPrimary, fontSize: 20),
                                ),
                                Text(
                                  "/100",
                                  style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        )),
                        18.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => Text("Health Score: ${controller.healthScore.value}%", style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w700))),
                              4.height,
                              Text(
                                "Your overall channel engagement & reach is performing 14% higher than last week.",
                                style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    Divider(height: 1, color: CC.stroke),
                    14.height,
                    // Quick Stats Row
                    Obx(() => Row(
                      children: [
                        Expanded(child: _statItem("Subscribers", controller.subscribersCount.value, "+340", Icons.people_outline_rounded)),
                        Container(width: 1, height: 36, color: CC.stroke),
                        Expanded(child: _statItem("Avg Views", controller.viewsCount.value, "+18%", Icons.play_arrow_outlined)),
                        Container(width: 1, height: 36, color: CC.stroke),
                        Expanded(child: _statItem("Engagement", controller.engagementRate.value, "High", Icons.bolt_rounded)),
                      ],
                    )),
                    14.height,

                    // Action button bar to Analytics
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: CC.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart_rounded, size: 15, color: CC.primary),
                          6.width,
                          Text(
                            "Open Full Channel Analytics & Audit",
                            style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 12),
                          ),
                          4.width,
                          Icon(Icons.chevron_right_rounded, size: 16, color: CC.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ],
    );
  }

  Widget _statItem(String label, String value, String badge, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: CC.textPrimary),
            4.width,
            Text(value, style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15)),
          ],
        ),
        2.height,
        Text(label, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10)),
        4.height,
        Text(badge, style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 10)),
      ],
    );
  }

  // ─── Channel Audit & SWOT Explanation Section ─────────────────────────────
  Widget _buildSwotAuditSection() {
    final categories = [
      {"key": "Strengths", "label": "Strengths"},
      {"key": "Weaknesses", "label": "Weakness"},
      {"key": "Opportunities", "label": "Oppty"},
      {"key": "Threats", "label": "Threats"},
    ];

    final swotData = {
      "Strengths": [
        {"title": "High Shorts Retention (>75%)", "desc": "Viewer retention on Short-form videos outperforms 85% of creator benchmarks.", "icon": Icons.thumb_up_alt_outlined},
        {"title": "Consistent Upload Schedule", "desc": "Uploading every Tuesday & Friday maintains steady audience return rates.", "icon": Icons.check_circle_outline_rounded},
      ],
      "Weaknesses": [
        {"title": "Missing Description SEO", "desc": "Recent video descriptions lack high-search volume keywords for discovery.", "icon": Icons.warning_amber_rounded},
        {"title": "Low Thumbnail Text Contrast", "desc": "Mobile CTR is impacted by low color contrast on text overlays.", "icon": Icons.find_in_page_outlined},
      ],
      "Opportunities": [
        {"title": "Trending Topic: 'AI Tools 2026'", "desc": "Search volume for AI productivity tools is up 320% this week.", "icon": Icons.trending_up_rounded},
        {"title": "Peak Post Window: Fri 6:00 PM", "desc": "82% of your subscriber base is active during Friday evening hours.", "icon": Icons.schedule_rounded},
      ],
      "Threats": [
        {"title": "Niche Creator Saturation", "desc": "Tech commentary channel count increased 22% in your primary tag category.", "icon": Icons.shield_outlined},
        {"title": "Audience Drop at 45s Mark", "desc": "Drop-off occurs when transitioning from intro to main content.", "icon": Icons.timelapse_rounded},
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("SWOT Audit", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16)),
            Icon(Icons.analytics_outlined, color: CC.textPrimary, size: 20),
          ],
        ),
        12.height,
        // Equal width tab pills across row
        Obx(() => Row(
          children: categories.map((cat) {
            final key = cat["key"]!;
            final label = cat["label"]!;
            final isSelected = controller.selectedSwotCategory.value == key;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedSwotCategory.value = key,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? CC.primary : CC.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? CC.primary : CC.stroke,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.caption(
                      color: isSelected ? Colors.white : CC.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ).copyWith(fontSize: 11),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        12.height,
        // SWOT Cards List
        Obx(() {
          final cat = controller.selectedSwotCategory.value;
          final items = swotData[cat] ?? [];
          return Column(
            children: items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CC.surface,
                  borderRadius: BorderRadius.circular(16),
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
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: CC.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'] as IconData, color: CC.textPrimary, size: 20),
                    ),
                    14.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title'] as String, style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w700)),
                          3.height,
                          Text(item['desc'] as String, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11, height: 1.3)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // ─── Actionable Creator To-Dos Section ────────────────────────────────────
  Widget _buildActionableToDosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Creator To-Dos", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16)),
            Obx(() {
              final done = controller.toDoItems.where((i) => (i['isDone'] as bool)).length;
              final total = controller.toDoItems.length;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$done/$total Completed",
                  style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 10),
                ),
              );
            }),
          ],
        ),
        6.height,
        Text("AI-generated tasks to boost your channel reach", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
        10.height,
        // Progress bar
        Obx(() {
          final done = controller.toDoItems.where((i) => (i['isDone'] as bool)).length;
          final total = controller.toDoItems.isEmpty ? 1 : controller.toDoItems.length;
          final progress = done / total;
          return Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * progress,
                    height: 6,
                    decoration: BoxDecoration(
                      color: CC.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          );
        }),
        12.height,
        Obx(() => Column(
          children: controller.toDoItems.map((item) {
            final id = item['id'] as int;
            final title = item['title'] as String;
            final subtitle = item['subtitle'] as String;
            final isDone = item['isDone'] as bool;
            final tag = item['tag'] as String;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDone ? CC.surface.withValues(alpha: 0.6) : CC.surface,
                borderRadius: BorderRadius.circular(16),
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
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => controller.toggleToDoItem(id),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Custom check box indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isDone ? CC.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDone ? CC.primary : CC.grey,
                              width: 1.8,
                            ),
                          ),
                          child: isDone
                              ? const Center(
                                  child: Icon(Icons.check_rounded, color: Colors.white, size: 15),
                                )
                              : null,
                        ),
                        12.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TS.bodySmall(
                                  color: isDone ? CC.textSecondary : CC.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ).copyWith(
                                  fontSize: 13,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                  decorationColor: CC.textSecondary,
                                ),
                              ),
                              3.height,
                              Text(
                                subtitle,
                                style: TS.caption(
                                  color: CC.textSecondary,
                                ).copyWith(fontSize: 11, height: 1.2),
                              ),
                            ],
                          ),
                        ),
                        10.width,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDone
                                ? CC.stroke.withValues(alpha: 0.2)
                                : CC.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: TS.caption(
                              color: isDone ? CC.textSecondary : CC.primary,
                              fontWeight: FontWeight.w700,
                            ).copyWith(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildRecentContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Content", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16)),
            if (controller.isYoutubeConnected.value || controller.isInstagramConnected.value)
              Text("View All", style: TS.caption(color: CC.primary, fontWeight: FontWeight.w600)),
          ],
        ),
        16.height,
        if (!controller.isYoutubeConnected.value && !controller.isInstagramConnected.value)
          _buildEmptyState(
            "No channels connected",
            "Connect your YouTube or Instagram account to start managing your content with Lala AI.",
            "Connect a Channel",
            () => controller.activeTab.value = DashboardTab.connect,
          )
        else if (!controller.hasRecentContent.value)
          _buildEmptyState(
            "No recent content",
            "Your latest content will appear here once it's available.",
            "Refresh",
            () {
               controller.hasRecentContent.value = true;
            },
          )
        else
          Column(
            children: [
              if (controller.isYoutubeConnected.value) ...[
                _buildContentCard(
                  title: "10 AI Tools Every Creator Needs",
                  platform: "YouTube",
                  timestamp: "2 days ago",
                  icon: Icons.play_circle_fill_rounded,
                  iconColor: const Color(0xFFFF0000),
                ),
                12.height,
              ],
              if (controller.isInstagramConnected.value) ...[
                _buildContentCard(
                  title: "How I Scripted 30 Reels in 1 Hour",
                  platform: "Instagram",
                  timestamp: "5 days ago",
                  icon: Icons.camera_alt_rounded,
                  iconColor: const Color(0xFFE1306C),
                ),
              ] else
                _buildPlatformNotConnectedBanner("Instagram"),
            ],
          ),
      ],
    );
  }

  Widget _buildPlatformNotConnectedBanner(String platform) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CC.stroke, width: 0.7),
      ),
      child: Row(
        children: [
          Icon(Icons.link_off_rounded, color: CC.grey, size: 20),
          12.width,
          Expanded(
            child: Text(
              "$platform not connected. Connect to see your latest content.",
              style: TS.caption(color: CC.textSecondary),
            ),
          ),
          8.width,
          GestureDetector(
            onTap: () => controller.activeTab.value = DashboardTab.connect,
            child: Text("Connect", style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, String btnTitle, VoidCallback onBtnTap) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          Icon(Icons.video_library_outlined, size: 48, color: CC.grey),
          16.height,
          Text(title, style: TS.titleMedium(color: CC.textPrimary)),
          8.height,
          Text(subtitle, textAlign: TextAlign.center, style: TS.bodySmall(color: CC.textSecondary)),
          24.height,
          CW.commonBtn(
            title: btnTitle,
            width: 200,
            onTap: onBtnTap,
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard({
    required String title,
    required String platform,
    required String timestamp,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: CC.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, color: iconColor.withValues(alpha: 0.5), size: 24),
            ),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600)),
                4.height,
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: 10),
                    4.width,
                    Text("$platform · $timestamp", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: CC.textSecondary, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorTipSection() {
    return CW.aiTipCard(
      title: "Lala AI Tip",
      message: controller.isYoutubeConnected.value || controller.isInstagramConnected.value
          ? "Your latest content is ready for review. Schedule your posts consistently to keep your audience engaged."
          : "Connect your channels to unlock personalized AI insights and recommendations.",
    );
  }

  // ===========================================================================
  // CONNECT SECTION UI
  // ===========================================================================
  Widget _buildConnectSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Connect your channels to enable automated channel audits, real-time analytics, and AI content scheduling.",
          style: TS.bodySmall(color: CC.textSecondary),
        ),
        16.height,

        // YouTube Connection Card
        _platformConnectCard(
          platform: "YouTube",
          brandIcon: _youtubeLogo(size: 40),
          iconBg: const Color(0xFFFF0000),
          handle: "@alexcreators",
          status: controller.isYoutubeConnected.value ? "Connected" : "Disconnected",
          statusColor: controller.isYoutubeConnected.value ? CC.success : CC.error,
          isConnected: controller.isYoutubeConnected.value,
          onToggle: () => controller.toggleYoutubeConnection(),
        ),
        12.height,

        // Instagram Connection Card
        _platformConnectCard(
          platform: "Instagram",
          brandIcon: _instagramLogo(size: 40),
          iconBg: const Color(0xFFE1306C),
          handle: "@alex_reels",
          status: controller.isInstagramConnected.value ? "Connected" : "Re-auth Required",
          statusColor: controller.isInstagramConnected.value ? CC.success : CC.insightful,
          isConnected: controller.isInstagramConnected.value,
          onToggle: () => controller.toggleInstagramConnection(),
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
    );
  }

  Widget _platformConnectCard({
    required String platform,
    required Widget brandIcon,
    required Color iconBg,
    required String handle,
    required String status,
    required Color statusColor,
    required bool isConnected,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
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
              // Platform icon
              brandIcon,
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(platform, style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w700)),
                    4.height,
                    Text(isConnected ? handle : "Not connected", style: TS.caption(color: CC.textSecondary)),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 5, height: 5, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    5.width,
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
                  isOutlined: isConnected,
                  onTap: () {
                    if (isConnected) {
                      AppToast.info("Syncing $platform with Lala AI...");
                    } else {
                      onToggle();
                    }
                  },
                ),
              ),
              if (isConnected) ...[
                10.width,
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Text("Disconnect", style: TS.caption(color: CC.error, fontWeight: FontWeight.w600)),
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
  Widget _buildInitialEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.hub_rounded, size: 80, color: CC.primary),
        32.height,
        Text("Connect your accounts", style: TS.titleMedium(color: CC.textPrimary)),
        16.height,
        Text(
          "Connect Instagram or YouTube to start viewing your\ncontent performance and analytics.",
          textAlign: TextAlign.center,
          style: TS.bodySmall(color: CC.textSecondary).copyWith(height: 1.4),
        ),
        48.height,
        CW.commonBtn(
          title: "Connect Instagram",
          leadingImage: Image.asset('assets/icons/img_instagram.png', width: 20, height: 20),
          onTap: () => Get.to(() => const ConnectAccountsView()),
        ),
        20.height,
        CW.commonBtn(
          title: "Connect YouTube",
          leadingImage: Image.asset('assets/icons/img_youtube.png', width: 20, height: 20),
          onTap: () => Get.to(() => const ConnectAccountsView()),
        ),
      ],
    );
  }
}
