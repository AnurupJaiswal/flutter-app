import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lala_ai/utils/common_methods.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class StudioCodeBlockWidget extends StatefulWidget {
  final String language;
  final String code;

  const StudioCodeBlockWidget({
    super.key,
    required this.language,
    required this.code,
  });

  @override
  State<StudioCodeBlockWidget> createState() => _StudioCodeBlockWidgetState();
}

class _StudioCodeBlockWidgetState extends State<StudioCodeBlockWidget> {
  bool _copied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    CM.showToast("Copied to clipboard");

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: CC.codeBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CC.codeBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: const BoxDecoration(
              color: CC.codeHeader,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
              border: Border(bottom: BorderSide(color: CC.codeBorder, width: 0.8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.language.isNotEmpty ? widget.language.toLowerCase() : "code",
                  style: TS.caption(
                    color: CC.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: _copyToClipboard,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          _copied ? Icons.check_rounded : Icons.copy_rounded,
                          size: 13,
                          color: _copied ? CC.success : CC.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _copied ? "Copied" : "Copy",
                          style: TS.caption(
                            color: _copied ? CC.success : CC.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code text
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: SelectableText.rich(
              _highlightCode(widget.code, widget.language),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.45,
                color: CC.codeText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _highlightCode(String source, String lang) {
    final keywords = {
      'class', 'extends', 'implements', 'import', 'return', 'void', 'final',
      'const', 'override', 'async', 'await', 'if', 'else', 'for', 'while',
      'static', 'bool', 'int', 'double', 'String', 'List', 'Map', 'Set',
      'Future', 'Widget', 'BuildContext', 'State', 'StatefulWidget', 'StatelessWidget',
      'GetxController', 'GetView', 'Obx', 'Get', 'Rx', 'try', 'catch', 'throw'
    };

    final lines = source.split('\n');
    final List<TextSpan> spans = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().startsWith('//') || line.trim().startsWith('#')) {
        spans.add(TextSpan(
          text: line + (i < lines.length - 1 ? '\n' : ''),
          style: TextStyle(color: CC.grey, fontStyle: FontStyle.italic),
        ));
        continue;
      }

      final tokens = line.split(RegExp(r'(?<=\s|[(<>{};:,])|(?=\s|[(<>{};:,])'));
      for (final token in tokens) {
        if (keywords.contains(token.trim())) {
          spans.add(TextSpan(
            text: token,
            style: const TextStyle(color: CC.codeKeyword, fontWeight: FontWeight.w600),
          ));
        } else if (token.startsWith('"') || token.startsWith("'") || token.endsWith('"') || token.endsWith("'")) {
          spans.add(TextSpan(
            text: token,
            style: const TextStyle(color: CC.codeString),
          ));
        } else if (RegExp(r'^\d+$').hasMatch(token.trim())) {
          spans.add(TextSpan(
            text: token,
            style: TextStyle(color: CC.warning),
          ));
        } else {
          spans.add(TextSpan(text: token));
        }
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(children: spans);
  }
}
