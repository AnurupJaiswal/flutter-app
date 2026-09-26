import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/connect_accounts/views/connect_accounts_view.dart';
import 'package:lala_ai/app/modules/home/controllers/home_controller.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:lala_ai/app/modules/competitor/controllers/competitor_controller.dart';
import 'package:lala_ai/Models/compare_creator_model.dart';
import 'package:lala_ai/core/widgets/skeleton/app_skeleton.dart';
import 'package:lala_ai/utils/common_methods.dart';

class CompetitorView extends StatefulWidget {
  final bool isEmbedded;
  const CompetitorView({super.key, this.isEmbedded = false});

  @override
  State<CompetitorView> createState() => _CompetitorViewState();
}

class _CompetitorViewState extends State<CompetitorView> {
  final _searchController = TextEditingController();
  final CompetitorController controller = Get.put(CompetitorController());

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runComparison(int? accountId, String platformStr) {
    if (accountId == null) {
      CM.showToast('No connected account found. Please connect an account first.');
      return;
    }
    var query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Clean tracking query parameters (?si=..., ?feature=...) and trailing slashes
    if (query.contains('?')) {
      query = query.split('?').first;
    }
    query = query.replaceAll(RegExp(r'/+$'), '');
    FocusScope.of(context).unfocus();

    controller.compareWithCreator(
      accountId: accountId,
      competitorIdentifier: query,
      platform: platformStr,
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

    return GetBuilder<ThemeService>(
      builder: (_) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: widget.isEmbedded
              ? null
              : CW.commonAppbar(
                  isNotHomepage: true,
                  wantBackIcon: true,
                  title: "Discover",
                ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                final List<ChannelOption> channels = homeController?.availableChannels ?? <ChannelOption>[];
                final activeChannel = homeController?.selectedChannel.value ?? (channels.isNotEmpty ? channels.first : null);

                final String platformStr = activeChannel?.platform ?? "YOUTUBE";
                final bool isYouTube = platformStr.toUpperCase() == 'YOUTUBE';

                final String creatorName = activeChannel?.name.isNotEmpty == true
                    ? activeChannel!.name
                    : (homeController?.creatorName.value.isNotEmpty == true
                        ? homeController!.creatorName.value
                        : ApiService.effectiveDisplayName);

                final String userHandle = activeChannel != null
                    ? (activeChannel.handle.startsWith('@') ? activeChannel.handle : "@${activeChannel.handle}")
                    : "@your_account";

                final String audienceCount = isYouTube
                    ? "${homeController?.subscribersCount.value.isNotEmpty == true ? homeController!.subscribersCount.value : '42.3K'} subscribers"
                    : "28.6K followers";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. SECTION TITLE & DESCRIPTION ─────────────────────────
                    Text(
                      "Compare With Another Creator",
                      style: TS.sectionTitle(color: CC.textPrimary, fontSize: 18),
                    ),
                    4.height,
                    Text(
                      "Compare another creator with your connected account.",
                      style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12.5),
                    ),
                    20.height,

                    // ── 2. YOUR ACCOUNT CARD ──────────────────────────────────
                    Text(
                      "Your Account",
                      style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w700).copyWith(fontSize: 13),
                    ),
                    8.height,
                    _buildConnectedAccountCard(
                      context: context,
                      creatorName: creatorName,
                      userHandle: userHandle,
                      platform: platformStr,
                      audienceCount: audienceCount,
                      statusColor: activeChannel?.statusColor,
                      statusText: activeChannel?.statusDisplay,
                    ),
                    8.height,
                    // "Change Account >" Action
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _showChangeAccountBottomSheet(context, homeController, channels),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Change Account",
                                style: TS.caption(color: CC.primary, fontWeight: FontWeight.w600).copyWith(fontSize: 12),
                              ),
                              2.width,
                              Icon(Icons.chevron_right_rounded, size: 16, color: CC.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                    20.height,

                    // ── 3. COMPETITOR INPUT SECTION ───────────────────────────
                    Text(
                      "Competitor",
                      style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w700).copyWith(fontSize: 13),
                    ),
                    8.height,
                    CW.commonSearchField(
                      controller: _searchController,
                      hintText: "Enter handle or channel URL",
                      onSubmitted: (_) => _runComparison(activeChannel?.id, platformStr),
                    ),
                    24.height,

                    // ── 4. COMPARE BUTTON ─────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => CW.commonBtn(
                        title: controller.isLoading.value ? "Comparing..." : "Compare",
                        height: 46,
                        onTap: controller.isLoading.value ? null : () => _runComparison(activeChannel?.id, platformStr),
                      )),
                    ),
                    24.height,

                    // ── 5. COMPARISON OVERVIEW RESULT ─────────────────────────
                    Obx(() {
                      if (controller.isLoading.value) {
                        return _buildCompareSkeletonCard();
                      }
                      if (controller.errorMessage.isNotEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                          decoration: BoxDecoration(
                            color: CC.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: CC.stroke.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline_rounded, color: CC.error, size: 40),
                              16.height,
                              Text(
                                "Couldn't Fetch Data",
                                style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w700).copyWith(fontSize: 15),
                              ),
                              8.height,
                              Text(
                                controller.errorMessage.value,
                                style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 13, height: 1.4),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      if (controller.compareData.value != null) {
                        return _buildComparisonOverviewCard(
                          isYouTube: isYouTube,
                          data: controller.compareData.value!,
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    100.height,
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  // ── Connected Account Card (Matches Home Screen Connected Card Style) ─────
  Widget _buildConnectedAccountCard({
    required BuildContext context,
    required String creatorName,
    required String userHandle,
    required String platform,
    required String audienceCount,
    Color? statusColor,
    String? statusText,
  }) {
    final bool isYt = platform.toUpperCase() == 'YOUTUBE';
    final Color effectiveStatusColor = statusColor ?? const Color(0xFF22C55E);
    final String effectiveStatusText = statusText ?? "Connected";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar Icon with Platform Indicator Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: CC.searchBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CC.stroke.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.person_rounded, color: CC.grey, size: 24),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: CC.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: CC.surface, width: 2),
                  ),
                  child: isYt ? CW.youtubeIcon(size: 13) : CW.instagramIcon(size: 13),
                ),
              ),
            ],
          ),
          14.width,

          // Account & Platform Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creatorName,
                  style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                2.height,
                Text(
                  "$userHandle • $audienceCount",
                  style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Dynamic Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: effectiveStatusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: effectiveStatusColor.withValues(alpha: 0.3), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5.5,
                  height: 5.5,
                  decoration: BoxDecoration(
                    color: effectiveStatusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                5.width,
                Text(
                  effectiveStatusText,
                  style: TS.caption(color: effectiveStatusColor, fontWeight: FontWeight.w700).copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Change Account Bottom Sheet Modal ──────────────────────────────────────
  void _showChangeAccountBottomSheet(
    BuildContext context,
    HomeController? homeController,
    List<ChannelOption> availableChannels,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CC.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: CC.stroke,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                16.height,
                Text(
                  "Select Connected Account",
                  style: TS.sectionTitle(color: CC.textPrimary, fontSize: 18),
                ),
                4.height,
                Text(
                  "Choose which connected channel to use for comparison.",
                  style: TS.caption(color: CC.textSecondary),
                ),
                16.height,

                if (availableChannels.isNotEmpty) ...[
                  ...availableChannels.map((ch) {
                    final isSelected = homeController?.selectedChannel.value?.id.toString() == ch.id.toString();
                    final isYt = ch.platform.toUpperCase() == 'YOUTUBE';
                    final displayHandle = ch.handle.startsWith('@') ? ch.handle : "@${ch.handle}";
                    final statusColor = ch.statusColor;
                    final statusText = ch.statusDisplay;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? CC.primary.withValues(alpha: 0.08) : CC.searchBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? CC.primary : CC.stroke.withValues(alpha: 0.4),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isYt
                                ? const Color(0xFFFF0000).withValues(alpha: 0.08)
                                : const Color(0xFFE1306C).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isYt
                                  ? const Color(0xFFFF0000).withValues(alpha: 0.2)
                                  : const Color(0xFFE1306C).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: isYt ? CW.youtubeIcon(size: 20) : CW.instagramIcon(size: 20),
                          ),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                ch.name.isNotEmpty ? ch.name : displayHandle,
                                style: TS.bodySmall(
                                  color: CC.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            8.width,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  4.width,
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text("${ch.platform} • $displayHandle", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded, color: CC.primary, size: 22)
                            : null,
                        onTap: () {
                          Navigator.pop(ctx);
                          if (homeController != null) {
                            homeController.selectChannel(ch);
                          }
                        },
                      ),
                    );
                  }),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        "No connected accounts found.",
                        style: TS.caption(color: CC.textSecondary),
                      ),
                    ),
                  ),
                ],

                12.height,
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: CC.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(Icons.add_rounded, color: CC.primary, size: 18),
                    label: Text("Manage Connected Accounts", style: TS.bodySmall(color: CC.primary, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Get.to(() => const ConnectAccountsView());
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 5. Comparison Overview Card (Clean Metric Table) ──────────────────────
  Widget _buildComparisonOverviewCard({
    required bool isYouTube,
    required CompareCreatorModel data,
  }) {
    final audienceLabel = isYouTube ? "Subscribers" : "Followers";
    final contentLabel = "Total Content";

    final you = data.you;
    final them = data.competitor;

    final homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

    final youSubscribersFormatted = you.subscribers != null
        ? _formatMetric(you.subscribers, isCount: true)
        : (homeController?.subscribersCount.value.isNotEmpty == true
            ? homeController!.subscribersCount.value
            : "N/A");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Comparison Overview",
                style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16),
              ),
              if (you.sampleSize != null && you.sampleWindowDays != null)
                Tooltip(
                  message: "Calculated based on the last ${you.sampleSize} posts over ${you.sampleWindowDays} days.",
                  child: Icon(Icons.info_outline_rounded, size: 18, color: CC.textSecondary),
                ),
            ],
          ),
          18.height,

          // Table Header:  You    Them
          Row(
            children: [
              Expanded(
                flex: 4,
                child: const SizedBox.shrink(),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "You",
                  textAlign: TextAlign.center,
                  style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 13),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Them",
                  textAlign: TextAlign.center,
                  style: TS.caption(color: CC.textSecondary, fontWeight: FontWeight.w700).copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
          10.height,
          Divider(color: CC.stroke.withValues(alpha: 0.5), height: 1),
          12.height,

          // Table Row 1: Followers / Subscribers
          _buildTableRow(audienceLabel, youSubscribersFormatted, _formatMetric(them.subscribers, isCount: true), them.dataStatus),
          12.height,
          Divider(color: CC.stroke.withValues(alpha: 0.3), height: 1),
          12.height,

          // Table Row 2: Total Content
          _buildTableRow(contentLabel, _formatMetric(you.totalContent, isCount: true), _formatMetric(them.totalContent, isCount: true), them.dataStatus),
          12.height,
          Divider(color: CC.stroke.withValues(alpha: 0.3), height: 1),
          12.height,

          // Table Row 3: Avg. Views
          _buildTableRow("Avg. Views", _formatMetric(you.avgViews), _formatMetric(them.avgViews), them.dataStatus),
          12.height,
          Divider(color: CC.stroke.withValues(alpha: 0.3), height: 1),
          12.height,

          // Table Row 4: Avg. Likes
          _buildTableRow("Avg. Likes", _formatMetric(you.avgLikes), _formatMetric(them.avgLikes), them.dataStatus),
          12.height,
          Divider(color: CC.stroke.withValues(alpha: 0.3), height: 1),
          12.height,

          // Table Row 5: Posting Frequency
          _buildTableRow(
              "Posting Frequency", 
              _formatMetric(you.postingFrequencyPerWeek, isFrequency: true), 
              _formatMetric(them.postingFrequencyPerWeek, isFrequency: true),
              them.dataStatus),
          
          if (them.dataStatus == 'UNAVAILABLE') ...[
            16.height,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 0.8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Colors.amber),
                  8.width,
                  Expanded(
                    child: Text(
                      "Competitor metrics are unavailable or private. Make sure the channel is public and contains recent uploaded videos.",
                      style: TS.caption(color: CC.textPrimary).copyWith(fontSize: 11.5, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (them.dataStatus == 'PARTIAL') ...[
            16.height,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 0.8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.amber),
                  8.width,
                  Expanded(
                    child: Text(
                      "Some competitor metrics are hidden or private on this creator's channel.",
                      style: TS.caption(color: CC.textPrimary).copyWith(fontSize: 11.5, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatMetric(dynamic value, {bool isCount = false, bool isFrequency = false}) {
    if (value == null) return "N/A";
    if (value is num) {
      if (isFrequency) {
        return "${value.formatDecimal}/week";
      }
      if (isCount) {
        if (value >= 1000) return value.formatK;
        return value.toInt().toString();
      }
      if (value >= 1000) return value.formatK;
      return value.formatDecimal;
    }
    final parsed = num.tryParse(value.toString());
    if (parsed != null) {
      return _formatMetric(parsed, isCount: isCount, isFrequency: isFrequency);
    }
    return value.toString();
  }

  Widget _buildTableRow(String label, String youValue, String themValue, String? themStatus) {
    final bool isThemNA = themValue == "N/A";
    
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600).copyWith(fontSize: 13),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            youValue,
            textAlign: TextAlign.center,
            style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w700).copyWith(fontSize: 13.5),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            themValue,
            textAlign: TextAlign.center,
            style: TS.bodySmall(
              color: isThemNA ? CC.grey : CC.textSecondary, 
              fontWeight: isThemNA ? FontWeight.w500 : FontWeight.w600,
            ).copyWith(fontSize: 13.5),
          ),
        ),
      ],
    );
  }

  // ── Comparison Loading Skeleton Placeholder ────────────────────────────────
  Widget _buildCompareSkeletonCard() {
    return SkeletonShimmer(
      child: SkeletonCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title & Info Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonBox(width: 170, height: 16, borderRadius: BorderRadius.all(Radius.circular(6))),
                SkeletonCircle(size: 18),
              ],
            ),
            18.height,

            // Table Header: You / Them
            Row(
              children: const [
                Expanded(flex: 4, child: SizedBox.shrink()),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: SkeletonBox(width: 40, height: 14, borderRadius: BorderRadius.all(Radius.circular(4))),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: SkeletonBox(width: 45, height: 14, borderRadius: BorderRadius.all(Radius.circular(4))),
                  ),
                ),
              ],
            ),
            10.height,
            Divider(color: CC.stroke.withValues(alpha: 0.5), height: 1),
            14.height,

            // Metric Rows
            for (int i = 0; i < 5; i++) ...[
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SkeletonBox(
                      width: [110.0, 90.0, 80.0, 80.0, 120.0][i],
                      height: 12,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: SkeletonBox(
                        width: [45.0, 35.0, 48.0, 42.0, 50.0][i],
                        height: 12,
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: SkeletonBox(
                        width: [48.0, 40.0, 52.0, 38.0, 46.0][i],
                        height: 12,
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                  ),
                ],
              ),
              if (i < 4) ...[
                12.height,
                Divider(color: CC.stroke.withValues(alpha: 0.3), height: 1),
                12.height,
              ],
            ],
          ],
        ),
      ),
    );
  }
}
