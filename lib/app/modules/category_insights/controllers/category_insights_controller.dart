import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/category_insights_model.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// CategoryInsightsController — Manages category selection, dataset fetching,
/// and freshness state for creator-facing Category Insights.
/// ─────────────────────────────────────────────────────────────────────────────
class CategoryInsightsController extends GetxController {
  // All system supported categories available to creators
  final List<String> allAvailableCategories = const [
    "Fashion",
    "Beauty",
    "Lifestyle",
    "Tech",
    "Gaming",
    "Fitness & Health",
    "Travel & Vlogs",
    "Food & Cooking",
    "Finance & Business",
    "Entertainment",
  ];

  // User's configured categories from profile
  final RxList<String> userCategories = <String>[
    "Fashion",
    "Beauty",
    "Lifestyle",
    "Tech",
    "Gaming",
  ].obs;

  final RxString selectedCategory = "Fashion".obs;
  final RxBool isLoading = false.obs;
  final RxString lastUpdated = "Updated 2 hours ago".obs;

  // Mock repository of category-level shared insights
  final Map<String, CategoryInsightsModel> _insightsDb = {
    "Fashion": CategoryInsightsModel(
      categoryName: "Fashion",
      updatedTime: "Updated 2 hours ago",
      trendingNow: [
        "Oversized silhouettes",
        "Minimal styling",
        "Sustainable fabrics",
      ],
      popularTopics: [
        "Streetwear",
        "Luxury fashion",
        "Creator fashion",
      ],
      sharedInsights: [
        CategoryInsightItem(
          tag: "Rising Topic",
          title: "Sustainable Fashion",
          description: "Growing interest among audiences searching for eco-friendly capsule wardrobes and styling tips.",
          icon: Icons.trending_up_rounded,
        ),
        CategoryInsightItem(
          tag: "Trending Format",
          title: "Short-Form Video",
          description: "15-30s outfit transitions & GRWM format driving +48% higher engagement rates.",
          icon: Icons.play_circle_outline_rounded,
        ),
        CategoryInsightItem(
          tag: "Popular Theme",
          title: "Minimal & Neutral Styling",
          description: "Monochrome aesthetic generating top save and bookmark metrics across creators.",
          icon: Icons.palette_outlined,
        ),
      ],
    ),
    "Beauty": CategoryInsightsModel(
      categoryName: "Beauty",
      updatedTime: "Updated 1 hour ago",
      trendingNow: [
        "Glass skin routines",
        "Clean makeup look",
        "Scalp care trends",
      ],
      popularTopics: [
        "Skincare Routine",
        "Drugstore Dupes",
        "Glowy Base",
      ],
      sharedInsights: [
        CategoryInsightItem(
          tag: "Rising Topic",
          title: "Barrier Repair Skincare",
          description: "High audience search volume around ceramide treatments and soothing routine steps.",
          icon: Icons.spa_outlined,
        ),
        CategoryInsightItem(
          tag: "Trending Format",
          title: "ASMR Routine Reviews",
          description: "Pulls 2.4x higher watch time on YouTube Shorts & Instagram Reels.",
          icon: Icons.headset_mic_outlined,
        ),
        CategoryInsightItem(
          tag: "Popular Theme",
          title: "Natural Light Closeups",
          description: "Unfiltered natural lighting visuals build high audience trust and retention.",
          icon: Icons.wb_sunny_outlined,
        ),
      ],
    ),
    "Lifestyle": CategoryInsightsModel(
      categoryName: "Lifestyle",
      updatedTime: "Updated 3 hours ago",
      trendingNow: [
        "Morning routine vlogs",
        "Minimalist living",
        "Productivity resets",
      ],
      popularTopics: [
        "Day In The Life",
        "Room Tour",
        "Healthy Habits",
      ],
      sharedInsights: [
        CategoryInsightItem(
          tag: "Rising Topic",
          title: "Slow Morning Rituals",
          description: "Audience engagement spikes during weekend morning feed browsing.",
          icon: Icons.wb_twilight_rounded,
        ),
        CategoryInsightItem(
          tag: "Trending Format",
          title: "Aesthetic Mini Vlog",
          description: "Calm voiceover paired with Lofi audio yields top share counts.",
          icon: Icons.video_camera_back_outlined,
        ),
        CategoryInsightItem(
          tag: "Popular Theme",
          title: "Cozy Workspace Setup",
          description: "Organized desk setups generate top comment interactions and questions.",
          icon: Icons.chair_alt_outlined,
        ),
      ],
    ),
    "Tech": CategoryInsightsModel(
      categoryName: "Tech",
      updatedTime: "Updated 30 mins ago",
      trendingNow: [
        "AI workflow tools",
        "Desk setup 2026",
        "Smartphone reviews",
      ],
      popularTopics: [
        "AI Tools",
        "Productivity Apps",
        "Gadget Comparison",
      ],
      sharedInsights: [
        CategoryInsightItem(
          tag: "Rising Topic",
          title: "AI Content Automation",
          description: "+65% surge in creator searches for workflow AI assistants and prompt tools.",
          icon: Icons.auto_awesome_rounded,
        ),
        CategoryInsightItem(
          tag: "Trending Format",
          title: "Direct Comparison Tests",
          description: "Side-by-side feature comparisons drive maximum audience debate and comments.",
          icon: Icons.compare_arrows_rounded,
        ),
        CategoryInsightItem(
          tag: "Popular Theme",
          title: "Clean Matte Dark Aesthetic",
          description: "High-contrast dark mode hardware presentations perform best.",
          icon: Icons.dark_mode_outlined,
        ),
      ],
    ),
    "Gaming": CategoryInsightsModel(
      categoryName: "Gaming",
      updatedTime: "Updated 4 hours ago",
      trendingNow: [
        "Indie game hidden gems",
        "Speedrun highlights",
        "Custom PC builds",
      ],
      popularTopics: [
        "Game Reactions",
        "Patch Notes Breakdown",
        "Setup Specs",
      ],
      sharedInsights: [
        CategoryInsightItem(
          tag: "Rising Topic",
          title: "Cozy Indie Games",
          description: "Growing audience seeking relaxing gameplay commentary and recommendations.",
          icon: Icons.sports_esports_outlined,
        ),
        CategoryInsightItem(
          tag: "Trending Format",
          title: "15s Clutch Highlights",
          description: "Short clutch moment clips deliver top viral algorithmic distribution.",
          icon: Icons.bolt_rounded,
        ),
        CategoryInsightItem(
          tag: "Popular Theme",
          title: "RGB Ambient Setup",
          description: "Vibrant neon lighting aesthetic keeps audience retention high.",
          icon: Icons.light_mode_outlined,
        ),
      ],
    ),
    "Fitness & Health": CategoryInsightsModel(
      categoryName: "Fitness & Health",
      updatedTime: "Updated 1 hour ago",
      trendingNow: [
        "Home workout routines",
        "High protein recipes",
        "Mobility stretches",
      ],
      popularTopics: [
        "Full Body Workout",
        "Meal Prep",
        "Form Tips",
      ],
      sharedInsights: [
        CategoryInsightItem(
          tag: "Rising Topic",
          title: "Functional Mobility",
          description: "Spike in audience searches for joint care and daily mobility drills.",
          icon: Icons.fitness_center_rounded,
        ),
        CategoryInsightItem(
          tag: "Trending Format",
          title: "30s Voiceover Routine",
          description: "Quick exercise breakdowns with clear visual cues perform best.",
          icon: Icons.timer_outlined,
        ),
        CategoryInsightItem(
          tag: "Popular Theme",
          title: "High-Energy Music Sync",
          description: "Rhythmic beat-synced workout montages hold user attention.",
          icon: Icons.music_note_outlined,
        ),
      ],
    ),
    "Travel & Vlogs": CategoryInsightsModel(
      categoryName: "Travel & Vlogs",
      updatedTime: "Updated 5 hours ago",
      trendingNow: [
        "Budget travel hacks",
        "Solo trip guides",
        "Hidden aesthetic cafes",
      ],
      popularTopics: [
        "Packing Tips",
        "City Guide",
        "Flight Hacks",
      ],
      sharedInsights: [
        CategoryInsightItem(
          tag: "Rising Topic",
          title: "Off-the-Beaten-Path Spots",
          description: "Audiences prefer authentic local recommendations over tourist hotspots.",
          icon: Icons.explore_outlined,
        ),
        CategoryInsightItem(
          tag: "Trending Format",
          title: "Cinematic 4K Shorts",
          description: "Slow panning landscape shots drive high bookmark & save rates.",
          icon: Icons.videocam_outlined,
        ),
        CategoryInsightItem(
          tag: "Popular Theme",
          title: "POV Travel Experience",
          description: "First-person perspective videos deliver high audience empathy.",
          icon: Icons.camera_alt_outlined,
        ),
      ],
    ),
    "Food & Cooking": CategoryInsightsModel(
      categoryName: "Food & Cooking",
      updatedTime: "Updated 2 hours ago",
      trendingNow: [
        "15-minute meals",
        "Air fryer hacks",
        "One-pot recipes",
      ],
      popularTopics: [
        "Easy Dinners",
        "Baking Basics",
        "Healthy Snacks",
      ],
      sharedInsights: [
        CategoryInsightItem(
          tag: "Rising Topic",
          title: "High-Protein Meals",
          description: "High demand for quick, macro-friendly meal ideas for busy weekdays.",
          icon: Icons.restaurant_rounded,
        ),
        CategoryInsightItem(
          tag: "Trending Format",
          title: "Satisfying Cooking ASMR",
          description: "Focused sizzle & chopping sounds drive top completion rates.",
          icon: Icons.mic_none_rounded,
        ),
        CategoryInsightItem(
          tag: "Popular Theme",
          title: "Clean Overhead Shot",
          description: "Top-down lighting showcase makes recipes look clean and approachable.",
          icon: Icons.soup_kitchen_outlined,
        ),
      ],
    ),
    "Finance & Business": CategoryInsightsModel(
      categoryName: "Finance & Business",
      updatedTime: "Updated 3 hours ago",
      trendingNow: [
        "Passive income ideas",
        "Side hustle tips",
        "Budgeting frameworks",
      ],
      popularTopics: [
        "Investing 101",
        "Creator Economy",
        "Tax Basics",
      ],
      sharedInsights: [
        CategoryInsightItem(
          tag: "Rising Topic",
          title: "Creator Monetization",
          description: "High audience interest in digital products and affiliate income.",
          icon: Icons.attach_money_rounded,
        ),
        CategoryInsightItem(
          tag: "Trending Format",
          title: "On-Screen Chart Breakdowns",
          description: "Visual breakdown graphics build authority and high save counts.",
          icon: Icons.bar_chart_rounded,
        ),
        CategoryInsightItem(
          tag: "Popular Theme",
          title: "Clear Step-by-Step Lists",
          description: "Direct action items without fluff keep viewer retention strong.",
          icon: Icons.checklist_rounded,
        ),
      ],
    ),
    "Entertainment": CategoryInsightsModel(
      categoryName: "Entertainment",
      updatedTime: "Updated 1 hour ago",
      trendingNow: [
        "Pop culture breakdowns",
        "Movie & show easter eggs",
        "Meme formats 2026",
      ],
      popularTopics: [
        "Film Reviews",
        "Trending Memes",
        "Storytime",
      ],
      sharedInsights: [
        CategoryInsightItem(
          tag: "Rising Topic",
          title: "Behind-the-Scenes Lore",
          description: "Deep dive explanations of popular shows and viral culture trends.",
          icon: Icons.movie_outlined,
        ),
        CategoryInsightItem(
          tag: "Trending Format",
          title: "Relatable Storytelling",
          description: "Humorous commentary paired with green-screen background visuals.",
          icon: Icons.face_retouching_natural_rounded,
        ),
        CategoryInsightItem(
          tag: "Popular Theme",
          title: "Fast-Paced Editing",
          description: "Snappy cuts every 2-3 seconds maintain maximum watch time.",
          icon: Icons.auto_fix_high_rounded,
        ),
      ],
    ),
  };

  CategoryInsightsModel? get currentInsights => _insightsDb[selectedCategory.value];

  void selectCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      isLoading.value = false;
      if (currentInsights != null) {
        lastUpdated.value = currentInsights!.updatedTime;
      }
    });
  }

  void removeCategory(String category) {
    userCategories.remove(category);
    if (selectedCategory.value == category) {
      if (userCategories.isNotEmpty) {
        selectedCategory.value = userCategories.first;
      } else {
        selectedCategory.value = "";
      }
    }
  }

  void addCategory(String category) {
    if (!userCategories.contains(category)) {
      userCategories.add(category);
      if (selectedCategory.value.isEmpty || !userCategories.contains(selectedCategory.value)) {
        selectCategory(category);
      }
    }
  }

  /// Icon lookup helper for categories
  IconData getCategoryIcon(String cat) {
    switch (cat) {
      case "Fashion":
        return Icons.checkroom_rounded;
      case "Beauty":
        return Icons.auto_awesome_rounded;
      case "Lifestyle":
        return Icons.coffee_rounded;
      case "Tech":
        return Icons.devices_rounded;
      case "Gaming":
        return Icons.sports_esports_rounded;
      case "Fitness & Health":
        return Icons.fitness_center_rounded;
      case "Travel & Vlogs":
        return Icons.explore_rounded;
      case "Food & Cooking":
        return Icons.restaurant_rounded;
      case "Finance & Business":
        return Icons.account_balance_wallet_rounded;
      case "Entertainment":
        return Icons.movie_filter_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  /// Open interactive Manage Categories Bottom Sheet
  void manageCategories(BuildContext context) {
    final RxList<String> tempSelected = RxList<String>.from(userCategories);

    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: CC.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
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

                // Title & Close Header (Surgically aligned)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Manage Categories",
                            style: TS.sectionTitle(
                              color: CC.textPrimary,
                              fontSize: 18,
                            ),
                          ),
                          4.height,
                          Text(
                            "Select the categories you actively create in",
                            style: TS.caption(color: CC.textSecondary).copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    12.width,
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
                18.height,

                // Available Categories Grid / Wrap
                Expanded(
                  child: Obx(
                    () => SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: allAvailableCategories.map((cat) {
                          final isSelected = tempSelected.contains(cat);
                          final catIcon = getCategoryIcon(cat);

                          return InkWell(
                            onTap: () {
                              if (isSelected) {
                                tempSelected.remove(cat);
                              } else {
                                tempSelected.add(cat);
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? CC.primary
                                    : (CC.isDark
                                        ? CC.whiteText.withValues(alpha: 0.04)
                                        : CC.black.withValues(alpha: 0.03)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? CC.primary : CC.stroke,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : catIcon,
                                    size: 16,
                                    color: isSelected
                                        ? CC.whiteText
                                        : CC.textSecondary,
                                  ),
                                  8.width,
                                  Text(
                                    cat,
                                    style: TS.bodySmall(
                                      color: isSelected
                                          ? CC.whiteText
                                          : CC.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ).copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                16.height,

                // Bottom Save Button with Safe Area
                SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        userCategories.assignAll(tempSelected);
                        if (tempSelected.isNotEmpty) {
                          if (!tempSelected.contains(selectedCategory.value)) {
                            selectedCategory.value = tempSelected.first;
                          }
                        } else {
                          selectedCategory.value = "";
                        }
                        CW.dismissBottomSheet(sheetContext);
                        AppToast.success("Categories updated successfully!");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CC.primary,
                        foregroundColor: CC.whiteText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "Save Changes",
                        style: TS.bodySmall(
                          color: CC.whiteText,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 15),
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
}
