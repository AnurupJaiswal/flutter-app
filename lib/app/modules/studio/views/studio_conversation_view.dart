import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/studio/controllers/studio_controller.dart';
import 'package:lala_ai/app/modules/studio/widgets/pixo_message_bubble_widget.dart';
import 'package:lala_ai/app/modules/studio/widgets/studio_drawer_sidebar.dart';
import 'package:lala_ai/app/modules/studio/widgets/studio_message_composer.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class StudioConversationView extends GetView<StudioController> {
  const StudioConversationView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (_) {
        final isDesktop = MediaQuery.of(context).size.width >= 800;

        Widget mainContent = Scaffold(
          backgroundColor: CC.background,
          drawer: isDesktop ? null : const StudioDrawerSidebar(),
          appBar: CW.commonAppbar(
            wantBackIcon: true,
            onBackTap: () => controller.startNewChat(),
            leadingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: CC.textPrimary, size: 16),
                  splashRadius: 16,
                  tooltip: "Back to Home",
                  onPressed: () => controller.startNewChat(),
                ),
                if (!isDesktop)
                  Builder(
                    builder: (scaffoldContext) => IconButton(
                      icon: Icon(Icons.menu_rounded, color: CC.textSecondary, size: 18),
                      splashRadius: 16,
                      tooltip: "Open History",
                      onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                    ),
                  ),
              ],
            ),
            titleWidget: Obx(() => Text(
                  controller.activeChat.value?.title ?? "Conversation",
                  style: TS.sectionTitle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
            actions: [
              IconButton(
                icon: Icon(Icons.add_comment_outlined, color: CC.primary, size: 18),
                splashRadius: 16,
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
                    final list = controller.pixoMessages;
                    final isThinking = controller.isAiThinkingValue;

                    if (list.isEmpty && !isThinking) {
                      return Center(
                        child: Text(
                          "Start typing to begin your conversation.",
                          style: TS.caption(color: CC.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: controller.chatScrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final msg = list[index];
                        return PixoMessageBubbleWidget(
                          key: ValueKey(msg.localId),
                          message: msg,
                          onRegenerate: (index == list.length - 1 && msg.isAssistant && !isThinking)
                              ? controller.regenerateLastMessage
                              : null,
                        );
                      },
                    );
                  }),
                ),

                // Message Composer
                Obx(() => StudioMessageComposer(
                      controller: controller.messageInputController,
                      focusNode: controller.messageFocusNode,
                      isLoading: controller.isAiThinkingValue,
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
                VerticalDivider(color: CC.stroke, width: 1),
                Expanded(child: mainContent),
              ],
            ),
          );
        }

        return mainContent;
      },
    );
  }
}
