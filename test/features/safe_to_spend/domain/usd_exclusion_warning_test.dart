// test/features/safe_to_spend/domain/usd_exclusion_warning_test.dart
//
// Security regression test for H-40:
// SafeToSpendCalculator must populate SafeToSpendResult.excludedWarnings with
// a human-readable warning for each USD income entry that has no valid fxRate.
// Without this, the user cannot distinguish between "USD income counted" and
// "USD income silently excluded" — a trust violation for a financial app.

import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/utils/id_generator.dart';
import 'package:helm/features/income/domain/entities/income_entry_entity.dart';
import 'package:helm/features/safe_to_spend/domain/entities/fixed_cost_entry.dart';
import 'package:helm/features/safe_to_spend/domain/entities/sts_settings.dart';
import 'package:helm/features/safe_to_spend/domain/safe_to_spend_calculator.dart';

void main() {
  final now = DateTime(2026, 6, 15);

  IncomeEntryEntity makeUsdEntry({
    required String clientName,
    double amount = 500.0,
    IncomeStatus status = IncomeStatus.received,
    double? fxRate,
  }) {
    return IncomeEntryEntity(
      id: IdGenerator.uniqueId(),
      clientName: clientName,
      projectName: 'Test Project',
      amount: amount,
      currency: 'USD',
      status: status,
      expectedDate: now,
      createdAt: now,
      updatedAt: now,
      fxRate: fxRate,
    );
  }

  IncomeEntryEntity makeBdtEntry({double amount = 50000.0}) {
    return IncomeEntryEntity(
      id: IdGenerator.uniqueId(),
      clientName: 'BDT Client',
      projectName: 'BDT Project',
      amount: amount,
      currency: 'BDT',
      status: IncomeStatus.received,
      expectedDate: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  const settings = StsSettings(taxRate: 0.10, bufferPercent: 15.0);

  group('H-40: USD exclusion warning — excludedWarnings field', () {
    test(
      'excludedWarnings is empty when USD entry has a valid fxRate',
      () {
        final entry = makeUsdEntry(clientName: 'Upwork', fxRate: 110.0);
        final result = SafeToSpendCalculator.calculate(
          incomeEntries: [entry],
          transactions: [],
          settings: settings,
          fixedCosts: [],
          now: now,
        );

        expect(result.excludedWarnings, isEmpty);
      },
    );

    test(
      'excludedWarnings is non-empty when USD entry has no fxRate (null)',
      () {
        final entry = makeUsdEntry(clientName: 'Fiverr', fxRate: null);
        final result = SafeToSpendCalculator.calculate(
          incomeEntries: [entry],
          transactions: [],
          settings: settings,
          fixedCosts: [],
          now: now,
        );

        expect(result.excludedWarnings, isNotEmpty,
            reason:
                'A received USD entry with no fxRate must generate an '
                'exclusion warning so the user is aware of the omission.');
      },
    );

    test(
      'warning message contains the client name for identification',
      () {
        const clientName = 'DirectClient_ABC';
        final entry = makeUsdEntry(clientName: clientName, fxRate: null);
        final result = SafeToSpendCalculator.calculate(
          incomeEntries: [entry],
          transactions: [],
          settings: settings,
          fixedCosts: [],
          now: now,
        );

        expect(
          result.excludedWarnings.any((w) => w.contains(clientName)),
          isTrue,
          reason:
              'The exclusion warning must identify the client so the user '
              'knows which income entry to fix.',
        );
      },
    );

    test(
      'excludedWarnings is non-empty when fxRate is zero (invalid)',
      () {
        final entry = makeUsdEntry(clientName: 'ZeroRate', fxRate: 0.0);
        final result = SafeToSpendCalculator.calculate(
          incomeEntries: [entry],
          transactions: [],
          settings: settings,
          fixedCosts: [],
          now: now,
        );

        expect(result.excludedWarnings, isNotEmpty,
            reason:
                'A zero fxRate is invalid (M-8) and should generate an '
                'exclusion warning identical to a null fxRate.');
      },
    );

    test(
      'excludedWarnings is non-empty when fxRate is negative (invalid)',
      () {
        final entry = makeUsdEntry(clientName: 'NegRate', fxRate: -50.0);
        final result = SafeToSpendCalculator.calculate(
          incomeEntries: [entry],
          transactions: [],
          settings: settings,
          fixedCosts: [],
          now: now,
        );

        expect(result.excludedWarnings, isNotEmpty,
            reason:
                'A negative fxRate is invalid and must produce an exclusion warning.');
      },
    );

    test(
      'one warning per excluded USD entry — multiple entries produce multiple warnings',
      () {
        final entries = [
          makeUsdEntry(clientName: 'ClientA', fxRate: null),
          makeUsdEntry(clientName: 'ClientB', fxRate: null),
          makeUsdEntry(clientName: 'ClientC', fxRate: 110.0), // valid — no warning
        ];
        final result = SafeToSpendCalculator.calculate(
          incomeEntries: entries,
          transactions: [],
          settings: settings,
          fixedCosts: [],
          now: now,
        );

        expect(result.excludedWarnings.length, equals(2));
      },
    );

    test(
      'USD entry excluded via fxRate does not contribute to totalReceivedIncomeBdt',
      () {
        // A BDT entry of 50 000 and a USD entry with no fxRate.
        // Only the BDT entry should count.
        final bdtEntry = makeBdtEntry(amount: 50000.0);
        final usdEntry = makeUsdEntry(clientName: 'NoRate', fxRate: null);

        final result = SafeToSpendCalculator.calculate(
          incomeEntries: [bdtEntry, usdEntry],
          transactions: [],
          settings: settings,
          fixedCosts: const <FixedCostEntry>[],
          now: now,
        );

        expect(result.totalReceivedIncomeBdt, closeTo(50000.0, 0.01));
        expect(result.excludedWarnings, isNotEmpty);
      },
    );

    test(
      'BDT entries never generate exclusion warnings regardless of amount',
      () {
        final bdtEntry = makeBdtEntry(amount: 999999.0);
        final result = SafeToSpendCalculator.calculate(
          incomeEntries: [bdtEntry],
          transactions: [],
          settings: settings,
          fixedCosts: [],
          now: now,
        );

        expect(result.excludedWarnings, isEmpty,
            reason: 'BDT entries always have an implicit fxRate of 1.0 '
                'and must never produce exclusion warnings.');
      },
    );
  });
}
