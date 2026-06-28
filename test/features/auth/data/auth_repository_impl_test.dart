// test/features/auth/data/auth_repository_impl_test.dart

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:helm/core/constants/app_box_names.dart';
import 'package:helm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:helm/features/auth/data/datasources/biometric_datasource.dart';
import 'package:helm/features/auth/data/models/session_model.dart';
import 'package:helm/features/auth/data/repositories/auth_repository_impl.dart';

// Unit-test stub: no platform channel, always returns false.
class _FakeBiometricDataSource extends BiometricDataSource {
  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> authenticate(String reason) async => false;
}

void main() {
  group('AuthRepositoryImpl — sendMagicLink', () {
    test('rejects empty email', () async {
      final ds = AuthRemoteDataSource();
      final repo = AuthRepositoryImpl(remoteDataSource: ds);
      final result = await repo.sendMagicLink('');
      expect(result, isFalse);
    });

    test('rejects invalid email format', () async {
      final ds = AuthRemoteDataSource();
      final repo = AuthRepositoryImpl(remoteDataSource: ds);
      final result = await repo.sendMagicLink('not-an-email');
      expect(result, isFalse);
    });

    test('accepts valid email', () async {
      final ds = AuthRemoteDataSource();
      final repo = AuthRepositoryImpl(remoteDataSource: ds);
      final result = await repo.sendMagicLink('freelancer@example.com');
      expect(result, isTrue);
    });
  });

  group('AuthRepositoryImpl — verifyMagicLink + session storage', () {
    late Directory tempDir;
    late AuthRemoteDataSource ds;
    late AuthRepositoryImpl repo;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(9)) {
        Hive.registerAdapter(SessionModelAdapter());
      }
      await Hive.openBox<SessionModel>(AppBoxNames.sessionBox);
      ds = AuthRemoteDataSource();
      repo = AuthRepositoryImpl(remoteDataSource: ds);
    });

    tearDown(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test('returns null for empty token', () async {
      final result = await repo.verifyMagicLink('');
      expect(result, isNull);
    });

    test('persists session to Hive on successful verify', () async {
      await ds.sendMagicLink('freelancer@example.com');
      final token = ds.getIssuedTokenForEmail('freelancer@example.com')!;
      final session = await repo.verifyMagicLink(token);
      expect(session, isNotNull);

      // Verify persistence
      final stored = await repo.getStoredSession();
      expect(stored, isNotNull);
      expect(stored!.userId, equals(session!.userId));
    });

    test('getStoredSession returns null after clearSession', () async {
      await ds.sendMagicLink('freelancer@example.com');
      final token = ds.getIssuedTokenForEmail('freelancer@example.com')!;
      await repo.verifyMagicLink(token);

      await repo.clearSession();
      final stored = await repo.getStoredSession();
      expect(stored, isNull);
    });

    test('getStoredSession returns null when no session stored', () async {
      final stored = await repo.getStoredSession();
      expect(stored, isNull);
    });

    test('biometric delegates to datasource and returns false when unavailable', () async {
      final stubRepo = AuthRepositoryImpl(
        remoteDataSource: ds,
        biometricDataSource: _FakeBiometricDataSource(),
      );
      expect(await stubRepo.isBiometricAvailable(), isFalse);
      expect(await stubRepo.authenticateWithBiometrics(), isFalse);
    });
  });
}
