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

class _CompetitorViewState extends State<CompetitorView> with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  final CompetitorController controller = Get.put(CompetitorController());
  final FocusNode _focusNode = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  void _runComparison(int? accountId, String platformStr) {
    if (accountId == null) {
      CM.showToast('No connected account found. Please connect an account first.');
      return;
    }
    var query = _searchController.text.trim();
    if (query.isEmpty) {
      CM.showToast('Please enter a competitor handle or URL.');
      return;
    }

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
    super.build(context);
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
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

                final String? rawAudienceCount = homeController?.subscribersCount.value.isNotEmpty == true
                    ? homeController!.subscribersCount.value
                    : null;
                final String? audienceCount = rawAudienceCount != null
                    ? "$rawAudienceCount ${isYouTube ? 'subscribers' : 'followers'}"
                    : null;

                final bool isInputValid = _searchController.text.trim().isNotEmpty && activeChannel?.id != null;
                final bool isLoading = controller.isLoading.value;
                final bool isCompareEnabled = isInputValid && !isLoading;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. TITLE & SUBTITLE ─────────────────────────────────
                    Text(
                      "Compare With Another Creator",
                      style: TS.sectionTitle(color: CC.textPrimary, fontSize: 17),
                    ),
                    3.height,
                    Text(
                      "Compare another creator with your connected account.",
                      style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12.5),
                    ),
                    18.height,

                    // ── 2. YOUR ACCOUNT SECTION ─────────────────────────────
                    _buildSectionHeader("Your Account"),
                    8.height,
                    _buildAccountCard(
                      context: context,
                      creatorName: creatorName,
                      userHandle: userHandle,
                      platform: platformStr,
                      audienceCount: audienceCount,
                      statusColor: activeChannel?.statusColor,
                      statusText: activeChannel?.statusDisplay,
                      homeController: homeController,
                      channels: channels,
                    ),
                    20.height,

                    // ── 3. COMPETITOR INPUT SECTION ─────────────────────────
                    _buildSectionHeader("Competitor"),
                    8.height,
                    _buildSearchField(
                      activeChannelId: activeChannel?.id,
                      platformStr: platformStr,
                      isYouTube: isYouTube,
                    ),
                    18.height,

                    // ── 4. COMPARE BUTTON (DYNAMICALLY DISABLED) ────────────
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isCompareEnabled ? () => _runComparison(activeChannel?.id, platformStr) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CC.primary,
                          disabledBackgroundColor: CC.isDark ? const Color(0xFF1E242B) : const Color(0xFFE2E8F0),
                          foregroundColor: CC.whiteText,
                          disabledForegroundColor: CC.textSecondary.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(CC.whiteText),
                                    ),
                                  ),
                                  10.width,
                                  Text(
                                    "Comparing...",
                                    style: TS.bodySmall(color: CC.whiteText, fontWeight: FontWeight.w700).copyWith(fontSize: 14),
                                  ),
                                ],
                              )
                            : Text(
                                "Compare",
                                style: TS.bodySmall(
                                  color: isCompareEnabled ? CC.whiteText : CC.textSecondary.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w700,
                                ).copyWith(fontSize: 14),
                              ),
                      ),
                    ),
                    24.height,

                    // ── 5. COMPARISON OVERVIEW RESULTS ──────────────────────
                    Obx(() {
                      if (controller.isLoading.value) {
                        return _buildCompareSkeletonCard();
                      }
                      if (controller.errorMessage.isNotEmpty) {
                        return _buildErrorStateCard();
                      }
                      if (controller.compareData.value != null) {
                        return _buildComparisonOverviewCard(
                          isYouTube: isYouTube,
                          data: controller.compareData.value!,
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    80.height,
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TS.bodySmall(
        color: CC.textPrimary,
        fontWeight: FontWeight.w700,
      ).copyWith(fontSize: 13),
    );
  }

  // ── 1. Clean "Your Account" Card (No text clipping) ────────────────────────
  Widget _buildAccountCard({
    required BuildContext context,
    required String creatorName,
    required String userHandle,
    required String platform,
    String? audienceCount,
    Color? statusColor,
    String? statusText,
    HomeController? homeController,
    required List<ChannelOption> channels,
  }) {
    final bool isYt = platform.toUpperCase() == 'YOUTUBE';
    final Color effectiveStatusColor = statusColor ?? const Color(0xFF22C55E);
    final String effectiveStatusText = statusText ?? "Connected";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark ? CC.black.withValues(alpha: 0.3) : CC.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with Platform Icon Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CC.searchBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CC.stroke.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.person_rounded, color: CC.grey, size: 22),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: CC.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: CC.surface, width: 1.5),
                  ),
                  child: isYt ? CW.youtubeIcon(size: 13) : CW.instagramIcon(size: 13),
                ),
              ),
            ],
          ),
          12.width,

          // Account Details (Full Name Row + Handle & Status Row)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  creatorName,
                  style: TS.sectionTitle(color: CC.textPrimary, fontSize: 14.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                3.height,
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        audienceCount != null && audienceCount.trim().isNotEmpty
                            ? "$userHandle • $audienceCount"
                            : userHandle,
                        style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    6.width,
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: effectiveStatusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    4.width,
                    Text(
                      effectiveStatusText,
                      style: TS.caption(
                        color: effectiveStatusColor,
                        fontWeight: FontWeight.w600,
                      ).copyWith(fontSize: 10.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          8.width,

          // Change / Switch Account Button
          GestureDetector(
            onTap: () => _showChangeAccountBottomSheet(context, homeController, channels),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: CC.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CC.primary.withValues(alpha: 0.25), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz_rounded, size: 14, color: CC.primary),
                  4.width,
                  Text(
                    "Change",
                    style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Clean Competitor EditText Field ─────────────────────────────────────
  Widget _buildSearchField({
    required dynamic activeChannelId,
    required String platformStr,
    required bool isYouTube,
  }) {
    final borderSide = BorderSide(
      color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
      width: 1,
    );
    final borderRadius = BorderRadius.circular(14);

    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      onSubmitted: (_) => _runComparison(activeChannelId, platformStr),
      style: TS.bodySmall(color: CC.textPrimary).copyWith(fontSize: 13.5),
      textInputAction: TextInputAction.search,
      cursorColor: CC.primary,
      decoration: InputDecoration(
        filled: true,
        fillColor: CC.surface,
        isDense: true,
        hintText: "Enter handle or channel URL",
        hintStyle: TS.caption(color: CC.textSecondary.withValues(alpha: 0.65)).copyWith(fontSize: 13),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(Icons.search_rounded, size: 20, color: CC.grey),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.cancel_rounded, size: 18, color: CC.textSecondary),
                splashRadius: 18,
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: borderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: borderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: CC.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }

  // ── 3. Comparison Overview Card (Clean Metric Table) ───────────────────────
  Widget _buildComparisonOverviewCard({
    required bool isYouTube,
    required CompareCreatorModel data,
  }) {
    final audienceLabel = isYouTube ? "Subscribers" : "Followers";
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
            color: CC.isDark ? CC.black.withValues(alpha: 0.3) : CC.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Comparison Overview",
                style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15),
              ),
              if (you.sampleSize != null && you.sampleWindowDays != null)
                Tooltip(
                  message: "Calculated based on the last ${you.sampleSize} posts over ${you.sampleWindowDays} days.",
                  child: Icon(Icons.info_outline_rounded, size: 16, color: CC.textSecondary),
                ),
            ],
          ),
          14.height,

          // Table Header: You / Them
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
          Divider(color: CC.stroke.withValues(alpha: 0.4), height: 1),
          12.height,

          // Table Rows
          _buildTableRow(audienceLabel, youSubscribersFormatted, _formatMetric(them.subscribers, isCount: true), them.dataStatus),
          12.height,
          Divider(color: CC.stroke.withValues(alpha: 0.25), height: 1),
          12.height,

          _buildTableRow("Total Content", _formatMetric(you.totalContent, isCount: true), _formatMetric(them.totalContent, isCount: true), them.dataStatus),
          12.height,
          Divider(color: CC.stroke.withValues(alpha: 0.25), height: 1),
          12.height,

          _buildTableRow("Avg. Views", _formatMetric(you.avgViews), _formatMetric(them.avgViews), them.dataStatus),
          12.height,
          Divider(color: CC.stroke.withValues(alpha: 0.25), height: 1),
          12.height,

          _buildTableRow("Avg. Likes", _formatMetric(you.avgLikes), _formatMetric(them.avgLikes), them.dataStatus),
          12.height,
          Divider(color: CC.stroke.withValues(alpha: 0.25), height: 1),
          12.height,

          _buildTableRow(
            "Posting Frequency",
            _formatMetric(you.postingFrequencyPerWeek, isFrequency: true),
            _formatMetric(them.postingFrequencyPerWeek, isFrequency: true),
            them.dataStatus,
          ),

          if (them.dataStatus == 'UNAVAILABLE') ...[
            14.height,
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 0.8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 15, color: Colors.amber),
                  8.width,
                  Expanded(
                    child: Text(
                      "Competitor metrics are unavailable or private. Make sure the channel is public.",
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
            style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w700).copyWith(fontSize: 13),
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
            ).copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }

  // ── Error State Card ───────────────────────────────────────────────────────
  Widget _buildErrorStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CC.stroke.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: CC.error, size: 36),
          12.height,
          Text(
            "Couldn't Fetch Data",
            style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w700).copyWith(fontSize: 14),
          ),
          6.height,
          Text(
            controller.errorMessage.value,
            style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12, height: 1.35),
            textAlign: TextAlign.center,
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
                              child: Text(
                                statusText,
                                style: TS.caption(color: statusColor, fontWeight: FontWeight.w700).copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          displayHandle,
                          style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11.5),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded, color: CC.primary, size: 20)
                            : null,
                        onTap: () {
                          homeController?.selectChannel(ch);
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  }),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: CC.searchBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.link_off_rounded, size: 36, color: CC.grey),
                        10.height,
                        Text(
                          "No Connected Accounts Found",
                          style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600),
                        ),
                        4.height,
                        Text(
                          "Connect your YouTube or Instagram channel to start comparing.",
                          style: TS.caption(color: CC.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
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

  // ── Comparison Loading Skeleton Placeholder ────────────────────────────────
  Widget _buildCompareSkeletonCard() {
    return SkeletonShimmer(
      child: SkeletonCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonBox(width: 170, height: 16, borderRadius: BorderRadius.all(Radius.circular(6))),
                SkeletonCircle(size: 16),
              ],
            ),
            16.height,
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
            Divider(color: CC.stroke.withValues(alpha: 0.4), height: 1),
            12.height,
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
                10.height,
                Divider(color: CC.stroke.withValues(alpha: 0.25), height: 1),
                10.height,
              ],
            ],
          ],
        ),
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
}
