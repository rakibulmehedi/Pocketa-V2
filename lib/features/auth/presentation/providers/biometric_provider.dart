// lib/features/auth/presentation/providers/biometric_provider.dart
//
// Owns device biometric availability check and the user's opt-in preference.
// Separating this from AuthNotifier keeps auth state minimal and testable.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/features/auth/presentation/providers/auth_provider.dart';

class BiometricState {
  final bool isAvailable;
  final bool isEnabled;

  const BiometricState({
    required this.isAvailable,
    required this.isEnabled,
  });

  BiometricState copyWith({bool? isAvailable, bool? isEnabled}) => BiometricState(
        isAvailable: isAvailable ?? this.isAvailable,
        isEnabled: isEnabled ?? this.isEnabled,
      );
}

class BiometricNotifier extends AsyncNotifier<BiometricState> {
  @override
  Future<BiometricState> build() async {
    final datasource = ref.read(biometricDataSourceProvider);
    final isAvailable = await datasource.isAvailable();
    final isEnabled = SharedPrefServices.getBiometricEnabled() && isAvailable;
    return BiometricState(isAvailable: isAvailable, isEnabled: isEnabled);
  }

  /// Saves user preference. Clamps to false if hardware unavailable.
  Future<void> setEnabled(bool value) async {
    final current = state.valueOrNull;
    final isAvailable = current?.isAvailable ?? false;
    final effective = value && isAvailable;
    await SharedPrefServices.setBiometricEnabled(effective);
    state = AsyncData(BiometricState(
      isAvailable: isAvailable,
      isEnabled: effective,
    ));
  }
}

final biometricProvider =
    AsyncNotifierProvider<BiometricNotifier, BiometricState>(
  BiometricNotifier.new,
);
