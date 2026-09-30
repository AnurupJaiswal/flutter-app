import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

/// AppMarkdownView — Standardized, rich markdown renderer matching Lala AI typography & theme.
class AppMarkdownView extends StatelessWidget {
  final String data;
  final TextStyle? baseStyle;
  final Color? textColor;
  final bool selectable;

  const AppMarkdownView({
    super.key,
    required this.data,
    this.baseStyle,
    this.textColor,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? CC.textPrimary;
    final defaultStyle = baseStyle ?? TS.body(color: effectiveTextColor);

    return MarkdownBody(
      data: data,
      selectable: selectable,
      styleSheet: MarkdownStyleSheet(
        p: defaultStyle,
        pPadding: const EdgeInsets.only(bottom: 6),
        strong: defaultStyle.copyWith(
          fontWeight: FontWeight.w700,
          color: effectiveTextColor,
        ),
        em: defaultStyle.copyWith(
          fontStyle: FontStyle.italic,
        ),
        h1: TS.displayLarge(color: effectiveTextColor),
        h2: TS.screenTitle(color: effectiveTextColor),
        h3: TS.headingLarge(color: effectiveTextColor),
        h4: TS.sectionTitle(color: effectiveTextColor),
        h5: TS.headingMedium(color: effectiveTextColor),
        h6: TS.subHeading(color: effectiveTextColor, fontWeight: FontWeight.w600),
        listBullet: defaultStyle.copyWith(
          color: effectiveTextColor,
          fontWeight: FontWeight.w600,
        ),
        listBulletPadding: const EdgeInsets.only(right: 6),
        listIndent: 16.0,
        blockquote: TS.body(color: CC.textSecondary),
        blockquoteDecoration: BoxDecoration(
          color: CC.surface,
          border: Border(left: BorderSide(color: CC.primary, width: 3)),
          borderRadius: BorderRadius.circular(4),
        ),
        blockquotePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        code: TextStyle(
          fontFamily: 'Courier',
          fontSize: 12,
          color: CC.primary,
          backgroundColor: CC.primary.withValues(alpha: 0.08),
        ),
        codeblockDecoration: BoxDecoration(
          color: CC.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CC.stroke, width: 0.8),
        ),
        tableBody: TS.bodySmall(color: effectiveTextColor),
        tableHead: TS.caption(color: effectiveTextColor, fontWeight: FontWeight.w600),
        tableBorder: TableBorder.all(color: CC.stroke, width: 0.8),
        tableCellsPadding: const EdgeInsets.all(8),
        a: defaultStyle.copyWith(
          color: CC.primary,
          decoration: TextDecoration.underline,
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null && href.isNotEmpty) {
          final uri = Uri.tryParse(href);
          if (uri != null) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
    );
  }
}
