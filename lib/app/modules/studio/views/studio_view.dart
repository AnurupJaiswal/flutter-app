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

class StudioView extends StatefulWidget {
  const StudioView({super.key});

  @override
  State<StudioView> createState() => _StudioViewState();
}

class _StudioViewState extends State<StudioView> with WidgetsBindingObserver {
  late final StudioController _ctrl;
  Worker? _entitlementWorker;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<StudioController>();
    WidgetsBinding.instance.addObserver(this);

    // Watch for ENTITLEMENT_DENIED and show upsell modal reactively.
    _entitlementWorker = ever(_ctrl.streamState, (state) {
      if (state == PixoStreamState.entitlementDenied && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            PixoEntitlementModal.show(
              context,
              message: _ctrl.entitlementMessage.value,
              requiredPlan: _ctrl.requiredPlan.value,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _entitlementWorker?.dispose();
    super.dispose();
  }

  // ── App lifecycle — backgrounding / resuming (M10 checklist) ──────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _ctrl.onAppResumed();
    }
  }

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
                      icon: Icon(Icons.menu_rounded,
                          color: CC.textSecondary, size: 20),
                      splashRadius: 18,
                      tooltip: 'Open History',
                      onPressed: () =>
                          Scaffold.of(scaffoldContext).openDrawer(),
                    ),
                  ),
            actions: [
              IconButton(
                icon: Icon(Icons.add_comment_outlined,
                    color: CC.textPrimary, size: 18),
                splashRadius: 18,
                tooltip: 'New Chat',
                onPressed: _ctrl.startNewChat,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    final messages = _ctrl.pixoMessages;
                    final state = _ctrl.streamState.value;
                    final isThinking = _ctrl.isAiThinkingValue;

                    // ── Empty / Starter state ──
                    if (messages.isEmpty && !isThinking) {
                      return _buildEmptyState();
                    }

                    // ── Active message list ──
                    return ListView.builder(
                      controller: _ctrl.chatScrollController,
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
                                  ? _ctrl.regenerateLastMessage
                                  : null,
                        );
                      },
                    );
                  }),
                ),

                // ── Message composer with Pixo command support ──
                Obx(() => StudioMessageComposer(
                      controller: _ctrl.messageInputController,
                      focusNode: _ctrl.messageFocusNode,
                      isLoading: _ctrl.isAiThinkingValue,
                      onSend: () => _ctrl.sendMessage(),
                      onStop: _ctrl.stopGenerating,
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: CC.primary.withValues(alpha: 0.20), width: 0.8),
                ),
                child: Text(
                  'Lala AI Studio',
                  style: TS.caption(
                      color: CC.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
              ),
              16.height,
              Text(
                'How can I help you today?',
                style: TS.displayLarge(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              8.height,
              Text(
                'Generate scripts, audit creators, discover trends and grow your audience — all powered by Lala AI.',
                style: TS.subHeading(color: CC.textSecondary).copyWith(height: 1.4),
              ),
              24.height,
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: [
                  '/audit @creator',
                  '/trends',
                  '/script',
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
    return GestureDetector(
      onTap: () {
        final ctrl = Get.find<StudioController>();
        ctrl.messageInputController.text = '$label ';
        ctrl.messageInputController.selection = TextSelection.fromPosition(
          TextPosition(offset: ctrl.messageInputController.text.length),
        );
        ctrl.messageFocusNode.requestFocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: CC.surface,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: CC.stroke.withValues(alpha: 0.6), width: 0.8),
        ),
        child: Text(
          label,
          style: TS.caption(
              color: CC.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12),
        ),
      ),
    );
  }
}
