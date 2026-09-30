import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/content_draft_model.dart';
import 'package:lala_ai/app/data/repositories/calendar_repository.dart';
import 'package:lala_ai/app/modules/home/controllers/home_controller.dart';
import 'package:lala_ai/utils/app_toast.dart';

class CalendarController extends GetxController {
  final CalendarRepository calendarRepository;

  CalendarController({CalendarRepository? calendarRepository})
    : calendarRepository = calendarRepository ?? ApiCalendarRepository();

  final isGridView = false.obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = "".obs;

  final availableChannels = <ChannelOption>[].obs;
  final selectedChannel = Rxn<ChannelOption>();

  static DateTime get _todayDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Real DateTime tracking initialized to today's date
  late final selectedDate = Rx<DateTime>(_todayDate);
  late final currentDisplayMonth = Rx<DateTime>(
    DateTime(_todayDate.year, _todayDate.month, 1),
  );
  final selectedFilter = "All Posts".obs;

  final filterOptions = const [
    "All Posts",
    "Scheduled",
    "Drafts",
    "YouTube",
    "Instagram",
  ];

  static const _monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  String get currentMonthName {
    final d = currentDisplayMonth.value;
    return "${_monthNames[d.month - 1]} ${d.year}";
  }

  String get selectedDateFormatted {
    final d = selectedDate.value;
    return "${_monthNames[d.month - 1]} ${d.day}";
  }

  bool get isCurrentMonthSelected {
    final now = DateTime.now();
    final d = currentDisplayMonth.value;
    return d.year == now.year && d.month == now.month;
  }

  final serverDrafts = <ContentDraftModel>[].obs;
  final allPosts = <Map<String, dynamic>>[].obs;

  bool _hasPostOnDate(DateTime date) {
    return allPosts.any((p) {
      final d = p["date"] as DateTime?;
      return d != null &&
          d.year == date.year &&
          d.month == date.month &&
          d.day == date.day;
    });
  }

  // Dynamic days calculation for all days of the current display month
  List<Map<String, dynamic>> get daysList {
    final dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    final displayMonth = currentDisplayMonth.value;
    final totalDays = DateUtils.getDaysInMonth(
      displayMonth.year,
      displayMonth.month,
    );

    return List.generate(totalDays, (i) {
      final dayNum = i + 1;
      final date = DateTime(displayMonth.year, displayMonth.month, dayNum);
      final isSelected =
          date.year == selectedDate.value.year &&
          date.month == selectedDate.value.month &&
          date.day == selectedDate.value.day;
      final isToday =
          date.year == _todayDate.year &&
          date.month == _todayDate.month &&
          date.day == _todayDate.day;
      final hasPost = _hasPostOnDate(date);

      return {
        "day": dayNames[date.weekday % 7],
        "date": date.day,
        "fullDate": date,
        "isSelected": isSelected,
        "isToday": isToday,
        "hasDot": hasPost,
        "dotColor": "teal",
      };
    });
  }

  List<Map<String, dynamic>> get todayPosts {
    final selDate = selectedDate.value;
    return allPosts.where((p) {
      final d = p["date"] as DateTime?;
      return d != null &&
          d.year == selDate.year &&
          d.month == selDate.month &&
          d.day == selDate.day;
    }).toList();
  }

  List<Map<String, dynamic>> get upcomingPosts {
    final selDate = selectedDate.value;
    return allPosts.where((p) {
      final d = p["date"] as DateTime?;
      if (d == null) return true;
      return d.year != selDate.year ||
          d.month != selDate.month ||
          d.day != selDate.day;
    }).toList();
  }

  List<Map<String, dynamic>> get filteredTodayPosts {
    final filter = selectedFilter.value;
    return todayPosts.where((post) {
      if (filter == "All Posts") return true;
      if (filter == "Scheduled") return post["status"] == "Scheduled";
      if (filter == "Drafts") return post["status"] == "Draft";
      if (filter == "YouTube") return post["platform"] == "YouTube";
      if (filter == "Instagram") return post["platform"] == "Instagram";
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> get filteredUpcomingPosts {
    final filter = selectedFilter.value;
    return upcomingPosts.where((post) {
      if (filter == "All Posts") return true;
      if (filter == "Scheduled") return post["status"] == "Scheduled";
      if (filter == "Drafts") return post["status"] == "Draft";
      if (filter == "YouTube") return post["platform"] == "YouTube";
      if (filter == "Instagram") return post["platform"] == "Instagram";
      return true;
    }).toList();
  }

  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _initChannels();
    fetchDrafts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToSelectedDate(animate: false);
    });
  }

  void _initChannels() {
    if (Get.isRegistered<HomeController>()) {
      final homeCtrl = Get.find<HomeController>();
      if (homeCtrl.availableChannels.isNotEmpty) {
        availableChannels.assignAll(homeCtrl.availableChannels);
        selectedChannel.value = homeCtrl.selectedChannel.value;
      }
      // Listen to channel changes from HomeController if any
      ever(homeCtrl.availableChannels, (channels) {
        availableChannels.assignAll(channels);
      });
    }
  }

  void selectChannel(ChannelOption? channel) {
    selectedChannel.value = channel;
    fetchDrafts();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  /// 1. Fetch Drafts from backend API strictly with date range & filter query parameters
  Future<void> fetchDrafts() async {
    isLoading.value = true;
    errorMessage.value = "";
    try {
      dynamic accountId = selectedChannel.value?.id;
      if (accountId == null && Get.isRegistered<HomeController>()) {
        accountId = Get.find<HomeController>().activeConnectedAccountId.value;
      }

      final monthDate = currentDisplayMonth.value;
      final startDate = DateTime(monthDate.year, monthDate.month, 1, 0, 0, 0);
      final totalDays = DateUtils.getDaysInMonth(
        monthDate.year,
        monthDate.month,
      );
      final endDate = DateTime(
        monthDate.year,
        monthDate.month,
        totalDays,
        23,
        59,
        59,
      );

      String? statusFilter;
      String? contentTypeFilter;
      final filter = selectedFilter.value;

      if (filter == "Scheduled") statusFilter = "SCHEDULED";
      if (filter == "Drafts") statusFilter = "DRAFT";
      if (filter == "YouTube") contentTypeFilter = "SHORT";
      if (filter == "Instagram") contentTypeFilter = "REEL";

      final res = await calendarRepository.getDrafts(
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
        year: monthDate.year,
        month: monthDate.month,
        status: statusFilter,
        contentType: contentTypeFilter,
        limit: 100,
      );

      if (res.isSuccess) {
        final fetched = res.data ?? [];
        serverDrafts.assignAll(fetched);
        final mapped = fetched.map((d) => _convertDraftToPostMap(d)).toList();
        allPosts.assignAll(mapped);
      } else {
        errorMessage.value = res.message.isNotEmpty
            ? res.message
            : "Failed to load content drafts.";
        allPosts.clear();
      }
    } catch (e) {
      debugPrint("CalendarController fetchDrafts error: $e");
      errorMessage.value = "Failed to load content drafts: $e";
      allPosts.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _convertDraftToPostMap(ContentDraftModel d) {
    final date = d.scheduledAt ?? DateTime.now();
    String formattedTime = d.scheduledAt != null
        ? "${_monthNames[date.month - 1]} ${date.day}, ${date.year} at ${date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour)}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}"
        : "Draft (Not Scheduled)";

    return {
      "id": d.id,
      "title": d.title,
      "platform": d.platform,
      "platformTag": d.platformTag,
      "time": formattedTime,
      "aiTime": "AI Suggested Peak Time",
      "aiIconType": "sparkle",
      "status": d.statusDisplay,
      "date": date,
      "caption": d.scriptData ?? "${d.title} — Created with Lala AI!",
      "hashtags": "#LalaAI #AITools #${d.contentType} #ContentCreator",
      "rawModel": d,
    };
  }

  /// 2. Create a Content Draft via API (Only adds item & shows success toast if server call succeeds!)
  Future<bool> createContentDraft({
    required String title,
    required String contentType, // SHORT, LONG_FORM, REEL
    String? scriptData,
    dynamic copilotPlanId,
    dynamic accountId,
  }) async {
    isSubmitting.value = true;
    try {
      dynamic effectiveAccountId = accountId;
      if (effectiveAccountId == null && Get.isRegistered<HomeController>()) {
        effectiveAccountId =
            Get.find<HomeController>().activeConnectedAccountId.value;
      }

      final res = await calendarRepository.createDraft(
        accountId: effectiveAccountId,
        title: title,
        contentType: contentType,
        scriptData: scriptData,
        copilotPlanId: copilotPlanId,
      );

      if (res.isSuccess && res.data != null) {
        final created = res.data!;
        serverDrafts.add(created);
        allPosts.add(_convertDraftToPostMap(created));
        allPosts.refresh();
        AppToast.success("Content draft created!");
        return true;
      } else {
        // DO NOT add mock data! Show exact server error message!
        final errorMsg = res.message.isNotEmpty
            ? res.message
            : "Failed to create post draft.";
        AppToast.error(errorMsg);
        return false;
      }
    } catch (e) {
      debugPrint("createContentDraft error: $e");
      AppToast.error("Error creating post draft: $e");
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 2b. Create and Schedule a Content Draft directly via API
  Future<bool> createAndScheduleContentDraft({
    required String title,
    required String contentType, // SHORT, LONG_FORM, REEL
    String? scriptData,
    dynamic copilotPlanId,
    dynamic accountId,
    required DateTime localScheduledAt,
  }) async {
    isSubmitting.value = true;
    try {
      dynamic effectiveAccountId = accountId;
      if (effectiveAccountId == null && Get.isRegistered<HomeController>()) {
        effectiveAccountId =
            Get.find<HomeController>().activeConnectedAccountId.value;
      }

      // Step 1: Create draft via API
      final res = await calendarRepository.createDraft(
        accountId: effectiveAccountId,
        title: title,
        contentType: contentType,
        scriptData: scriptData,
        copilotPlanId: copilotPlanId,
      );

      if (!res.isSuccess || res.data == null) {
        final errorMsg = res.message.isNotEmpty
            ? res.message
            : "Failed to create post draft.";
        AppToast.error(errorMsg);
        return false;
      }

      final createdDraft = res.data!;

      // Step 2: Schedule the created draft via API
      final schedRes = await calendarRepository.scheduleDraft(
        draftId: createdDraft.id,
        scheduledAt: localScheduledAt,
      );

      if (schedRes.isSuccess && schedRes.data != null) {
        final scheduledDraft = schedRes.data!;
        serverDrafts.add(scheduledDraft);
        allPosts.add(_convertDraftToPostMap(scheduledDraft));
        allPosts.refresh();

        final formattedTime =
            "${_monthNames[localScheduledAt.month - 1]} ${localScheduledAt.day} at ${localScheduledAt.hour > 12 ? localScheduledAt.hour - 12 : (localScheduledAt.hour == 0 ? 12 : localScheduledAt.hour)}:${localScheduledAt.minute.toString().padLeft(2, '0')} ${localScheduledAt.hour >= 12 ? 'PM' : 'AM'}";
        AppToast.success("Post created & scheduled for $formattedTime!");
        return true;
      } else {
        // Draft created, but scheduling failed
        serverDrafts.add(createdDraft);
        allPosts.add(_convertDraftToPostMap(createdDraft));
        allPosts.refresh();

        final errorMsg = schedRes.message.isNotEmpty
            ? schedRes.message
            : "Draft saved, but failed to schedule post.";
        AppToast.error(errorMsg);
        return false;
      }
    } catch (e) {
      debugPrint("createAndScheduleContentDraft error: $e");
      AppToast.error("Error creating and scheduling post: $e");
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 3. Schedule a Draft for a specific Local DateTime (Only updates state & shows toast if server call succeeds!)
  Future<bool> scheduleContentDraft({
    required dynamic draftId,
    required DateTime localScheduledAt,
  }) async {
    isSubmitting.value = true;
    try {
      final res = await calendarRepository.scheduleDraft(
        draftId: draftId,
        scheduledAt: localScheduledAt,
      );

      if (res.isSuccess && res.data != null) {
        final updated = res.data!;
        final index = allPosts.indexWhere(
          (p) => p["id"].toString() == draftId.toString(),
        );
        if (index != -1) {
          allPosts[index] = _convertDraftToPostMap(updated);
          allPosts.refresh();
        }
        AppToast.success(
          "Post scheduled for ${_monthNames[localScheduledAt.month - 1]} ${localScheduledAt.day} at ${localScheduledAt.hour}:${localScheduledAt.minute.toString().padLeft(2, '0')}",
        );
        return true;
      } else {
        final errorMsg = res.message.isNotEmpty
            ? res.message
            : "Failed to schedule post.";
        AppToast.error(errorMsg);
        return false;
      }
    } catch (e) {
      debugPrint("scheduleContentDraft error: $e");
      AppToast.error("Error scheduling post: $e");
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 4. Update Calendar Status (Only updates state & shows toast if server call succeeds!)
  Future<bool> updateDraftStatus({
    required dynamic draftId,
    required String status, // POSTED or DRAFT
  }) async {
    isSubmitting.value = true;
    try {
      final res = await calendarRepository.updateDraftStatus(
        draftId: draftId,
        status: status,
      );

      if (res.isSuccess && res.data != null) {
        final updated = res.data!;
        final index = allPosts.indexWhere(
          (p) => p["id"].toString() == draftId.toString(),
        );
        if (index != -1) {
          allPosts[index] = _convertDraftToPostMap(updated);
          allPosts.refresh();
        }
        if (status.toUpperCase() == 'POSTED') {
          AppToast.success("Marked as Posted!");
        } else {
          AppToast.info("Reverted to Draft (unscheduled)");
        }
        return true;
      } else {
        final errorMsg = res.message.isNotEmpty
            ? res.message
            : "Failed to update draft status.";
        AppToast.error(errorMsg);
        return false;
      }
    } catch (e) {
      debugPrint("updateDraftStatus error: $e");
      AppToast.error("Error updating status: $e");
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void scrollToSelectedDate({bool animate = true}) {
    if (!scrollController.hasClients) return;
    final dayIndex = selectedDate.value.day - 1;
    final targetOffset = (dayIndex * 50.0 - 60.0).clamp(
      0.0,
      scrollController.position.maxScrollExtent,
    );
    if (animate) {
      scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    } else {
      scrollController.jumpTo(targetOffset);
    }
  }

  void jumpToToday() {
    final now = _todayDate;
    final isDifferentMonth = currentDisplayMonth.value.year != now.year ||
        currentDisplayMonth.value.month != now.month;
    currentDisplayMonth.value = DateTime(now.year, now.month, 1);
    selectedDate.value = now;
    scrollToSelectedDate(animate: true);
    if (isDifferentMonth) {
      fetchDrafts();
    }
  }

  void previousMonth() {
    final curr = currentDisplayMonth.value;
    final prev = DateTime(curr.year, curr.month - 1, 1);
    currentDisplayMonth.value = prev;
    selectedDate.value = DateTime(prev.year, prev.month, 1);
    scrollToSelectedDate(animate: true);
    fetchDrafts();
  }

  void nextMonth() {
    final curr = currentDisplayMonth.value;
    final next = DateTime(curr.year, curr.month + 1, 1);
    currentDisplayMonth.value = next;
    selectedDate.value = DateTime(next.year, next.month, 1);
    scrollToSelectedDate(animate: true);
    fetchDrafts();
  }

  void selectDay(DateTime date) {
    final prevMonth = currentDisplayMonth.value.month;
    selectedDate.value = date;
    currentDisplayMonth.value = DateTime(date.year, date.month, 1);
    scrollToSelectedDate(animate: true);
    if (prevMonth != date.month) {
      fetchDrafts();
    }
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
    fetchDrafts();
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  /// Copy Everything action: Copies full structured title, time, caption & hashtags to Clipboard
  void copyEverything(BuildContext context, Map<String, dynamic> post) {
    final title = post["title"] ?? "";
    final platformTag = post["platformTag"] ?? "";
    final time = post["time"] ?? "";
    final aiTime = post["aiTime"] ?? "";
    final caption =
        post["caption"] ??
        "Here are top insights & actionable prompts for creators to save hours every week using Lala AI!";
    final hashtags =
        post["hashtags"] ??
        "#LalaAI #AIForCreators #ContentCreation #Shorts #Productivity";

    final formattedText = StringBuffer();
    formattedText.writeln("📌 TITLE: $title");
    formattedText.writeln("📱 PLATFORM: $platformTag");
    formattedText.writeln("⏰ SCHEDULED TIME: $time");
    formattedText.writeln("💡 AI PEAK TIME: $aiTime");
    formattedText.writeln("");
    formattedText.writeln("📝 CAPTION:");
    formattedText.writeln(caption);
    formattedText.writeln("");
    formattedText.writeln("🏷️ HASHTAGS:");
    formattedText.writeln(hashtags);

    final fullContentStr = formattedText.toString();
    Clipboard.setData(ClipboardData(text: fullContentStr));
    AppToast.success("Copied complete post details & hashtags to clipboard!");
  }
}
