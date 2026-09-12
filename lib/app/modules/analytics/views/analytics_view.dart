import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/analytics_model.dart';
import 'package:lala_ai/app/modules/analytics/controllers/analytics_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CC.background,
      appBar: CW.commonAppbar(
        wantBackIcon: false,
        titleWidget: Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: CC.primary, size: 20),
            8.width,
            Text("Analytics & Metrics", style: TS.sectionTitle(fontSize: 16)),
          ],
        ),
        actions: [
          Obx(() => OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  side: BorderSide(color: CC.stroke, width: 0.7),
                  backgroundColor: CC.surface,
                ),
                icon: Icon(Icons.calendar_today_rounded, size: 13, color: CC.primary),
                label: Text(
                  controller.selectedTimeRange.value,
                  style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  CW.showCustomBottomSheet(
                    context: context,
                    title: "Select Time Range",
                    titleIcon: Icons.calendar_month_rounded,
                    children: controller.timeRanges.map((range) {
                      return Obx(() {
                        final isSelected = controller.selectedTimeRange.value == range;
                        return ListTile(
                          dense: true,
                          title: Text(
                            range,
                            style: TS.bodySmall(
                              color: isSelected ? CC.primary : CC.textPrimary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_rounded, color: CC.primary, size: 18)
                              : null,
                          onTap: () {
                            Get.back();
                            controller.selectTimeRange(range);
                          },
                        );
                      });
                    }).toList(),
                  );
                },
              )),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(strokeWidth: 2, color: CC.primary));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Overview", style: TS.sectionTitle(fontSize: 16)),
                    12.height,

                    // Analytics Cards List
                    ...controller.metrics.map((m) => _buildMetricCard(context, m)),

                    20.height,

                    // Popular Topics Distribution
                    Text("Popular Topics Distribution", style: TS.sectionTitle(fontSize: 16)),
                    12.height,
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: CC.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: CC.stroke, width: 0.7),
                      ),
                      child: Column(
                        children: controller.popularTopics.map((topic) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(topic.topicName, style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600)),
                                    Text("${topic.score.toInt()}%", style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                6.height,
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: topic.score / 100,
                                    minHeight: 6,
                                    backgroundColor: CC.stroke,
                                    valueColor: AlwaysStoppedAnimation<Color>(CC.primary),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    32.height,
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, AnalyticsMetricModel m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CC.stroke, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(m.title, style: TS.sectionTitle(fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CC.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text("+${m.changePercentage}%", style: TS.caption(color: CC.success, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          8.height,
          Text(m.metricValue, style: TS.displayLarge(fontSize: 24, color: CC.primary)),
          10.height,
          // Custom Line Chart Representation
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: m.chartPoints.map((p) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: (p / 100) * 36,
                    decoration: BoxDecoration(
                      color: CC.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          10.height,
          Text(m.aiInsight, style: TS.caption(color: CC.textSecondary)),
          12.height,
          CW.commonBtn(
            title: "Ask Lala Ai about this data",
            height: 34,
            onTap: () => controller.askAiAboutAnalytics(m),
          ),
        ],
      ),
    );
  }
}
