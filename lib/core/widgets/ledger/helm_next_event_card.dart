// lib/core/widgets/ledger/helm_next_event_card.dart
// Paper Ledger — the one "next event" card. Paper surface, terracotta action.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../themes/helm_colors.dart';
import '../../themes/helm_spacing.dart';
import '../../themes/helm_typography.dart';
import '../../../l10n/app_localization.dart';

class HelmNextEventCard extends StatelessWidget {
  const HelmNextEventCard({
    required this.eventLabel,
    required this.eventTitle,
    required this.actionLabel,
    required this.onAction,
    this.onTrace,
    super.key,
  });

  final String eventLabel;
  final String eventTitle;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback? onTrace;

  Future<void> _handleAction() async {
    await HapticFeedback.lightImpact();
    onAction();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.textStyles;

    return Container(
      padding: const EdgeInsets.all(HelmSpacing.s5),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
        border: Border.all(color: colors.divider, width: HelmSpacing.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eventLabel,
            style: typography.labelSm.copyWith(color: colors.inkTertiary),
          ),
          const SizedBox(height: HelmSpacing.s2),
          Text(
            eventTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: typography.headingSm.copyWith(color: colors.inkPrimary),
          ),
          const SizedBox(height: HelmSpacing.s4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleAction,
              child: Text(actionLabel, textAlign: TextAlign.center),
            ),
          ),
          if (onTrace != null) ...[
            const SizedBox(height: HelmSpacing.s1),
            TextButton(
                onPressed: onTrace,
                child: Text(context.l10n.viewTrace)),
          ],
        ],
      ),
    );
  }
}
