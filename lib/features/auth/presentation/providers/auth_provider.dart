// lib/features/auth/presentation/providers/auth_provider.dart
//
// PIN-based auth state management for Helm Trust Layer (D1).
// Uses Hive untyped dynamic box — no new packages required beyond crypto.
//
// Security: PIN stored as PBKDF2-HMAC-SHA256(salt + pin, 100k iterations).
// Salt generated per-setup. Version key guards against algorithm rollback.
// Migration: missing salt or stale hash version → clear → force re-setup.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:helm/config/router/route_names.dart';
import 'package:helm/features/auth/data/datasources/biometric_datasource.dart';
import 'package:helm/core/constants/app_box_names.dart';
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/core/security/constants/security_keys.dart';
import 'package:helm/core/utils/input_validator.dart';
import 'package:helm/features/auth/domain/entities/auth_state.dart';
import 'package:helm/features/auth/domain/pin_hasher.dart';

// ---------------------------------------------------------------------------
// Global refresh listenable for GoRouter.
// ---------------------------------------------------------------------------

/// Notifies GoRouter whenever the authenticated session state changes.
/// This replaces the previous static mutable bool that could be bypassed.
final ValueNotifier<bool> authRefreshListenable = ValueNotifier<bool>(false);

// ---------------------------------------------------------------------------
// AuthNotifier
// ---------------------------------------------------------------------------

class AuthNotifier extends Notifier<AuthState> {
  static const int maxAttempts = 5;
  static const int lockoutMinutes = 15;
  static const int pinLength = 6;

  static const String _pinHashKey = SecurityKeys.pinHashKey;
  static const String _pinSaltKey = SecurityKeys.pinSaltKey;
  static const String _pinIsSetupKey = SecurityKeys.pinIsSetupKey;
  static const String _pinHashVersionKey = SecurityKeys.pinHashVersionKey;
  static const int pinHashVersion = 2;

  bool _mounted = true;

  Box<dynamic> get _box => Hive.box<dynamic>(AppBoxNames.authBox);

  @override
  AuthState build() {
    ref.onDispose(() => _mounted = false);
    final isSetUp = _box.get(_pinIsSetupKey, defaultValue: false) as bool;
    if (!isSetUp) {
      _updateSessionAuthenticated(false);
      return const AuthState(status: AuthStatus.setupRequired);
    }
    // Migration guard: setup flag present but no salt key means old base64 hash.
    // Cannot upgrade without the original PIN — force re-setup for security.
    final hasSalt = _box.get(_pinSaltKey) != null;
    if (!hasSalt) {
      _box.delete(_pinHashKey);
      _box.delete(_pinIsSetupKey);
      _updateSessionAuthenticated(false);
      return const AuthState(status: AuthStatus.setupRequired);
    }

    // Migration guard: hash algorithm version mismatch forces re-setup so that
    // we never verify a v1 SHA-256 hash against the v2 PBKDF2 function.
    final storedVersion = _box.get(_pinHashVersionKey) as int?;
    if (storedVersion != pinHashVersion) {
      unawaited(_box.deleteAll([
        _pinHashKey,
        _pinSaltKey,
        _pinIsSetupKey,
        _pinHashVersionKey,
        SecurityKeys.authFailedAttempts,
        SecurityKeys.authLockoutUntil,
      ]));
      _updateSessionAuthenticated(false);
      return const AuthState(status: AuthStatus.setupRequired);
    }

    var failedAttempts =
        _box.get(SecurityKeys.authFailedAttempts, defaultValue: 0) as int;
    final lockoutUntilMillis =
        _box.get(SecurityKeys.authLockoutUntil) as int?;
    final lockoutUntil = InputValidator.dateTimeFromMillis(lockoutUntilMillis);

    // If the lockout window has expired, reset the counter so the user is not
    // permanently locked out after maxAttempts.
    final lockoutExpired =
        lockoutUntil != null && DateTime.now().isAfter(lockoutUntil);
    if (lockoutExpired) {
      failedAttempts = 0;
      _box.putAll({
        SecurityKeys.authFailedAttempts: 0,
        SecurityKeys.authLockoutUntil: null,
      });
    }

    _updateSessionAuthenticated(false);
    return AuthState(
      status: AuthStatus.locked,
      failedAttempts: failedAttempts,
      lockoutUntil: lockoutExpired ? null : lockoutUntil,
    );
  }

  /// Sets up a new PIN. Generates a fresh salt and stores SHA-256(salt+pin).
  /// All writes are performed atomically via putAll.
  Future<void> setupPin(String pin) async {
    if (pin.length < pinLength) {
      throw ArgumentError('PIN must be at least $pinLength digits');
    }

    final salt = PinHasher.generateSalt();
    final hash = PinHasher.hashPin(pin, salt);

    await _box.putAll({
      _pinSaltKey: salt,
      _pinHashKey: hash,
      _pinIsSetupKey: true,
      _pinHashVersionKey: pinHashVersion,
      SecurityKeys.authFailedAttempts: 0,
      SecurityKeys.authLockoutUntil: null,
    });

    if (!_mounted) return;
    _updateSessionAuthenticated(true);
    state = const AuthState(status: AuthStatus.authenticated);
  }

  /// Verifies a PIN for a sensitive in-app action (e.g., account deletion)
  /// without transitioning the global session to authenticated.
  /// Enforces the same attempt limit and lockout policy as [authenticate].
  Future<bool> verifyPinForSensitiveAction(String pin) async {
    if (state.isLockedOut) return false;

    final lockoutUntil = state.lockoutUntil;
    if (lockoutUntil != null && DateTime.now().isAfter(lockoutUntil)) {
      await _box.putAll({
        SecurityKeys.authFailedAttempts: 0,
        SecurityKeys.authLockoutUntil: null,
      });
      if (!_mounted) return false;
      state = AuthState(
        status: AuthStatus.locked,
        failedAttempts: 0,
        lockoutUntil: null,
      );
    }

    if (state.failedAttempts >= maxAttempts) return false;

    final stored = _box.get(_pinHashKey) as String?;
    final salt = _box.get(_pinSaltKey) as String?;
    if (stored == null || salt == null) return false;

    if (PinHasher.verify(pin, salt, stored)) {
      await _box.putAll({
        SecurityKeys.authFailedAttempts: 0,
        SecurityKeys.authLockoutUntil: null,
      });
      if (!_mounted) return true;
      state = AuthState(
        status: AuthStatus.locked,
        failedAttempts: 0,
        lockoutUntil: null,
      );
      return true;
    }

    final newAttempts = state.failedAttempts + 1;
    DateTime? newLockoutUntil;
    if (newAttempts >= maxAttempts) {
      newLockoutUntil =
          DateTime.now().add(const Duration(minutes: lockoutMinutes));
    }

    await _box.putAll({
      SecurityKeys.authFailedAttempts: newAttempts,
      SecurityKeys.authLockoutUntil: newLockoutUntil?.millisecondsSinceEpoch,
    });

    if (!_mounted) return false;
    state = AuthState(
      status: AuthStatus.locked,
      failedAttempts: newAttempts,
      lockoutUntil: newLockoutUntil,
    );
    return false;
  }

  /// Attempts to authenticate with the provided PIN.
  /// Returns true on success, false on failure.
  /// Blocked after [maxAttempts] consecutive failures for [lockoutMinutes].
  Future<bool> authenticate(String pin) async {
    if (state.isLockedOut) return false;

    // Refresh lockout state in case the expiry window has passed since build().
    final lockoutUntil = state.lockoutUntil;
    if (lockoutUntil != null && DateTime.now().isAfter(lockoutUntil)) {
      await _box.putAll({
        SecurityKeys.authFailedAttempts: 0,
        SecurityKeys.authLockoutUntil: null,
      });
      if (!_mounted) return false;
      state = AuthState(
        status: AuthStatus.locked,
        failedAttempts: 0,
        lockoutUntil: null,
      );
    }

    if (state.failedAttempts >= maxAttempts) return false;

    final stored = _box.get(_pinHashKey) as String?;
    final salt = _box.get(_pinSaltKey) as String?;
    if (stored == null || salt == null) return false;

    if (PinHasher.verify(pin, salt, stored)) {
      await _box.putAll({
        SecurityKeys.authFailedAttempts: 0,
        SecurityKeys.authLockoutUntil: null,
      });

      if (!_mounted) return true;
      _updateSessionAuthenticated(true);
      state = const AuthState(status: AuthStatus.authenticated);
      return true;
    }

    final newAttempts = state.failedAttempts + 1;
    DateTime? newLockoutUntil;
    if (newAttempts >= maxAttempts) {
      newLockoutUntil =
          DateTime.now().add(const Duration(minutes: lockoutMinutes));
    }

    await _box.putAll({
      SecurityKeys.authFailedAttempts: newAttempts,
      SecurityKeys.authLockoutUntil:
          newLockoutUntil?.millisecondsSinceEpoch,
    });

    if (!_mounted) return false;
    state = AuthState(
      status: AuthStatus.locked,
      failedAttempts: newAttempts,
      lockoutUntil: newLockoutUntil,
    );
    return false;
  }

  /// Locks the session. PIN is preserved — user must re-enter to unlock.
  void lock() {
    _updateSessionAuthenticated(false);
    state = AuthState(
      status: AuthStatus.locked,
      failedAttempts: state.failedAttempts,
      lockoutUntil: state.lockoutUntil,
    );
  }

  /// Ends the authenticated session and clears Magic Link session state.
  /// The PIN remains set; user must re-authenticate to continue.
  Future<void> logout() async {
    _updateSessionAuthenticated(false);

    // Clear Magic Link session token and flag so the next cold start requires
    // identity re-verification.
    await _box.delete(SecurityKeys.authMagicLinkSessionToken);
    await _box.delete('magic_link_verified');
    await SharedPrefServices.setMagicLinkAuthCompleted(false);
    await SharedPrefServices.setGuestMode(false);

    if (!_mounted) return;
    state = AuthState(
      status: AuthStatus.locked,
      failedAttempts: state.failedAttempts,
      lockoutUntil: state.lockoutUntil,
    );
  }

  /// Removes the stored PIN entirely. Resets to setup-required state.
  /// All deletions are performed atomically via deleteFromDisk? No — use deleteAll.
  Future<void> clearPin() async {
    _updateSessionAuthenticated(false);
    await _box.deleteAll([
      _pinHashKey,
      _pinSaltKey,
      _pinIsSetupKey,
      _pinHashVersionKey,
      SecurityKeys.authFailedAttempts,
      SecurityKeys.authLockoutUntil,
      SecurityKeys.authMagicLinkSessionToken,
    ]);

    if (!_mounted) return;
    state = const AuthState(status: AuthStatus.setupRequired);
  }

  /// Authenticates via biometrics. On success, transitions to authenticated
  /// and resets the failed-attempts counter — same trust level as PIN.
  Future<bool> unlockViaBiometrics({String reason = 'Unlock Helm'}) async {
    if (state.isLockedOut) return false;

    final datasource = ref.read(biometricDataSourceProvider);
    final success = await datasource.authenticate(reason);
    if (!_mounted) return false;

    if (success) {
      await _box.putAll({
        SecurityKeys.authFailedAttempts: 0,
        SecurityKeys.authLockoutUntil: null,
      });
      _updateSessionAuthenticated(true);
      state = const AuthState(status: AuthStatus.authenticated);
    }
    return success;
  }

  void _updateSessionAuthenticated(bool value) {
    if (authRefreshListenable.value != value) {
      authRefreshListenable.value = value;
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final biometricDataSourceProvider = Provider<BiometricDataSource>(
  (_) => BiometricDataSource(),
);

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Returns true if the user currently has an authenticated session.
/// Prefer watching [authProvider] for full auth state; this is a convenience
/// for router guards that only need the boolean.
bool get isSessionAuthenticated => authRefreshListenable.value;

/// Public routes that do not require an authenticated session.
/// Keep in sync with the routes declared in [appRouter].
const Set<String> publicRoutes = {
  RouteNames.splash,
  RouteNames.welcome,
  RouteNames.onboarding,
  RouteNames.magicLink,
  RouteNames.pinSetup,
  RouteNames.pinEntry,
};
