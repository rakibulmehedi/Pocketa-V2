// lib/features/spend/presentation/views/spend_screen.dart
// Spend tab — outflows that reduce Safe-to-Spend.
// NOT an expense tracker: no categories, no charts, no budgets (Final Doctrine).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:helm/config/router/route_names.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_spacing.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/core/widgets/helm_amount.dart';
import 'package:helm/core/widgets/helm_icon.dart';
import 'package:helm/core/widgets/cards/helm_ledger_card.dart';
import 'package:helm/features/transactions/domain/entities/transaction_entity.dart';
import 'package:helm/features/transactions/domain/entities/transaction_type.dart';
import 'package:helm/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:helm/l10n/app_localization.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SpendScreen extends ConsumerWidget {
  const SpendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.textStyles;
    final l10n = context.l10n;
    final async = ref.watch(transactionsProvider);

    final expenses = (async.valueOrNull ?? const <TransactionEntity>[])
        .where((t) => t.type == TransactionType.expense)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final total = expenses.fold<double>(0, (sum, t) => sum + t.amount);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: Text(l10n.spendTitle,
            style: typo.headingMd.copyWith(color: colors.inkPrimary)),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (!SharedPrefServices.getGuestMode())
            IconButton(
              key: const ValueKey('spend-audit-link'),
              tooltip: l10n.viewAuditTrail,
              icon: const HelmIcon(LucideIcons.history, size: HelmIconSize.lg),
              onPressed: () => context.push(RouteNames.trace),
            ),
          IconButton(
            key: const ValueKey('spend-settings-gear'),
            tooltip: l10n.settings,
            icon: const HelmIcon(LucideIcons.settings, size: HelmIconSize.lg),
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.addTransaction),
        backgroundColor: colors.interactive,
        foregroundColor: colors.surface,
        elevation: 0,
        tooltip: l10n.spendFabLabel,
        child: HelmIcon(LucideIcons.plus,
            size: HelmIconSize.lg, color: colors.surface),
      ),
      body: SafeArea(
        child: expenses.isEmpty
            ? _Empty(l10n: l10n, typo: typo, colors: colors)
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  HelmSpacing.screenEdge,
                  HelmSpacing.s4,
                  HelmSpacing.screenEdge,
                  100,
                ),
                children: [
                  _SummaryStrip(
                      total: total, l10n: l10n, typo: typo, colors: colors),
                  const SizedBox(height: HelmSpacing.s4),
                  for (final t in expenses) ...[
                    HelmLedgerCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(t.title,
                                style: typo.bodyMd
                                    .copyWith(color: colors.inkPrimary)),
                          ),
                          HelmAmount(amount: t.amount, size: AmountSize.md),
                        ],
                      ),
                    ),
                    const SizedBox(height: HelmSpacing.s3),
                  ],
                ],
              ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  final double total;
  final AppLocalizations l10n;
  final HelmTypography typo;
  final HelmColors colors;

  const _SummaryStrip({
    required this.total,
    required this.l10n,
    required this.typo,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(l10n.spendSummaryLabel,
              style: typo.labelSm.copyWith(color: colors.inkSecondary)),
        ),
        HelmAmount(amount: total, size: AmountSize.md),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  final AppLocalizations l10n;
  final HelmTypography typo;
  final HelmColors colors;

  const _Empty({
    required this.l10n,
    required this.typo,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(HelmSpacing.screenEdge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.spendEmptyTitle,
                style: typo.headingSm.copyWith(color: colors.inkPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: HelmSpacing.s3),
            Text(l10n.spendEmptyBody,
                style: typo.bodyMd.copyWith(color: colors.inkSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
