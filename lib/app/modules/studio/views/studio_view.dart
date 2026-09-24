import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/studio/controllers/studio_controller.dart';
import 'package:lala_ai/app/modules/studio/widgets/studio_drawer_sidebar.dart';
import 'package:lala_ai/app/modules/studio/widgets/studio_message_bubble_widget.dart';
import 'package:lala_ai/app/modules/studio/widgets/studio_message_composer.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class StudioView extends GetView<StudioController> {
  const StudioView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (_) {
        final isDesktop = MediaQuery.of(context).size.width >= 800;

        Widget mainContent = Scaffold(
          backgroundColor: CC.background,
          drawer: isDesktop ? null : const StudioDrawerSidebar(),
          appBar: CW.commonAppbar(
            wantBackIcon: false,
            leadingWidget: isDesktop
                ? null
                : Builder(
                    builder: (scaffoldContext) => IconButton(
                      icon: Icon(Icons.menu_rounded, color: CC.textSecondary, size: 20),
                      splashRadius: 18,
                      tooltip: "Open History",
                      onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                    ),
                  ),
            titleWidget: const SizedBox.shrink(),
            actions: [
              IconButton(
                icon: Icon(Icons.add_comment_outlined, color: CC.textPrimary, size: 18),
                splashRadius: 18,
                tooltip: "New Chat",
                onPressed: controller.startNewChat,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    final list = controller.messages;
                    final isThinking = controller.isAiThinking.value;

                    // 1. Single Screen Empty/Starter State
                    if (list.isEmpty && !isThinking) {
                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 580),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: CC.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.auto_awesome_rounded,
                                        color: CC.textPrimary,
                                        size: 18,
                                      ),
                                    ),
                                    10.width,
                                    Text(
                                      "AI Studio",
                                      style: TS.screenTitle(fontSize: 16),
                                    ),
                                  ],
                                ),

                                18.height,

                                Text(
                                  "How can I help?",
                                  style: TS.displayLarge(fontSize: 22),
                                ),

                                6.height,

                                Text(
                                  "Generate scripts, viral hooks, SEO titles, thumbnail advice, or audience growth strategies.",
                                  style: TS.subHeading(color: CC.textSecondary),
                                ),

                                28.height,

                                Text(
                                  "Suggested prompts",
                                  style: TS.caption(color: CC.grey, fontWeight: FontWeight.w700),
                                ),

                                10.height,

                                _buildPromptItem(
                                  "Generate 5 scroll-stopping Reels/Shorts hooks",
                                  "Generate 5 high-converting, curiosity-driven hooks for a 30-second Short about productivity tools.",
                                ),
                                _buildPromptItem(
                                  "Write a 60-second video script with CTA",
                                  "Write a complete 60-second YouTube Short script for '5 AI hacks every creator needs' with a 3-second hook.",
                                ),
                                _buildPromptItem(
                                  "Optimize YouTube video title & SEO description",
                                  "Give me 3 high-CTR YouTube titles and a keyword-rich description for a channel growth video.",
                                ),
                                _buildPromptItem(
                                  "Fix viewer drop-off & boost channel retention",
                                  "How do I fix viewer drop-off at the 45-second mark and increase overall channel retention past 75%?",
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // 2. Active Message List Stream
                    return ListView.builder(
                      controller: controller.chatScrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: list.length + (isThinking ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == list.length && isThinking) {
                          return _buildThinkingIndicator();
                        }

                        final msg = list[index];
                        return StudioMessageBubbleWidget(
                          message: msg,
                          onRegenerate: (index == list.length - 1 && msg.isAssistant)
                              ? controller.regenerateLastMessage
                              : null,
                          onLike: (liked) => controller.toggleLikeMessage(msg, liked),
                          onSuggestedPromptTap: (prompt) => controller.sendMessage(prompt),
                        );
                      },
                    );
                  }),
                ),

                // Unified Message Composer
                Obx(() => StudioMessageComposer(
                      controller: controller.messageInputController,
                      focusNode: controller.messageFocusNode,
                      isLoading: controller.isAiThinking.value,
                      onSend: () => controller.sendMessage(),
                      onStop: controller.stopGenerating,
                    )),
              ],
            ),
          ),
        );

        if (isDesktop) {
          return Scaffold(
            backgroundColor: CC.background,
            body: Row(
              children: [
                const SizedBox(
                  width: 260,
                  child: StudioDrawerSidebar(),
                ),
                VerticalDivider(color: CC.stroke, width: 0.7, thickness: 0.7),
                Expanded(child: mainContent),
              ],
            ),
          );
        }

        return mainContent;
      },
    );
  }

  Widget _buildThinkingIndicator() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CW.aiAvatar(size: 26, isAssistant: true),
              12.width,
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(CC.primary),
                ),
              ),
              8.width,
              Text(
                "Thinking...",
                style: TS.caption(color: CC.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptItem(String label, String fullPrompt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: CC.isDark ? CC.black.withValues(alpha: 0.4) : CC.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => controller.sendMessage(fullPrompt),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CC.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.arrow_forward_rounded, size: 14, color: CC.textPrimary),
                ),
                12.width,
                Expanded(
                  child: Text(
                    label,
                    style: TS.bodyMedium(color: CC.textPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
