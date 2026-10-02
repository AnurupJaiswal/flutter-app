import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/calendar/controllers/calendar_controller.dart';
import 'package:lala_ai/app/modules/connect_accounts/views/connect_accounts_view.dart';
import 'package:lala_ai/app/modules/home/controllers/home_controller.dart';
import 'package:lala_ai/app/modules/profile/views/profile_view.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CalendarController>()) {
      Get.put(CalendarController());
    }

    return GetBuilder<ThemeService>(
      builder: (_) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            isNotHomepage: false,
            wantBackIcon: false,
            title: "Content Calendar",
            actions: [
              IconButton(
                icon: Icon(
                  Icons.person_outline_rounded,
                  color: CC.textPrimary,
                  size: 22,
                ),
                splashRadius: 20,
                onPressed: () => Get.to(() => const ProfileView()),
                tooltip: "Profile",
              ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                RefreshIndicator(
                  color: CC.primary,
                  onRefresh: () async => controller.fetchDrafts(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Channel / Account Selector Dropdown Pill ───────────
                        _buildChannelHeaderSection(context),
                        16.height,

                        // ── Month & Weekly Date Selector Strip ──────────────────
                        _buildMonthAndWeeklyStrip(context),
                        16.height,

                        // ── Filter Category Pills ───────────────────────────────
                        _buildFilterPills(),
                        18.height,

                        // ── Posts Section for Selected Date ─────────────────────
                        _buildSectionHeader(context),
                        12.height,

                        Obx(() {
                          if (controller.isLoading.value) {
                            return _buildLoadingSkeleton();
                          }
                          if (controller.errorMessage.value.isNotEmpty) {
                            return _buildErrorState(
                              controller.errorMessage.value,
                            );
                          }

                          final list = controller.filteredTodayPosts;
                          if (list.isEmpty) {
                            return _buildEmptyDateSection(context);
                          }
                          return Column(
                            children: list
                                .asMap()
                                .entries
                                .map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildPostCard(
                                      context: context,
                                      post: entry.value,
                                      index: entry.key,
                                      isToday: true,
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        }),
                        20.height,

                        // ── Upcoming & Drafts Section ───────────────────────────
                        _buildUpcomingSection(context),
                        90.height, // Spacing for floating action button
                      ],
                    ),
                  ),
                ),

                // ── Floating Action Button (New Post Draft) ─────────────────
                Positioned(
                  right: 16,
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () => _showCreateDraftSheet(context),
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: CC.primary,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: CC.primary.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            color: CC.whiteText,
                            size: 22,
                          ),
                          6.width,
                          Text(
                            "New Post",
                            style: TS
                                .bodySmall(
                                  color: CC.whiteText,
                                  fontWeight: FontWeight.w700,
                                )
                                .copyWith(fontSize: 14),
                          ),
                        ],
                      ),
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

  // ════════════════════════════════════════════════════════════════════════════
  // ── 1. ACCOUNT / CHANNEL SELECTOR (SAME AS HOME & ANALYTICS) ────────────────
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildChannelHeaderSection(BuildContext context) {
    return Obx(() {
      final current = controller.selectedChannel.value;
      final channels = controller.availableChannels;

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (channels.isNotEmpty)
            _buildChannelDropdownSelector(context, current)
          else
            GestureDetector(
              onTap: () => Get.to(() => const ConnectAccountsView()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CC.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_link_rounded,
                      size: 16,
                      color: CC.primary,
                    ),
                    6.width,
                    Text(
                      "Connect Channel",
                      style: TS
                          .caption(
                            color: CC.primary,
                            fontWeight: FontWeight.w700,
                          )
                          .copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildChannelDropdownSelector(
    BuildContext context,
    ChannelOption? current,
  ) {
    final isAll = current == null;
    final platform = current?.platform ?? 'YOUTUBE';
    final handle =
        current?.handle ??
        (platform == 'YOUTUBE' ? 'YouTube Channel' : 'Instagram Profile');
    final formattedHandle = isAll
        ? "All Channels"
        : (handle.startsWith('@') ? handle : "@$handle");
    final isYt = platform.toUpperCase() == 'YOUTUBE';
    final statusColor = current?.statusColor ?? const Color(0xFF22C55E);

    return GestureDetector(
      onTap: () => _showChannelSelectorBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: CC.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: CC.isDark
                  ? CC.black.withValues(alpha: 0.25)
                  : CC.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAll)
              Icon(Icons.grid_view_rounded, size: 16, color: CC.primary)
            else if (isYt)
              CW.youtubeIcon(size: 16)
            else
              CW.instagramIcon(size: 16),
            8.width,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                formattedHandle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TS
                    .caption(color: CC.textPrimary, fontWeight: FontWeight.w700)
                    .copyWith(fontSize: 12),
              ),
            ),
            if (!isAll) ...[
              6.width,
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            4.width,
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: CC.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Same exact channel selector bottom sheet used across the entire application
  void _showChannelSelectorBottomSheet(BuildContext context) {
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
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                      "Select Active Channel",
                      style: TS.sectionTitle(
                        color: CC.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                    4.height,
                    Text(
                      "Choose a channel to inspect its schedule, drafts, and calendar recommendations.",
                      style: TS.caption(color: CC.textSecondary),
                    ),
                    16.height,

                    // Connected Channel Options
                    Obx(() {
                      final channels = controller.availableChannels;
                      return Column(
                        children: channels.map((ch) {
                          final isSelected =
                              controller.selectedChannel.value?.id.toString() ==
                              ch.id.toString();
                          final isYt = ch.platform.toUpperCase() == 'YOUTUBE';
                          final displayHandle = ch.handle.startsWith('@')
                              ? ch.handle
                              : "@${ch.handle}";
                          final statusColor = ch.statusColor;
                          final statusText = ch.statusDisplay;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (CC.isDark
                                      ? CC.primary.withValues(alpha: 0.12)
                                      : CC.surface)
                                  : CC.searchBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? CC.primary
                                    : CC.stroke.withValues(alpha: 0.4),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              leading: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isYt
                                      ? const Color(0xFFFF0000).withValues(alpha: 0.08)
                                      : const Color(0xFFE1306C).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isYt
                                        ? const Color(0xFFFF0000).withValues(alpha: 0.2)
                                        : const Color(0xFFE1306C).withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: isYt
                                      ? CW.youtubeIcon(size: 22)
                                      : CW.instagramIcon(size: 22),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      ch.name.isNotEmpty
                                          ? ch.name
                                          : displayHandle,
                                      style: TS.bodySmall(
                                        color: CC.textPrimary,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  8.width,
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
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
                                child: Text(
                                  displayHandle,
                                  style: TS
                                      .caption(color: CC.textSecondary)
                                      .copyWith(fontSize: 11),
                                ),
                              ),
                              trailing: isSelected
                                  ? Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: CC.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    )
                                  : Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: CC.stroke.withValues(
                                            alpha: CC.isDark ? 0.4 : 0.7,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                              onTap: () {
                                Navigator.pop(ctx);
                                controller.selectChannel(ch);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }),

                    14.height,
                    // Link to connect new channel
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: CC.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(
                          Icons.add_rounded,
                          color: CC.primary,
                          size: 18,
                        ),
                        label: Text(
                          "Manage / Connect Channels",
                          style: TS.bodySmall(
                            color: CC.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Get.to(() => const ConnectAccountsView());
                        },
                      ),
                    ),
                    8.height,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ── 2. MONTH & HORIZONTAL DATE STRIP ────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildMonthAndWeeklyStrip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark
                ? CC.black.withValues(alpha: 0.3)
                : CC.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month navigation bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: CC.primary,
                ),
                6.width,
                Expanded(
                  child: Obx(
                    () => FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        controller.currentMonthName,
                        style: TS.sectionTitle(
                          color: CC.textPrimary,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                6.width,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Quick "Today" jump button
                    InkWell(
                      onTap: () => controller.jumpToToday(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CC.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: CC.primary.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          "Today",
                          style: TS
                              .caption(
                                color: CC.primary,
                                fontWeight: FontWeight.w700,
                              )
                              .copyWith(fontSize: 11),
                        ),
                      ),
                    ),
                    6.width,
                    InkWell(
                      onTap: () => controller.previousMonth(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: CC.isDark
                              ? CC.whiteText.withValues(alpha: 0.06)
                              : CC.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: CC.textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                    4.width,
                    InkWell(
                      onTap: () => controller.nextMonth(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: CC.isDark
                              ? CC.whiteText.withValues(alpha: 0.06)
                              : CC.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: CC.textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          12.height,

          // Days Horizontal Carousel Strip
          _buildMonthStripView(),
        ],
      ),
    );
  }

  Widget _buildMonthStripView() {
    return Obx(() {
      final days = controller.daysList;
      return SizedBox(
        height: 74,
        child: ListView.separated(
          controller: controller.scrollController,
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.antiAlias,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: days.length,
          separatorBuilder: (_, __) => 6.width,
          itemBuilder: (context, index) {
            final item = days[index];
            final dayStr = item["day"] as String;
            final dateNum = item["date"] as int;
            final fullDate = item["fullDate"] as DateTime;
            final isSelected = item["isSelected"] as bool;
            final hasDot = item["hasDot"] as bool;

            return GestureDetector(
              onTap: () => controller.selectDay(fullDate),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? CC.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? Border.all(color: CC.primary, width: 1.2)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayStr,
                      style: TS
                          .caption(
                            color: isSelected
                                ? CC.whiteText.withValues(alpha: 0.9)
                                : CC.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          )
                          .copyWith(fontSize: 11),
                    ),
                    4.height,
                    Text(
                      "$dateNum",
                      style: TS
                          .bodySmall(
                            color: isSelected
                                ? CC.whiteText
                                : CC.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          )
                          .copyWith(fontSize: 14),
                    ),
                    4.height,
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CC.whiteText
                            : (hasDot ? CC.primary : Colors.transparent),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ── 3. FILTER PILLS ─────────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildFilterPills() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.filterOptions.length,
        separatorBuilder: (_, __) => 8.width,
        itemBuilder: (context, index) {
          final label = controller.filterOptions[index];
          return Obx(() {
            final isSelected = controller.selectedFilter.value == label;

            return GestureDetector(
              onTap: () => controller.selectFilter(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? CC.primary : CC.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? CC.primary
                        : CC.stroke.withValues(alpha: 0.55),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: CC.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: CC.isDark
                                ? CC.black.withValues(alpha: 0.2)
                                : CC.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TS
                        .bodySmall(
                          color: isSelected ? CC.whiteText : CC.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        )
                        .copyWith(fontSize: 12),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ── 4. SECTION HEADER & POST CARD ───────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Obx(
              () => Text(
                "Posts for ${controller.selectedDateFormatted}",
                style: TS.sectionTitle(
                  color: CC.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        Obx(() {
          final count = controller.filteredTodayPosts.length;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: count > 0
                  ? CC.primary.withValues(alpha: 0.12)
                  : CC.stroke.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "$count post${count == 1 ? '' : 's'}",
              style: TS
                  .caption(
                    color: count > 0 ? CC.primary : CC.textSecondary,
                    fontWeight: FontWeight.w700,
                  )
                  .copyWith(fontSize: 11),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPostCard({
    required BuildContext context,
    required Map<String, dynamic> post,
    required int index,
    required bool isToday,
  }) {
    final id = post["id"];
    final title = post["title"] as String;
    final platform = post["platform"] as String;
    final platformTag = post["platformTag"] as String;
    final time = post["time"] as String;
    final aiTime = post["aiTime"] as String;
    final status = post["status"] as String;
    final isPosted = status == "Posted";
    final isScheduled = status == "Scheduled";

    return Container(
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
                ? CC.black.withValues(alpha: 0.35)
                : CC.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Platform & Status Badges
          Row(
            children: [
              _buildPlatformBadge(platform, platformTag),
              const Spacer(),

              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPosted
                      ? const Color(0xFFE8F5E9)
                      : (isScheduled
                          ? const Color(0xFFE3F2FD)
                          : (CC.isDark
                              ? CC.whiteText.withValues(alpha: 0.08)
                              : CC.black.withValues(alpha: 0.05))),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPosted
                          ? Icons.check_circle_rounded
                          : (isScheduled
                              ? Icons.alarm_on_rounded
                              : Icons.edit_note_rounded),
                      size: 13,
                      color: isPosted
                          ? const Color(0xFF2E7D32)
                          : (isScheduled
                              ? const Color(0xFF1976D2)
                              : CC.textSecondary),
                    ),
                    4.width,
                    Text(
                      status,
                      style: TS
                          .caption(
                            color: isPosted
                                ? const Color(0xFF2E7D32)
                                : (isScheduled
                                    ? const Color(0xFF1976D2)
                                    : CC.textSecondary),
                            fontWeight: FontWeight.w700,
                          )
                          .copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              6.width,

              // 3-Dots Action Options Menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: CC.textSecondary,
                  size: 18,
                ),
                color: CC.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (val) {
                  if (val == 'schedule') {
                    _pickScheduleDateTime(context, id);
                  } else if (val == 'mark_posted') {
                    controller.updateDraftStatus(draftId: id, status: 'POSTED');
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'schedule',
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: CC.primary,
                        ),
                        8.width,
                        Text(
                          "Schedule / Reschedule",
                          style: TS.bodySmall(color: CC.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  if (!isPosted)
                    PopupMenuItem(
                      value: 'mark_posted',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                            color: Colors.green,
                          ),
                          8.width,
                          Text(
                            "Mark as Posted",
                            style: TS.bodySmall(color: CC.textPrimary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          10.height,

          // Post Title
          Text(
            title,
            style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15),
          ),
          8.height,

          // Time Info Row
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: CC.textSecondary,
              ),
              4.width,
              Text(
                time,
                style: TS
                    .caption(color: CC.textSecondary)
                    .copyWith(fontSize: 12),
              ),
              if (aiTime.isNotEmpty) ...[
                12.width,
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 14,
                  color: CC.primary,
                ),
                4.width,
                Expanded(
                  child: Text(
                    aiTime,
                    style: TS
                        .caption(color: CC.primary, fontWeight: FontWeight.w700)
                        .copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          14.height,

          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => controller.copyEverything(context, post),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: CC.isDark
                          ? CC.whiteText.withValues(alpha: 0.06)
                          : CC.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: CC.stroke.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.content_copy_rounded,
                          size: 14,
                          color: CC.textPrimary,
                        ),
                        6.width,
                        Text(
                          "Copy Details",
                          style: TS
                              .bodySmall(
                                color: CC.textPrimary,
                                fontWeight: FontWeight.w600,
                              )
                              .copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isPosted) ...[
                10.width,
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (isScheduled) {
                        controller.updateDraftStatus(
                          draftId: id,
                          status: "POSTED",
                        );
                      } else {
                        _pickScheduleDateTime(context, id);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: CC.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isScheduled
                                ? Icons.check_rounded
                                : Icons.calendar_month_rounded,
                            size: 14,
                            color: CC.whiteText,
                          ),
                          6.width,
                          Text(
                            isScheduled ? "Mark as Posted" : "Schedule",
                            style: TS
                                .bodySmall(
                                  color: CC.whiteText,
                                  fontWeight: FontWeight.w700,
                                )
                                .copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformBadge(String platform, String platformTag) {
    final isYt = platform.toLowerCase().contains("youtube");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isYt
            ? const Color(0xFFFF0000).withValues(alpha: 0.08)
            : const Color(0xFFE1306C).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isYt
              ? const Color(0xFFFF0000).withValues(alpha: 0.2)
              : const Color(0xFFE1306C).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isYt ? CW.youtubeIcon(size: 14) : CW.instagramIcon(size: 14),
          6.width,
          Text(
            platformTag,
            style: TS
                .caption(
                  color: isYt ? const Color(0xFFD32F2F) : const Color(0xFFC2185B),
                  fontWeight: FontWeight.w700,
                )
                .copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ── 5. UPCOMING POSTS & EMPTY STATES ────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildUpcomingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Upcoming & Drafts",
              style: TS.sectionTitle(
                color: CC.textPrimary,
                fontSize: 16,
              ),
            ),
            Obx(() {
              final count = controller.filteredUpcomingPosts.length;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: count > 0
                      ? CC.primary.withValues(alpha: 0.12)
                      : CC.stroke.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$count post${count == 1 ? '' : 's'}",
                  style: TS
                      .caption(
                        color: count > 0 ? CC.primary : CC.textSecondary,
                        fontWeight: FontWeight.w700,
                      )
                      .copyWith(fontSize: 11),
                ),
              );
            }),
          ],
        ),
        12.height,
        Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingSkeleton();
          }

          final list = controller.filteredUpcomingPosts;
          if (list.isEmpty) {
            return _buildEmptySection(
              "No other upcoming posts or drafts for this filter",
            );
          }
          return Column(
            children: list
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPostCard(
                      context: context,
                      post: entry.value,
                      index: entry.key,
                      isToday: false,
                    ),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyDateSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.event_note_rounded,
                size: 26,
                color: CC.primary,
              ),
            ),
          ),
          12.height,
          Text(
            "No Posts Scheduled",
            style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15),
          ),
          4.height,
          Text(
            "You haven't scheduled any content for ${controller.selectedDateFormatted}",
            style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          14.height,
          InkWell(
            onTap: () => _showCreateDraftSheet(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: CC.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: CC.primary,
                  ),
                  6.width,
                  Text(
                    "Plan a Post for this day",
                    style: TS.bodySmall(
                      color: CC.primary,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 24,
                decoration: BoxDecoration(
                  color: CC.stroke.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: CC.stroke.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
          14.height,
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: CC.stroke.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          10.height,
          Container(
            height: 12,
            width: 180,
            decoration: BoxDecoration(
              color: CC.stroke.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: CC.error,
            size: 28,
          ),
          8.height,
          Text(
            error,
            style: TS.bodySmall(color: CC.error),
            textAlign: TextAlign.center,
          ),
          12.height,
          OutlinedButton(
            onPressed: () => controller.fetchDrafts(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: CC.primary),
            ),
            child: Text(
              "Retry",
              style: TS.bodySmall(color: CC.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ── 6. CREATE & SCHEDULE DRAFT BOTTOM SHEET ────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _pickScheduleDateTime(
    BuildContext context,
    dynamic draftId,
  ) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate == null) return;
    if (!context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 15),
    );

    if (pickedTime == null) return;

    final localDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    await controller.scheduleContentDraft(
      draftId: draftId,
      localScheduledAt: localDateTime,
    );
  }

  void _showCreateDraftSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final scriptCtrl = TextEditingController();
    String selectedContentType = 'SHORT'; // SHORT, LONG_FORM, REEL
    DateTime selectedScheduleDate = controller.selectedDate.value;
    TimeOfDay selectedScheduleTime = const TimeOfDay(hour: 18, minute: 15);
    ChannelOption? selectedAccount = controller.selectedChannel.value ??
        (controller.availableChannels.isNotEmpty
            ? controller.availableChannels.first
            : null);
    bool isSavingDraft = false;
    bool isScheduling = false;

    CW
        .showCustomBottomSheet(
          context: context,
          title: "New Post",
          titleIcon: Icons.edit_calendar_rounded,
          children: [
            StatefulBuilder(
              builder: (ctx, setModalState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Content Format",
                      style: TS.caption(
                        color: CC.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    6.height,
                    Row(
                      children: [
                        _buildTypeChip(
                          "Short",
                          "SHORT",
                          selectedContentType,
                          (val) =>
                              setModalState(() => selectedContentType = val),
                        ),
                        8.width,
                        _buildTypeChip(
                          "Reel",
                          "REEL",
                          selectedContentType,
                          (val) =>
                              setModalState(() => selectedContentType = val),
                        ),
                        8.width,
                        _buildTypeChip(
                          "Long-Form",
                          "LONG_FORM",
                          selectedContentType,
                          (val) =>
                              setModalState(() => selectedContentType = val),
                        ),
                      ],
                    ),
                    14.height,
                    CW.commonTextFormField(
                      controller: titleCtrl,
                      hintText: "Enter post title or concept...",
                      labelText: "Post Title",
                    ),
                    12.height,
                    CW.commonTextFormField(
                      controller: scriptCtrl,
                      hintText: "Enter script notes or hook context...",
                      labelText: "Script / Hook Notes (Optional)",
                    ),
                    16.height,
                    Text(
                      "Schedule Date & Time",
                      style: TS.caption(
                        color: CC.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    6.height,
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedScheduleDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(DateTime.now().year + 5),
                              );
                              if (picked != null) {
                                setModalState(
                                  () => selectedScheduleDate = picked,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: CC.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: CC.stroke.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    size: 16,
                                    color: CC.primary,
                                  ),
                                  8.width,
                                  Expanded(
                                    child: Text(
                                      "${selectedScheduleDate.day}/${selectedScheduleDate.month}/${selectedScheduleDate.year}",
                                      style: TS.bodySmall(
                                        color: CC.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedScheduleTime,
                              );
                              if (picked != null) {
                                setModalState(
                                  () => selectedScheduleTime = picked,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: CC.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: CC.stroke.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: CC.primary,
                                  ),
                                  8.width,
                                  Expanded(
                                    child: Text(
                                      selectedScheduleTime.format(context),
                                      style: TS.bodySmall(
                                        color: CC.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    20.height,
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: CC.stroke.withValues(alpha: 0.6),
                              ),
                            ),
                            onPressed: (isSavingDraft || isScheduling)
                                ? null
                                : () async {
                                    if (titleCtrl.text.trim().isEmpty) {
                                      AppToast.error(
                                        "Please enter a title for your draft.",
                                      );
                                      return;
                                    }
                                    setModalState(() => isSavingDraft = true);
                                    try {
                                      final success =
                                          await controller.createContentDraft(
                                        accountId: selectedAccount?.id,
                                        title: titleCtrl.text.trim(),
                                        contentType: selectedContentType,
                                        scriptData:
                                            scriptCtrl.text.trim().isNotEmpty
                                                ? scriptCtrl.text.trim()
                                                : null,
                                      );
                                      if (success) {
                                        if (ctx.mounted) {
                                          CW.dismissBottomSheet(ctx);
                                        }
                                      } else {
                                        if (ctx.mounted) {
                                          setModalState(
                                              () => isSavingDraft = false);
                                        }
                                      }
                                    } catch (_) {
                                      if (ctx.mounted) {
                                        setModalState(
                                            () => isSavingDraft = false);
                                      }
                                    }
                                  },
                            child: isSavingDraft
                                ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        CC.textPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    "Save as Draft",
                                    style: TS.bodySmall(
                                      color: CC.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: CW.commonBtn(
                            title: "Schedule",
                            isLoading: isScheduling,
                            onTap: (isSavingDraft || isScheduling)
                                ? null
                                : () async {
                                    if (titleCtrl.text.trim().isEmpty) {
                                      AppToast.error(
                                        "Please enter a title for your draft.",
                                      );
                                      return;
                                    }
                                    final localScheduledAt = DateTime(
                                      selectedScheduleDate.year,
                                      selectedScheduleDate.month,
                                      selectedScheduleDate.day,
                                      selectedScheduleTime.hour,
                                      selectedScheduleTime.minute,
                                    );
                                    setModalState(() => isScheduling = true);
                                    try {
                                      final success = await controller
                                          .createAndScheduleContentDraft(
                                        accountId: selectedAccount?.id,
                                        title: titleCtrl.text.trim(),
                                        contentType: selectedContentType,
                                        scriptData:
                                            scriptCtrl.text.trim().isNotEmpty
                                                ? scriptCtrl.text.trim()
                                                : null,
                                        localScheduledAt: localScheduledAt,
                                      );
                                      if (success) {
                                        if (ctx.mounted) {
                                          CW.dismissBottomSheet(ctx);
                                        }
                                      } else {
                                        if (ctx.mounted) {
                                          setModalState(
                                              () => isScheduling = false);
                                        }
                                      }
                                    } catch (_) {
                                      if (ctx.mounted) {
                                        setModalState(
                                            () => isScheduling = false);
                                      }
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        )
        .then((_) {
          titleCtrl.dispose();
          scriptCtrl.dispose();
        });
  }

  Widget _buildTypeChip(
    String label,
    String value,
    String selectedValue,
    ValueChanged<String> onSelect,
  ) {
    final isSelected = selectedValue == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? CC.primary : CC.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? CC.primary : CC.stroke,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TS
                  .bodySmall(
                    color: isSelected ? CC.whiteText : CC.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  )
                  .copyWith(fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}
