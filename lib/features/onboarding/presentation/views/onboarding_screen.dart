// lib/features/onboarding/presentation/views/onboarding_screen.dart
// UX-2.09 — 6-step doctrine-aligned onboarding flow with UX improvements.
//
// Scope: qualifier → balance → fixed costs → income pattern → buffer → pipeline → home
// Skipped: email/auth (Screen 2), PIN/biometric (Screen 7) — trust layer, non-goal for UX-2.
//
// Rules enforced:
//   ONB-002: no back button, no AppBar
//   ONB-003: 2pt progress line only, no step numbers
//   ONB-012: after last step, go straight to home (no celebration screen)
//   ONB-014: no confetti, no "Welcome!", no tour
//
// UX Improvements:
//   - Uses HelmMotion tokens for page transitions
//   - Semantics for screen reader support

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:helm/config/router/route_names.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_motion.dart';
import 'package:helm/core/themes/helm_spacing.dart';
import 'package:helm/core/utils/id_generator.dart';
import 'package:helm/features/onboarding/domain/onboarding_draft.dart';
import 'package:helm/features/onboarding/presentation/views/pages/buffer_comfort_page.dart';
import 'package:helm/features/onboarding/presentation/views/pages/fixed_costs_page.dart';
import 'package:helm/features/onboarding/presentation/views/pages/income_pattern_page.dart';
import 'package:helm/features/onboarding/presentation/views/pages/liquid_balance_page.dart';
import 'package:helm/features/onboarding/presentation/views/pages/first_pipeline_page.dart';
import 'package:helm/features/onboarding/presentation/views/pages/qualifying_question_page.dart';
import 'package:helm/features/onboarding/presentation/widgets/onboarding_progress_line.dart';
import 'package:helm/features/income/domain/entities/income_entry_entity.dart';
import 'package:helm/features/income/presentation/providers/income_providers.dart';
import 'package:helm/features/safe_to_spend/domain/entities/fixed_cost_entry.dart';
import 'package:helm/core/analytics/analytics_service.dart';
import 'package:helm/core/analytics/event_registry.dart';
import 'package:helm/l10n/app_localization.dart';
import 'package:helm/features/safe_to_spend/presentation/providers/safe_to_spend_providers.dart';
import 'package:helm/features/settings/presentation/views/cadence_preference_sheet.dart';

// ONB-003 progress values per step (6 steps)
final List<double> _kStepProgress = [
  0.0,
  HelmSpacing.onboardingSteps[0], // 0.20
  HelmSpacing.onboardingSteps[1], // 0.40
  HelmSpacing.onboardingSteps[2], // 0.55
  HelmSpacing.onboardingSteps[3], // 0.70
  HelmSpacing.onboardingSteps[4], // 0.90
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  OnboardingDraft _draft = const OnboardingDraft();

  @override
  void initState() {
    super.initState();
    // H-21: If onboarding was already completed, skip straight to home.
    // Guards against re-running onboarding on back-navigation after completion.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (SharedPrefServices.getOnboardingCompleted()) {
        context.go(RouteNames.home);
      }
    });
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: HelmMotion.slow,
      curve: HelmMotion.defaultCurve,
    );
    if (step > 0) {
      ref.read(analyticsProvider).trackEvent(
        TransactionalEvents.onboardingStepCompleted,
        properties: {EventProperties.stepNumber: step.toString()},
      );
    }
  }

  /// Creates a pipeline entry from onboarding step 6, then completes.
  Future<void> _addPipelineEntryAndComplete(PipelineDraftEntry entry) async {
    final now = DateTime.now();
    final incomeEntity = IncomeEntryEntity(
      id: IdGenerator.uniqueId(),
      clientName: entry.clientName,
      projectName: '',
      amount: entry.amount,
      currency: entry.currency,
      status: IncomeStatus.expected,
      expectedDate: now.add(const Duration(days: 14)),
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(incomeNotifierProvider.notifier).addIncome(incomeEntity);
    await _completeOnboarding();
  }

  /// Persists all draft data then navigates to home (ONB-012).
  Future<void> _completeOnboarding() async {
    await SharedPrefServices.setLiquidBalanceBdt(_draft.liquidBalanceBdt);
    await SharedPrefServices.setIncomePattern(_draft.incomePattern.name);

    final fixedCostNotifier = ref.read(fixedCostNotifierProvider.notifier);
    for (final item in _draft.fixedCosts) {
      await fixedCostNotifier.addFixedCost(FixedCostEntry(
        id: IdGenerator.uniqueId(),
        label: item.label,
        amount: item.amount,
        dueDayOfMonth: item.dayOfMonth.clamp(1, 28),
        createdAt: DateTime.now(),
      ));
    }

    // Buffer: store as percentage in StsSettings (D1.11).
    final stsNotifier = ref.read(stsSettingsProvider.notifier);
    await stsNotifier.updateBufferPercent(_draft.bufferPercent.toDouble());

    await SharedPrefServices.setOnboardingCompleted(true);
    ref.read(analyticsProvider).trackEvent(BoundaryEvents.onboardingCompleted);
    if (mounted) {
      await CadencePreferenceSheet.show(context);
    }
    if (mounted) context.go(RouteNames.home);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: Column(
        children: [
          // ONB-003: 2pt progress line at top, no labels
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                OnboardingProgressLine(
                  progress: _kStepProgress[_currentStep],
                ),
              ],
            ),
          ),

          Expanded(
            child: Semantics(
              label: context.l10n.onboardingStepOf(_currentStep + 1, 6),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Step 0 — Qualifying question
                  QualifyingQuestionPage(
                    onQualified: () => _goToStep(1),
                    onDisqualified: () {
                      if (mounted) context.go(RouteNames.welcome);
                    },
                  ),

                  // Step 1 — Liquid balance
                  LiquidBalancePage(
                    initialBalance: _draft.liquidBalanceBdt,
                    onContinue: (balance) {
                      setState(() {
                        _draft = _draft.copyWith(liquidBalanceBdt: balance);
                      });
                      _goToStep(2);
                    },
                  ),

                  // Step 2 — Fixed costs
                  FixedCostsPage(
                    initialCosts: _draft.fixedCosts,
                    onContinue: (costs) {
                      setState(() {
                        _draft = _draft.copyWith(fixedCosts: costs);
                      });
                      _goToStep(3);
                    },
                  ),

                  // Step 3 — Income pattern
                  IncomePatternPage(
                    initialPattern: _draft.incomePattern,
                    onContinue: (pattern) {
                      setState(() {
                        _draft = _draft.copyWith(incomePattern: pattern);
                      });
                      _goToStep(4);
                    },
                  ),

                  // Step 4 — Buffer comfort
                  BufferComfortPage(
                    initialBufferPercent: _draft.bufferPercent,
                    liquidBalanceBdt: _draft.liquidBalanceBdt,
                    totalFixedCostsBdt: _draft.totalFixedCostsBdt,
                    onContinue: (bufferPct) {
                      setState(() {
                        _draft = _draft.copyWith(bufferPercent: bufferPct);
                      });
                      _goToStep(5);
                    },
                  ),

                  // Step 5 — First pipeline entry (optional, M5)
                  FirstPipelinePage(
                    onAddEntry: (entry) => _addPipelineEntryAndComplete(entry),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}