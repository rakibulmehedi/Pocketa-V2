// lib/core/widgets/cards/helm_audit_card.dart
// UX-5.10 — Five Card Widgets: HelmAuditCard
//
// Calculation trace card. Values right-aligned, ledger style.
// Labels left-aligned in bodyMd, values right-aligned in monoFinancialSm.
// Final row uses stronger divider above + weight 600 on label and value.
// Subtraction rows format value as "(tk X)" in inkSecondary.
//
// UX Improvements:
//   - Empty state when rows list is empty
//   - Semantics for screen reader support

import 'package:flutter/material.dart';

import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_spacing.dart';
import 'package:helm/core/themes/helm_typography.dart';

class AuditRow {
  final String label;
  final String value;
  final bool isSubtraction;
  final bool isFinal;
  final Color? valueColor;

  const AuditRow({
    required this.label,
    required this.value,
    this.isSubtraction = false,
    this.isFinal = false,
    this.valueColor,
  });
}

class HelmAuditCard extends StatelessWidget {
  final List<AuditRow> rows;
  final String? title;
  final bool isLoading;

  const HelmAuditCard({
    super.key,
    required this.rows,
    this.title,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.textStyles;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
        border: Border.all(
          color: colors.divider,
          width: HelmSpacing.cardBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HelmSpacing.s4),
        child: _buildContent(colors, typography),
      ),
    );
  }

  Widget _buildContent(HelmColors colors, HelmTypography typography) {
    // Loading state
    if (isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Empty state
    if (rows.isEmpty) {
      return Semantics(
        label: 'No calculation data',
        child: SizedBox(
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calculate_outlined,
                size: HelmSpacing.iconLg,
                color: colors.inkTertiary,
              ),
              const SizedBox(height: HelmSpacing.s2),
              Text(
                'No calculation data',
                style: typography.bodySm.copyWith(
                  color: colors.inkTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Content with optional title
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: typography.headingSm.copyWith(
              color: colors.inkPrimary,
            ),
          ),
          const SizedBox(height: HelmSpacing.s3),
          Divider(
            color: colors.divider,
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: HelmSpacing.s3),
        ],
        ...List.generate(rows.length, (index) {
          final row = rows[index];
          final isFirst = index == 0;
          final isLast = index == rows.length - 1;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isFirst) ...[
                Divider(
                  color: row.isFinal ? colors.divider : colors.hairline,
                  height: 1,
                  thickness: 1,
                ),
                SizedBox(
                  height: row.isFinal
                      ? HelmSpacing.s3
                      : HelmSpacing.s2,
                ),
              ],
              Semantics(
                label: '${row.label}: ${row.value}',
                child: _AuditRowWidget(
                  row: row,
                  colors: colors,
                  typography: typography,
                ),
              ),
              if (!isLast)
                SizedBox(
                  height: row.isFinal
                      ? HelmSpacing.s3
                      : HelmSpacing.s2,
                ),
            ],
          );
        }),
      ],
    );
  }
}

class _AuditRowWidget extends StatelessWidget {
  final AuditRow row;
  final HelmColors colors;
  final HelmTypography typography;

  const _AuditRowWidget({
    required this.row,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = row.isFinal
        ? typography.bodyMd.copyWith(
            color: colors.inkPrimary,
            fontWeight: FontWeight.w600,
          )
        : typography.bodyMd.copyWith(color: colors.inkPrimary);

    final String displayValue =
        row.isSubtraction ? '(${row.value})' : row.value;

    Color resolvedValueColor;
    if (row.valueColor != null) {
      resolvedValueColor = row.valueColor!;
    } else if (row.isSubtraction) {
      resolvedValueColor = colors.inkSecondary;
    } else {
      resolvedValueColor = colors.inkPrimary;
    }

    final valueStyle = row.isFinal
        ? typography.monoFinancialSm.copyWith(
            color: resolvedValueColor,
            fontWeight: FontWeight.w600,
          )
        : typography.monoFinancialSm.copyWith(color: resolvedValueColor);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            row.label,
            style: labelStyle,
          ),
        ),
        const SizedBox(width: HelmSpacing.s3),
        Text(
          displayValue,
          style: valueStyle,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}