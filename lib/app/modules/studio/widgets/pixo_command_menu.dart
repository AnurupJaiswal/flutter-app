import 'package:flutter/material.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

// ── Command definitions ────────────────────────────────────────────────────────

class _PixoCommand {
  final String slash;
  final String label;
  final String description;
  final IconData icon;

  const _PixoCommand({
    required this.slash,
    required this.label,
    required this.description,
    required this.icon,
  });
}

const _kCommands = [
  _PixoCommand(
    slash: '/audit',
    label: 'Audit Creator',
    description: 'Analyze a creator\'s performance & health score',
    icon: Icons.analytics_rounded,
  ),
  _PixoCommand(
    slash: '/trends',
    label: 'Discover Trends',
    description: 'Find rising content topics in your niche',
    icon: Icons.trending_up_rounded,
  ),
  _PixoCommand(
    slash: '/script',
    label: 'Generate Script',
    description: 'Write a short-form video script with hooks & CTA',
    icon: Icons.article_rounded,
  ),
];

/// Bottom sheet shown when the user types `/` in the message composer.
///
/// Displays all available Pixo commands.  Selecting one fills the composer
/// with the slash prefix — the backend determines authorization; Flutter never
/// hard-codes paywall logic here.
class PixoCommandMenuSheet extends StatefulWidget {
  final String filter;
  final void Function(String slashPrefix) onCommandSelected;

  const PixoCommandMenuSheet({
    super.key,
    required this.filter,
    required this.onCommandSelected,
  });

  @override
  State<PixoCommandMenuSheet> createState() => _PixoCommandMenuSheetState();
}

class _PixoCommandMenuSheetState extends State<PixoCommandMenuSheet> {
  late List<_PixoCommand> _filtered;

  @override
  void initState() {
    super.initState();
    _applyFilter(widget.filter);
  }

  @override
  void didUpdateWidget(covariant PixoCommandMenuSheet old) {
    super.didUpdateWidget(old);
    if (old.filter != widget.filter) _applyFilter(widget.filter);
  }

  void _applyFilter(String q) {
    final lower = q.toLowerCase();
    _filtered = _kCommands
        .where((c) =>
            c.slash.contains(lower) ||
            c.label.toLowerCase().contains(lower) ||
            c.description.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: CC.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Lala Commands',
                  style: TS.sectionTitle(fontSize: 15, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: CC.primary.withValues(alpha: 0.20), width: 0.6),
                ),
                child: Text('AI Tools',
                    style: TS.caption(
                        color: CC.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10)),
              ),
            ],
          ),
          6.height,
          Text(
            'Select a command to trigger Lala AI capabilities.',
            style: TS.caption(color: CC.textSecondary, fontSize: 11),
          ),
          12.height,
          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No matching commands.',
                  style: TS.bodySmall(color: CC.textSecondary)),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _filtered
                      .map((cmd) => _CommandTile(
                            command: cmd,
                            onTap: () {
                              widget.onCommandSelected('${cmd.slash} ');
                            },
                          ))
                      .toList(),
                ),
              ),
            ),
          4.height,
        ],
      ),
    );
  }
}

class _CommandTile extends StatelessWidget {
  final _PixoCommand command;
  final VoidCallback onTap;
  const _CommandTile({required this.command, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: CC.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: CC.stroke.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CC.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(command.icon, color: CC.primary, size: 18),
                ),
                14.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(command.slash,
                              style: TS.caption(
                                  color: CC.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11)),
                          8.width,
                          Text(command.label,
                              style: TS.bodyMedium(
                                  color: CC.textPrimary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      3.height,
                      Text(command.description,
                          style: TS.caption(
                              color: CC.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: CC.textSecondary, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Entity Typeahead overlay ──────────────────────────────────────────────────

/// Inline popup that appears above the composer when the user types `@`.
///
/// The backend's PixoEntityResolver turns `@mkbhd` into a resolved entity —
/// Flutter just forwards the handle as plain text in the payload.
class PixoEntityTypeahead extends StatelessWidget {
  final String query;
  final List<String> suggestions;
  final void Function(String handle) onSelected;

  const PixoEntityTypeahead({
    super.key,
    required this.query,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: CC.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: suggestions.length,
          itemBuilder: (_, i) {
            final handle = suggestions[i];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(handle),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            CC.primary.withValues(alpha: 0.16),
                        child: Text(
                          handle.isNotEmpty
                              ? handle[0].toUpperCase()
                              : '@',
                          style: TS.caption(
                              color: CC.primary,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      10.width,
                      Expanded(
                        child: Text('@$handle',
                            style: TS.bodySmall(
                                color: CC.textPrimary,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
