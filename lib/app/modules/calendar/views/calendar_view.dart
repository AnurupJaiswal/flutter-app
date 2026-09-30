import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/profile/views/profile_view.dart';
import 'package:lala_ai/app/modules/calendar/controllers/calendar_controller.dart';
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
                  Icons.refresh_rounded,
                  color: CC.textPrimary,
                  size: 22,
                ),
                splashRadius: 20,
                onPressed: () => controller.fetchDrafts(),
                tooltip: "Refresh Drafts",
              ),
              IconButton(
                icon: Icon(
                  Icons.person_outline_rounded,
                  color: CC.textPrimary,
                  size: 22,
                ),
                splashRadius: 20,
                onPressed: () => Get.to(() => const ProfileView()),
              ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Subtitle Description ───────────────────────────────
                      Text(
                        "Plan, manage and grow your content",
                        style: TS
                            .bodySmall(color: CC.textSecondary)
                            .copyWith(fontSize: 13),
                      ),
                      16.height,

                      // ── Month & Weekly Date Selector Strip ──────────────────
                      _buildMonthAndWeeklyStrip(context),
                      20.height,

                      // ── Filter Category Pills ───────────────────────────────
                      _buildFilterPills(),
                      20.height,

                      // ── Posts Section for Selected Date ─────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Obx(
                            () => Text(
                              "${controller.filteredTodayPosts.length} post",
                              style: TS.caption(
                                color: CC.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      10.height,

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
                          return _buildEmptySection(
                            "No scheduled posts for ${controller.selectedDateFormatted}",
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
                                    isToday: true,
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      }),
                      20.height,

                      // ── Upcoming & Drafts Section ───────────────────────────
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
                          Obx(
                            () => Text(
                              "${controller.filteredUpcomingPosts.length} posts",
                              style: TS.caption(
                                color: CC.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      10.height,
                      Obx(() {
                        if (controller.isLoading.value) {
                          return _buildLoadingSkeleton();
                        }

                        final list = controller.filteredUpcomingPosts;
                        if (list.isEmpty) {
                          return _buildEmptySection(
                            "No upcoming posts for this filter",
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
                      100.height, // Spacing for floating action button
                    ],
                  ),
                ),

                // ── Floating Action Button (New Post Draft) ─────────────────
                Positioned(
                  right: 16,
                  bottom: 24,
                  child: GestureDetector(
                    onTap: () => _showCreateDraftSheet(context),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: CC.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: CC.isDark
                                ? CC.black.withValues(alpha: 0.45)
                                : CC.black.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_rounded,
                          color: CC.whiteText,
                          size: 30,
                        ),
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

  /// Month Header & Day Selector
  Widget _buildMonthAndWeeklyStrip(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        clipBehavior: Clip.antiAlias,
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
                  ? CC.black.withValues(alpha: 0.3)
                  : CC.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Month navigation title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: CC.textPrimary,
                      size: 22,
                    ),
                    onPressed: () => controller.previousMonth(),
                    splashRadius: 18,
                    tooltip: "Previous Month",
                  ),
                  Obx(
                    () => Text(
                      controller.currentMonthName,
                      style: TS.sectionTitle(
                        color: CC.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: CC.textPrimary,
                      size: 22,
                    ),
                    onPressed: () => controller.nextMonth(),
                    splashRadius: 18,
                    tooltip: "Next Month",
                  ),
                ],
              ),
            ),
            8.height,

            // Days Container
            _buildMonthStripView(),
          ],
        ),
      ),
    );
  }

  /// Horizontal Scrollable Month Strip
  Widget _buildMonthStripView() {
    return Obx(() {
      final days = controller.daysList;
      return SizedBox(
        height: 76,
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
            final dotColorType = item["dotColor"] as String;

            Color dotColor = CC.primary;
            if (dotColorType == "amber") {
              dotColor = Colors.amber;
            }

            return GestureDetector(
              onTap: () => controller.selectDay(fullDate),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CC.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
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
                            color: isSelected ? CC.primary : CC.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          )
                          .copyWith(fontSize: 11),
                    ),
                    3.height,
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isSelected ? CC.primary : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "$dateNum",
                          style: TS
                              .bodySmall(
                                color: isSelected
                                    ? CC.whiteText
                                    : CC.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              )
                              .copyWith(fontSize: 13),
                        ),
                      ),
                    ),
                    2.height,
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CC.primary
                            : (hasDot ? dotColor : Colors.transparent),
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

  /// Filter Category Pills
  Widget _buildFilterPills() {
    return SizedBox(
      height: 38,
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
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? CC.primary : CC.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? CC.primary
                        : CC.stroke.withValues(alpha: 0.6),
                    width: 1,
                  ),
                  boxShadow: !isSelected
                      ? [
                          BoxShadow(
                            color: CC.isDark
                                ? CC.black.withValues(alpha: 0.2)
                                : CC.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
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
                        .copyWith(fontSize: 13),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  /// Post Card Component
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
    final aiIconType = post["aiIconType"] as String? ?? "sparkle";
    final status = post["status"] as String;

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
              _buildPlatformIcon(platform),
              8.width,

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: platform == "YouTube" || platform == "Instagram"
                      ? const Color(0xFFFDE8EC)
                      : (CC.isDark
                            ? CC.whiteText.withValues(alpha: 0.08)
                            : CC.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  platformTag,
                  style: TS
                      .caption(
                        color: platform == "YouTube" || platform == "Instagram"
                            ? const Color(0xFFD81B60)
                            : CC.textPrimary,
                        fontWeight: FontWeight.w600,
                      )
                      .copyWith(fontSize: 11),
                ),
              ),
              const Spacer(),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status == "Scheduled" || status == "Posted"
                      ? const Color(0xFFE8F5E9)
                      : (CC.isDark
                            ? CC.whiteText.withValues(alpha: 0.08)
                            : CC.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      status == "Scheduled" || status == "Posted"
                          ? Icons.check_circle_outline_rounded
                          : Icons.description_outlined,
                      size: 13,
                      color: status == "Scheduled" || status == "Posted"
                          ? const Color(0xFF2E7D32)
                          : CC.textSecondary,
                    ),
                    4.width,
                    Text(
                      status,
                      style: TS
                          .caption(
                            color: status == "Scheduled" || status == "Posted"
                                ? const Color(0xFF2E7D32)
                                : CC.textSecondary,
                            fontWeight: FontWeight.w600,
                          )
                          .copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              6.width,

              // Action Options Menu
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
                  } else if (val == 'revert_draft') {
                    controller.updateDraftStatus(draftId: id, status: 'DRAFT');
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
                          "Schedule Post",
                          style: TS.bodySmall(color: CC.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  if (status != "Posted")
                    PopupMenuItem(
                      value: 'mark_posted',
                      child: Row(
                        children: [
                          Icon(
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
                  if (status == "Scheduled" || status == "Posted")
                    PopupMenuItem(
                      value: 'revert_draft',
                      child: Row(
                        children: [
                          Icon(
                            Icons.undo_rounded,
                            size: 16,
                            color: CC.textSecondary,
                          ),
                          8.width,
                          Text(
                            "Revert to Draft",
                            style: TS.bodySmall(color: CC.textPrimary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          12.height,

          Text(
            title,
            style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15),
          ),
          8.height,

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
              12.width,
              Icon(
                aiIconType == "chart"
                    ? Icons.bar_chart_rounded
                    : Icons.schedule_rounded,
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
          ),
          14.height,

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => controller.copyEverything(context, post),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: CC.isDark
                          ? CC.whiteText.withValues(alpha: 0.06)
                          : CC.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.content_copy_rounded,
                          size: 15,
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
              10.width,
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (status == "Posted") {
                      controller.updateDraftStatus(
                        draftId: id,
                        status: "DRAFT",
                      );
                    } else {
                      controller.updateDraftStatus(
                        draftId: id,
                        status: "POSTED",
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: status == "Posted" ? CC.darkPopUpBack : CC.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          status == "Posted"
                              ? Icons.undo_rounded
                              : Icons.near_me_rounded,
                          size: 15,
                          color: status == "Posted"
                              ? CC.textPrimary
                              : CC.whiteText,
                        ),
                        6.width,
                        Text(
                          status == "Posted"
                              ? "Revert to Draft"
                              : "Mark as Posted",
                          style: TS
                              .bodySmall(
                                color: status == "Posted"
                                    ? CC.textPrimary
                                    : CC.whiteText,
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
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformIcon(String platform) {
    if (platform.toLowerCase().contains("youtube")) {
      return CW.youtubeIcon(size: 26);
    } else {
      return CW.instagramIcon(size: 26);
    }
  }

  Widget _buildEmptySection(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          message,
          style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 13),
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
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: CC.stroke,
                  shape: BoxShape.circle,
                ),
              ),
              12.width,
              Expanded(child: Container(height: 16, color: CC.stroke)),
            ],
          ),
          12.height,
          Container(height: 12, width: double.infinity, color: CC.stroke),
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
          Text(error, style: TS.bodySmall(color: CC.error)),
          12.height,
          OutlinedButton(
            onPressed: () => controller.fetchDrafts(),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickScheduleDateTime(
    BuildContext context,
    dynamic draftId,
  ) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value.isBefore(now)
          ? now
          : controller.selectedDate.value,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
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
    final now = DateTime.now();
    DateTime selectedScheduleDate = controller.selectedDate.value.isBefore(now)
        ? now
        : controller.selectedDate.value;
    TimeOfDay selectedScheduleTime = const TimeOfDay(hour: 18, minute: 15);

    CW
        .showCustomBottomSheet(
          context: context,
          title: "Create & Schedule Post",
          titleIcon: Icons.edit_calendar_rounded,
          children: [
            StatefulBuilder(
              builder: (ctx, setModalState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Content Type",
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
                    16.height,
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
                                firstDate: DateTime.now(),
                                lastDate: DateTime(DateTime.now().year + 2),
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
                    10.height,
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 14,
                          color: CC.primary,
                        ),
                        6.width,
                        Text(
                          "Pixo AI Peak Engagement: 6:15 PM",
                          style: TS.caption(
                            color: CC.primary,
                            fontWeight: FontWeight.w600,
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
                            onPressed: () async {
                              if (titleCtrl.text.trim().isEmpty) {
                                AppToast.error(
                                  "Please enter a title for your draft.",
                                );
                                return;
                              }
                              CW.dismissBottomSheet();
                              await controller.createContentDraft(
                                title: titleCtrl.text.trim(),
                                contentType: selectedContentType,
                                scriptData: scriptCtrl.text.trim().isNotEmpty
                                    ? scriptCtrl.text.trim()
                                    : null,
                              );
                            },
                            child: Text(
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
                            title: "Schedule Post",
                            onTap: () async {
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
                              CW.dismissBottomSheet();
                              await controller.createAndScheduleContentDraft(
                                title: titleCtrl.text.trim(),
                                contentType: selectedContentType,
                                scriptData: scriptCtrl.text.trim().isNotEmpty
                                    ? scriptCtrl.text.trim()
                                    : null,
                                localScheduledAt: localScheduledAt,
                              );
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
