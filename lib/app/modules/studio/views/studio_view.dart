import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/studio/controllers/studio_controller.dart';
import 'package:lala_ai/app/modules/studio/widgets/pixo_entitlement_modal.dart';
import 'package:lala_ai/app/modules/studio/widgets/pixo_message_bubble_widget.dart';
import 'package:lala_ai/app/modules/studio/widgets/studio_drawer_sidebar.dart';
import 'package:lala_ai/app/modules/studio/widgets/studio_message_composer.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class StudioView extends GetView<StudioController>
    with WidgetsBindingObserver {
  const StudioView({super.key});

  @override
  Widget build(BuildContext context) {
    // Register for app lifecycle events to handle backgrounding (M10 checklist)
    WidgetsBinding.instance.addObserver(this as WidgetsBindingObserver);

    return GetBuilder<ThemeService>(
      builder: (_) {
        final isDesktop = MediaQuery.of(context).size.width >= 800;

        // Watch for ENTITLEMENT_DENIED and show upsell modal reactively.
        ever(controller.streamState, (state) {
          if (state == PixoStreamState.entitlementDenied) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              PixoEntitlementModal.show(
                context,
                message: controller.entitlementMessage.value,
                requiredPlan: controller.requiredPlan.value,
              );
            });
          }
        });

        Widget mainContent = Scaffold(
          backgroundColor: CC.background,
          drawer: isDesktop ? null : const StudioDrawerSidebar(),
          appBar: CW.commonAppbar(
            wantBackIcon: false,
            leadingWidget: isDesktop
                ? null
                : Builder(
                    builder: (scaffoldContext) => IconButton(
                      icon: Icon(Icons.menu_rounded,
                          color: CC.textSecondary, size: 20),
                      splashRadius: 18,
                      tooltip: 'Open History',
                      onPressed: () =>
                          Scaffold.of(scaffoldContext).openDrawer(),
                    ),
                  ),
            titleWidget: Obx(() => _buildStatusChip()),
            actions: [
              IconButton(
                icon: Icon(Icons.add_comment_outlined,
                    color: CC.textPrimary, size: 18),
                splashRadius: 18,
                tooltip: 'New Chat',
                onPressed: controller.startNewChat,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    final messages = controller.pixoMessages;
                    final state = controller.streamState.value;
                    final isThinking = controller.isAiThinkingValue;

                    // ── Empty / Starter state ──
                    if (messages.isEmpty && !isThinking) {
                      return _buildEmptyState();
                    }

                    // ── Active message list ──
                    return ListView.builder(
                      controller: controller.chatScrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      itemCount: messages.length +
                          (state == PixoStreamState.reconnecting ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Reconnecting banner appended at end
                        if (state == PixoStreamState.reconnecting &&
                            index == messages.length) {
                          return const PixoReconnectingBanner();
                        }

                        final msg = messages[index];
                        return PixoMessageBubbleWidget(
                          message: msg,
                          onRegenerate:
                              (index == messages.length - 1 &&
                                      msg.isAssistant &&
                                      !isThinking)
                                  ? controller.regenerateLastMessage
                                  : null,
                          onLike: (liked) =>
                              controller.toggleLikeMessage(msg, liked),
                        );
                      },
                    );
                  }),
                ),

                // ── Message composer with Pixo command support ──
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
                const SizedBox(width: 260, child: StudioDrawerSidebar()),
                VerticalDivider(
                    color: CC.stroke, width: 0.7, thickness: 0.7),
                Expanded(child: mainContent),
              ],
            ),
          );
        }

        return mainContent;
      },
    );
  }

  Widget _buildStatusChip() {
    final state = controller.streamState.value;
    String label = '';
    Color color = CC.primary;

    switch (state) {
      case PixoStreamState.idle:
      case PixoStreamState.completed:
        return const SizedBox.shrink();
      case PixoStreamState.start:
        label = 'Connecting...';
        color = CC.primary;
      case PixoStreamState.contextReady:
        label = 'Fetching context...';
        color = CC.primary;
      case PixoStreamState.toolResult:
        label = 'Processing command...';
        color = CC.primary;
      case PixoStreamState.generating:
        label = 'Generating...';
        color = CC.primary;
      case PixoStreamState.reconnecting:
        label = 'Reconnecting...';
        color = CC.warning;
      case PixoStreamState.error:
        label = 'Error';
        color = CC.error;
      case PixoStreamState.entitlementDenied:
        label = 'Upgrade required';
        color = CC.warning;
      case PixoStreamState.usageLimitReached:
        label = 'Limit reached';
        color = CC.error;
      case PixoStreamState.providerUnavailable:
        label = 'Provider down';
        color = CC.error;
      case PixoStreamState.contextUnavailable:
        label = 'Not found';
        color = CC.error;
      case PixoStreamState.cancelled:
        label = 'Stopped';
        color = CC.textSecondary;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(label),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state == PixoStreamState.generating ||
                state == PixoStreamState.start ||
                state == PixoStreamState.contextReady ||
                state == PixoStreamState.toolResult ||
                state == PixoStreamState.reconnecting)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
            Text(label,
                style: TS.caption(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                    child: Icon(Icons.movie_creation_outlined,
                        color: CC.textPrimary, size: 18),
                  ),
                  10.width,
                  Text('Pixo AI Studio',
                      style: TS.screenTitle(fontSize: 16)),
                ],
              ),
              18.height,
              Text('How can I help?',
                  style: TS.displayLarge(fontSize: 22)),
              6.height,
              Text(
                'Generate scripts, audit creators, discover trends and grow your audience — all via natural language or slash commands.',
                style: TS.subHeading(color: CC.textSecondary),
              ),
              20.height,
              // Command hint chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  '/audit @creator',
                  '/trends',
                  '/script',
                  '/compare',
                  '/plan',
                ].map((cmd) => _CommandHintChip(cmd)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommandHintChip extends StatelessWidget {
  final String label;
  const _CommandHintChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CC.stroke.withValues(alpha: 0.6), width: 0.8),
      ),
      child: Text(
        label,
        style: TS.caption(
            color: CC.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12),
      ),
    );
  }
}
