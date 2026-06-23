// lib/features/account/presentation/views/delete_account_screen.dart
// D1.10 — Account deletion flow.
//
// Two-step irreversible data wipe:
//   Step 1 — Warning screen with explicit list of what is deleted.
//   Step 2 — ConfirmDeletionDialog: PIN entry (if set) or type "DELETE".
//
// Trust rules:
//   - Language is unambiguous: "This cannot be undone"
//   - Confirm button stays disabled until valid input
//   - Cancel is always available
//   - After deletion: navigates to /welcome (full reset)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:helm/config/router/route_names.dart';
import 'package:helm/core/analytics/analytics_service.dart';
import 'package:helm/core/constants/app_box_names.dart';
import 'package:helm/core/analytics/event_registry.dart';
import 'package:helm/core/security/secure_key_manager.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_spacing.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/features/auth/presentation/providers/auth_provider.dart';
import 'package:helm/l10n/app_localization.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _deleting = false;

  // ── Deletion logic ─────────────────────────────────────────────────────────

  Future<void> _deleteAllData() async {
    if (_deleting) return;
    setState(() => _deleting = true);

    try {
      // Clear least-sensitive boxes first; auth_box is last so a crash mid-wipe
      // leaves the identity/PIN gate intact where possible.
      final boxNames = [
        // Tier 1 — non-sensitive operational data (safe to lose mid-wipe)
        AppBoxNames.transactions,
        AppBoxNames.incomeBox,
        AppBoxNames.fixedCostsBox,
        AppBoxNames.categories,
        AppBoxNames.analyticsEventsBox,
        AppBoxNames.nudgePreferencesBox,
        AppBoxNames.nudgeLogBox,
        AppBoxNames.sessionBox,
        // Tier 2 — audit integrity (should survive as long as possible)
        AppBoxNames.auditEventsBox,
        AppBoxNames.auditChainBox,
        // Tier 3 — identity/PIN gate (last, so crash mid-wipe keeps gate intact)
        AppBoxNames.authBox,
      ];

      for (final name in boxNames) {
        try {
          if (Hive.isBoxOpen(name)) {
            final box = Hive.box<dynamic>(name);
            await box.clear();
            await box.close();
            await Hive.deleteBoxFromDisk(name);
          }
        } on Exception catch (e, st) {
          debugPrint('[DELETE_ACCOUNT] failed to clear box $name: $e\n$st');
        }
      }

      try {
        await SecureKeyManager().deleteHiveKey();
      } on Exception catch (e, st) {
        debugPrint('[DELETE_ACCOUNT] failed to delete Hive key: $e\n$st');
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } on Exception catch (e, st) {
        debugPrint(
          '[DELETE_ACCOUNT] failed to clear SharedPreferences: $e\n$st',
        );
      }

      // D2P — Beta instrumentation: account deleted (irreversible data wipe)
      ref
          .read(analyticsProvider)
          .trackEvent(TransactionalEvents.accountDeleted);
      if (mounted) context.go(RouteNames.welcome);
    } on Exception catch (e, st) {
      // H-29: surface incomplete deletion to the user so they can retry or
      // contact support rather than silently leaving data behind.
      debugPrint('[DELETE_ACCOUNT] deletion sequence failed: $e\n$st');
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Deletion incomplete. Please try again or contact support.',
            ),
          ),
        );
      }
    }
  }

  // ── Step 2: show confirmation dialog ───────────────────────────────────────

  Future<void> _showConfirmDialog() async {
    // D2P — Beta instrumentation: deletion dialog opened (user intent signal)
    ref.read(analyticsProvider).trackEvent(
      TransactionalEvents.accountDeletionRequested,
    );
    final authState = ref.read(authProvider);
    final hasPin = authState.isSetUp;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => hasPin
          ? const _PinConfirmDialog()
          : const _TypeDeleteDialog(),
    );

    if (confirmed == true && mounted) {
      await _deleteAllData();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.textStyles;
    final atRisk = colors.stateAtRisk;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        elevation: 0,
        title: Text(l10n.deleteAllData, style: typography.headingSm),
        leading: BackButton(color: colors.inkPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HelmSpacing.screenEdge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning card
              Container(
                padding: const EdgeInsets.all(HelmSpacing.s4),
                decoration: BoxDecoration(
                  color: atRisk.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
                  border: Border.all(color: atRisk.withValues(alpha: 0.35)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: atRisk, size: 24),
                    const SizedBox(width: HelmSpacing.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.deleteCannotBeUndone,
                            style: typography.headingSm
                                .copyWith(color: atRisk),
                          ),
                          const SizedBox(height: HelmSpacing.s1),
                          Text(
                            l10n.deleteWarningBody,
                            style: typography.bodyMd
                                .copyWith(color: colors.inkSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: HelmSpacing.s6),

              // What will be deleted
              Text(
                l10n.deleteWhatWillBeDeleted,
                style: typography.headingSm
                    .copyWith(color: colors.inkPrimary),
              ),
              const SizedBox(height: HelmSpacing.s3),
              ..._deletionItems(context, colors, typography),

              const Spacer(),

              // Destructive action button
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: atRisk,
                  foregroundColor: colors.surface,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(HelmSpacing.cardRadius),
                  ),
                ),
                onPressed: _deleting ? null : _showConfirmDialog,
                child: _deleting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.surface,
                        ),
                      )
                    : Text(l10n.deleteContinue),
              ),

              const SizedBox(height: HelmSpacing.s2),

              // Cancel link
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  l10n.cancel,
                  style: typography.bodyMd
                      .copyWith(color: colors.inkTertiary),
                ),
              ),

              const SizedBox(height: HelmSpacing.s2),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _deletionItems(
    BuildContext context,
    HelmColors colors,
    HelmTypography typography,
  ) {
    final l10n = context.l10n;
    final items = [
      l10n.deleteItemAllIncomeEntries,
      l10n.deleteItemAllTransactions,
      l10n.deleteItemAllFixedCosts,
      l10n.deleteItemYourSettings,
      l10n.changeHistory,
    ];
    return items
        .map(
          (item) => Padding(
            padding:
                const EdgeInsets.only(bottom: HelmSpacing.s2),
            child: Row(
              children: [
                Icon(Icons.remove_circle_outline,
                    size: 16, color: colors.stateAtRisk),
                const SizedBox(width: HelmSpacing.s2),
                Text(
                  item,
                  style: typography.bodyMd
                      .copyWith(color: colors.inkSecondary),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}

// ---------------------------------------------------------------------------
// PIN confirmation dialog
// ---------------------------------------------------------------------------

class _PinConfirmDialog extends ConsumerStatefulWidget {
  const _PinConfirmDialog();

  @override
  ConsumerState<_PinConfirmDialog> createState() => _PinConfirmDialogState();
}

class _PinConfirmDialogState extends ConsumerState<_PinConfirmDialog> {
  final List<String> _digits = [];
  bool _wrongPin = false;
  String? _lockoutMessage;

  int get _pinLength => AuthNotifier.pinLength;

  void _onDigit(String d) {
    if (_digits.length >= _pinLength) return;
    setState(() {
      _digits.add(d);
      _wrongPin = false;
      _lockoutMessage = null;
    });
    if (_digits.length == _pinLength) _verify();
  }

  void _onDelete() {
    if (_digits.isEmpty) return;
    setState(() {
      _digits.removeLast();
      _wrongPin = false;
      _lockoutMessage = null;
    });
  }

  Future<void> _verify() async {
    final notifier = ref.read(authProvider.notifier);
    final entered = _digits.join();

    final ok = await notifier.verifyPinForSensitiveAction(entered);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }

    final authState = ref.read(authProvider);
    setState(() {
      _digits.clear();
      _wrongPin = true;
      if (authState.isLockedOut && authState.lockoutUntil != null) {
        final remaining = authState.lockoutUntil!.difference(DateTime.now());
        if (mounted) {
          _lockoutMessage = context.l10n.deleteLockoutMessage(
            '${remaining.inMinutes + 1}',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.textStyles;
    final atRisk = colors.stateAtRisk;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HelmSpacing.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.deletePinConfirmTitle,
              style: typography.headingSm.copyWith(color: colors.inkPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HelmSpacing.s4),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (i) {
                final filled = i < _digits.length;
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: HelmSpacing.s2),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _wrongPin
                        ? atRisk
                        : filled
                            ? colors.interactive
                            : colors.hairline,
                  ),
                );
              }),
            ),

            if (_wrongPin) ...[
              const SizedBox(height: HelmSpacing.s2),
              Text(
                _lockoutMessage ?? l10n.deleteIncorrectPin,
                style: typography.bodySm.copyWith(color: atRisk),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: HelmSpacing.s4),

            // Keypad
            _Keypad(onDigit: _onDigit, onDelete: _onDelete),

            const SizedBox(height: HelmSpacing.s4),

            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l10n.cancel,
                style: typography.bodyMd
                    .copyWith(color: colors.inkTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "Type DELETE" confirmation dialog (no PIN set)
// ---------------------------------------------------------------------------

class _TypeDeleteDialog extends StatefulWidget {
  const _TypeDeleteDialog();

  @override
  State<_TypeDeleteDialog> createState() => _TypeDeleteDialogState();
}

class _TypeDeleteDialogState extends State<_TypeDeleteDialog> {
  final _controller = TextEditingController();
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final v = _controller.text.trim() == 'DELETE';
      if (v != _valid) setState(() => _valid = v);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.textStyles;
    final atRisk = colors.stateAtRisk;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HelmSpacing.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.deleteTypeConfirmTitle,
              style: typography.headingSm.copyWith(color: colors.inkPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HelmSpacing.s4),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: l10n.deleteConfirmHint,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(HelmSpacing.cardRadius),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(HelmSpacing.cardRadius),
                  borderSide: BorderSide(color: atRisk),
                ),
              ),
            ),
            const SizedBox(height: HelmSpacing.s4),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: atRisk,
                  foregroundColor: colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(HelmSpacing.cardRadius),
                  ),
                ),
                onPressed:
                    _valid ? () => Navigator.of(context).pop(true) : null,
                child: Text(l10n.deleteAllData),
              ),
            ),
            const SizedBox(height: HelmSpacing.s2),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l10n.cancel,
                style: typography.bodyMd
                    .copyWith(color: colors.inkTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Simple numeric keypad
// ---------------------------------------------------------------------------

class _Keypad extends StatelessWidget {
  final void Function(String digit) onDigit;
  final VoidCallback onDelete;

  const _Keypad({required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.textStyles;

    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Column(
      children: rows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 72, height: 52);
            if (key == 'del') {
              return SizedBox(
                width: 72,
                height: 52,
                child: TextButton(
                  onPressed: onDelete,
                  child: Icon(Icons.backspace_outlined,
                      color: colors.inkSecondary, size: 20),
                ),
              );
            }
            return SizedBox(
              width: 72,
              height: 52,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: colors.inkPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(HelmSpacing.s2),
                  ),
                ),
                onPressed: () => onDigit(key),
                child: Text(key, style: typography.headingSm),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
