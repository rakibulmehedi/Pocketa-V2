// test/features/safe_to_spend/domain/sts_migration_test.dart
//
// Security regression test for H-11:
// _migrateBufferPercent must convert an absolute BDT value (>100) to a
// percentage clamped to the 5–30 range and write an audit-visible backup
// of the original BDT amount to SharedPreferences.
//
// The audit event is conditional on the Hive audit box being open; in this
// unit test the box is intentionally closed so the audit guard path is also
// exercised (audit failure is non-fatal per the implementation contract).

import 'package:flutter_test/flutter_test.dart';
import 'package:helm/features/safe_to_spend/data/datasources/sts_settings_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('H-11: _migrateBufferPercent — absolute BDT → percentage conversion',
      () {
    // H-11 migration keys (matching the private constants in the data source).
    const legacyKey = 'stsSettings_anxietyBuffer';
    const newKey = 'stsSettings_bufferPercent';
    const backupKey = 'stsSettings_anxietyBuffer_backup_bdt';

    test(
      'value within 0–100 is treated as a percentage and stored unchanged',
      () async {
        // Legacy value of 20.0 is already a valid percentage.
        SharedPreferences.setMockInitialValues({legacyKey: 20.0});
        final ds = StsSettingsDataSourceImpl();
        final loaded = await ds.loadSettings();

        expect(loaded, isNotNull);
        expect(loaded!.bufferPercent, 20.0);

        // The legacy key must be removed after migration.
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.containsKey(legacyKey), isFalse);
      },
    );

    test(
      'absolute BDT value > 100 is converted to a percentage clamped to 5–30',
      () async {
        // 10 000 BDT absolute.  Formula: (10000 / 50000 * 100).clamp(5, 30) = 20.0%
        SharedPreferences.setMockInitialValues({legacyKey: 10000.0});
        final ds = StsSettingsDataSourceImpl();
        final loaded = await ds.loadSettings();

        expect(loaded, isNotNull);
        final pct = loaded!.bufferPercent;
        expect(pct, greaterThanOrEqualTo(5.0));
        expect(pct, lessThanOrEqualTo(30.0));
      },
    );

    test(
      'very large BDT value is clamped to maximum 30%',
      () async {
        // 500 000 BDT → (500000/50000*100) = 1000%, clamped to 30%.
        SharedPreferences.setMockInitialValues({legacyKey: 500000.0});
        final ds = StsSettingsDataSourceImpl();
        final loaded = await ds.loadSettings();

        expect(loaded, isNotNull);
        expect(loaded!.bufferPercent, closeTo(30.0, 0.001));
      },
    );

    test(
      'very small BDT value (>100) is clamped to minimum 5%',
      () async {
        // 101 BDT → (101/50000*100) = 0.202%, clamped to 5%.
        // Uses 101 because the code treats anything > 100 as an absolute BDT.
        SharedPreferences.setMockInitialValues({legacyKey: 101.0});
        final ds = StsSettingsDataSourceImpl();
        final loaded = await ds.loadSettings();

        expect(loaded, isNotNull);
        expect(loaded!.bufferPercent, closeTo(5.0, 0.001));
      },
    );

    test(
      'original BDT amount is preserved in backup key after migration',
      () async {
        // Verify H-11 guarantee: user data is never silently discarded.
        SharedPreferences.setMockInitialValues({legacyKey: 25000.0});
        final ds = StsSettingsDataSourceImpl();
        await ds.loadSettings();

        final prefs = await SharedPreferences.getInstance();
        // The backup key must hold the original absolute BDT value.
        expect(prefs.containsKey(backupKey), isTrue);
        expect(prefs.getDouble(backupKey), closeTo(25000.0, 0.001));
      },
    );

    test(
      'legacy absolute BDT key is removed after migration',
      () async {
        SharedPreferences.setMockInitialValues({legacyKey: 12000.0});
        final ds = StsSettingsDataSourceImpl();
        await ds.loadSettings();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.containsKey(legacyKey), isFalse,
            reason:
                'The legacy stsSettings_anxietyBuffer key must be deleted '
                'after migration to prevent double-migration on next load.');
      },
    );

    test(
      'migrated percentage is written to the new bufferPercent key',
      () async {
        SharedPreferences.setMockInitialValues({legacyKey: 10000.0});
        final ds = StsSettingsDataSourceImpl();
        await ds.loadSettings();

        final prefs = await SharedPreferences.getInstance();
        // After migration the value must be findable under the new key
        // (either directly or via the atomic v2 blob).
        final hasNewKey = prefs.containsKey(newKey) ||
            prefs.containsKey('stsSettings_v2');
        expect(hasNewKey, isTrue,
            reason:
                'Migrated buffer percent must be persisted under the new '
                'key or the atomic v2 blob.');
      },
    );
  });
}
