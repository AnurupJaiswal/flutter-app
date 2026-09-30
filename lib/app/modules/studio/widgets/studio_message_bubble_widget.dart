import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lala_ai/Models/chat_model.dart';
import 'package:lala_ai/app/modules/studio/widgets/studio_code_block_widget.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class StudioMessageBubbleWidget extends StatelessWidget {
  final ChatMessageModel message;
  final VoidCallback? onRegenerate;
  final void Function(bool isLiked)? onLike;
  final void Function(String prompt)? onSuggestedPromptTap;

  const StudioMessageBubbleWidget({
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
        child: message.isUser ? _buildUserMessage(context) : _buildAssistantMessage(context),
      ),
    );
  }

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
                    message.content,
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
                // Header
                Row(
                  children: [
                    Text(
                      "AI Studio",
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
                  ],
                ),

                6.height,

                // Content Stream (Clean, natural reading)
                SelectableText(
                  message.content,
                  style: TS.body(color: CC.textPrimary),
                ),

                // Code Blocks (if any)
                if (message.codeSnippets.isNotEmpty) ...[
                  8.height,
                  ...message.codeSnippets.map((snippet) => StudioCodeBlockWidget(
                        language: snippet.language,
                        code: snippet.code,
                      )),
                ],

                // Follow-up Suggestions
                if (message.suggestedPrompts.isNotEmpty && onSuggestedPromptTap != null) ...[
                  10.height,
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: message.suggestedPrompts.map((prompt) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => onSuggestedPromptTap!(prompt),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: CC.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: CC.stroke, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_forward_rounded, size: 12, color: CC.primary),
                              6.width,
                              Flexible(
                                child: Text(
                                  prompt,
                                  style: TS.caption(
                                    color: CC.textPrimary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                6.height,

                // Minimal Actions Toolbar
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.copy_rounded,
                      tooltip: "Copy",
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: message.content));
                        AppToast.success("Copied to clipboard");
                      },
                    ),
                    if (onRegenerate != null)
                      _buildActionButton(
                        icon: Icons.refresh_rounded,
                        tooltip: "Regenerate",
                        onTap: onRegenerate,
                      ),
                  ],
                ),
              ],
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
