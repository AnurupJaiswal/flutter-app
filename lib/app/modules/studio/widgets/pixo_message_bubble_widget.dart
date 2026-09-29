import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lala_ai/app/modules/studio/data/pixo_message.dart';
import 'package:lala_ai/app/modules/studio/widgets/pixo_tool_result_card.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

/// Renders a single Pixo message in the conversation list.
///
/// Golden rule (M10.4):
/// - [PixoRenderMode.toolResult] → [PixoToolResultCard] structured widget
/// - [PixoRenderMode.text] / [PixoRenderMode.streaming] → markdown text bubble
///
/// A single message can contain BOTH (tool result card above, text below).
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

  // ── User bubble ───────────────────────────────────────────────────────────

  Widget _buildUserMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 56),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: CC.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(2),
                ),
                border: Border.all(color: CC.stroke, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: CC.black.withOpacityValue(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SelectableText(
                    message.textContent,
                    style: TS.body(color: CC.textPrimary),
                  ),
                  4.height,
                  Text(
                    DateFormat('hh:mm a').format(message.timestamp),
                    style: TS.caption(color: CC.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          8.width,
          CW.aiAvatar(size: 26, isAssistant: false),
        ],
      ),
    );
  }

  // ── Assistant bubble ──────────────────────────────────────────────────────

  Widget _buildAssistantMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CW.aiAvatar(size: 26, isAssistant: true),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──
                Row(
                  children: [
                    Text(
                      'Pixo AI',
                      style: TS.caption(
                        color: CC.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    8.width,
                    Text(
                      DateFormat('hh:mm a').format(message.timestamp),
                      style: TS.caption(color: CC.grey, fontSize: 10),
                    ),
                    if (message.isStreaming) ...[
                      8.width,
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(CC.primary),
                        ),
                      ),
                    ],
                  ],
                ),

                6.height,

                // ── TOOL_RESULT rendering path (M10.4) ──
                // Rendered ABOVE conversational text — never parse from tokens.
                if (message.hasToolResult) ...[
                  PixoToolResultCard(
                      payload: message.toolResultPayload!),
                ],

                // ── Error state ──
                if (message.hasError) ...[
                  _buildErrorBubble(),
                ] else if (message.textContent.isNotEmpty) ...[
                  // ── TOKEN rendering path (M10.4) ──
                  // Markdown text streamed from TOKEN events.
                  _buildTextContent(),
                ] else if (message.isStreaming &&
                    !message.hasToolResult) ...[
                  // Still waiting for first token
                  _buildStreamingPlaceholder(),
                ],

                6.height,

                // ── Action toolbar ──
                if (!message.isStreaming)
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.copy_rounded,
                        tooltip: 'Copy',
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: message.textContent));
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return SelectableText(
      message.textContent,
      style: TS.body(color: CC.textPrimary),
    );
  }

  Widget _buildStreamingPlaceholder() {
    return Row(
      children: [
        _BlinkingDot(),
        4.width,
        _BlinkingDot(delay: const Duration(milliseconds: 200)),
        4.width,
        _BlinkingDot(delay: const Duration(milliseconds: 400)),
      ],
    );
  }

  Widget _buildErrorBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CC.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CC.error.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: CC.error, size: 14),
          8.width,
          Expanded(
            child: Text(
              message.errorMessage ??
                  'Something went wrong. Please try again.',
              style: TS.bodySmall(color: CC.error),
            ),
          ),
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
    return IconButton(
      visualDensity: VisualDensity.compact,
      iconSize: 15,
      splashRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      icon: Icon(icon, color: color ?? CC.grey),
      tooltip: tooltip,
      onPressed: onTap,
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
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
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
                color: CC.warning.withValues(alpha: 0.25), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(CC.warning),
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
