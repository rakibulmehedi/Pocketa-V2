// lib/features/export/presentation/views/export_screen.dart
// D1.09 — CSV Export: user-facing export screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:helm/core/analytics/analytics_service.dart';
import 'package:helm/core/analytics/event_registry.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_spacing.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/core/widgets/helm_toast.dart';
import 'package:helm/features/export/presentation/providers/export_provider.dart';
import 'package:helm/l10n/app_localization.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.textStyles;
    final status = ref.watch(exportProvider);
    final isExporting = status == ExportStatus.exporting;

    ref.listen<ExportStatus>(exportProvider, (prev, next) {
      if (!mounted) return;
      if (next == ExportStatus.success) {
        final notifier = ref.read(exportProvider.notifier);
        _shareFiles(notifier.lastResult?.filePaths ?? [], l10n);
        notifier.reset();
      } else if (next == ExportStatus.error) {
        final notifier = ref.read(exportProvider.notifier);
        // M-33: use user-friendly export error message instead of raw error.
        HelmToast.show(
          context,
          message: l10n.exportError,
          type: ToastType.error,
        );
        notifier.reset();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exportMyData),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HelmSpacing.screenEdge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.exportDataBelongsToYou,
              style: typo.headingLg.copyWith(
                color: colors.inkPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.exportDescription,
              style: typo.bodyMd.copyWith(
                color: colors.inkSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(HelmSpacing.s3),
              decoration: BoxDecoration(
                color: colors.stateAtRisk.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(HelmSpacing.s2),
                border: Border.all(
                  color: colors.stateAtRisk.withValues(alpha: 0.24),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: colors.stateAtRisk, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.exportWarning,
                      style: typo.bodySm.copyWith(
                        color: colors.inkSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.exportWhatWillBeExported,
              style: typo.bodyLg.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.inkPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ..._exportItems(context, colors),
            const SizedBox(height: 24),
            // H-24: plaintext security warning above the export button.
            Container(
              padding: const EdgeInsets.all(HelmSpacing.s3),
              decoration: BoxDecoration(
                color: colors.stateAtRisk.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(HelmSpacing.s2),
                border: Border.all(
                  color: colors.stateAtRisk.withValues(alpha: 0.24),
                ),
              ),
              child: Text(
                l10n.csvExportWarning,
                style: typo.bodySm.copyWith(color: colors.inkSecondary),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isExporting
                    ? null
                    : () {
                        // D2P — Beta instrumentation: export initiated
                        ref.read(analyticsProvider).trackEvent(
                          TransactionalEvents.exportTriggered,
                        );
                        ref.read(exportProvider.notifier).export();
                      },
                child: isExporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.exportAllData),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _exportItems(BuildContext context, HelmColors colors) {
    final l10n = context.l10n;
    final items = [
      l10n.exportItemIncomeEntries,
      l10n.exportItemTransactions,
      l10n.exportItemFixedCosts,
      l10n.exportItemSettings,
      l10n.changeHistory,
    ];
    return items
        .map(
          (name) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: colors.stateSafe,
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: context.textStyles.bodyMd.copyWith(
                    color: colors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  void _shareFiles(List<String> filePaths, AppLocalizations l10n) {
    if (filePaths.isEmpty) return;
    SharePlus.instance.share(
      ShareParams(
        files: filePaths.map((p) => XFile(p)).toList(),
        subject: l10n.exportShareSubject,
      ),
    );
  }
}
