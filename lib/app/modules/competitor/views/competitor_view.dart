import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/app/modules/main_container/controllers/main_container_controller.dart';
import 'package:lala_ai/app/navigation/app_navigation_service.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class CompetitorView extends StatefulWidget {
  final bool isEmbedded;
  const CompetitorView({super.key, this.isEmbedded = false});

  @override
  State<CompetitorView> createState() => _CompetitorViewState();
}

class _CompetitorViewState extends State<CompetitorView> {
  final _searchController = TextEditingController();
  bool _hasSearched = true;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (_) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: widget.isEmbedded 
            ? null 
            : CW.commonAppbar(
                isNotHomepage: true,
                wantBackIcon: true,
                title: "Competitor Intelligence",
              ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search / Add Competitor Field
                  Text("Analyze Competitor Channel", style: TS.caption(color: CC.textSecondary, fontWeight: FontWeight.w600)),
                  6.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CW.commonSearchField(
                          controller: _searchController,
                          hintText: "Enter handle or URL (e.g. @tech_creator)",
                          prefixIcon: Icon(Icons.link_rounded, size: 18, color: CC.grey),
                        ),
                      ),
                      8.width,
                      CW.commonBtn(
                        title: "Analyze",
                        width: 90,
                        height: 40,
                        onTap: () => setState(() => _hasSearched = true),
                      ),
                    ],
                  ),
                  16.height,

                  if (_hasSearched) ...[
                    // Competitor Snapshot Header Card
                    CW.commonCard(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: CC.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_outline_rounded, color: CC.textPrimary, size: 24),
                          ),
                          12.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("@tech_creator", style: TS.sectionTitle(color: CC.textPrimary)),
                                Text("YouTube & Instagram Creator • Tech Niche", style: TS.caption(color: CC.textSecondary)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: CC.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text("Score: 91", style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    14.height,

                    // Key Stats Row
                    Row(
                      children: [
                        Expanded(child: _compStat("Followers", "450K", Icons.people_outline)),
                        10.width,
                        Expanded(child: _compStat("Engagement", "11.2%", Icons.thumb_up_outlined)),
                        10.width,
                        Expanded(child: _compStat("Post Frequency", "1.4/day", Icons.schedule_rounded)),
                      ],
                    ),
                    16.height,

                    // You vs Them Comparison Card
                    Text("You vs Them Comparison", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 14)),
                    10.height,
                    CW.commonCard(
                      child: Column(
                        children: [
                          _compRow("Watch Time Retention", "68%", "74%", false),
                          const Divider(height: 16, thickness: 0.7),
                          _compRow("Hook Conversion (0-3s)", "82%", "78%", true),
                          const Divider(height: 16, thickness: 0.7),
                          _compRow("Upload Consistency", "4 posts/wk", "6 posts/wk", false),
                        ],
                      ),
                    ),
                    16.height,

                    // 30-Day Beat Plan & Content DNA
                    Text("30-Day Creator Beat Plan", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 14)),
                    10.height,
                    CW.commonCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pixo Recommendation to Outperform @tech_creator:", style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w600)),
                          8.height,
                          Text("1. Publish 2 short-form tutorials on 'AI Productivity Shortcuts' on Tuesday & Thursday at 6:00 PM.", style: TS.bodySmall(color: CC.textSecondary)),
                          6.height,
                          Text("2. Use visual pattern interrupts at the 0:03 mark to match their high retention rate.", style: TS.bodySmall(color: CC.textSecondary)),
                          14.height,
                          Row(
                            children: [
                              Expanded(
                                child: CW.commonBtn(
                                  title: "Push to To-Do",
                                  height: 38,
                                  isOutlined: true,
                                  onTap: () {
                                    AppToast.success("Beat plan recommendations added to Dashboard!");
                                  },
                                ),
                              ),
                              10.width,
                              Expanded(
                                child: CW.commonBtn(
                                  title: "Use in Studio",
                                  height: 38,
                                  onTap: () => Get.find<MainContainerController>().changeTab(AppNavigationService.tabStudio),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  100.height,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _compStat(String label, String val, IconData icon) {
    return CW.commonCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: CC.textPrimary, size: 16),
          ),
          8.height,
          Text(val, style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15)),
          2.height,
          Text(label, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _compRow(String metric, String you, String them, bool isYouAhead) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(metric, style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w600))),
        Text("You: $you", style: TS.caption(color: isYouAhead ? CC.success : CC.textSecondary, fontWeight: FontWeight.w600)),
        12.width,
        Flexible(
          child: Text("Them: $them", style: TS.caption(color: CC.textSecondary), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
