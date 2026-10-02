import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/public_document_model.dart';
import 'package:lala_ai/app/data/repositories/public_repository.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:lala_ai/utils/common_methods.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/app/modules/settings/controllers/settings_controller.dart';
import 'package:lala_ai/app/modules/settings/views/support_bottom_sheet.dart';
import 'package:lala_ai/app/modules/support/views/support_list_view.dart';

class FaqItemData {
  final dynamic id;
  final String question;
  final String answer;
  final String? answerHtml;
  final String category;

  const FaqItemData({
    this.id,
    required this.question,
    required this.answer,
    this.answerHtml,
    required this.category,
  });

  factory FaqItemData.fromModel(PublicFaqModel model) {
    return FaqItemData(
      id: model.id,
      question: model.question,
      answer: model.answer,
      answerHtml: model.answerHtml,
      category: model.category,
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// FaqView — Dedicated full-screen FAQ & Help Center with single-expand
/// accordion animations, pull-to-refresh & support CTA.
/// ─────────────────────────────────────────────────────────────────────────────
class FaqView extends StatefulWidget {
  const FaqView({super.key});

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  final PublicRepository _publicRepository = ApiPublicRepository();
  int? _expandedIndex;
  bool _hasLoadedOnce = false;
  bool _isLoading = true;
  List<FaqItemData> _faqList = [];

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs({bool isRefresh = false}) async {
    if (!_hasLoadedOnce && _faqList.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final remoteFaqs = await _publicRepository.getFaqs();
      if (mounted) {
        setState(() {
          _faqList = remoteFaqs.map((m) => FaqItemData.fromModel(m)).toList();
          _isLoading = false;
          _hasLoadedOnce = true;
        });
        return;
      }
    } catch (e) {
      debugPrint("Error loading remote FAQs: $e");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasLoadedOnce = true;
      });
    }
  }

  void _showContactSupportSheet(BuildContext context) {
    Get.to(() => const SupportListView());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (_) {
        final list = _faqList;

        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            isNotHomepage: true,
            title: "FAQ & Help Center",
          ),
          body: SafeArea(
            child: RefreshIndicator(
              color: CC.primary,
              backgroundColor: CC.surface,
              onRefresh: () => _loadFaqs(isRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 36),
                child: _isLoading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            10.height,
                            CW.skeletonList(itemCount: 6, itemHeight: 74, padding: EdgeInsets.zero),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── FAQ Accordion List ────────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: list.isEmpty
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
                                          "No questions available",
                                          style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: List.generate(list.length, (index) {
                                      final faq = list[index];
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
