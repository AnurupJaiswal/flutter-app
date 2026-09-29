import 'package:flutter/material.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shown when the backend emits `ENTITLEMENT_DENIED`.
///
/// Flutter never hard-codes the paywall — the event data drives the copy.
/// This modal is a pure presentation layer; upgrade logic lives in Java.
class PixoEntitlementModal extends StatelessWidget {
  final String message;
  final String? requiredPlan;

  const PixoEntitlementModal({
    super.key,
    required this.message,
    this.requiredPlan,
  });

  static Future<void> show(
    BuildContext context, {
    required String message,
    String? requiredPlan,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PixoEntitlementModal(
        message: message,
        requiredPlan: requiredPlan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planLabel = requiredPlan ?? 'Pro';

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: BoxDecoration(
          color: CC.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: CC.black.withValues(alpha: 0.30),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: CC.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            20.height,

            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CC.primary.withValues(alpha: 0.18),
                    CC.primary.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                    color: CC.primary.withValues(alpha: 0.25), width: 1.5),
              ),
              child: Icon(Icons.workspace_premium_rounded,
                  color: CC.primary, size: 28),
            ),
            16.height,

            Text(
              'Upgrade to $planLabel',
              style: TS.displayLarge(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            8.height,
            Text(
              message,
              style: TS.subHeading(color: CC.textSecondary),
              textAlign: TextAlign.center,
            ),
            24.height,

            // Feature bullets
            _FeatureBullet(
              icon: Icons.analytics_rounded,
              text: 'Full creator audits with health scores',
            ),
            _FeatureBullet(
              icon: Icons.trending_up_rounded,
              text: 'Real-time trending topic discovery',
            ),
            _FeatureBullet(
              icon: Icons.compare_arrows_rounded,
              text: 'Unlimited creator comparisons',
            ),
            _FeatureBullet(
              icon: Icons.calendar_month_rounded,
              text: 'AI-generated content calendars',
            ),

            24.height,

            // CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CC.primary,
                  foregroundColor: CC.whiteText,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  final uri = Uri.parse(
                      'https://lala-ai-green.vercel.app/auth/get-started?redirect=/checkout');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: Text('Upgrade to $planLabel',
                    style: TS.bodyMedium(
                        color: CC.whiteText, fontWeight: FontWeight.w700)),
              ),
            ),

            12.height,

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Maybe later',
                  style: TS.caption(color: CC.textSecondary, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: CC.primary, size: 15),
          ),
          12.width,
          Expanded(
            child:
                Text(text, style: TS.bodySmall(color: CC.textPrimary)),
          ),
          Icon(Icons.check_circle_rounded,
              size: 15, color: CC.primary.withValues(alpha: 0.6)),
        ],
      ),
    );
  }
}
