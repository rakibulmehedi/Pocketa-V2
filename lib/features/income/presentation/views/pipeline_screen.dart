// lib/features/income/presentation/views/pipeline_screen.dart
//
// UX-3.04 — Pipeline Quick-Update: dedicated pipeline management tab.
//
// Replaces IncomeListScreen at /pipeline route.
// Groups entries by state: Overdue → Pending → Expected → Received (collapsed).
// Each group shows count + total. Overdue at top with urgent styling.
// FAB: "+ Expected" label if < 5 entries, icon-only otherwise (PIPE-014).
//
// Tap any non-received card → ConfirmReceivedSheet (via PipelineEntryCard).
// Long-press any card → "Duplicate as next month" (via PipelineEntryCard).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:helm/config/router/route_names.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_spacing.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/core/widgets/helm_icon.dart';
import 'package:helm/features/income/domain/entities/income_entry_entity.dart';
import 'package:helm/features/income/presentation/providers/income_providers.dart';
import 'package:helm/features/income/presentation/widgets/pipeline_entry_card.dart';
import 'package:helm/l10n/app_localization.dart';

class PipelineScreen extends ConsumerWidget {
  const PipelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.textStyles;
    final l10n = context.l10n;
    final entries = ref.watch(incomeNotifierProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Partition entries into buckets
    final overdueBase = entries.where((e) =>
        e.status != IncomeStatus.received &&
        !e.excludeFromCalculation &&
        e.expectedDate.isBefore(today));

    // PIPE-013: 30+ days overdue → own "Needs decision" header (requires action)
    final needsDecision = overdueBase
        .where((e) => today.difference(e.expectedDate).inDays >= 30)
        .toList()
      ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));

    final overdue = overdueBase
        .where((e) => today.difference(e.expectedDate).inDays < 30)
        .toList()
      ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));

    final pending = entries
        .where((e) =>
            e.status == IncomeStatus.pending &&
            !e.expectedDate.isBefore(today))
        .toList()
      ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));

    final expected = entries
        .where((e) =>
            e.status == IncomeStatus.expected &&
            !e.expectedDate.isBefore(today))
        .toList()
      ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));

    final received = entries
        .where((e) => e.status == IncomeStatus.received)
        .toList()
      ..sort((a, b) => b.receivedDate!.compareTo(a.receivedDate!));

    final hasAny = entries.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.pipelineTitle,
          style: typo.headingSm.copyWith(color: colors.inkPrimary),
        ),
        centerTitle: false,
        actions: [
          if (!SharedPrefServices.getGuestMode())
            IconButton(
              key: const ValueKey('pipeline-audit-link'),
              tooltip: l10n.viewAuditTrail,
              icon: const HelmIcon(LucideIcons.history, size: HelmIconSize.lg),
              onPressed: () => context.push(RouteNames.trace),
            ),
          IconButton(
            key: const ValueKey('pipeline-settings-gear'),
            tooltip: l10n.settings,
            icon: const HelmIcon(LucideIcons.settings, size: HelmIconSize.lg),
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      floatingActionButton: _PipelineFab(entryCount: entries.length),
      body: hasAny
          ? ListView(
              padding: const EdgeInsets.fromLTRB(
                HelmSpacing.screenEdge,
                0,
                HelmSpacing.screenEdge,
                HelmSpacing.s6,
              ),
              children: [
                if (needsDecision.isNotEmpty) ...[
                  _SectionHeader(
                    label: l10n.pipelineNeedsDecision,
                    count: needsDecision.length,
                    total: _sum(needsDecision),
                    color: colors.stateAtRisk,
                    typo: typo,
                    colors: colors,
                  ),
                  const SizedBox(height: HelmSpacing.s2),
                  ...needsDecision.map((e) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: HelmSpacing.s2),
                        child: PipelineEntryCard(entry: e),
                      )),
                  const SizedBox(height: HelmSpacing.s3),
                ],
                if (overdue.isNotEmpty) ...[
                  _SectionHeader(
                    label: l10n.pipelineOverdueAttention,
                    count: overdue.length,
                    total: _sum(overdue),
                    color: colors.stateAtRisk,
                    typo: typo,
                    colors: colors,
                  ),
                  const SizedBox(height: HelmSpacing.s2),
                  ...overdue.map((e) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: HelmSpacing.s2),
                        child: PipelineEntryCard(entry: e),
                      )),
                  const SizedBox(height: HelmSpacing.s3),
                ],
                if (pending.isNotEmpty) ...[
                  _SectionHeader(
                    label: l10n.pending,
                    count: pending.length,
                    total: _sum(pending),
                    color: colors.stateTight,
                    typo: typo,
                    colors: colors,
                  ),
                  const SizedBox(height: HelmSpacing.s2),
                  ...pending.map((e) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: HelmSpacing.s2),
                        child: PipelineEntryCard(entry: e),
                      )),
                  const SizedBox(height: HelmSpacing.s3),
                ],
                if (expected.isNotEmpty) ...[
                  _SectionHeader(
                    label: l10n.expected,
                    count: expected.length,
                    total: _sum(expected),
                    color: colors.stateHope,
                    typo: typo,
                    colors: colors,
                  ),
                  const SizedBox(height: HelmSpacing.s2),
                  ...expected.map((e) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: HelmSpacing.s2),
                        child: PipelineEntryCard(entry: e),
                      )),
                  const SizedBox(height: HelmSpacing.s3),
                ],
                if (received.isNotEmpty)
                  _ReceivedSection(
                      entries: received, colors: colors, typo: typo),
              ],
            )
          : _EmptyPipelineView(colors: colors, typo: typo),
    );
  }

  double _sum(List<IncomeEntryEntity> entries) =>
      entries.fold(0.0, (sum, e) => sum + e.amount);
}

// ── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.typo,
    required this.colors,
  });

  final String label;
  final int count;
  final double total;
  final Color color;
  final HelmTypography typo;
  final HelmColors colors;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_US');
    return Row(
      children: [
        Container(width: 3, height: 14, color: color),
        const SizedBox(width: HelmSpacing.s2),
        Text(label, style: typo.labelMd.copyWith(color: color)),
        const Spacer(),
        Text(
          '$count · ${fmt.format(total)}',
          style: typo.labelSm.copyWith(color: colors.inkTertiary),
        ),
      ],
    );
  }
}

// ── Received section (collapsible) ─────────────────────────────────────────

class _ReceivedSection extends StatefulWidget {
  const _ReceivedSection({
    required this.entries,
    required this.colors,
    required this.typo,
  });

  final List<IncomeEntryEntity> entries;
  final HelmColors colors;
  final HelmTypography typo;

  @override
  State<_ReceivedSection> createState() => _ReceivedSectionState();
}

class _ReceivedSectionState extends State<_ReceivedSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_US');
    final total = widget.entries.fold(0.0, (s, e) => s + e.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(HelmSpacing.s1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: HelmSpacing.s1),
            child: Row(
              children: [
                Container(
                    width: 3, height: 14, color: widget.colors.stateSafe),
                const SizedBox(width: HelmSpacing.s2),
                Text(
                  context.l10n.received,
                  style: widget.typo.labelMd
                      .copyWith(color: widget.colors.stateSafe),
                ),
                const Spacer(),
                Text(
                  '${widget.entries.length} · ${fmt.format(total)}',
                  style: widget.typo.labelSm
                      .copyWith(color: widget.colors.inkTertiary),
                ),
                const SizedBox(width: HelmSpacing.s2),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: widget.colors.inkTertiary,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: HelmSpacing.s2),
          ...widget.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: HelmSpacing.s2),
                child: PipelineEntryCard(entry: e),
              )),
        ],
      ],
    );
  }
}

// ── FAB ────────────────────────────────────────────────────────────────────

class _PipelineFab extends ConsumerWidget {
  const _PipelineFab({required this.entryCount});
  final int entryCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.textStyles;

    // PIPE-014: show label while user is learning (< 5 entries)
    if (entryCount < 5) {
      return FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.addIncome),
        backgroundColor: colors.interactive,
        icon: Icon(Icons.add, color: colors.surface),
        label: Text(
          context.l10n.expected,
          style: typo.labelMd.copyWith(color: colors.surface),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: () => context.push(RouteNames.addIncome),
      backgroundColor: colors.interactive,
      child: Icon(Icons.add, color: colors.surface),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyPipelineView extends StatelessWidget {
  const _EmptyPipelineView({required this.colors, required this.typo});
  final HelmColors colors;
  final HelmTypography typo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(HelmSpacing.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: colors.inkTertiary),
            const SizedBox(height: HelmSpacing.s3),
            Text(
              context.l10n.notCountedEmpty,
              style: typo.bodyMd.copyWith(color: colors.inkSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
