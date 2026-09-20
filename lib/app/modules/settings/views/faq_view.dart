import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:lala_ai/utils/common_methods.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class FaqItemData {
  final String question;
  final String answer;
  final String category;

  const FaqItemData({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class _StickyCategoryChipsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyCategoryChipsDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: CC.background,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  @override
  double get maxExtent => 52.0;

  @override
  double get minExtent => 52.0;

  @override
  bool shouldRebuild(covariant _StickyCategoryChipsDelegate oldDelegate) {
    return true;
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// FaqView — Dedicated full-screen FAQ & Help Center with pinned sticky
/// horizontal category chips bar, single-expand accordion animations & support CTA.
/// ─────────────────────────────────────────────────────────────────────────────
class FaqView extends StatefulWidget {
  const FaqView({super.key});

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  String _selectedCategory = "All";
  int? _expandedIndex;

  static const List<String> _categories = [
    "All",
    "AI Credits",
    "Scripts",
    "Channels",
    "Billing",
    "Security",
  ];

  static const List<FaqItemData> _allFaqs = [
    FaqItemData(
      question: "How do AI credits work?",
      answer:
          "AI credits are renewed monthly depending on your active plan tier. Each script generation, video idea brainstorm, or trend analysis consumes credits. Unused credits rollover for up to 60 days on active Pro plans.",
      category: "AI Credits",
    ),
    FaqItemData(
      question: "Can I export my scripts and ideas?",
      answer:
          "Yes! You can export your data anytime under Account → Download My Data. You can also export individual scripts as PDF, plain text, or copy directly into your clipboard as Markdown.",
      category: "Scripts",
    ),
    FaqItemData(
      question: "How do I connect my channel?",
      answer:
          "Go to Profile → Connect Channels to link YouTube or Instagram accounts. We use official OAuth 2.0 authorization with read-only permissions to analyze your content performance.",
      category: "Channels",
    ),
    FaqItemData(
      question: "Can I change my subscription plan anytime?",
      answer:
          "Yes, upgrades take effect immediately with pro-rated billing. Downgrades apply at the end of the current billing cycle without losing any of your saved drafts or historical data.",
      category: "Billing",
    ),
    FaqItemData(
      question: "Is my channel data and creative content secure?",
      answer:
          "We prioritize data privacy. Your connected channel statistics and custom AI scripts are encrypted end-to-end. We never train public AI models on your private drafts or proprietary video ideas.",
      category: "Security",
    ),
    FaqItemData(
      question: "How often are viral trends updated?",
      answer:
          "Our AI engine continuously monitors video surges and engagement metrics across YouTube Shorts and Instagram Reels every 15 minutes to bring you real-time trending topics.",
      category: "AI Credits",
    ),
    FaqItemData(
      question: "What happens if I run out of monthly credits?",
      answer:
          "If you run out of credits before your monthly renewal date, you can upgrade your subscription tier anytime from Settings → Subscription Details or purchase top-up credit packs.",
      category: "AI Credits",
    ),
    FaqItemData(
      question: "How do I contact 24/7 human creator support?",
      answer:
          "You can reach out to our dedicated support team via the 'Contact Support' button at the bottom of this page, or send us a direct message on WhatsApp anytime.",
      category: "Billing",
    ),
  ];

  List<FaqItemData> get _filteredFaqs {
    return _allFaqs.where((faq) {
      return _selectedCategory == "All" || faq.category == _selectedCategory;
    }).toList();
  }

  void _showContactSupportSheet(BuildContext context) {
    final msgController = TextEditingController();
    CW.showCustomBottomSheet(
      context: context,
      title: "Contact 24/7 Support",
      titleIcon: Icons.support_agent_rounded,
      children: [
        Text(
          "Our creator support team typically responds within 1 hour.",
          style: TS.caption(color: CC.textSecondary),
        ),
        12.height,
        CW.commonTextFormField(
          controller: msgController,
          hintText: "Describe your issue or question...",
          labelText: "Your Message",
        ),
        16.height,
        CW.commonBtn(
          title: "Send Message",
          onTap: () {
            CW.dismissBottomSheet();
            CM.showToast("Support ticket created! We'll reply shortly.");
          },
        ),
      ],
    ).then((_) => msgController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (_) {
        final filteredList = _filteredFaqs;

        return Scaffold(
      backgroundColor: CC.background,
      appBar: CW.commonAppbar(
        isNotHomepage: true,
        title: "FAQ & Help Center",
      ),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyCategoryChipsDelegate(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          key: ValueKey(category),
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                  _expandedIndex = null;
                                });
                              }
                            },
                            selectedColor: CC.primary,
                            backgroundColor: CC.surface,
                            labelStyle: TS.caption(
                              color: isSelected ? CC.whiteText : CC.textPrimary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? CC.primary : CC.stroke,
                                width: 1,
                              ),
                            ),
                            showCheckmark: false,
                            elevation: 0,
                            pressElevation: 0,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header count ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "FREQUENTLY ASKED QUESTIONS",
                        style: TS.caption(
                          color: CC.primary,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 11, letterSpacing: 1.2),
                      ),
                      Text(
                        "${filteredList.length} ${filteredList.length == 1 ? 'article' : 'articles'}",
                        style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                10.height,

                // ── FAQ Accordion List ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: filteredList.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                          decoration: BoxDecoration(
                            color: CC.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded, color: CC.grey, size: 42),
                              12.height,
                              Text(
                                "No matching questions found",
                                style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15),
                              ),
                              6.height,
                              Text(
                                "Try searching with different keywords or switch categories.",
                                textAlign: TextAlign.center,
                                style: TS.caption(color: CC.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: List.generate(filteredList.length, (index) {
                            final faq = filteredList[index];
                            final isExpanded = _expandedIndex == index;

                            return _buildFaqAccordionItem(
                              key: ValueKey(faq.question),
                              faq: faq,
                              isExpanded: isExpanded,
                              onTap: () {
                                setState(() {
                                  if (_expandedIndex == index) {
                                    _expandedIndex = null;
                                  } else {
                                    _expandedIndex = index;
                                  }
                                });
                              },
                            );
                          }),
                        ),
                ),
                20.height,

                // ── Support CTA Banner ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CC.primary.withValues(alpha: 0.15),
                          CC.primary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: CC.primary.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: CC.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.headset_mic_rounded,
                                color: CC.whiteText,
                                size: 18,
                              ),
                            ),
                            12.width,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Still need assistance?",
                                    style: TS.sectionTitle(
                                      color: CC.textPrimary,
                                      fontSize: 15,
                                    ),
                                  ),
                                  2.height,
                                  Text(
                                    "Our creator support team is available 24/7",
                                    style: TS.caption(color: CC.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        14.height,
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showContactSupportSheet(context),
                            icon: const Icon(Icons.support_agent_rounded, size: 18, color: CC.whiteText),
                            label: Text(
                              "Contact Creator Support",
                              style: TS.bodySmall(
                                color: CC.whiteText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CC.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                24.height,
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildFaqAccordionItem({
    Key? key,
    required FaqItemData faq,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isExpanded
                              ? CC.primary
                              : CC.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.help_outline_rounded,
                          color: isExpanded ? CC.whiteText : CC.primary,
                          size: 18,
                        ),
                      ),
                      14.width,
                      Expanded(
                        child: Text(
                          faq.question,
                          style: TS.bodySmall(
                            color: CC.textPrimary,
                            fontWeight: isExpanded ? FontWeight.w700 : FontWeight.w600,
                          ).copyWith(fontSize: 14),
                        ),
                      ),
                      8.width,
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.fastOutSlowIn,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isExpanded ? CC.primary : CC.textSecondary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.fastOutSlowIn,
                    alignment: Alignment.topCenter,
                    child: isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              12.height,
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: CC.isDark
                                      ? CC.whiteText.withValues(alpha: 0.05)
                                      : CC.primary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  faq.answer,
                                  style: TS.bodySmall(color: CC.textSecondary).copyWith(
                                    height: 1.45,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
