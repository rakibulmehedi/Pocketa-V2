# Security Policy

## Scope

Helm is an offline-first mobile application. User financial data is stored locally on the device using Hive CE with AES encryption backed by the platform keystore. The current MVP/closed-beta build does not transmit financial data to any Helm-owned backend.

## Reporting a Vulnerability

If you discover a security vulnerability:

1. **Do not open a public GitHub issue.**
2. Email the maintainer directly: rakibulmehedi.dev@gmail.com
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

You will receive a response within 72 hours.

---

## C-1: Client-Side Authentication Trust Chain (Known Limitation — Accepted for MVP)

### Limitation

The authentication trust chain in the current MVP build is **entirely client-side**. Specifically:

- **Magic Link verification is a client-side mock.** `AuthRemoteDataSource` generates and verifies tokens locally. No backend service validates the token or issues a server-signed session credential. An attacker who gains root access to the device filesystem can read, forge, or replay the token stored in the encrypted Hive session box.
- **PIN verification is local.** The 6-digit PIN hash is compared against a value stored in the device-local encrypted Hive `auth_box`. There is no server-side check of PIN correctness. A sufficiently privileged attacker on a rooted/jailbroken device could, in theory, bypass this check by directly manipulating Hive data.
- **No server-side session invalidation.** There is no server-issued session token with a revocation mechanism. Logging out clears the local state but does not invalidate any server-held token (because none exists).

This is a known architectural gap. The design deliberately accepts this risk for the MVP closed-beta phase because:

1. The beta cohort is small (15–25 users), invited, and using their own uncompromised devices.
2. Helm stores no payment credentials, no banking API keys, and no PII beyond email address and manually-entered financial figures.
3. A malicious actor exploiting this path on a non-rooted device faces the same attack surface as any other locally-encrypted mobile app with a PIN gate.

### Mitigations in Place

The following controls reduce the practical risk of this limitation during the MVP phase:

| Control | Implementation | File |
|---------|---------------|------|
| Root / Jailbreak detection | `JailbreakRootCheck` runs at splash and blocks the app on compromised devices with a non-dismissible screen | `lib/core/security/root_check.dart`, `lib/core/security/views/compromised_device_screen.dart` |
| Hive AES-256 encryption | Every Hive box (including `auth_box` and `session_box`) is opened with a `HiveAesCipher` derived from a platform keystore key | `lib/core/local_storage/hive_service.dart` |
| 6-digit PIN minimum | `pinLength = 6` enforced in both setup and entry screens | `lib/features/auth/presentation/providers/auth_provider.dart` |
| PIN attempt lockout | Failed attempts are persisted; lockout timer is enforced across app restarts | `lib/features/auth/presentation/providers/auth_provider.dart` |
| Token replay prevention | Used Magic Link tokens are stored in encrypted Hive and rejected on reuse | `lib/features/auth/data/datasources/used_magic_link_token_store.dart` |
| App lifecycle lock | Any non-resumed lifecycle state triggers re-authentication | `lib/core/security/widgets/app_lifecycle_lock.dart` |
| FLAG_SECURE (Android) | `MainActivity` sets `FLAG_SECURE` to prevent screenshot capture of financial data | `android/app/src/main/kotlin/co/helm/finance/MainActivity.kt` |
| Dart code obfuscation | Release builds use `DART_OBFUSCATION=true` | `ios/Flutter/Release.xcconfig` |
| ProGuard / R8 rules | Android release keeps only necessary reflection targets | `android/app/proguard-rules.pro` |

### Planned Fix (V1 Post-Beta)

Before the V1 public release, the authentication trust chain MUST be migrated to a server-side model:

1. **Backend Magic Link service**: Replace `AuthRemoteDataSource` mock with a real server (Next.js API route or Supabase Edge Function) that:
   - Generates cryptographically random single-use tokens
   - Stores the hashed token with a 15-minute TTL
   - Validates the token on the server and issues a signed session JWT
   - Marks the token as consumed on first use (server-side replay prevention)

2. **Server-side session management**: Issue JWTs with a 15-minute expiry and a refresh token. The app must re-authenticate at the server when the JWT expires. PIN/biometric provides a fast re-authentication path without a network round-trip, but the server session remains the authority.

3. **Backend-verified PIN (optional hardening)**: For V1, PIN verification may remain local (as a UX convenience layer) as long as the server-issued JWT is the actual authorization credential for any future network calls.

This work is scoped to V1 and is a hard gate before any Helm-owned backend receives financial data.

---

## Known Scope Limitations

- **Client-side Magic Link mock**: See C-1 above.
- PIN/biometric lock is implemented locally but is not a substitute for OS-level device security.
- No network transmission of financial data in the current build.

## Out of Scope

- Vulnerabilities in third-party Flutter packages (report to the package maintainer)
- Social engineering
- Compromised-device attacks that bypass OS sandboxing when the device is unlocked and the attacker has physical possession

## Supported Versions

Only the current main branch is actively maintained.
