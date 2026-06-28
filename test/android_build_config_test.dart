// test/android_build_config_test.dart
//
// Security regression test for H-33 / bundle-ID fix:
// Verifies the MethodChannel name constant in HiveService is the corrected
// value "com.safetospends.helm/backup" and NOT the old bundle-ID-aligned name
// "co.helm.finance/backup".
//
// Why this matters: the native Android/iOS handler registers itself under the
// correct channel name. If the Dart side diverges, the excludeFromBackup call
// silently becomes a no-op and sensitive Hive files are included in device
// backups.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HiveService MethodChannel backup name (H-33 regression)', () {
    late String content;

    setUpAll(() {
      final file = File('lib/core/local_storage/hive_service.dart');
      content = file.readAsStringSync();
    });

    test(
      'backup MethodChannel uses "com.safetospends.helm/backup"',
      () {
        expect(
          content.contains("'com.safetospends.helm/backup'"),
          isTrue,
          reason:
              'HiveService must declare the backup exclusion channel as '
              '"com.safetospends.helm/backup" so it matches the native handler.',
        );
      },
    );

    test(
      'backup MethodChannel does NOT use the old "co.helm.finance/backup"',
      () {
        expect(
          content.contains("'co.helm.finance/backup'"),
          isFalse,
          reason:
              'The old bundle-ID-aligned channel name "co.helm.finance/backup" '
              'must not appear — native handlers now register under '
              '"com.safetospends.helm/backup".',
        );
      },
    );

    test(
      'backup channel constant is assigned to _backupExclusionChannel field',
      () {
        expect(
          content.contains('_backupExclusionChannel'),
          isTrue,
          reason:
              'The MethodChannel for backup exclusion must be stored in the '
              '_backupExclusionChannel field so it is used consistently.',
        );
      },
    );
  });
}
