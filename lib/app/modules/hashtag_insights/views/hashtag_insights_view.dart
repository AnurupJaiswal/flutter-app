import 'package:flutter/material.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class HashtagInsightsView extends StatelessWidget {
  const HashtagInsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CC.background,
      appBar: CW.commonAppbar(
        isNotHomepage: true,
        wantBackIcon: true,
        title: "Hashtag Insights",
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Field
              Text("Analyze Hashtag", style: TS.caption(color: CC.textSecondary, fontWeight: FontWeight.w600)),
              6.height,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CW.commonSearchField(
                      hintText: "Enter hashtag (e.g. #tech)",
                      prefixIcon: Icon(Icons.tag_rounded, size: 18, color: CC.grey),
                    ),
                  ),
                  8.width,
                  CW.commonBtn(
                    title: "Analyze",
                    width: 90,
                    height: 40,
                    onTap: () {},
                  ),
                ],
              ),
              24.height,
              
              // Top Trending Hashtags
              Text("Trending Hashtags Today", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16)),
              12.height,
              
              _buildHashtagCard("#AI", "2.4M posts", "+14%", true),
              _buildHashtagCard("#TechNews", "850K posts", "+8%", true),
              _buildHashtagCard("#CodingLife", "410K posts", "-2%", false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHashtagCard(String tag, String posts, String trend, bool isUp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark ? CC.black.withValues(alpha: 0.3) : CC.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.tag_rounded, color: CC.primary, size: 20),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tag, style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15)),
                4.height,
                Text(posts, style: TS.bodySmall(color: CC.textSecondary).copyWith(fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded, 
                color: isUp ? CC.success : CC.errorText, 
                size: 20
              ),
              4.height,
              Text(
                trend,
                style: TS.caption(color: isUp ? CC.success : CC.errorText, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
