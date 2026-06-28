// lib/features/onboarding/presentation/views/pages/first_pipeline_page.dart
// A3 — M5: Optional first pipeline entry during onboarding.
//
// "Any money you're expecting soon?"
// User can add one pipeline entry or skip.
// This seeds the dashboard so S2S isn't empty on first view.
//
// UX Improvements:
//   - Uses HelmMotion tokens
//   - Page entry animation
//   - Loading state on submit
//   - Error iconography
//   - Semantics for screen reader support

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/utils/number_formatter.dart';
import 'package:helm/core/themes/helm_motion.dart';
import 'package:helm/core/themes/helm_spacing.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/core/utils/input_validator.dart';
import 'package:helm/core/widgets/buttons/button_multiple_types.dart';
import 'package:helm/l10n/app_localization.dart';

/// Data captured from the optional first pipeline entry.
class PipelineDraftEntry {
  final String clientName;
  final double amount;
  final String currency;

  const PipelineDraftEntry({
    required this.clientName,
    required this.amount,
    this.currency = 'BDT',
  });
}

class FirstPipelinePage extends StatefulWidget {
  final Future<void> Function(PipelineDraftEntry entry) onAddEntry;

  const FirstPipelinePage({
    super.key,
    required this.onAddEntry,
  });

  @override
  State<FirstPipelinePage> createState() => _FirstPipelinePageState();
}

class _FirstPipelinePageState extends State<FirstPipelinePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _amountController = TextEditingController();
  String _currency = 'BDT';
  bool _isLoading = false;
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Page entry animation
    _entryController = AnimationController(
      vsync: this,
      duration: HelmMotion.slow,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: HelmMotion.defaultCurve),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entryController.forward();
    });
  }

  @override
  void dispose() {
    _clientController.dispose();
    _amountController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = InputValidator.parseAmount(_amountController.text);
    if (amount == null) return;

    setState(() => _isLoading = true);
    await HapticFeedback.mediumImpact();
    await widget.onAddEntry(PipelineDraftEntry(
      clientName: InputValidator.sanitizeText(_clientController.text),
      amount: amount,
      currency: InputValidator.normalizeCurrency(_currency),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.textStyles;
    final l10n = context.l10n;

    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: HelmSpacing.screenEdge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: HelmSpacing.s10),
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.firstPipelineQuestion,
                            style:
                                typo.headingLg.copyWith(color: colors.inkPrimary),
                          ),
                        ),
                        const SizedBox(height: HelmSpacing.s2),
                        Text(
                          l10n.firstPipelineSubtext,
                          style:
                              typo.bodyLg.copyWith(color: colors.inkSecondary),
                        ),
                        const SizedBox(height: HelmSpacing.s8),

                        // Client name
                        Semantics(
                          label: l10n.pipelineClientNameSemantics,
                          textField: true,
                          child: TextFormField(
                            controller: _clientController,
                            maxLength: 100,
                            inputFormatters: const [
                              SanitizingTextInputFormatter(),
                            ],
                            decoration: InputDecoration(
                              labelText: l10n.clientOrSource,
                              hintText: l10n.clientOrSourceHint,
                              labelStyle: typo.labelMd.copyWith(
                                color: colors.inkSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    HelmSpacing.cardRadius),
                                borderSide: BorderSide(color: colors.divider),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    HelmSpacing.cardRadius),
                                borderSide: BorderSide(color: colors.divider),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    HelmSpacing.cardRadius),
                                borderSide: BorderSide(
                                  color: colors.interactive,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    HelmSpacing.cardRadius),
                                borderSide: BorderSide(
                                  color: colors.stateAtRisk,
                                  width: 1.5,
                                ),
                              ),
                              errorStyle: typo.labelSm.copyWith(
                                color: colors.stateAtRisk,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                size: HelmSpacing.iconMd,
                                color: colors.inkTertiary,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return l10n.whoIsThisFrom;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: HelmSpacing.s4),

                        // Amount + currency
                        Semantics(
                          label: l10n.pipelineAmountSemantics(_currency),
                          textField: true,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _amountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d*')),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: l10n.amount,
                                    prefixText:
                                        NumberFormatter.prefixForCode(_currency),
                                    labelStyle: typo.labelMd.copyWith(
                                      color: colors.inkSecondary,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          HelmSpacing.cardRadius),
                                      borderSide: BorderSide(color: colors.divider),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          HelmSpacing.cardRadius),
                                      borderSide: BorderSide(color: colors.divider),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          HelmSpacing.cardRadius),
                                      borderSide: BorderSide(
                                        color: colors.interactive,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          HelmSpacing.cardRadius),
                                      borderSide: BorderSide(
                                        color: colors.stateAtRisk,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorStyle: typo.labelSm.copyWith(
                                      color: colors.stateAtRisk,
                                    ),
                                  ),
                                  validator: (val) {
                                    if (InputValidator.parseAmount(val) == null) {
                                      return l10n.pipelineAmountMustBePositive;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: HelmSpacing.s3),
                              Expanded(
                                child: Semantics(
                                  label: l10n.pipelineCurrencySemantics,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _currency,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              HelmSpacing.cardRadius)),
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 16),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'BDT', child: Text('BDT')),
                                      DropdownMenuItem(
                                          value: 'USD', child: Text('USD')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _currency = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: HelmSpacing.s6),

                        // Info note
                        Semantics(
                          label: l10n.pipelineEntryNoteSemantics,
                          child: Container(
                            padding: const EdgeInsets.all(HelmSpacing.s3),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius:
                                  BorderRadius.circular(HelmSpacing.cardRadius),
                              border: Border.all(color: colors.hairline),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    size: HelmSpacing.iconSm, color: colors.inkTertiary),
                                const SizedBox(width: HelmSpacing.s2),
                                Expanded(
                                  child: Text(
                                    l10n.pipelineEntryNote,
                                    style: typo.bodySm
                                        .copyWith(color: colors.inkTertiary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom buttons with loading state
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: HelmSpacing.screenEdge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      label: _isLoading ? l10n.pipelineAdding : l10n.pipelineAddAndContinue,
                      onPressed: _isLoading ? null : _submit,
                      isEnabled: !_isLoading,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: HelmSpacing.s4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}