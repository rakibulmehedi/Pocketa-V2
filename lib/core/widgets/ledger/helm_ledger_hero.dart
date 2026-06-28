// lib/core/widgets/ledger/helm_ledger_hero.dart
// Paper Ledger — the Safe-to-Spend hero.
// Fraunces number on paper, 3pt runway rail (state color), italic runway line,
// then committed/reserve/pending rows. Tappable -> calculation trace.
// No decorative animation: calm, static, trustworthy.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../themes/helm_colors.dart';
import '../../themes/helm_spacing.dart';
import '../../themes/helm_typography.dart';
import '../../utils/number_formatter.dart';
import 'helm_ledger_row.dart';
import 'ledger_state.dart';

class HelmLedgerHero extends StatelessWidget {
  const HelmLedgerHero({
    required this.safeToSpend,
    required this.state,
    required this.runwayLabel,
    required this.committedValue,
    required this.reserveValue,
    required this.pendingValue,
    required this.onTapTrace,
    this.showUnavailable = false,
    super.key,
  });

  final double safeToSpend;
  final LedgerState state;
  final String runwayLabel;
  final String committedValue;
  final String reserveValue;
  final String pendingValue;
  final VoidCallback onTapTrace;
  final bool showUnavailable;

  Future<void> _handleTap() async {
    await HapticFeedback.lightImpact();
    onTapTrace();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.textStyles;
    final railColor = ledgerStateColor(context, state);

    // H-41: formatBDTCompact now uses '৳ ' prefix (U+09F3); strip the prefix
    // and re-attach without trailing space for tight hero display.
    final amount = showUnavailable
        ? '—' // em dash
        : NumberFormatter.formatBDTCompact(safeToSpend);

    return Semantics(
      label: 'Safe to spend now '
          '${showUnavailable ? 'unavailable' : amount}. '
          '${ledgerStateLabel(state)}. $runwayLabel.',
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Container(
          padding: const EdgeInsets.all(HelmSpacing.s5),
          decoration: BoxDecoration(
            color: colors.canvas,
            borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SAFE TO SPEND NOW',
                style: typography.labelSm.copyWith(color: colors.inkSecondary),
              ),
              const SizedBox(height: HelmSpacing.s2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount,
                  maxLines: 1,
                  style: typography.displayHero.copyWith(color: colors.inkPrimary),
                ),
              ),
              const SizedBox(height: HelmSpacing.s3),
              Container(
                height: 3,
                width: 80,
                decoration: BoxDecoration(
                  color: railColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: HelmSpacing.s3),
              Text(
                runwayLabel,
                style: typography.bodySm.copyWith(
                  color: colors.inkSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: HelmSpacing.s4),
              HelmLedgerRow(label: 'Already committed', value: committedValue),
              HelmLedgerRow(label: 'Reserve · protected', value: reserveValue),
              HelmLedgerRow(
                label: 'Not counted yet',
                value: pendingValue,
                muted: true,
                showDivider: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
