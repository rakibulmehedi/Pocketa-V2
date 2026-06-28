// test/features/auth/presentation/biometric_provider_test.dart
//
// Tests for BiometricNotifier: availability check, opt-in preference,
// and the hardware-unavailable clamp behaviour.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:helm/features/auth/data/datasources/biometric_datasource.dart';
import 'package:helm/features/auth/presentation/providers/auth_provider.dart';
import 'package:helm/features/auth/presentation/providers/biometric_provider.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';

class _FakeBiometric extends BiometricDataSource {
  final bool available;
  _FakeBiometric({required this.available});

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async => false;
}

ProviderContainer _makeContainer({required bool available}) {
  return ProviderContainer(
    overrides: [
      biometricDataSourceProvider.overrideWithValue(_FakeBiometric(available: available)),
    ],
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefServices.init();
  });

  group('BiometricNotifier build', () {
    test('isAvailable false when hardware unavailable', () async {
      final container = _makeContainer(available: false);
      final state = await container.read(biometricProvider.future);
      expect(state.isAvailable, isFalse);
      expect(state.isEnabled, isFalse);
    });

    test('isAvailable true when hardware available', () async {
      final container = _makeContainer(available: true);
      final state = await container.read(biometricProvider.future);
      expect(state.isAvailable, isTrue);
      expect(state.isEnabled, isFalse); // not enabled by default
    });

    test('isEnabled true when available and pref was saved', () async {
      SharedPreferences.setMockInitialValues({'biometric_enabled': true});
      await SharedPrefServices.init();
      final container = _makeContainer(available: true);
      final state = await container.read(biometricProvider.future);
      expect(state.isEnabled, isTrue);
    });

    test('isEnabled false even when pref true but hardware unavailable', () async {
      SharedPreferences.setMockInitialValues({'biometric_enabled': true});
      await SharedPrefServices.init();
      final container = _makeContainer(available: false);
      final state = await container.read(biometricProvider.future);
      expect(state.isEnabled, isFalse);
    });
  });

  group('BiometricNotifier setEnabled', () {
    test('setEnabled(true) persists pref and updates state', () async {
      final container = _makeContainer(available: true);
      // build must complete before setEnabled
      await container.read(biometricProvider.future);

      await container.read(biometricProvider.notifier).setEnabled(true);
      final state = container.read(biometricProvider).valueOrNull!;
      expect(state.isEnabled, isTrue);
      expect(SharedPrefServices.getBiometricEnabled(), isTrue);
    });

    test('setEnabled(false) clears pref and updates state', () async {
      SharedPreferences.setMockInitialValues({'biometric_enabled': true});
      await SharedPrefServices.init();
      final container = _makeContainer(available: true);
      await container.read(biometricProvider.future);

      await container.read(biometricProvider.notifier).setEnabled(false);
      final state = container.read(biometricProvider).valueOrNull!;
      expect(state.isEnabled, isFalse);
      expect(SharedPrefServices.getBiometricEnabled(), isFalse);
    });

    test('setEnabled(true) clamped to false when hardware unavailable', () async {
      final container = _makeContainer(available: false);
      await container.read(biometricProvider.future);

      await container.read(biometricProvider.notifier).setEnabled(true);
      final state = container.read(biometricProvider).valueOrNull!;
      expect(state.isEnabled, isFalse);
      expect(SharedPrefServices.getBiometricEnabled(), isFalse);
    });
  });
}
