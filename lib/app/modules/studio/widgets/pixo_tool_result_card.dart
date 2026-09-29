import 'package:flutter/material.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

/// Renders structured TOOL_RESULT payloads as premium Flutter widgets.
///
/// This widget is the exclusive rendering path for `PixoToolResultEvent`
/// payloads.  It auto-detects the command type from the payload shape
/// and renders the appropriate card.
///
/// Golden Rule: Never try to parse these out of TOKEN markdown text.
class PixoToolResultCard extends StatelessWidget {
  final Map<String, dynamic> payload;

  const PixoToolResultCard({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    final type = _detectType(payload);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CC.primary.withValues(alpha: 0.06),
            CC.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CC.primary.withValues(alpha: CC.isDark ? 0.22 : 0.18),
          width: 1,
        ),
      ),
      child: switch (type) {
        _ToolType.audit => _AuditCard(payload: payload),
        _ToolType.trends => _TrendsCard(payload: payload),
        _ToolType.compare => _CompareCard(payload: payload),
        _ToolType.script => _ScriptCard(payload: payload),
        _ToolType.plan => _PlanCard(payload: payload),
        _ToolType.generic => _GenericCard(payload: payload),
      },
    );
  }

  _ToolType _detectType(Map<String, dynamic> p) {
    if (p.containsKey('audit') ||
        p.containsKey('followers') ||
        p.containsKey('engagement_rate') ||
        p.containsKey('creatorHandle')) return _ToolType.audit;
    if (p.containsKey('trends') ||
        p.containsKey('trending_topics')) return _ToolType.trends;
    if (p.containsKey('comparison') ||
        p.containsKey('creator_a') ||
        p.containsKey('creator_b')) return _ToolType.compare;
    if (p.containsKey('script') ||
        p.containsKey('hook') ||
        p.containsKey('scenes')) return _ToolType.script;
    if (p.containsKey('plan') ||
        p.containsKey('calendar') ||
        p.containsKey('schedule')) return _ToolType.plan;
    return _ToolType.generic;
  }
}

enum _ToolType { audit, trends, compare, script, plan, generic }

// ── Audit Card ────────────────────────────────────────────────────────────────

class _AuditCard extends StatelessWidget {
  final Map<String, dynamic> payload;
  const _AuditCard({required this.payload});

  @override
  Widget build(BuildContext context) {
    final audit = payload['audit'] as Map? ?? payload;
    final handle = audit['creatorHandle']?.toString() ??
        payload['creatorHandle']?.toString() ??
        'Creator';
    final followers = _fmt(audit['followers'] ?? audit['followerCount']);
    final engagement =
        audit['engagement_rate']?.toString() ?? audit['engagementRate']?.toString() ?? '–';
    final views = _fmt(audit['avg_views'] ?? audit['avgViews']);
    final growth = audit['growth_rate']?.toString() ??
        audit['growthRate']?.toString() ??
        audit['monthlyGrowth']?.toString();
    final score = audit['health_score'] ?? audit['healthScore'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.analytics_rounded, color: CC.primary, size: 18),
              ),
              10.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Creator Audit',
                        style: TS.caption(
                            color: CC.primary, fontWeight: FontWeight.w700)),
                    Text('@$handle',
                        style: TS.sectionTitle(fontSize: 15)),
                  ],
                ),
              ),
              if (score != null)
                _ScoreBadge(score: score),
            ],
          ),
          14.height,

          // ── Stats grid ──
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (followers != null) _StatChip(label: 'Followers', value: followers, icon: Icons.people_rounded),
              if (engagement != '–') _StatChip(label: 'Engagement', value: '$engagement%', icon: Icons.favorite_rounded),
              if (views != null) _StatChip(label: 'Avg Views', value: views, icon: Icons.play_circle_rounded),
              if (growth != null) _StatChip(label: 'Monthly Growth', value: '$growth%', icon: Icons.trending_up_rounded),
            ],
          ),

          // ── Extra fields ──
          if (audit.isNotEmpty) ...[
            12.height,
            _ExtraFields(data: audit, exclude: {
              'creatorHandle', 'followers', 'followerCount', 'engagement_rate',
              'engagementRate', 'avg_views', 'avgViews', 'growth_rate',
              'growthRate', 'monthlyGrowth', 'health_score', 'healthScore',
            }),
          ],
        ],
      ),
    );
  }

  String? _fmt(dynamic v) {
    if (v == null) return null;
    final n = num.tryParse(v.toString());
    if (n == null) return v.toString();
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }
}

// ── Trends Card ───────────────────────────────────────────────────────────────

class _TrendsCard extends StatelessWidget {
  final Map<String, dynamic> payload;
  const _TrendsCard({required this.payload});

  @override
  Widget build(BuildContext context) {
    final items = <String>[];
    final rawTrends = payload['trends'] ?? payload['trending_topics'] ?? [];
    if (rawTrends is List) {
      for (final t in rawTrends) {
        if (t is String) items.add(t);
        if (t is Map) items.add(t['topic']?.toString() ?? t['name']?.toString() ?? t.toString());
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.trending_up_rounded, color: CC.primary, size: 18),
              ),
              10.width,
              Text('Rising Trends', style: TS.sectionTitle(fontSize: 15)),
            ],
          ),
          14.height,
          if (items.isEmpty)
            Text('No trends data available.',
                style: TS.bodySmall(color: CC.textSecondary))
          else
            ...items.asMap().entries.map((e) => _TrendRow(
                  rank: e.key + 1,
                  topic: e.value,
                )),
          if (payload['category'] != null) ...[
            10.height,
            _LabelChip(label: 'Category', value: payload['category'].toString()),
          ],
        ],
      ),
    );
  }
}

// ── Compare Card ──────────────────────────────────────────────────────────────

class _CompareCard extends StatelessWidget {
  final Map<String, dynamic> payload;
  const _CompareCard({required this.payload});

  @override
  Widget build(BuildContext context) {
    final comp = payload['comparison'] as Map? ?? payload;
    final aData = comp['creator_a'] as Map? ?? comp['creatorA'] as Map? ?? {};
    final bData = comp['creator_b'] as Map? ?? comp['creatorB'] as Map? ?? {};
    final aName = aData['handle']?.toString() ?? aData['name']?.toString() ?? 'Creator A';
    final bName = bData['handle']?.toString() ?? bData['name']?.toString() ?? 'Creator B';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.compare_arrows_rounded, color: CC.primary, size: 18),
              ),
              10.width,
              Text('Creator Comparison', style: TS.sectionTitle(fontSize: 15)),
            ],
          ),
          14.height,
          Row(
            children: [
              Expanded(child: _CreatorColumn(name: '@$aName', data: aData)),
              Container(width: 1, height: 80, color: CC.stroke),
              Expanded(child: _CreatorColumn(name: '@$bName', data: bData)),
            ],
          ),
          if (comp['winner'] != null) ...[
            12.height,
            Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: CC.warning, size: 16),
                6.width,
                Text('Winner: ${comp['winner']}',
                    style: TS.bodySmall(
                        color: CC.warning, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Script Card ───────────────────────────────────────────────────────────────

class _ScriptCard extends StatelessWidget {
  final Map<String, dynamic> payload;
  const _ScriptCard({required this.payload});

  @override
  Widget build(BuildContext context) {
    final hook = payload['hook']?.toString() ?? '';
    final body = payload['body']?.toString() ?? payload['script']?.toString() ?? '';
    final cta = payload['cta']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.article_rounded, color: CC.primary, size: 18),
              ),
              10.width,
              Text('Video Script', style: TS.sectionTitle(fontSize: 15)),
            ],
          ),
          14.height,
          if (hook.isNotEmpty) _ScriptSection(label: 'Hook', text: hook),
          if (body.isNotEmpty) _ScriptSection(label: 'Body', text: body),
          if (cta.isNotEmpty) _ScriptSection(label: 'CTA', text: cta),
        ],
      ),
    );
  }
}

// ── Plan Card ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> payload;
  const _PlanCard({required this.payload});

  @override
  Widget build(BuildContext context) {
    final items = <String>[];
    final raw = payload['schedule'] ?? payload['plan'] ?? payload['calendar'] ?? [];
    if (raw is List) {
      for (final t in raw) {
        if (t is String) items.add(t);
        if (t is Map) {
          items.add([t['day'], t['date'], t['topic'], t['platform']]
              .whereType<String>()
              .join(' · '));
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.calendar_month_rounded, color: CC.primary, size: 18),
              ),
              10.width,
              Text('Content Calendar', style: TS.sectionTitle(fontSize: 15)),
            ],
          ),
          14.height,
          if (items.isEmpty)
            Text('Calendar data unavailable.',
                style: TS.bodySmall(color: CC.textSecondary))
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.radio_button_checked_rounded,
                          size: 12, color: CC.primary),
                      8.width,
                      Expanded(
                          child: Text(item,
                              style: TS.bodySmall(color: CC.textPrimary))),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

// ── Generic Card (fallback) ───────────────────────────────────────────────────

class _GenericCard extends StatelessWidget {
  final Map<String, dynamic> payload;
  const _GenericCard({required this.payload});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.data_object_rounded, color: CC.primary, size: 18),
              ),
              10.width,
              Text('Result', style: TS.sectionTitle(fontSize: 15)),
            ],
          ),
          12.height,
          _ExtraFields(data: payload, exclude: {}),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatChip({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: CC.background,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: CC.stroke.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: CC.primary),
              4.width,
              Text(label,
                  style: TS.caption(color: CC.textSecondary, fontSize: 10)),
            ],
          ),
          3.height,
          Text(value,
              style: TS.sectionTitle(
                  fontSize: 14, color: CC.textPrimary)),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final dynamic score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final val = num.tryParse(score.toString()) ?? 0;
    final color = val >= 80
        ? Colors.green
        : val >= 50
            ? CC.warning
            : CC.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text('$score/100',
          style: TS.caption(
              color: color, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}

class _TrendRow extends StatelessWidget {
  final int rank;
  final String topic;
  const _TrendRow({required this.rank, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text('#$rank',
                style: TS.caption(
                    color: CC.primary, fontWeight: FontWeight.w700)),
          ),
          8.width,
          Expanded(
              child: Text(topic,
                  style: TS.bodySmall(color: CC.textPrimary))),
          Icon(Icons.trending_up_rounded, size: 14, color: CC.primary),
        ],
      ),
    );
  }
}

class _CreatorColumn extends StatelessWidget {
  final String name;
  final Map data;
  const _CreatorColumn({required this.name, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(name,
              style: TS.bodyMedium(
                  color: CC.primary, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
          6.height,
          if (data['followers'] != null)
            Text(_fmt(data['followers']),
                style: TS.sectionTitle(fontSize: 16)),
          if (data['engagement_rate'] != null ||
              data['engagementRate'] != null)
            Text(
                '${data['engagement_rate'] ?? data['engagementRate']}% eng.',
                style: TS.caption(color: CC.textSecondary)),
        ],
      ),
    );
  }

  String _fmt(dynamic v) {
    final n = num.tryParse(v.toString());
    if (n == null) return v.toString();
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }
}

class _ScriptSection extends StatelessWidget {
  final String label;
  final String text;
  const _ScriptSection({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TS.caption(
                  color: CC.primary, fontWeight: FontWeight.w700, fontSize: 10)),
          4.height,
          Text(text, style: TS.bodySmall(color: CC.textPrimary)),
        ],
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  final String label;
  final String value;
  const _LabelChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ',
            style: TS.caption(color: CC.textSecondary, fontSize: 11)),
        Text(value,
            style: TS.caption(
                color: CC.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 11)),
      ],
    );
  }
}

class _ExtraFields extends StatelessWidget {
  final Map data;
  final Set<String> exclude;
  const _ExtraFields({required this.data, required this.exclude});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries
        .where((e) =>
            !exclude.contains(e.key.toString()) &&
            e.value != null &&
            e.value.toString().isNotEmpty &&
            e.value is! Map &&
            e.value is! List)
        .toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: entries.map((e) {
        return _LabelChip(
          label: _humanize(e.key.toString()),
          value: e.value.toString(),
        );
      }).toList(),
    );
  }

  String _humanize(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((w) => w.isEmpty
            ? ''
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
