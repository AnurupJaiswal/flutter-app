import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class CalendarController extends GetxController {
  final isGridView = false.obs;

  static DateTime get _todayDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Real DateTime tracking initialized to today's date
  late final selectedDate = Rx<DateTime>(_todayDate);
  late final currentDisplayMonth = Rx<DateTime>(DateTime(_todayDate.year, _todayDate.month, 1));
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
    "December"
  ];

  String get currentMonthName {
    final d = currentDisplayMonth.value;
    return "${_monthNames[d.month - 1]} ${d.year}";
  }

  String get selectedDateFormatted {
    final d = selectedDate.value;
    return "${_monthNames[d.month - 1]} ${d.day}";
  }

  bool _hasPostOnDate(DateTime date) {
    return todayPosts.any((p) {
      final d = p["date"] as DateTime?;
      return d != null && d.year == date.year && d.month == date.month && d.day == date.day;
    }) || upcomingPosts.any((p) {
      final d = p["date"] as DateTime?;
      return d != null && d.year == date.year && d.month == date.month && d.day == date.day;
    });
  }

  // Dynamic days calculation for all days of the current display month
  List<Map<String, dynamic>> get daysList {
    final dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    final displayMonth = currentDisplayMonth.value;
    final totalDays = DateUtils.getDaysInMonth(displayMonth.year, displayMonth.month);

    return List.generate(totalDays, (i) {
      final dayNum = i + 1;
      final date = DateTime(displayMonth.year, displayMonth.month, dayNum);
      final isSelected = date.year == selectedDate.value.year &&
          date.month == selectedDate.value.month &&
          date.day == selectedDate.value.day;
      final hasPost = _hasPostOnDate(date);

      return {
        "day": dayNames[date.weekday % 7],
        "date": date.day,
        "fullDate": date,
        "isSelected": isSelected,
        "hasDot": hasPost,
        "dotColor": "teal",
      };
    });
  }

  final todayPosts = <Map<String, dynamic>>[
    {
      "title": "10 AI Prompts That Will Save 10 Hours a Week",
      "platform": "YouTube",
      "platformTag": "YouTube Shorts",
      "time": "Today at 6:15 PM",
      "aiTime": "AI Suggested Peak Time",
      "aiIconType": "sparkle",
      "status": "Scheduled",
      "date": DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      "caption": "Here are 10 powerful AI prompts that will automate your content research, scripting, and editing workflow in 2026! Save this reel and steal these prompts for your next video.",
      "hashtags": "#AITools #ContentCreator #Productivity #Shorts #LalaAI #CreatorTools",
    },
  ].obs;

  final upcomingPosts = <Map<String, dynamic>>[
    {
      "title": "Top 5 AI Tools for Shorts Creators in 2026",
      "platform": "YouTube",
      "platformTag": "YouTube Shorts",
      "time": "Sep 9, 2026 at 6:00 PM",
      "aiTime": "6:15 PM (Highest Engagement)",
      "aiIconType": "chart",
      "status": "Draft",
      "date": DateTime(2026, 9, 9),
      "caption": "Looking to scale your short-form video creation? Here are the top 5 AI tools every creator must use in 2026 to boost watch time and engagement.",
      "hashtags": "#YouTubeShorts #AITools #CreatorTips #VideoEditing #LalaAI",
    },
    {
      "title": "Behind the Scenes: Pixo AI Voice Automation",
      "platform": "Instagram",
      "platformTag": "Instagram Reel",
      "time": "Sep 10, 2026 at 4:30 PM",
      "aiTime": "Best time: 5:00 PM",
      "aiIconType": "chart",
      "status": "Draft",
      "date": DateTime(2026, 9, 10),
      "caption": "Take a look behind the scenes at how Pixo AI generates studio-quality voiceovers and script breakdowns in seconds!",
      "hashtags": "#InstagramReels #BehindTheScenes #AIVoice #ContentWorkflow #LalaAI",
    },
    {
      "title": "Viral Hook Formulas That Guarantee Retention",
      "platform": "Instagram",
      "platformTag": "Instagram Reel",
      "time": "Sep 11, 2026 at 10:00 AM",
      "aiTime": "AI Suggested Peak Time",
      "aiIconType": "sparkle",
      "status": "Scheduled",
      "date": DateTime(2026, 9, 11),
      "caption": "Master the first 3 seconds of your Instagram Reels with these 5 proven hook formulas designed for maximum audience retention.",
      "hashtags": "#InstagramReels #ViralHooks #CreatorGrowth #ReelTips #LalaAI",
    },
  ].obs;

  List<Map<String, dynamic>> get filteredTodayPosts {
    final filter = selectedFilter.value;
    final selDate = selectedDate.value;

    return todayPosts.where((post) {
      final postDate = post["date"] as DateTime?;
      if (postDate != null) {
        final sameDate = postDate.year == selDate.year &&
            postDate.month == selDate.month &&
            postDate.day == selDate.day;
        if (!sameDate) return false;
      }

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
    final selDate = selectedDate.value;

    return upcomingPosts.where((post) {
      final postDate = post["date"] as DateTime?;
      if (postDate != null) {
        final sameDate = postDate.year == selDate.year &&
            postDate.month == selDate.month &&
            postDate.day == selDate.day;
        if (sameDate) return false; // Already in selected date's posts
      }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToSelectedDate(animate: false);
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void scrollToSelectedDate({bool animate = true}) {
    if (!scrollController.hasClients) return;
    final dayIndex = selectedDate.value.day - 1;
    final targetOffset = (dayIndex * 50.0 - 60.0).clamp(0.0, scrollController.position.maxScrollExtent);
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

  void previousMonth() {
    final curr = currentDisplayMonth.value;
    final prev = DateTime(curr.year, curr.month - 1, 1);
    currentDisplayMonth.value = prev;
    selectedDate.value = DateTime(prev.year, prev.month, 1);
    scrollToSelectedDate(animate: true);
  }

  void nextMonth() {
    final curr = currentDisplayMonth.value;
    final next = DateTime(curr.year, curr.month + 1, 1);
    currentDisplayMonth.value = next;
    selectedDate.value = DateTime(next.year, next.month, 1);
    scrollToSelectedDate(animate: true);
  }

  void selectDay(DateTime date) {
    selectedDate.value = date;
    currentDisplayMonth.value = DateTime(date.year, date.month, 1);
    scrollToSelectedDate(animate: true);
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  void addDraft(Map<String, dynamic> newDraft) {
    upcomingPosts.add(newDraft);
    AppToast.success("Post draft added to calendar!");
  }

  void markAsPosted(Map<String, dynamic> post) {
    post["status"] = "Posted";
    todayPosts.refresh();
    upcomingPosts.refresh();
    AppToast.success("Marked as Posted!");
  }

  /// Copy Everything action: Copies full structured title, time, caption & hashtags to Clipboard
  void copyEverything(BuildContext context, Map<String, dynamic> post) {
    final title = post["title"] ?? "";
    final platformTag = post["platformTag"] ?? "";
    final time = post["time"] ?? "";
    final aiTime = post["aiTime"] ?? "";
    final caption = post["caption"] ?? "Here are top insights & actionable prompts for creators to save hours every week using Lala AI!";
    final hashtags = post["hashtags"] ?? "#LalaAI #AIForCreators #ContentCreation #Shorts #Productivity";

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

    _showCopiedPreviewSheet(context, title, fullContentStr);
  }

  /// Bottom Sheet Preview showing copied details
  void _showCopiedPreviewSheet(BuildContext context, String title, String copiedContent) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: CC.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CC.stroke,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              16.height,

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CC.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_circle_rounded, color: CC.primary, size: 20),
                      ),
                      10.width,
                      Text(
                        "Copied to Clipboard!",
                        style: TS.sectionTitle(color: CC.textPrimary, fontSize: 17),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => CW.dismissBottomSheet(sheetContext),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CC.isDark
                            ? CC.whiteText.withValues(alpha: 0.1)
                            : CC.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: CC.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              14.height,

              // Content preview card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CC.isDark
                        ? CC.whiteText.withValues(alpha: 0.05)
                        : CC.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CC.stroke.withValues(alpha: 0.5)),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      copiedContent,
                      style: TS.bodySmall(color: CC.textPrimary).copyWith(fontSize: 13, height: 1.45),
                    ),
                  ),
                ),
              ),
              16.height,

              // Close action button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => CW.dismissBottomSheet(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CC.primary,
                    foregroundColor: CC.whiteText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Ready to Paste & Publish",
                    style: TS.bodySmall(color: CC.whiteText, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
