// test/features/onboarding/onboarding_no_synthetic_entry_test.dart
//
// Security regression test for C-10:
// Onboarding must NOT fabricate income entries on behalf of the user.
// A finance app inventing financial data the user never entered is a trust violation.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('C-10: onboarding_screen must not fabricate income entries', () {
    late String content;

    setUpAll(() {
      final file = File(
        'lib/features/onboarding/presentation/views/onboarding_screen.dart',
      );
      content = file.readAsStringSync();
    });

    test('does not call addIncome to create a synthetic Initial Balance', () {
      // The fabrication block called incomeNotifierProvider.notifier.addIncome()
      // with clientName: 'Initial Balance' — data the user never entered.
      expect(
        content.contains('Initial Balance'),
        isFalse,
        reason:
            'Onboarding must not fabricate an "Initial Balance" income entry (C-10). '
            'Liquid balance is stored in SharedPreferences, not as a synthetic income record.',
      );
    });

    test('does not silently create income entries from liquid balance', () {
      // The specific guard was: if (_draft.liquidBalanceBdt > 0) { addIncome(...) }
      // Removing that block is the fix. The test detects if it comes back.
      expect(
        content.contains('Starting cash from onboarding'),
        isFalse,
        reason:
            'Onboarding must not create income entries with fabricated project names (C-10).',
      );
    });

    test('does not contain the synthetic balance income creation comment', () {
      expect(
        content.contains('Auto-create initial balance as a received income entry'),
        isFalse,
        reason:
            'The synthetic income creation comment must be removed along with the code (C-10).',
      );
    });
  });
}
