// test/features/auth/presentation/auth_provider_test.dart
//
// Tests for AuthNotifier PIN lockout, expiry, sensitive-action PIN
// verification, and biometric unlock.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:helm/core/constants/app_box_names.dart';
import 'package:helm/core/security/constants/security_keys.dart';
import 'package:helm/features/auth/data/datasources/biometric_datasource.dart';
import 'package:helm/features/auth/domain/entities/auth_state.dart';
import 'package:helm/features/auth/domain/pin_hasher.dart';
import 'package:helm/features/auth/presentation/providers/auth_provider.dart';

import '../../../helpers/test_hive.dart';

class _FakeBiometric extends BiometricDataSource {
  final bool _success;
  _FakeBiometric({required bool success}) : _success = success;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> authenticate(String reason) async => _success;
}

ProviderContainer _makeContainerWithBiometric({required bool success}) {
  return ProviderContainer(
    overrides: [
      biometricDataSourceProvider.overrideWithValue(
        _FakeBiometric(success: success),
      ),
    ],
  );
}

void main() {
  late Box<dynamic> authBox;

  setUpAll(() async {
    await TestHive.init();
  });

  tearDownAll(() async {
    await TestHive.tearDown();
  });

  setUp(() async {
    authBox = await TestHive.openBox(AppBoxNames.authBox);
  });

  tearDown(() async {
    await TestHive.clearBox(AppBoxNames.authBox);
  });

  group('AuthNotifier lockout expiry', () {
    test('build resets failed attempts when lockout has expired', () async {
      final expiredLockout = DateTime.now()
          .subtract(const Duration(minutes: 1))
          .millisecondsSinceEpoch;
      await authBox.putAll({
        SecurityKeys.pinIsSetupKey: true,
        SecurityKeys.pinSaltKey: PinHasher.generateSalt(),
        SecurityKeys.pinHashVersionKey: AuthNotifier.pinHashVersion,
        SecurityKeys.authFailedAttempts: 5,
        SecurityKeys.authLockoutUntil: expiredLockout,
      });

      final container = TestHive.makeContainer();
      final state = container.read(authProvider);

      expect(state.status, AuthStatus.locked);
      expect(state.failedAttempts, 0);
      expect(state.lockoutUntil, isNull);
      expect(authBox.get(SecurityKeys.authFailedAttempts), 0);
    });

    test('build preserves lockout when still active', () async {
      final futureLockout = DateTime.now()
          .add(const Duration(minutes: 5))
          .millisecondsSinceEpoch;
      await authBox.putAll({
        SecurityKeys.pinIsSetupKey: true,
        SecurityKeys.pinSaltKey: PinHasher.generateSalt(),
        SecurityKeys.pinHashVersionKey: AuthNotifier.pinHashVersion,
        SecurityKeys.authFailedAttempts: 5,
        SecurityKeys.authLockoutUntil: futureLockout,
      });

      final container = TestHive.makeContainer();
      final state = container.read(authProvider);

      expect(state.status, AuthStatus.locked);
      expect(state.failedAttempts, 5);
      expect(state.lockoutUntil, isNotNull);
      expect(state.isLockedOut, isTrue);
    });
  });

  group('AuthNotifier authenticate', () {
    test('successful auth resets failed attempts', () async {
      final salt = PinHasher.generateSalt();
      const pin = '123456';
      await authBox.putAll({
        SecurityKeys.pinIsSetupKey: true,
        SecurityKeys.pinSaltKey: salt,
        SecurityKeys.pinHashKey: PinHasher.hashPin(pin, salt),
        SecurityKeys.pinHashVersionKey: AuthNotifier.pinHashVersion,
        SecurityKeys.authFailedAttempts: 2,
      });

      final container = TestHive.makeContainer();
      final notifier = container.read(authProvider.notifier);
      final ok = await notifier.authenticate(pin);

      expect(ok, isTrue);
      expect(container.read(authProvider).status, AuthStatus.authenticated);
      expect(authBox.get(SecurityKeys.authFailedAttempts), 0);
    });

    test('locks out after max failed attempts', () async {
      final salt = PinHasher.generateSalt();
      const pin = '123456';
      await authBox.putAll({
        SecurityKeys.pinIsSetupKey: true,
        SecurityKeys.pinSaltKey: salt,
        SecurityKeys.pinHashKey: PinHasher.hashPin(pin, salt),
        SecurityKeys.pinHashVersionKey: AuthNotifier.pinHashVersion,
      });

      final container = TestHive.makeContainer();
      final notifier = container.read(authProvider.notifier);

      for (var i = 0; i < AuthNotifier.maxAttempts; i++) {
        await notifier.authenticate('000000');
      }

      final state = container.read(authProvider);
      expect(state.failedAttempts, AuthNotifier.maxAttempts);
      expect(state.lockoutUntil, isNotNull);
      expect(state.isLockedOut, isTrue);
    });

    test('allows attempts again once lockout expires', () async {
      final salt = PinHasher.generateSalt();
      const pin = '123456';
      final futureLockout = DateTime.now()
          .add(const Duration(milliseconds: 200))
          .millisecondsSinceEpoch;
      await authBox.putAll({
        SecurityKeys.pinIsSetupKey: true,
        SecurityKeys.pinSaltKey: salt,
        SecurityKeys.pinHashKey: PinHasher.hashPin(pin, salt),
        SecurityKeys.pinHashVersionKey: AuthNotifier.pinHashVersion,
        SecurityKeys.authFailedAttempts: 5,
        SecurityKeys.authLockoutUntil: futureLockout,
      });

      final container = TestHive.makeContainer();
      final notifier = container.read(authProvider.notifier);

      // Wait for the lockout to expire while the app is running.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final ok = await notifier.authenticate(pin);

      expect(ok, isTrue);
    });
  });

  group('AuthNotifier unlockViaBiometrics', () {
    test('returns false without changing state when locked out', () async {
      final futureLockout = DateTime.now()
          .add(const Duration(minutes: 5))
          .millisecondsSinceEpoch;
      await authBox.putAll({
        SecurityKeys.pinIsSetupKey: true,
        SecurityKeys.pinSaltKey: PinHasher.generateSalt(),
        SecurityKeys.pinHashVersionKey: AuthNotifier.pinHashVersion,
        SecurityKeys.authFailedAttempts: 5,
        SecurityKeys.authLockoutUntil: futureLockout,
      });

      final container = _makeContainerWithBiometric(success: true);
      final notifier = container.read(authProvider.notifier);
      final ok = await notifier.unlockViaBiometrics();

      expect(ok, isFalse);
      expect(container.read(authProvider).status, isNot(AuthStatus.authenticated));
    });

    test('transitions to authenticated and resets attempts on success', () async {
      final salt = PinHasher.generateSalt();
      await authBox.putAll({
        SecurityKeys.pinIsSetupKey: true,
        SecurityKeys.pinSaltKey: salt,
        SecurityKeys.pinHashKey: PinHasher.hashPin('123456', salt),
        SecurityKeys.pinHashVersionKey: AuthNotifier.pinHashVersion,
        SecurityKeys.authFailedAttempts: 2,
      });

      final container = _makeContainerWithBiometric(success: true);
      final notifier = container.read(authProvider.notifier);
      final ok = await notifier.unlockViaBiometrics();

      expect(ok, isTrue);
      expect(container.read(authProvider).status, AuthStatus.authenticated);
      expect(authBox.get(SecurityKeys.authFailedAttempts), 0);
    });

    test('returns false and preserves state when biometric fails', () async {
      final salt = PinHasher.generateSalt();
      await authBox.putAll({
        SecurityKeys.pinIsSetupKey: true,
        SecurityKeys.pinSaltKey: salt,
        SecurityKeys.pinHashKey: PinHasher.hashPin('123456', salt),
        SecurityKeys.pinHashVersionKey: AuthNotifier.pinHashVersion,
      });

      final container = _makeContainerWithBiometric(success: false);
      final notifier = container.read(authProvider.notifier);
      final ok = await notifier.unlockViaBiometrics();

      expect(ok, isFalse);
      expect(container.read(authProvider).status, isNot(AuthStatus.authenticated));
      // failed attempts NOT incremented (biometric failure ≠ security threat)
      expect(authBox.get(SecurityKeys.authFailedAttempts), isNull);
    });
  });

  group('AuthNotifier verifyPinForSensitiveAction', () {
    test('returns true for correct PIN without authenticating session', () async {
      final salt = PinHasher.generateSalt();
      const pin = '123456';
      await authBox.putAll({
        SecurityKeys.pinIsSetupKey: true,
        SecurityKeys.pinSaltKey: salt,
        SecurityKeys.pinHashKey: PinHasher.hashPin(pin, salt),
        SecurityKeys.pinHashVersionKey: AuthNotifier.pinHashVersion,
      });

      final container = TestHive.makeContainer();
      final notifier = container.read(authProvider.notifier);
      final ok = await notifier.verifyPinForSensitiveAction(pin);

      expect(ok, isTrue);
      expect(container.read(authProvider).status, isNot(AuthStatus.authenticated));
      expect(authBox.get(SecurityKeys.authFailedAttempts), 0);
    });

    test('increments failed attempts and locks out', () async {
      final salt = PinHasher.generateSalt();
      const pin = '123456';
      await authBox.putAll({
        SecurityKeys.pinIsSetupKey: true,
        SecurityKeys.pinSaltKey: salt,
        SecurityKeys.pinHashKey: PinHasher.hashPin(pin, salt),
        SecurityKeys.pinHashVersionKey: AuthNotifier.pinHashVersion,
      });

      final container = TestHive.makeContainer();
      final notifier = container.read(authProvider.notifier);

      for (var i = 0; i < AuthNotifier.maxAttempts; i++) {
        await notifier.verifyPinForSensitiveAction('000000');
      }

      expect(container.read(authProvider).isLockedOut, isTrue);
    });
  });
}
