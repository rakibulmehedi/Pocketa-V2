import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/utils/number_formatter.dart';
import 'package:helm/core/themes/helm_motion.dart';
import 'package:helm/core/themes/helm_spacing.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/core/utils/input_validator.dart';
import 'package:helm/core/widgets/buttons/button_multiple_types.dart';
import 'package:helm/features/onboarding/domain/onboarding_draft.dart';
import 'package:helm/l10n/app_localization.dart';

class FixedCostsPage extends StatefulWidget {
  final List<FixedCostDraftItem> initialCosts;
  final void Function(List<FixedCostDraftItem> costs) onContinue;

  const FixedCostsPage({
    super.key,
    required this.initialCosts,
    required this.onContinue,
  });

  @override
  State<FixedCostsPage> createState() => _FixedCostsPageState();
}

class _FixedCostCategory {
  /// English label — used as data key for persistence and matching.
  final String label;
  final int defaultDay;

  const _FixedCostCategory(this.label, this.defaultDay);

  /// Returns the localized display label for this category.
  String localizedLabel(AppLocalizations l10n) {
    switch (label) {
      case 'Rent / Housing':
        return l10n.fixedCostsCategoryRentHousing;
      case 'Internet':
        return l10n.fixedCostsCategoryInternet;
      case 'Mobile / Phone':
        return l10n.fixedCostsCategoryMobilePhone;
      case 'Subscriptions':
        return l10n.fixedCostsCategorySubscriptions;
      case 'Family support / Parents':
        return l10n.fixedCostsCategoryFamilySupport;
      case 'Loan EMI':
        return l10n.fixedCostsCategoryLoanEmi;
      case 'Other fixed cost':
        return l10n.fixedCostsCategoryOther;
      default:
        return label;
    }
  }
}

class _FixedCostsPageState extends State<FixedCostsPage> {
  static const List<_FixedCostCategory> _categories = [
    _FixedCostCategory('Rent / Housing', 1),
    _FixedCostCategory('Internet', 5),
    _FixedCostCategory('Mobile / Phone', 10),
    _FixedCostCategory('Subscriptions', 15),
    _FixedCostCategory('Family support / Parents', 5),
    _FixedCostCategory('Loan EMI', 10),
    _FixedCostCategory('Other fixed cost', 1),
  ];

  late final List<bool> _checked;
  late final List<TextEditingController> _amountControllers;
  late final List<int> _days;

  bool _zeroStateReasked = false;
  bool _showZeroStateReask = false;

  @override
  void initState() {
    super.initState();
    _checked = List.filled(_categories.length, false);
    _days = List.generate(_categories.length, (i) => _categories[i].defaultDay);
    _amountControllers = List.generate(
      _categories.length,
      (_) => TextEditingController(),
    );

    for (final item in widget.initialCosts) {
      final idx = _categories.indexWhere((c) => c.label == item.label);
      if (idx >= 0) {
        _checked[idx] = true;
        _amountControllers[idx].text = item.amount.toStringAsFixed(0);
        _days[idx] = item.dayOfMonth;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _amountControllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<FixedCostDraftItem> _buildItems() {
    final items = <FixedCostDraftItem>[];
    for (int i = 0; i < _categories.length; i++) {
      if (!_checked[i]) continue;
      final amount = InputValidator.parseAmount(_amountControllers[i].text);
      if (amount == null) continue;
      items.add(FixedCostDraftItem(
        label: InputValidator.sanitizeText(_categories[i].label, maxLength: 100),
        amount: amount,
        dayOfMonth: _days[i].clamp(1, 28),
      ));
    }
    return items;
  }

  void _onContinueTap() {
    final items = _buildItems();
    if (items.isEmpty && !_zeroStateReasked) {
      setState(() {
        _showZeroStateReask = true;
        _zeroStateReasked = true;
      });
      return;
    }
    widget.onContinue(items);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.textStyles;
    final l10n = context.l10n;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress indicator — step 5
          LinearProgressIndicator(
            value: HelmSpacing.onboardingFixedCost,
            backgroundColor: colors.hairline,
            color: colors.interactive,
            minHeight: HelmSpacing.progressBarHeight,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              HelmSpacing.screenEdge,
              HelmSpacing.s10,
              HelmSpacing.screenEdge,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.fixedCostsQuestion,
                  style: typo.headingLg.copyWith(color: colors.inkPrimary),
                ),
                const SizedBox(height: HelmSpacing.s2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.fixedCostsSubtext,
                        style: typo.bodyLg.copyWith(color: colors.inkSecondary),
                      ),
                    ),
                    Tooltip(
                      message: l10n.fixedCostsDueDayTooltip,
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: HelmSpacing.iconMd,
                        color: colors.inkTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: HelmSpacing.s4),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: HelmSpacing.screenEdge,
                vertical: HelmSpacing.s2,
              ),
              itemCount: _categories.length,
              separatorBuilder: (_, index) =>
                  Divider(color: colors.hairline, height: 1),
              itemBuilder: (context, i) => _CategoryRow(
                category: _categories[i],
                checked: _checked[i],
                amountController: _amountControllers[i],
                day: _days[i],
                l10n: l10n,
                onCheckedChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _checked[i] = val;
                    if (!val) _amountControllers[i].clear();
                  });
                },
                onDayChanged: (val) => setState(() => _days[i] = val),
              ),
            ),
          ),

          // Zero-state reask with AnimatedSwitcher
          AnimatedSwitcher(
            duration: HelmMotion.base,
            switchInCurve: HelmMotion.defaultCurve,
            switchOutCurve: HelmMotion.defaultCurve,
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _showZeroStateReask
                ? Padding(
                    key: const ValueKey('zero_state'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: HelmSpacing.screenEdge,
                      vertical: HelmSpacing.s3,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(HelmSpacing.s4),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius:
                            BorderRadius.circular(HelmSpacing.cardRadius),
                        border: Border.all(color: colors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.fixedCostsNoneSelected,
                            style:
                                typo.headingSm.copyWith(color: colors.inkPrimary),
                          ),
                          const SizedBox(height: HelmSpacing.s1),
                          Text(
                            l10n.fixedCostsNoneExplainer,
                            style:
                                typo.bodyMd.copyWith(color: colors.inkSecondary),
                          ),
                          const SizedBox(height: HelmSpacing.s4),
                          AppButton(
                            label: l10n.letMeAddSome,
                            onPressed: () =>
                                setState(() => _showZeroStateReask = false),
                            isEnabled: true,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              HelmSpacing.screenEdge,
              HelmSpacing.s3,
              HelmSpacing.screenEdge,
              HelmSpacing.s4,
            ),
            child: AppButton(
              label: l10n.continueButton,
              onPressed: _onContinueTap,
              isEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final _FixedCostCategory category;
  final bool checked;
  final TextEditingController amountController;
  final int day;
  final AppLocalizations l10n;
  final void Function(bool) onCheckedChanged;
  final void Function(int) onDayChanged;

  const _CategoryRow({
    required this.category,
    required this.checked,
    required this.amountController,
    required this.day,
    required this.l10n,
    required this.onCheckedChanged,
    required this.onDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onCheckedChanged(!checked),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: HelmSpacing.s3),
            child: Row(
              children: [
                Semantics(
                  label: l10n.fixedCostsCategorySemantics(
                    category.localizedLabel(l10n),
                    checked ? l10n.fixedCostsCategorySelected : l10n.fixedCostsCategoryNotSelected,
                  ),
                  button: true,
                  child: AnimatedContainer(
                    duration: HelmMotion.base,
                    width: HelmSpacing.s5,
                    height: HelmSpacing.s5,
                    decoration: BoxDecoration(
                      color: checked ? colors.interactive : colors.canvas,
                      borderRadius: BorderRadius.circular(HelmSpacing.s1),
                      border: Border.all(
                        color:
                            checked ? colors.interactive : colors.divider,
                        width: HelmSpacing.cardBorder,
                      ),
                    ),
                    child: checked
                        ? Icon(Icons.check,
                            size: HelmSpacing.s3, color: colors.surface)
                        : null,
                  ),
                ),
                const SizedBox(width: HelmSpacing.s3),
                Expanded(
                  child: Text(
                    category.localizedLabel(l10n),
                    style: typo.bodyLg.copyWith(
                      color: checked
                          ? colors.inkPrimary
                          : colors.inkSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (checked)
          Padding(
            padding: const EdgeInsets.only(
              left: HelmSpacing.s8,
              bottom: HelmSpacing.s3,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive: use more width on wider screens
                final inputWidth = constraints.maxWidth > 300 ? 140.0 : 100.0;
                return Row(
                  children: [
                    Text(
                        NumberFormatter.symbolForCode(
                            NumberFormatter.defaultCurrencyCode),
                        style: typo.bodyMd
                            .copyWith(color: colors.inkSecondary)),
                    const SizedBox(width: HelmSpacing.s1),
                    SizedBox(
                      width: inputWidth,
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: typo.bodyMd
                            .copyWith(color: colors.inkPrimary),
                        decoration: InputDecoration(
                          hintText: l10n.fixedCostsAmountHint,
                          hintStyle: typo.bodyMd
                              .copyWith(color: colors.inkTertiary),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: HelmSpacing.s2),
                          border: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: colors.divider, width: HelmSpacing.cardBorder),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: colors.interactive, width: 2),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: colors.divider, width: HelmSpacing.cardBorder),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: HelmSpacing.s3),
                    Text(l10n.fixedCostsDueDay,
                        style: typo.labelMd
                            .copyWith(color: colors.inkTertiary)),
                    const SizedBox(width: HelmSpacing.s2),
                    DropdownButton<int>(
                      value: day,
                      isDense: true,
                      underline:
                          Container(height: HelmSpacing.cardBorder, color: colors.divider),
                      style: typo.bodyMd
                          .copyWith(color: colors.inkPrimary),
                      items: List.generate(28, (i) => i + 1)
                          .map((d) => DropdownMenuItem(
                              value: d, child: Text('$d')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) onDayChanged(val);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}