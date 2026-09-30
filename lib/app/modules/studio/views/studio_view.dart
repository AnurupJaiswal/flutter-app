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
            titleWidget: Obx(() => _buildStatusChip(_ctrl.streamState.value)),
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

  Widget _buildStatusChip(PixoStreamState state) {
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

    final isSpinning = state == PixoStreamState.generating ||
        state == PixoStreamState.start ||
        state == PixoStreamState.contextReady ||
        state == PixoStreamState.toolResult ||
        state == PixoStreamState.reconnecting;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(label),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSpinning)
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
