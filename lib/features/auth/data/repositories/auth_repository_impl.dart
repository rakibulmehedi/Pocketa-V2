// lib/features/auth/data/repositories/auth_repository_impl.dart
//
// Implements AuthRepository using AuthRemoteDataSource (API) + Hive (local storage).
// Clean architecture gate: only datasources + domain entities cross this boundary.

import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:helm/core/constants/app_box_names.dart';
import 'package:helm/core/utils/input_validator.dart';
import 'package:helm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:helm/features/auth/data/datasources/biometric_datasource.dart';
import 'package:helm/features/auth/data/models/session_model.dart';
import 'package:helm/features/auth/domain/entities/session_entity.dart';
import 'package:helm/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final BiometricDataSource biometricDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    BiometricDataSource? biometricDataSource,
  }) : biometricDataSource = biometricDataSource ?? BiometricDataSource();

  // ── Session persistence key ─────────────────────────────────────────────

  static const String _sessionKey = 'magic_link_session';

  Box<SessionModel> get _box => Hive.box<SessionModel>(AppBoxNames.sessionBox);

  // ── Magic Link ──────────────────────────────────────────────────────────

  @override
  Future<bool> sendMagicLink(String email) async {
    final normalized = InputValidator.normalizeEmail(email);
    if (normalized == null) return false;
    return remoteDataSource.sendMagicLink(normalized);
  }

  @override
  Future<SessionEntity?> verifyMagicLink(String token) async {
    // Expect a base64url-encoded token of at least 32 bytes (44 chars).
    if (!_isValidToken(token.trim())) return null;

    final session = await remoteDataSource.verifyMagicLink(token.trim());
    if (session != null) {
      await storeSession(session);
    }
    return session;
  }

  // ── Local session storage ───────────────────────────────────────────────

  @override
  Future<SessionEntity?> getStoredSession() async {
    if (!Hive.isBoxOpen(AppBoxNames.sessionBox)) return null;

    final model = _box.get(_sessionKey);
    if (model == null) return null;

    final session = model.toEntity();
    if (session.isExpired) {
      await clearSession();
      return null;
    }
    return session;
  }

  @override
  Future<void> storeSession(SessionEntity session) async {
    await _box.put(_sessionKey, SessionModel.fromEntity(session));
  }

  @override
  Future<void> clearSession() async {
    await _box.delete(_sessionKey);
  }

  // ── Biometric ───────────────────────────────────────────────────────────

  @override
  Future<bool> isBiometricAvailable() => biometricDataSource.isAvailable();

  @override
  Future<bool> authenticateWithBiometrics() =>
      biometricDataSource.authenticate('Unlock Helm');

  // ── Helpers ─────────────────────────────────────────────────────────────

  bool _isValidToken(String token) {
    // Supabase magic-link tokens are base64url-encoded and include - and _.
    // Minimum 32 chars; real OTP tokens are typically 64+ chars.
    if (token.length < 32) return false;
    return RegExp(r'^[A-Za-z0-9\-_]+$').hasMatch(token);
  }
}
