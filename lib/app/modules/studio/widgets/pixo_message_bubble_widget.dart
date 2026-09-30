import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lala_ai/app/modules/studio/data/pixo_message.dart';
import 'package:lala_ai/app/modules/studio/widgets/pixo_tool_result_card.dart';
import 'package:lala_ai/core/widgets/app_markdown_view.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

/// Renders a single Pixo message in the conversation list with a sleek modern design.
class PixoMessageBubbleWidget extends StatelessWidget {
  final PixoMessage message;
  final VoidCallback? onRegenerate;
  final void Function(bool isLiked)? onLike;
  final void Function(String prompt)? onSuggestedPromptTap;

  const PixoMessageBubbleWidget({
    super.key,
    required this.message,
    this.onRegenerate,
    this.onLike,
    this.onSuggestedPromptTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: message.isUser
            ? _buildUserMessage(context)
            : _buildAssistantMessage(context),
      ),
    );
  }

  // ── Modern User Bubble ───────────────────────────────────────────────────

  Widget _buildUserMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18, left: 48, right: 6),
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: CC.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: CC.primary.withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                message.textContent,
                style: TS.body(color: Colors.white).copyWith(
                  height: 1.38,
                  letterSpacing: -0.1,
                ),
              ),
              4.height,
              Text(
                DateFormat('hh:mm a').format(message.timestamp),
                style: TS.caption(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Modern Assistant Bubble ──────────────────────────────────────────────

  Widget _buildAssistantMessage(BuildContext context) {
    final hasContent = message.textContent.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 6, right: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Brand Avatar
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: CW.aiAvatar(size: 28, isAssistant: true),
          ),
          10.width,
          // Assistant Message Bubble Container
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
              decoration: BoxDecoration(
                color: CC.isDark
                    ? const Color(0xFF191A1E)
                    : const Color(0xFFF3F5F8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                  color: CC.isDark
                      ? const Color(0xFF28292E)
                      : const Color(0xFFE5E8ED),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lala AI',
                            style: TS.caption(
                              color: CC.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11.5,
                            ),
                          ),
                          if (message.isStreaming) ...[
                            8.width,
                            SizedBox(
                              width: 9,
                              height: 9,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.4,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(CC.primary),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        DateFormat('hh:mm a').format(message.timestamp),
                        style: TS.caption(color: CC.grey, fontSize: 10),
                      ),
                    ],
                  ),

                  6.height,

                  // Tool result payload (Audit, trends, compare card)
                  if (message.hasToolResult) ...[
                    PixoToolResultCard(payload: message.toolResultPayload!),
                    if (hasContent) 8.height,
                  ],

                  // Conversational Text / Markdown
                  if (hasContent) ...[
                    _buildTextContent(),
                  ] else if (message.isStreaming && !message.hasToolResult) ...[
                    _buildStreamingPlaceholder(),
                  ],

                  // Action toolbar (compact bottom-right aligned)
                  if (!message.isStreaming && hasContent) ...[
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildActionButton(
                          icon: Icons.copy_rounded,
                          tooltip: 'Copy',
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: message.textContent),
                            );
                            AppToast.success('Copied to clipboard');
                          },
                        ),
                        if (onRegenerate != null)
                          _buildActionButton(
                            icon: Icons.refresh_rounded,
                            tooltip: 'Regenerate',
                            onTap: onRegenerate,
                          ),
                        if (onLike != null) ...[
                          _buildActionButton(
                            icon: message.isLiked == true
                                ? Icons.thumb_up_alt_rounded
                                : Icons.thumb_up_off_alt_rounded,
                            color: message.isLiked == true
                                ? CC.primary
                                : CC.grey,
                            tooltip: 'Helpful',
                            onTap: () => onLike!(true),
                          ),
                          _buildActionButton(
                            icon: message.isLiked == false
                                ? Icons.thumb_down_alt_rounded
                                : Icons.thumb_down_off_alt_rounded,
                            color: message.isLiked == false
                                ? CC.error
                                : CC.grey,
                            tooltip: 'Not helpful',
                            onTap: () => onLike!(false),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return AppMarkdownView(
      data: message.textContent,
      baseStyle: TS.body(color: CC.textPrimary).copyWith(
        height: 1.45,
      ),
    );
  }

  Widget _buildStreamingPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BlinkingDot(),
          5.width,
          _BlinkingDot(delay: const Duration(milliseconds: 200)),
          5.width,
          _BlinkingDot(delay: const Duration(milliseconds: 400)),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 14, color: color ?? CC.grey),
        ),
      ),
    );
  }
}

// ── Animated blinking dot ─────────────────────────────────────────────────────

class _BlinkingDot extends StatefulWidget {
  final Duration delay;
  const _BlinkingDot({this.delay = Duration.zero});

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: CC.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Reconnecting banner ───────────────────────────────────────────────────────

/// Shown in the message list footer when [PixoStreamState.reconnecting].
class PixoReconnectingBanner extends StatelessWidget {
  const PixoReconnectingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: CC.warning.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: CC.warning.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(CC.warning),
                ),
              ),
              10.width,
              Text(
                'Connection lost — restoring conversation...',
                style: TS.caption(color: CC.warning, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
