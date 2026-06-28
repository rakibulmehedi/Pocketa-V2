// lib/core/widgets/cards/helm_source_card.dart
// UX-5.10 — Five Card Widgets: HelmSourceCard
//
// Compact card showing payment source + status. Used in pipeline list.
// NO brand logos, NO colored icons, NO colored backgrounds for any status.
// Borders + text only for all status communication.

import 'package:flutter/material.dart';

import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_spacing.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/core/utils/number_formatter.dart';

enum SourceType { payoneer, wise, bank, bkash, nagad, upay, cash, manual }

enum SourceStatus { received, pending, processing, expected }

class HelmSourceCard extends StatelessWidget {
  final SourceType source;
  final SourceStatus status;
  final String label;
  final double? amountBDT;
  final double? amountUSD;
  final double? fxRate;
  final VoidCallback? onTap;

  const HelmSourceCard({
    super.key,
    required this.source,
    required this.status,
    required this.label,
    this.amountBDT,
    this.amountUSD,
    this.fxRate,
    this.onTap,
  });

  static String _sourceLabel(SourceType type) {
    return switch (type) {
      SourceType.payoneer => 'Payoneer',
      SourceType.wise     => 'Wise',
      SourceType.bank     => 'Bank',
      SourceType.bkash    => 'bKash',
      SourceType.nagad    => 'Nagad',
      SourceType.upay     => 'Upay',
      SourceType.cash     => 'Cash',
      SourceType.manual   => 'Manual',
    };
  }

  static String _statusLabel(SourceStatus status) {
    return switch (status) {
      SourceStatus.received   => 'Received',
      SourceStatus.pending    => 'Pending',
      SourceStatus.processing => 'Processing',
      SourceStatus.expected   => 'Expected',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.textStyles;

    final borderRadius = BorderRadius.circular(HelmSpacing.cardRadius);

    final Widget cardContent = Padding(
      padding: const EdgeInsets.all(HelmSpacing.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: source name + status label + detail label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _sourceLabel(source),
                  style: typography.headingSm.copyWith(
                    color: colors.inkPrimary,
                  ),
                ),
                const SizedBox(height: HelmSpacing.s1),
                Text(
                  _statusLabel(status),
                  style: typography.labelSm.copyWith(
                    color: colors.inkSecondary,
                  ),
                ),
                if (label.isNotEmpty) ...[
                  const SizedBox(height: HelmSpacing.s1),
                  Text(
                    label,
                    style: typography.bodySm.copyWith(
                      color: colors.inkTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Right: amounts (if present)
          if (amountBDT != null || amountUSD != null) ...[
            const SizedBox(width: HelmSpacing.s3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (amountBDT != null)
                  Text(
                    NumberFormatter.formatBDT(amountBDT!),
                    style: typography.monoFinancialSm.copyWith(
                      color: colors.inkPrimary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                if (amountUSD != null) ...[
                  if (amountBDT != null)
                    const SizedBox(height: HelmSpacing.s1),
                  Text(
                    NumberFormatter.formatUSD(amountUSD!),
                    style: typography.monoFinancialSm.copyWith(
                      color: colors.inkTertiary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
                if (fxRate != null) ...[
                  const SizedBox(height: HelmSpacing.s1),
                  Text(
                    '@ ${fxRate!.toStringAsFixed(2)}',
                    style: typography.labelSm.copyWith(
                      color: colors.inkTertiary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );

    final Widget decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: borderRadius,
        border: Border.all(
          color: colors.divider,
          width: HelmSpacing.cardBorder,
        ),
      ),
      child: cardContent,
    );

    final semanticsLabel =
        '${_sourceLabel(source)}, ${_statusLabel(status)}'
        '${amountBDT != null ? ', ${NumberFormatter.formatBDT(amountBDT!)}' : ''}';

    if (onTap != null) {
      return Semantics(
        label: semanticsLabel,
        button: true,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            splashColor: colors.interactive.withValues(alpha: 0.06),
            highlightColor: colors.interactive.withValues(alpha: 0.04),
            child: decorated,
          ),
        ),
      );
    }

    return Semantics(
      label: semanticsLabel,
      button: false,
      child: decorated,
    );
  }
}
