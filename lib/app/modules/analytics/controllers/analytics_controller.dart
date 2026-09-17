import 'package:get/get.dart';
import 'package:lala_ai/app/data/repositories/analytics_repository.dart';

class AnalyticsController extends GetxController {
  final AnalyticsRepository analyticsRepository;

  AnalyticsController({AnalyticsRepository? analyticsRepository})
      : analyticsRepository = analyticsRepository ?? MockAnalyticsRepository();

  final selectedPlatform = "Instagram".obs; // "Instagram" | "YouTube"
  final selectedDateRange = "30 Days".obs; // "7 Days" | "30 Days" | "90 Days"
  final dateRangeOptions = const ["7 Days", "30 Days", "90 Days"];

  // Connected Account Details
  Map<String, dynamic> get accountDetails {
    if (selectedPlatform.value == "Instagram") {
      return {
        "name": "Lala Creator",
        "handle": "@lala_creator",
        "avatar": "assets/icons/img_instagram.png",
        "platformTag": "Instagram Reel",
        "isVerified": true,
      };
    } else {
      return {
        "name": "Lala AI Studio",
        "handle": "@LalaAIStudio",
        "avatar": "assets/icons/img_youtube.png",
        "platformTag": "YouTube Shorts",
        "isVerified": true,
      };
    }
  }

  // 1. Overall Channel Score & Breakdown
  Map<String, dynamic> get channelScoreData {
    final isIg = selectedPlatform.value == "Instagram";
    final is30 = selectedDateRange.value == "30 Days";
    final is90 = selectedDateRange.value == "90 Days";

    return {
      "score": isIg ? (is30 ? 78 : (is90 ? 82 : 75)) : (is30 ? 84 : (is90 ? 88 : 80)),
      "status": "Good",
      "subtitle": "Your channel is performing well, with strong engagement but inconsistent posting.",
      "breakdown": [
        {"title": "Profile", "value": 0.85, "label": "85%"},
        {"title": "Content", "value": 0.72, "label": "72%"},
        {"title": "Engagement", "value": 0.88, "label": "88%"},
        {"title": "Consistency", "value": 0.64, "label": "64%"},
      ]
    };
  }

  // 2. Key Performance Metrics
  List<Map<String, dynamic>> get keyMetrics {
    final isIg = selectedPlatform.value == "Instagram";
    final range = selectedDateRange.value;

    if (isIg) {
      if (range == "7 Days") {
        return [
          {"title": "Followers", "value": "12.1K", "change": "+2.1%", "isUp": true},
          {"title": "Views", "value": "42.8K", "change": "+14.5%", "isUp": true},
          {"title": "Likes", "value": "2.4K", "change": "+8.2%", "isUp": true},
          {"title": "Consistency", "value": "82%", "change": "+5.0%", "isUp": true},
        ];
      } else if (range == "90 Days") {
        return [
          {"title": "Followers", "value": "13.8K", "change": "+18.4%", "isUp": true},
          {"title": "Views", "value": "540K", "change": "+32.1%", "isUp": true},
          {"title": "Likes", "value": "28.5K", "change": "+22.4%", "isUp": true},
          {"title": "Consistency", "value": "76%", "change": "+8.4%", "isUp": true},
        ];
      } else {
        // 30 Days
        return [
          {"title": "Followers", "value": "12.4K", "change": "+8.4%", "isUp": true},
          {"title": "Views", "value": "184K", "change": "+21.3%", "isUp": true},
          {"title": "Likes", "value": "9.8K", "change": "+14.2%", "isUp": true},
          {"title": "Consistency", "value": "64%", "change": "+3.1%", "isUp": true},
        ];
      }
    } else {
      // YouTube
      if (range == "7 Days") {
        return [
          {"title": "Subscribers", "value": "45.2K", "change": "+3.4%", "isUp": true},
          {"title": "Views", "value": "98.5K", "change": "+18.2%", "isUp": true},
          {"title": "Likes", "value": "6.1K", "change": "+11.4%", "isUp": true},
          {"title": "Consistency", "value": "88%", "change": "+5.0%", "isUp": true},
        ];
      } else if (range == "90 Days") {
        return [
          {"title": "Subscribers", "value": "52.4K", "change": "+28.6%", "isUp": true},
          {"title": "Views", "value": "1.2M", "change": "+42.0%", "isUp": true},
          {"title": "Likes", "value": "84.2K", "change": "+31.5%", "isUp": true},
          {"title": "Consistency", "value": "80%", "change": "+8.4%", "isUp": true},
        ];
      } else {
        // 30 Days
        return [
          {"title": "Subscribers", "value": "47.8K", "change": "+12.6%", "isUp": true},
          {"title": "Views", "value": "412K", "change": "+26.8%", "isUp": true},
          {"title": "Likes", "value": "24.6K", "change": "+19.1%", "isUp": true},
          {"title": "Consistency", "value": "74%", "change": "+4.5%", "isUp": true},
        ];
      }
    }
  }

  // 3. Audience Growth Graph Data
  Map<String, dynamic> get audienceGrowthData {
    final isIg = selectedPlatform.value == "Instagram";
    final range = selectedDateRange.value;

    return {
      "start": isIg ? "12.0K" : "44.2K",
      "end": isIg ? "12.4K" : "47.8K",
      "gain": isIg ? "+400 (+8.4%)" : "+3,600 (+12.6%)",
      "timeLabels": range == "7 Days"
          ? ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
          : ["Week 1", "Week 2", "Week 3", "Week 4"],
      "points": isIg ? [12.0, 12.1, 12.18, 12.25, 12.3, 12.36, 12.4] : [44.2, 44.9, 45.8, 46.4, 47.0, 47.4, 47.8],
    };
  }

  // 4. Views Graph Data
  Map<String, dynamic> get viewsData {
    final isIg = selectedPlatform.value == "Instagram";
    final range = selectedDateRange.value;

    return {
      "totalViews": isIg ? "184K" : "412K",
      "avgViews": isIg ? "6.1K / day" : "13.7K / day",
      "change": "+21.3%",
      "insight": "Views increased 21.3% compared with the previous $range period.",
      "timeLabels": range == "7 Days"
          ? ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
          : ["Week 1", "Week 2", "Week 3", "Week 4"],
      "points": isIg ? [28.0, 38.0, 32.0, 54.0, 48.0, 68.0, 78.0] : [65.0, 92.0, 85.0, 115.0, 128.0, 145.0, 160.0],
    };
  }

  // 5. Engagement Graph Data
  Map<String, dynamic> get engagementData {
    final isIg = selectedPlatform.value == "Instagram";
    return {
      "avgRate": isIg ? "6.8%" : "8.1%",
      "likesCount": isIg ? "9.8K" : "24.6K",
      "commentsCount": isIg ? "1.2K" : "3.2K",
      "timeLabels": ["Week 1", "Week 2", "Week 3", "Week 4"],
      "likesPoints": [40.0, 58.0, 48.0, 76.0],
      "commentsPoints": [18.0, 26.0, 22.0, 35.0],
    };
  }

  // 6. Content Activity Data
  Map<String, dynamic> get contentActivityData {
    final isIg = selectedPlatform.value == "Instagram";
    final range = selectedDateRange.value;
    return {
      "total": isIg ? "12 posts in the last $range" : "9 Shorts in the last $range",
      "avg": isIg ? "Average: 3 posts/week" : "Average: 2.2 posts/week",
      "best": isIg ? "Best Week: Week 2 (5 posts, 64K views)" : "Best Week: Week 3 (3 posts, 142K views)",
      "weeklyBars": [
        {"week": "Week 1", "count": 3, "label": "3 posts"},
        {"week": "Week 2", "count": 5, "label": "5 posts"},
        {"week": "Week 3", "count": 2, "label": "2 posts"},
        {"week": "Week 4", "count": 4, "label": "4 posts"},
      ]
    };
  }

  // 7. Top Performing Content
  List<Map<String, dynamic>> get topPerformingContent {
    final isIg = selectedPlatform.value == "Instagram";

    if (isIg) {
      return [
        {
          "rank": "01",
          "title": "How I built my first SaaS with AI in 2026",
          "platform": "Instagram",
          "views": "18.2K views",
          "likes": "842",
          "comments": "73",
          "engagement": "7.4%",
          "thumbnail": "assets/images/home_page_box_image.png",
        },
        {
          "rank": "02",
          "title": "3 mistakes creators make when scripting short reels",
          "platform": "Instagram",
          "views": "14.7K views",
          "likes": "721",
          "comments": "58",
          "engagement": "6.9%",
          "thumbnail": "assets/images/explore_all_bg1.png",
        },
        {
          "rank": "03",
          "title": "10 AI Prompts That Will Save You 10 Hours a Week",
          "platform": "Instagram",
          "views": "12.4K views",
          "likes": "610",
          "comments": "49",
          "engagement": "6.5%",
          "thumbnail": "assets/images/master_image.png",
        },
        {
          "rank": "04",
          "title": "Behind the scenes: Pixo AI Voice Generation Workflow",
          "platform": "Instagram",
          "views": "9.8K views",
          "likes": "490",
          "comments": "36",
          "engagement": "6.1%",
          "thumbnail": "assets/images/purple_bg.png",
        },
        {
          "rank": "05",
          "title": "Viral Hook Formulas That Guarantee Retention",
          "platform": "Instagram",
          "views": "8.5K views",
          "likes": "412",
          "comments": "29",
          "engagement": "5.8%",
          "thumbnail": "assets/images/challenge_bg.png",
        },
      ];
    } else {
      return [
        {
          "rank": "01",
          "title": "Build a Complete Flutter AI App in 10 Minutes",
          "platform": "YouTube",
          "views": "48.6K views",
          "likes": "2.4K",
          "comments": "194",
          "engagement": "8.9%",
          "thumbnail": "assets/images/home_page_box_image.png",
        },
        {
          "rank": "02",
          "title": "Top 5 AI Tools for Shorts Creators in 2026",
          "platform": "YouTube",
          "views": "36.2K views",
          "likes": "1.8K",
          "comments": "142",
          "engagement": "8.2%",
          "thumbnail": "assets/images/explore_all_bg1.png",
        },
        {
          "rank": "03",
          "title": "How to Automate Content Research with Lala AI",
          "platform": "YouTube",
          "views": "28.9K views",
          "likes": "1.4K",
          "comments": "98",
          "engagement": "7.8%",
          "thumbnail": "assets/images/master_image.png",
        },
        {
          "rank": "04",
          "title": "AI Video Editor vs Human Editor (Shocking Result)",
          "platform": "YouTube",
          "views": "22.4K views",
          "likes": "1.1K",
          "comments": "84",
          "engagement": "7.3%",
          "thumbnail": "assets/images/purple_bg.png",
        },
        {
          "rank": "05",
          "title": "Zero to 100K Subscribers: AI Content Strategy",
          "platform": "YouTube",
          "views": "19.8K views",
          "likes": "950",
          "comments": "72",
          "engagement": "6.9%",
          "thumbnail": "assets/images/challenge_bg.png",
        },
      ];
    }
  }

  void setPlatform(String platform) {
    selectedPlatform.value = platform;
  }

  void setDateRange(String range) {
    selectedDateRange.value = range;
  }
}
