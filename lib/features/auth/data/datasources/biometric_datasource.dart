// lib/features/auth/data/datasources/biometric_datasource.dart
//
// Wraps local_auth to provide biometric availability check and authentication.
// Catch-all on exceptions — biometric failure always falls back to PIN.

import 'package:local_auth/local_auth.dart';

class BiometricDataSource {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Returns true if the device has enrolled biometrics and the OS supports them.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } on Exception {
      return false;
    }
  }

  /// Presents the system biometric prompt. Returns true on success.
  /// [reason] is the localised string shown to the user in the OS dialog.
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on Exception {
      return false;
    }
  }
}
