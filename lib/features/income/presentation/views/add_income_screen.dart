// lib/features/income/presentation/views/add_income_screen.dart
//
// Phase 7b: Add / Edit Income entry screen.
// - Reuses AddTransactionScreen patterns (double-submit guard, mounted checks,
//   missing-entity error state, _inputDecoration helper)
// - Saves via incomeNotifierProvider (Phase 7a data layer)
// - receivedDate field shown only when status == received
// - Currency selector: BDT or USD

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:helm/core/analytics/analytics_service.dart';
import 'package:helm/core/analytics/event_registry.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_spacing.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/core/utils/id_generator.dart';
import 'package:helm/core/utils/input_validator.dart';
import 'package:helm/core/widgets/buttons/button_multiple_types.dart';
import 'package:helm/core/widgets/helm_toast.dart';
import 'package:helm/features/income/domain/entities/income_entry_entity.dart';
import 'package:helm/features/income/presentation/providers/income_providers.dart';
import 'package:helm/l10n/app_localization.dart';
import 'package:helm/utils/responsive_utils.dart';

/// Currencies available for income entries.
/// No conversion logic — display-only (per spec).
const List<String> _currencies = ['BDT', 'USD'];

class AddIncomeScreen extends ConsumerStatefulWidget {
  final String? incomeId;
  const AddIncomeScreen({super.key, this.incomeId});

  @override
  ConsumerState<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends ConsumerState<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _projectNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _fxRateController = TextEditingController();
  final _sourceLabelController = TextEditingController();

  IncomeStatus _selectedStatus = IncomeStatus.expected;
  String _selectedCurrency = _currencies.first;
  DateTime _expectedDate = DateTime.now();
  DateTime? _receivedDate;
  bool _isSaving = false;
  bool _excludeFromCalculation = false;

  /// True when editing and the target income entry was not found.
  bool _incomeNotFound = false;

  /// Cached createdAt from the original entry (edit mode).
  /// Avoids re-reading provider during submit.
  DateTime? _originalCreatedAt;

  @override
  void initState() {
    super.initState();
    if (widget.incomeId != null) {
      // Defer provider read to avoid timing issues with uninitialized state.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadEntryForEdit();
      });
    }
  }

  void _loadEntryForEdit() {
    if (!mounted || widget.incomeId == null) return;
    final incomes = ref.read(incomeNotifierProvider);
    final entry = incomes.where((e) => e.id == widget.incomeId).firstOrNull;
    if (entry != null) {
      setState(() {
        _clientNameController.text = entry.clientName;
        _projectNameController.text = entry.projectName;
        _amountController.text = entry.amount.toStringAsFixed(2);
        if (entry.notes != null) _noteController.text = entry.notes!;
        _selectedStatus = entry.status;
        _selectedCurrency = entry.currency;
        _expectedDate = entry.expectedDate;
        _receivedDate = entry.receivedDate;
        _originalCreatedAt = entry.createdAt;
        if (entry.fxRate != null) {
          _fxRateController.text = entry.fxRate!.toStringAsFixed(2);
        }
        _sourceLabelController.text = entry.sourceLabel ?? '';
        _excludeFromCalculation = entry.excludeFromCalculation;
      });
    } else {
      setState(() => _incomeNotFound = true);
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _projectNameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _fxRateController.dispose();
    _sourceLabelController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Future<void> _pickExpectedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null && mounted) setState(() => _expectedDate = picked);
  }

  Future<void> _pickReceivedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _receivedDate ?? DateTime.now(),
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked != null && mounted) setState(() => _receivedDate = picked);
  }

  Future<void> _submit() async {
    if (_isSaving) return; // double-submit guard
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Additional: receivedDate required when status is received
    if (_selectedStatus == IncomeStatus.received && _receivedDate == null) {
      HelmToast.show(
        context,
        message: context.l10n.pleaseSelectReceivedDate,
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final parsedAmount = InputValidator.parseAmount(_amountController.text);
      if (parsedAmount == null) {
        setState(() => _isSaving = false);
        HelmToast.show(
          context,
          message: context.l10n.amountInvalid,
          type: ToastType.error,
        );
        return;
      }
      final fxRate = _selectedCurrency == 'USD'
          ? InputValidator.parseAmount(_fxRateController.text)
          : null;
      if (_selectedCurrency == 'USD' && fxRate == null) {
        setState(() => _isSaving = false);
        HelmToast.show(
          context,
          message: context.l10n.fxRateInvalid,
          type: ToastType.error,
        );
        return;
      }
      final entity = IncomeEntryEntity(
        id: widget.incomeId ?? IdGenerator.uniqueId(),
        clientName: InputValidator.sanitizeText(_clientNameController.text),
        projectName: InputValidator.sanitizeText(_projectNameController.text),
        amount: parsedAmount,
        currency: InputValidator.normalizeCurrency(_selectedCurrency),
        status: _selectedStatus,
        expectedDate: _expectedDate,
        receivedDate:
            _selectedStatus == IncomeStatus.received ? _receivedDate : null,
        notes: InputValidator.sanitizeText(_noteController.text),
        createdAt: _originalCreatedAt ?? now,
        updatedAt: now,
        fxRate: fxRate,
        sourceLabel: InputValidator.sanitizeText(_sourceLabelController.text),
        excludeFromCalculation: _excludeFromCalculation,
      );

      if (widget.incomeId != null) {
        await ref.read(incomeNotifierProvider.notifier).updateIncome(entity);

        // P4.2: notification_resulted_in_update — within 30min of notification open
        final lastNotificationOpen =
            SharedPrefServices.getLastNotificationOpenedAt();
        if (lastNotificationOpen != null) {
          final sinceOpen = DateTime.now().difference(lastNotificationOpen);
          if (sinceOpen.inMinutes <= 30) {
            ref.read(analyticsProvider).trackEvent(
              TransactionalEvents.notificationResultedInUpdate,
              properties: {'minutes_since_open': sinceOpen.inMinutes.toString()},
            );
          }
        }
      } else {
        await ref.read(incomeNotifierProvider.notifier).addIncome(entity);
        // D2.04 — Beta instrumentation: pipeline entry created
        ref.read(analyticsProvider).trackEvent(
          TransactionalEvents.pipelineEntryCreated,
          properties: {EventProperties.entryCount: 1},
        );
        // P1.3: first_pipeline_entry — fire once ever
        if (!SharedPrefServices.getEventFired(BoundaryEvents.firstPipelineEntry)) {
          ref.read(analyticsProvider).trackEvent(
            BoundaryEvents.firstPipelineEntry,
          );
          await SharedPrefServices.setEventFired(
            BoundaryEvents.firstPipelineEntry,
          );
        }
      }

      if (!mounted) return;

      HelmToast.show(
        context,
        message: widget.incomeId != null
            ? context.l10n.incomeUpdatedSuccess
            : context.l10n.incomeSavedSuccess,
        type: ToastType.success,
      );
      context.pop();
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      HelmToast.show(
        context,
        message: context.l10n.incomeFailedToSave,
        type: ToastType.error,
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<HelmColors>() ?? HelmColors.light;
    final typo = theme.extension<HelmTypography>() ?? HelmTypography.build(theme.extension<HelmColors>() ?? HelmColors.light);
    final l10n = context.l10n;
    final isEditing = widget.incomeId != null;

    // ── Missing income error state ──────────────────────────────────────────
    if (_incomeNotFound) {
      return const _IncomeNotFoundView();
    }

    // L-12: PopScope(canPop:true) was dead code — onPopInvokedWithResult always
    // received didPop=true and returned immediately; fallback branch was unreachable.
    return Scaffold(
      backgroundColor: colors.canvas,
        appBar: AppBar(
          title: Text(
            isEditing ? l10n.editIncome : l10n.addIncome,
            style: typo.headingMd,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: ResponsiveUtilities.symmetricPadding(context),
            child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Client Name ──────────────────────────────────────────
                _FieldLabel(l10n.clientName),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _clientNameController,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                    hint: l10n.clientNameHint,
                    colors: colors,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.clientNameRequired;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── Project Name ─────────────────────────────────────────
                _FieldLabel(l10n.projectNameRecommended),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _projectNameController,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    hint: l10n.projectNameHint,
                    colors: colors,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Amount + Currency row ─────────────────────────────────
                _FieldLabel(l10n.amount),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount field
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: _inputDecoration(
                          hint: '0.00',
                          colors: colors,
                        ),
                        validator: (v) {
                          if (InputValidator.parseAmount(v) == null) {
                            return l10n.amountInvalid;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Currency selector
                    _CurrencySelector(
                      selected: _selectedCurrency,
                      onChanged: (c) =>
                          setState(() {
                            _selectedCurrency = c;
                            // Clear FX rate when switching away from USD to prevent stale data.
                            if (c != 'USD') {
                              _fxRateController.clear();
                            }
                          }),
                    ),
                  ],
                ),

                // ── FX Rate (USD only) ───────────────────────────────────
                if (_selectedCurrency == 'USD') ...[
                  const SizedBox(height: 20),
                  _FieldLabel(l10n.fxRateLabel),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _fxRateController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: _inputDecoration(
                      hint: l10n.fxRateHint,
                      colors: colors,
                    ),
                    validator: (v) {
                      if (InputValidator.parseAmount(v) == null) {
                        return l10n.fxRateInvalid;
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 20),

                // ── Status selector ──────────────────────────────────────
                _FieldLabel(l10n.statusLabel),
                const SizedBox(height: 10),
                _StatusToggle(
                  selected: _selectedStatus,
                  onChanged: (s) => setState(() {
                    _selectedStatus = s;
                    // Clear receivedDate if moving away from received
                    if (s != IncomeStatus.received) {
                      _receivedDate = null;
                    }
                  }),
                ),

                const SizedBox(height: 20),

                // ── Expected Date ────────────────────────────────────────
                _FieldLabel(l10n.expectedDate),
                const SizedBox(height: 8),
                _DatePickerTile(
                  date: _expectedDate,
                  onTap: _pickExpectedDate,
                ),

                // ── Received Date (only when received) ───────────────────
                if (_selectedStatus == IncomeStatus.received) ...[
                  const SizedBox(height: 20),
                  _FieldLabel(l10n.receivedDate),
                  const SizedBox(height: 8),
                  _DatePickerTile(
                    date: _receivedDate,
                    onTap: _pickReceivedDate,
                    placeholder: l10n.selectReceivedDate,
                  ),
                ],

                const SizedBox(height: 20),

                // ── Notes (optional) ─────────────────────────────────────
                _FieldLabel(l10n.notesOptional),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLength: 500,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    hint: l10n.addANote,
                    colors: colors,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Payment Source (optional) ────────────────────────────
                _FieldLabel(l10n.paymentSourceOptional),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sourceLabelController,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                    hint: l10n.paymentSourceHint,
                    colors: colors,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Exclude from Safe-to-Spend ───────────────────────────
                Semantics(
                  label: 'Exclude from Safe-to-Spend: ${_excludeFromCalculation ? "on" : "off"}',
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
                      border: Border.all(color: colors.divider),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      title: Text(
                        l10n.excludeFromSafeToSpend,
                        style: typo.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.inkPrimary,
                            ),
                      ),
                      subtitle: Text(
                        l10n.excludeFromSafeToSpendSubtitle,
                        style: typo.labelMd.copyWith(
                              color: colors.inkSecondary,
                            ),
                      ),
                      value: _excludeFromCalculation,
                      activeThumbColor: colors.interactive,
                      onChanged: (v) =>
                          setState(() => _excludeFromCalculation = v),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Submit button ────────────────────────────────────────
                AppButton(
                  label: isEditing ? l10n.updateIncome : l10n.saveIncome,
                  isLoading: _isSaving,
                  isEnabled: !_isSaving,
                  onPressed: _submit,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  // ── Shared input decoration ──────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String hint,
    required HelmColors colors,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: context.textStyles.bodyMd.copyWith(
        color: colors.inkTertiary.withValues(alpha: 0.6),
      ),
      filled: true,
      fillColor: colors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
        borderSide: BorderSide(color: colors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
        borderSide: BorderSide(color: colors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
        borderSide: BorderSide(color: colors.interactive, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
        borderSide: BorderSide(color: colors.stateAtRisk),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
        borderSide: BorderSide(color: colors.stateAtRisk, width: 1.5),
      ),
    );
  }
}

// ── Private sub-widgets ──────────────────────────────────────────────────────

/// Reusable field label — matches AddTransactionScreen pattern.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.textStyles;
    return Text(
      text,
      style: typo.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.inkPrimary,
          ),
    );
  }
}

/// Three-way status toggle: Expected / Pending / Received.
class _StatusToggle extends StatelessWidget {
  const _StatusToggle({
    required this.selected,
    required this.onChanged,
  });

  final IncomeStatus selected;
  final ValueChanged<IncomeStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: colors.hairline,
        borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
      ),
      padding: const EdgeInsets.all(HelmSpacing.s1),
      child: Row(
        children: IncomeStatus.values.map((status) {
          final isActive = selected == status;
          final color = _statusColor(status, colors);
          final label = _statusLabel(status, l10n);
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(HelmSpacing.buttonRadius),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: context.textStyles.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? colors.surface
                        : colors.inkSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Per INCOME_PIPELINE_MVP spec:
  /// Expected → soft grey, Pending → soft blue, Received → gentle green
  Color _statusColor(IncomeStatus status, HelmColors colors) {
    switch (status) {
      case IncomeStatus.expected:
        return colors.inkTertiary;
      case IncomeStatus.pending:
        return colors.stateTight;
      case IncomeStatus.received:
        return colors.stateSafe;
    }
  }

  String _statusLabel(IncomeStatus status, AppLocalizations l10n) {
    switch (status) {
      case IncomeStatus.expected:
        return l10n.expected;
      case IncomeStatus.pending:
        return l10n.pending;
      case IncomeStatus.received:
        return l10n.received;
    }
  }
}

/// Currency chip selector — BDT or USD.
class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.hairline,
        borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
      ),
      padding: const EdgeInsets.all(HelmSpacing.s1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _currencies.map((currency) {
          final isActive = selected == currency;
          return GestureDetector(
            onTap: () => onChanged(currency),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? colors.interactive : Colors.transparent,
                borderRadius: BorderRadius.circular(HelmSpacing.buttonRadius),
              ),
              child: Text(
                currency,
                style: context.textStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? colors.surface
                      : colors.inkSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Date picker tile matching the AddTransactionScreen pattern.
class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.date,
    required this.onTap,
    this.placeholder,
  });

  final DateTime? date;
  final VoidCallback onTap;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<HelmColors>() ?? HelmColors.light;
    return InkWell(
      borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(HelmSpacing.cardRadius),
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: colors.interactive,
            ),
            const SizedBox(width: 12),
            Text(
              date != null
                  ? DateFormat('dd MMM yyyy').format(date!)
                  : (placeholder ?? context.l10n.selectDate),
              style: context.textStyles.bodyMd.copyWith(
                color: date != null
                    ? colors.inkPrimary
                    : colors.inkTertiary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error view shown when navigating to edit an income that doesn't exist.
class _IncomeNotFoundView extends StatelessWidget {
  const _IncomeNotFoundView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<HelmColors>() ?? HelmColors.light;
    final typo = theme.extension<HelmTypography>() ?? HelmTypography.build(theme.extension<HelmColors>() ?? HelmColors.light);
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: Text(
          l10n.editIncome,
          style: typo.headingMd,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: ResponsiveUtilities.symmetricPadding(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: colors.stateAtRisk.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.incomeEntryNotFound,
                  style: typo.headingMd.copyWith(
                    color: colors.inkPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.incomeEntryDeleted,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.inkSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: l10n.goBack,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
