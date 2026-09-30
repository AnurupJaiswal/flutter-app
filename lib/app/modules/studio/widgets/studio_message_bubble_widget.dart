import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lala_ai/Models/chat_model.dart';
import 'package:lala_ai/app/modules/studio/widgets/studio_code_block_widget.dart';
import 'package:lala_ai/core/widgets/app_markdown_view.dart';
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
        child: message.isUser
            ? _buildUserMessage(context)
            : _buildAssistantMessage(context),
      ),
    );
  }

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
                message.content,
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

  Widget _buildAssistantMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 6, right: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: CW.aiAvatar(size: 28, isAssistant: true),
          ),
          10.width,
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "AI Studio",
                        style: TS.caption(
                          color: CC.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                      Text(
                        DateFormat('hh:mm a').format(message.timestamp),
                        style: TS.caption(color: CC.grey, fontSize: 10),
                      ),
                    ],
                  ),

                  6.height,

                  // Content Stream (Clean, natural reading)
                  AppMarkdownView(
                    data: message.content,
                    baseStyle: TS.body(color: CC.textPrimary),
                  ),

                  // Code Blocks (if any)
                  if (message.codeSnippets.isNotEmpty) ...[
                    8.height,
                    ...message.codeSnippets.map((snippet) =>
                        StudioCodeBlockWidget(
                          language: snippet.language,
                          code: snippet.code,
                        )),
                  ],

                  // Follow-up Suggestions
                  if (message.suggestedPrompts.isNotEmpty &&
                      onSuggestedPromptTap != null) ...[
                    10.height,
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: message.suggestedPrompts.map((prompt) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => onSuggestedPromptTap!(prompt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: CC.surface,
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: CC.stroke, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_forward_rounded,
                                    size: 12, color: CC.primary),
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        icon: Icons.copy_rounded,
                        tooltip: "Copy",
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: message.content));
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
