import 'package:flutter/services.dart';

/// Result of APK signature verification.
enum SignatureVerificationResult { authentic, tampered }

/// Verifies the APK signing certificate SHA-256 hash via MethodChannel.
class SignatureVerifier {
  static const _channel = MethodChannel('com.safetospends.helm/signature');

  /// Calls the native side to retrieve the APK signing certificate hash.
  Future<String?> fetchSignatureHash() async {
    try {
      return await _channel.invokeMethod<String>('getApkSignatureHash');
    } on MissingPluginException {
      // Not running on Android (e.g., tests, iOS).
      return null;
    } on Exception catch (_) {
      return null;
    }
  }

  /// Compares the actual APK hash against [expectedHash].
  Future<SignatureVerificationResult> verifySignature({
    required String expectedHash,
  }) async {
    final hash = await fetchSignatureHash();
    if (hash == null) {
      // Could not retrieve hash — skip verification (non-Android / early init).
      return SignatureVerificationResult.authentic;
    }
    return hash == expectedHash
        ? SignatureVerificationResult.authentic
        : SignatureVerificationResult.tampered;
  }
}
