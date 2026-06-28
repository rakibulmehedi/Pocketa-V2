# Helm Play Store Launch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Release Helm v1.0.0 on Google Play Store as a free app for Bangladeshi freelancers, execute a ৳5–20K Facebook/Instagram campaign, and validate organic distribution through freelancer communities.

**Architecture:** Sequential gate model — Phase 1 (Security + Build Config) → Phase 2 (QA) → Phase 3 (Closed Beta) → Phase 4 (Store Listing) → Phase 5 (Launch + Marketing). Each phase has explicit exit gates; no phase begins until the prior gate clears. Code phases dispatch subagents from `~/.claude/agents/`. Marketing phases dispatch subagents for content and campaign creation.

**Tech Stack:** Flutter/Dart (FVM), Android (primary target), Hive CE, Riverpod, GoRouter. Build: Gradle Kotlin DSL. Marketing: Facebook Ads Manager, Bangla copy, Onyx Traders Telegram (50K), freelancer Facebook groups.

## Global Constraints

- `dart analyze` 0/0/0 after every task that touches Dart/Kotlin code
- All existing tests must continue to pass — never delete tests to fix the suite
- Use `fvm flutter` / `fvm dart` for all Flutter/Dart commands
- `applicationId` = `com.safetospends.helm` (permanent — cannot change after first publish)
- `namespace` = `com.safetospends.helm`
- `versionName` = `1.0.0`, `versionCode` = `1` for production release
- `minSdkVersion` = 21, `targetSdkVersion` = 35
- Never commit `key.properties`, `*.jks`, or any keystore file to git
- All store copy and ad creative must exist in both English and Bangla
- Agent dispatches reference files in `~/.claude/agents/` by filename slug (e.g. `security-appsec-engineer`)

---

## File Map

### Phase 1 — Modified Files

| File | Change |
|------|--------|
| `android/app/build.gradle.kts` | namespace, applicationId, minSdk, targetSdk |
| `android/app/src/main/kotlin/co/helm/finance/MainActivity.kt` | package + channel name strings |
| `android/app/src/main/kotlin/com/safetospends/helm/MainActivity.kt` | new location after move |
| `pubspec.yaml` | version bump to 1.0.0+1 |
| `lib/features/onboarding/presentation/views/onboarding_screen.dart` | remove fake Initial Balance income entry (C-10) |
| `lib/l10n/app_en.arb` + `app_bn.arb` | remaining hardcoded string sweep (C-9) |
| `analysis_options.yaml` | strict lint rules (H-37) |
| Various security files | per S1 pending task list |

### Phase 4 — Created Files

| File | Purpose |
|------|---------|
| `store/en/title.txt` | Play Store title (EN) |
| `store/en/short_description.txt` | Short description (EN, 80 chars) |
| `store/en/full_description.txt` | Full description (EN, 4000 chars) |
| `store/bn/title.txt` | Play Store title (BN) |
| `store/bn/short_description.txt` | Short description (BN) |
| `store/bn/full_description.txt` | Full description (BN) |
| `store/release_notes/1.0.0.txt` | Release notes (EN + BN) |
| `store/screenshots/` | 8 phone screenshots per locale |
| `store/graphics/feature_graphic.png` | Feature graphic 1024×500px |
| `privacy-policy/index.html` | Privacy policy (publishable to GitHub Pages) |

---

## PHASE 1 — Security Completion + Build Config (Weeks 1–3)

### Task 1: Update Android applicationId, namespace, minSdk, targetSdk

**Files:**
- Modify: `android/app/build.gradle.kts:18,33,34,35`
- Modify: `android/app/src/main/kotlin/co/helm/finance/MainActivity.kt` → move + rename
- Create: `android/app/src/main/kotlin/com/safetospends/helm/MainActivity.kt`

**Interfaces:**
- Produces: `applicationId = "com.safetospends.helm"` consumed by all build tasks and Play Console

- [ ] **Step 1: Update build.gradle.kts**

Open `android/app/build.gradle.kts`. Make these four changes:

```kotlin
// Line 18 — change namespace
namespace = "com.safetospends.helm"

// Line 33 — change applicationId
applicationId = "com.safetospends.helm"

// Line 34 — fix minSdk (was flutter.minSdkVersion → resolves to API 24 via plugin merge)
minSdk = 21

// Line 35 — pin targetSdk explicitly
targetSdk = 35
```

- [ ] **Step 2: Create new Kotlin package directory and move MainActivity**

```bash
mkdir -p /Users/rakibulislammehedi/Helm/android/app/src/main/kotlin/com/safetospends/helm
```

Copy the file content but update package declaration and channel name constants:

New file at `android/app/src/main/kotlin/com/safetospends/helm/MainActivity.kt`:

```kotlin
package com.safetospends.helm

import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    companion object {
        private const val BACKUP_CHANNEL = "com.safetospends.helm/backup"
        private const val SIGNATURE_CHANNEL = "com.safetospends.helm/signature"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE,
        )
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BACKUP_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "excludeFromBackup" -> {
                    val path = (call.argument<String>("path"))
                    if (path != null) {
                        excludeFromBackup(path)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SIGNATURE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getApkSignatureHash" -> {
                    result.success(getSignatureHash())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun excludeFromBackup(path: String) {
        val file = File(path)
        if (file.exists()) {
            file.setWritable(true)
            file.setReadable(true)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            getSystemService(android.content.Context.STORAGE_SERVICE)
                ?.let { it as? android.os.storage.StorageManager }
                ?.let { storageManager ->
                    try {
                        storageManager.setCacheBehaviorGroup(file, false)
                        storageManager.setCacheBehaviorTombstone(file, false)
                    } catch (e: Exception) {
                        android.util.Log.w("Helm", "StorageManager exclusion failed", e)
                    }
                }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                File(file, ".nomedia").createNewFile()
            } catch (e: Exception) {
                android.util.Log.w("Helm", "Failed to write .nomedia marker", e)
            }
        }
    }

    private fun getSignatureHash(): String? {
        return try {
            val pm = packageManager
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                pm.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES)
            } else {
                @Suppress("DEPRECATION")
                pm.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
            } ?: return null

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val signatures = packageInfo.signingInfo ?: return null
                val certs = if (signatures.hasMultipleSigners()) {
                    signatures.signingCertificateHistory
                } else {
                    signatures.apkContentsSigners
                } ?: return null
                val digest = MessageDigest.getInstance("SHA-256").digest(certs[0].toByteArray())
                digest.joinToString("") { "%02x".format(it) }
            } else {
                @Suppress("DEPRECATION")
                val sig = packageInfo.signatures?.get(0) ?: return null
                val digest = MessageDigest.getInstance("SHA-256").digest(sig.toByteArray())
                digest.joinToString("") { "%02x".format(it) }
            }
        } catch (e: Exception) {
            android.util.Log.w("Helm", "Signature hash retrieval failed", e)
            null
        }
    }
}
```

- [ ] **Step 3: Delete old MainActivity.kt**

```bash
rm /Users/rakibulislammehedi/Helm/android/app/src/main/kotlin/co/helm/finance/MainActivity.kt
rmdir /Users/rakibulislammehedi/Helm/android/app/src/main/kotlin/co/helm/finance
rmdir /Users/rakibulislammehedi/Helm/android/app/src/main/kotlin/co/helm
rmdir /Users/rakibulislammehedi/Helm/android/app/src/main/kotlin/co
```

- [ ] **Step 4: Check for any Dart-side MethodChannel references to old package name**

```bash
grep -rn "co.helm.finance" /Users/rakibulislammehedi/Helm/lib/
```

For any file found, replace `co.helm.finance/backup` with `com.safetospends.helm/backup` and `co.helm.finance/signature` with `com.safetospends.helm/signature`.

- [ ] **Step 5: Bump version in pubspec.yaml**

In `pubspec.yaml`, change:
```yaml
version: 0.5.0-beta.1+1
```
to:
```yaml
version: 1.0.0+1
```

- [ ] **Step 6: Verify debug build compiles**

```bash
cd /Users/rakibulislammehedi/Helm && fvm flutter build apk --debug 2>&1 | tail -20
```

Expected: `Built build/app/outputs/flutter-apk/app-debug.apk`

- [ ] **Step 7: Run analyze and tests**

```bash
cd /Users/rakibulislammehedi/Helm && fvm dart analyze && fvm flutter test
```

Expected: `No issues found!` and all tests pass.

- [ ] **Step 8: Commit**

```bash
git add android/app/build.gradle.kts \
        android/app/src/main/kotlin/com/safetospends/helm/MainActivity.kt \
        pubspec.yaml
git commit -m "chore(release): set applicationId com.safetospends.helm, minSdk 21, targetSdk 35, version 1.0.0+1"
```

---

### Task 2: Fix C-10 — Remove fake Initial Balance income entry from onboarding

**Files:**
- Modify: `lib/features/onboarding/presentation/views/onboarding_screen.dart:137-146`
- Test: `test/features/onboarding/` (existing or new)

**Interfaces:**
- Consumes: `IncomeNotifier` from `income_providers.dart`
- Produces: onboarding completes without creating any synthetic income entry

- [ ] **Step 1: Write a failing test**

In `test/features/onboarding/onboarding_no_synthetic_entry_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helm_v2/features/income/presentation/providers/income_providers.dart';

void main() {
  test('onboarding completion does not create any income entries', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Income list should be empty after a fresh start — no synthetic entries
    final incomes = await container.read(incomeNotifierProvider.future);
    expect(incomes, isEmpty,
        reason: 'No synthetic Initial Balance entry should exist at startup');
  });
}
```

- [ ] **Step 2: Run test to confirm it fails (if fake entry still present)**

```bash
cd /Users/rakibulislammehedi/Helm && fvm flutter test test/features/onboarding/onboarding_no_synthetic_entry_test.dart -v
```

- [ ] **Step 3: Remove the fake Initial Balance creation in onboarding_screen.dart**

Open `lib/features/onboarding/presentation/views/onboarding_screen.dart`. Find the block around line 137-146 that calls `incomeNotifier.addIncome(...)` or creates an "Initial Balance" entry. Delete that entire block. The onboarding completion handler should save preferences and navigate to home — nothing more.

- [ ] **Step 4: Run the test to confirm it passes**

```bash
cd /Users/rakibulislammehedi/Helm && fvm flutter test test/features/onboarding/onboarding_no_synthetic_entry_test.dart -v
```

Expected: `PASS`

- [ ] **Step 5: Run full test suite**

```bash
cd /Users/rakibulislammehedi/Helm && fvm dart analyze && fvm flutter test
```

Expected: 0 issues, all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/features/onboarding/presentation/views/onboarding_screen.dart \
        test/features/onboarding/onboarding_no_synthetic_entry_test.dart
git commit -m "fix(onboarding): remove fake Initial Balance income entry on completion (C-10)"
```

---

### Task 3: Dispatch security-appsec-engineer — Critical + remaining S1 Wave A

This task dispatches `security-appsec-engineer` to fix C-9 (l10n sweep) and document C-1 (client-side auth accept).

**Files:** Various `lib/` files + `lib/l10n/app_en.arb` + `lib/l10n/app_bn.arb` + `SECURITY.md`

- [ ] **Step 1: Dispatch security-appsec-engineer**

Invoke the Agent tool with subagent_type `security-appsec-engineer` and the following prompt:

```
You are fixing remaining CRITICAL security findings in the Helm Flutter app at /Users/rakibulislammehedi/Helm.

Read these files first:
- docs/tracking/S1_CODEBASE_TASK_MAPPING.md (section "Still PENDING Tasks")
- docs/strategy/HELM_FINAL_PRODUCT_DOCTRINE.md
- CLAUDE.md

Fix the following two CRITICAL findings:

**C-1 (Accept + Document):**
The auth trust chain is client-side only. Root detection is in place. The decision is to ACCEPT this limitation for MVP and document it. Create SECURITY.md at the project root documenting:
- The known limitation (client-side PIN verification, no server-side auth for MVP)
- The mitigations in place (root/jailbreak detection, Hive AES encryption, 6-digit PIN, lockout)
- The planned fix (backend auth in V1 post-beta)

**C-9 (L10n sweep):**
There are still hardcoded English strings in widget files that bypass localization. Do a targeted sweep:
1. Run: grep -rn '"[A-Z][a-zA-Z ]{4,}"' lib/ --include="*.dart" | grep -v "//\|test\|\.g\.\|arb\|_test\." | grep -v "l10n\|AppLocalizations" | head -40
2. For each hardcoded string found in user-facing widgets, add it to lib/l10n/app_en.arb and lib/l10n/app_bn.arb (Bangla translation required — use the pattern from existing bn ARB entries), then replace with AppLocalizations.of(context)!.keyName
3. Run: fvm flutter gen-l10n
4. Run: fvm dart analyze && fvm flutter test
5. All tests must pass. Commit with: git commit -m "fix(l10n): replace hardcoded English strings with ARB keys (C-9)"

Deliver: SECURITY.md created, hardcoded strings replaced, dart analyze 0/0/0, all tests pass.
```

- [ ] **Step 2: Verify agent output**

```bash
cd /Users/rakibulislammehedi/Helm && fvm dart analyze && fvm flutter test
```

Expected: 0 issues, all tests pass.

- [ ] **Step 3: Verify SECURITY.md exists**

```bash
ls /Users/rakibulislammehedi/Helm/SECURITY.md
```

---

### Task 4: Dispatch security-appsec-engineer — HIGH remaining findings (H-11, H-21, H-24, H-26, H-29, H-35, H-37, H-38, H-39, H-40, H-41)

- [ ] **Step 1: Dispatch security-appsec-engineer**

```
Fix the following HIGH security findings in the Helm Flutter app at /Users/rakibulislammehedi/Helm.

Read docs/tracking/S1_CODEBASE_TASK_MAPPING.md first (section "Still PENDING Tasks → HIGH").

Fix each finding:

H-11: lib/features/safe_to_spend/data/datasources/sts_settings_data_source.dart:74-87
  _migrateBufferPercent silently drops legacy absolute value. Instead: if legacy absolute value exists, convert to a percentage estimate (value / 50000 * 100 clamped to 5–30%), log an audit event saying "buffer migrated from absolute BDT to %", then write the percentage. Never silently discard user data.

H-21: lib/features/onboarding/presentation/views/onboarding_screen.dart
  Add a guard at the top of build/initState: if SharedPreferences flag onboardingComplete == true, immediately navigate to home via context.go(RouteNames.home). Prevents re-running onboarding on back-navigation.

H-24: lib/features/export/presentation/views/export_screen.dart:68-87
  Add a plaintext warning banner above the export button: "CSV export contains unencrypted financial data. Only share with trusted recipients." Use AppColors for styling. Add to both EN and BN ARB files.

H-26: lib/features/safe_to_spend/data/repositories/sts_settings_repository_impl.dart:22-26
  Verify whether M-23 (single atomic JSON blob) already covers this. If saveSettings now writes a single JSON blob atomically, mark H-26 as resolved and add a comment. If not, implement atomic write.

H-29: lib/features/account/presentation/views/delete_account_screen.dart:49-63
  Add try/catch around the entire deletion sequence. On any exception, show a SnackBar: "Deletion incomplete. Please try again or contact support." Do not leave the app in a partially-deleted state silently.

H-35: 52 files with null-assert theme extensions (!)
  Run: grep -rn "Theme.of(context).extension<" lib/ --include="*.dart" | grep "!)" | wc -l
  For each file, replace ThemeExtension null-asserts with a safe fallback:
  Instead of: Theme.of(context).extension<HelmColors>()!
  Use: Theme.of(context).extension<HelmColors>() ?? HelmColors.light()
  HelmColors.light() is the fallback factory. Apply the same pattern for HelmSpacing and HelmTypography.

H-37: analysis_options.yaml
  Add these rules to analysis_options.yaml under linter > rules:
    - avoid_print
    - avoid_dynamic_calls  
    - prefer_final_locals
    - unawaited_futures
    - cancel_subscriptions
    - close_sinks
  Run dart analyze after each rule addition. Fix any new violations surfaced.

H-38: 4 label-action mismatches (First Pipeline button, Skip, Pipeline FAB, Welcome CTA)
  Find these 4 Semantics/ElevatedButton/TextButton widgets and ensure the label= parameter matches the visible text or action. Run: grep -rn "Semantics\|semanticsLabel" lib/ | grep -i "pipeline\|skip\|welcome" to locate them.

H-39: lib/features/income/presentation/views/income_list_screen.dart and lib/features/safe_to_spend/presentation/views/sts_settings_screen.dart
  Replace the swipe-to-delete undo toast with an AlertDialog confirmation before deletion. Pattern:
  ```dart
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(l10n.deleteConfirmTitle),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete)),
      ],
    ),
  );
  if (confirmed != true) return;
  ```
  Add deleteConfirmTitle, cancel, delete keys to ARB files if not present.

H-40: lib/features/safe_to_spend/domain/safe_to_spend_calculator.dart
  When a USD income entry has no valid fxRate (excluded per H-25), add the entry's amount and clientName to a List<String> excludedWarnings on SafeToSpendResult. In the dashboard S2S hero widget, if result.excludedWarnings.isNotEmpty, show a small warning chip: "⚠ ${count} USD entries excluded — add FX rate". Tap opens sts settings screen.

H-41: Currency symbol inconsistency tk vs ৳ in 4 files
  Run: grep -rn '"tk"\|"TK"\|" tk"' lib/ --include="*.dart"
  Replace all occurrences with the ৳ symbol (U+09F3). Use NumberFormatter.symbolForCode('BDT') if available, or the literal ৳ character.

After all fixes:
- fvm dart analyze (must be 0/0/0)
- fvm flutter test (all must pass)
- Commit: git commit -m "fix(security): resolve HIGH S1 findings H-11,H-21,H-24,H-26,H-29,H-35,H-37,H-38,H-39,H-40,H-41"
```

- [ ] **Step 2: Verify**

```bash
cd /Users/rakibulislammehedi/Helm && fvm dart analyze && fvm flutter test
```

---

### Task 5: Dispatch security-appsec-engineer — MEDIUM remaining findings

- [ ] **Step 1: Dispatch security-appsec-engineer**

```
Fix the following MEDIUM security findings in the Helm Flutter app at /Users/rakibulislammehedi/Helm.

Read docs/tracking/S1_CODEBASE_TASK_MAPPING.md first (section "Still PENDING → MEDIUM").

M-13: lib/config/router/route_names.dart + lib/config/router/app_router.dart
  Add a /history GoRoute that pushes AuditLogScreen as a named route. RouteNames.history = '/history'. Register it in app_router.dart alongside other routes.

M-16: lib/core/analytics/analytics_service.dart:54,67
  Wrap all debugPrint calls in analytics_service.dart and notification_service.dart with: if (kDebugMode) { debugPrint(...); }. Import foundation.dart for kDebugMode.

M-17: lib/features/safe_to_spend/domain/safe_to_spend_calculator.dart:32
  The excludedUsdIncome field tracks excluded entries but the comment says "contradiction." Verify the logic: if an entry is excluded (excludeFromCalculation=true), it should appear in excludedUsdIncome. If it's excluded because fxRate<=0, it should appear in excludedWarnings (from H-40). Both lists serve different purposes and can coexist. Add a code comment clarifying the distinction.

M-26: pubspec.yaml
  Pin these critical dependencies to exact versions (remove ^ caret):
    hive_ce: [current exact version]
    hive_ce_flutter: [current exact version]
    flutter_riverpod: [current exact version]
    go_router: [current exact version]
  Run: fvm flutter pub get
  Run: fvm flutter test (must still pass)

M-27: test/ directory
  Add one integration test covering the data integrity of the income pipeline:
  test/integration/income_pipeline_data_integrity_test.dart
  The test should:
  1. Create an IncomeEntryEntity with status=expected
  2. Transition to pending, then to received
  3. Verify each state was persisted correctly to Hive
  4. Verify the audit log has 3 events (create + 2 transitions)
  5. Verify the chain hash is valid via AuditChainService.verifyChain()

M-30: lib/features/dashboard/presentation/views/dashboard_screen.dart:207
  The dev reset button should show a confirmation dialog before resetting. Add:
  ```dart
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Reset all data?'),
      content: const Text('This will delete all income, transactions, and settings. Cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset', style: TextStyle(color: Colors.red))),
      ],
    ),
  );
  if (confirmed != true) return;
  ```

M-31: lib/core/theme/helm_colors.dart
  Find inkTertiary color. Verify its contrast ratio against white and the canvas background using the WCAG formula: (L1+0.05)/(L2+0.05) where L is relative luminance. If contrast < 4.5:1 at 11pt, darken the color until it passes. Document the new hex value and contrast ratio in a comment.

M-32: lib/l10n/app_localizations_bn.dart (or app_bn.arb)
  Fix 7 Bangla translation quality issues. Run: cat lib/l10n/app_bn.arb | grep -E '"[^"]+": "[^"]*[a-zA-Z][^"]*"' to find English words inside Bangla translations. For each, replace with proper Bangla. Common fixes: "Pipeline" → "পাইপলাইন", "Safe to Spend" → "নিরাপদ ব্যয়", "Settings" → "সেটিংস".
  Run: fvm flutter gen-l10n after edits.

M-33: Fix 3 unhelpful error messages
  1. Rate limit message: find in auth files → replace with "অনেকবার চেষ্টা হয়েছে। ১ মিনিট পরে আবার চেষ্টা করুন।" (EN: "Too many attempts. Please wait 1 minute.")
  2. Lockout message: find in pin_entry_screen.dart → replace with "অ্যাকাউন্ট সাময়িক বন্ধ। {minutes} মিনিট পরে আবার চেষ্টা করুন।" (EN: "Account temporarily locked. Try again in {minutes} minutes.")
  3. Export error: find in export_screen.dart → replace with "রপ্তানি ব্যর্থ হয়েছে। স্টোরেজ পার্মিশন চেক করুন।" (EN: "Export failed. Check storage permissions.")
  Add all to ARB files and use AppLocalizations references.

After all fixes:
- fvm flutter gen-l10n
- fvm dart analyze (0/0/0)
- fvm flutter test (all pass)
- Commit: git commit -m "fix(security): resolve MEDIUM S1 findings M-13,M-16,M-17,M-26,M-27,M-30,M-31,M-32,M-33"
```

- [ ] **Step 2: Verify**

```bash
cd /Users/rakibulislammehedi/Helm && fvm dart analyze && fvm flutter test
```

---

### Task 6: Dispatch security-appsec-engineer — LOW remaining findings

- [ ] **Step 1: Dispatch security-appsec-engineer**

```
Fix the following LOW security findings in the Helm Flutter app at /Users/rakibulislammehedi/Helm.

Read docs/tracking/S1_CODEBASE_TASK_MAPPING.md (section "Still PENDING → LOW").

L-2: No referential integrity between audit log and entities
  Accept this limitation for MVP. Add a comment in lib/features/audit_log/data/datasources/audit_local_data_source.dart explaining that entityId is a string reference with no FK validation, and this is acceptable because the audit log is append-only and entities are never deleted without a corresponding audit event.

L-4: lib/features/transactions/presentation/providers/transaction_provider.dart:56-93
  Replace the full Hive re-read after add/update/delete with in-memory state mutation:
  - addTransaction: append to current state list
  - updateTransaction: replace the matching item by id in state list
  - deleteTransaction: remove the matching item by id from state list
  Only call loadTransactions() on initial load. Add tests verifying state is correct after each mutation without a full reload.

L-5: lib/core/nudge/evaluator/nudge_evaluator.dart:108
  Find the '[Client]' literal string. Replace with the actual client name from the income entry, or 'client' as a fallback if name is empty. Pattern: entry.clientName.isNotEmpty ? entry.clientName : 'client'

L-6: lib/config/router/app_router.dart:100,119
  For path parameters like :id, add format validation before using them:
  ```dart
  final id = state.pathParameters['id'] ?? '';
  if (id.isEmpty || id.length > 100) {
    return const GoRoute(path: '/not-found'); // or redirect to home
  }
  ```

L-7: lib/core/analytics/analytics_service.dart:41-48
  The dailyActiveSession dedup uses read-check-write. Wrap with a lock flag:
  ```dart
  static bool _trackingSession = false;
  Future<void> trackDailySession() async {
    if (_trackingSession) return;
    _trackingSession = true;
    try { /* existing logic */ } finally { _trackingSession = false; }
  }
  ```

L-8: lib/core/analytics/analytics_service.dart:56
  Add unawaited() wrapper or await to all trackEvent calls that are not awaited:
  Run: grep -rn "trackEvent\|logEvent" lib/ | grep -v "await\|//\|test" | head -20
  For each unawaited call in non-test code, either add await or wrap with unawaited() from dart:async to make the intent explicit.

L-9: lib/features/export/presentation/views/export_screen.dart
  Before triggering share_plus, show a one-time warning dialog:
  "আপনার আর্থিক তথ্য শেয়ার করতে যাচ্ছেন। শুধুমাত্র বিশ্বস্ত ব্যক্তির সাথে শেয়ার করুন।"
  (EN: "You are about to share financial data. Only share with trusted recipients.")
  Store a SharedPreferences flag exportWarningShown. Show dialog only once — skip on subsequent exports.

L-10: Accept share_plus desktop dependency as non-issue for Android target. Add a comment in pubspec.yaml above share_plus: "# Desktop variants included transitively — acceptable for Android-only target"

L-11: lib/features/settings/presentation/views/cadence_preference_sheet.dart
  Change the default cadence from daily to weekly. The user should opt-in to daily notifications, not opt-out. Update the default value in StsSettings.defaults() or the cadence preference initialization.

L-12: lib/features/income/presentation/views/add_income_screen.dart:243-250
  Remove the dead PopScope code. Verify it's truly dead by checking if any route pushes this screen expecting a WillPopScope/PopScope result. If not, delete lines 243-250.

After all fixes:
- fvm dart analyze (0/0/0)
- fvm flutter test (all pass)
- Commit: git commit -m "fix(security): resolve LOW S1 findings L-2,L-4,L-5,L-6,L-7,L-8,L-9,L-10,L-11,L-12"
```

- [ ] **Step 2: Verify**

```bash
cd /Users/rakibulislammehedi/Helm && fvm dart analyze && fvm flutter test
```

---

### Task 7: Dispatch tdd-guide — Security regression test coverage

- [ ] **Step 1: Dispatch tdd-guide**

```
Add regression tests for the security fixes applied in Phase 1 of the Helm Play Store launch.

Project: /Users/rakibulislammehedi/Helm
Read: docs/tracking/S1_CODEBASE_TASK_MAPPING.md and CLAUDE.md first.

Add tests for these specific behaviors (use flutter_test + flutter_riverpod test utilities):

1. test/android_build_config_test.dart (Dart-only)
   - Verify the MethodChannel name constant is "com.safetospends.helm/backup" not "co.helm.finance/backup"
   - Read the string from wherever it's defined in Dart code

2. test/features/onboarding/onboarding_no_synthetic_entry_test.dart
   - Verify no income entry exists after fresh onboarding (C-10 regression)

3. test/features/safe_to_spend/domain/sts_migration_test.dart
   - Verify _migrateBufferPercent converts absolute BDT value to % and logs audit event (H-11)

4. test/features/onboarding/onboarding_guard_test.dart
   - Verify onboarding screen navigates to home when onboardingComplete flag is true (H-21)

5. test/features/safe_to_spend/domain/usd_exclusion_warning_test.dart
   - Verify SafeToSpendResult.excludedWarnings is non-empty when USD entry has no fxRate (H-40)

6. test/core/analytics/analytics_session_test.dart
   - Verify trackDailySession is idempotent (L-7 race condition regression)

For each test:
- Write failing test first
- Run to confirm failure
- Confirm implementation fixes it
- Run fvm flutter test to confirm pass

Final: fvm dart analyze && fvm flutter test (all pass)
Commit: git commit -m "test(security): add regression tests for Phase 1 S1 findings"
```

- [ ] **Step 2: Verify test count increased**

```bash
cd /Users/rakibulislammehedi/Helm && fvm flutter test --reporter=compact 2>&1 | tail -5
```

---

### Task 8: Dispatch flutter-reviewer — Final Phase 1 code review

- [ ] **Step 1: Dispatch flutter-reviewer**

```
Review all Dart and Kotlin files changed in Phase 1 security fixes for the Helm Flutter app at /Users/rakibulislammehedi/Helm.

Run: git diff HEAD~8..HEAD --name-only | grep -E "\.(dart|kt)$"
This gives you the files changed across the last ~8 security fix commits.

For each file, review:
1. Widget best practices — no setState for business logic, mounted guards on async
2. State management — Riverpod patterns correct, no provider leaks
3. Dart idioms — null safety correct, no ! on nullable theme extensions
4. Security — no new hardcoded strings, no new debugPrint of sensitive data
5. Performance — no unnecessary rebuilds in security-critical paths

Report: List any CRITICAL or HIGH issues with file:line references. Fix any you find directly — do not just report them.

After any fixes: fvm dart analyze && fvm flutter test
Commit fixes: git commit -m "fix(review): flutter-reviewer Phase 1 findings"
```

---

### Task 9: Dispatch security-reviewer — S1 re-audit and Phase 1 exit gate

- [ ] **Step 1: Dispatch security-reviewer**

```
Perform a security re-audit of the Helm Flutter app at /Users/rakibulislammehedi/Helm.

Context: Sprint S1 security hardening is complete. The original audit found 97 findings across 12 domains. Read docs/tracking/S1_CODEBASE_TASK_MAPPING.md for the full list and evidence.

Your job:
1. For each of the 29 previously-pending findings, verify whether it is now fixed by reading the relevant source files
2. For any finding still open, classify as CRITICAL/HIGH/MEDIUM/LOW
3. Check for any NEW security issues introduced during the fixes (regression scan)
4. Write your findings to docs/tracking/S1_REAUDIT_REPORT.md in this format:
   - Fixed: [count] findings
   - Still open: [list with severity]
   - New findings: [list]
   - Verdict: PASS (≤10 LOW only remaining) or FAIL (any CRITICAL/HIGH/MEDIUM open)

Exit gate for Phase 1:
- All 17 CRITICAL findings: DONE
- All 35 HIGH findings: DONE  
- MEDIUM findings: ≤5 open acceptable
- LOW findings: ≤10 open acceptable
- No new CRITICAL or HIGH findings introduced

If gate FAILS: list exactly what remains and stop. Do not proceed to Phase 2.
If gate PASSES: write VERDICT: PHASE 1 COMPLETE in the report.
```

- [ ] **Step 2: Read re-audit report**

```bash
cat /Users/rakibulislammehedi/Helm/docs/tracking/S1_REAUDIT_REPORT.md
```

- [ ] **Step 3: Only proceed if VERDICT: PHASE 1 COMPLETE**

If the report shows FAIL, fix remaining items before continuing.

- [ ] **Step 4: Commit re-audit report**

```bash
git add docs/tracking/S1_REAUDIT_REPORT.md
git commit -m "docs(security): S1 re-audit report — Phase 1 exit gate"
```

---

## PHASE 2 — QA Re-Run & Release Build (Week 4)

### Task 10: (HUMAN) Generate release keystore and configure key.properties

This task cannot be automated — the human must perform it.

**Steps:**

- [ ] **Step 1: Generate keystore**

Run this command in your terminal (replace values with your info):
```bash
keytool -genkey -v -keystore ~/helm-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias helm-release \
  -dname "CN=Rakibul Islam Mehedi, OU=Helm, O=SafeToSpend, L=Dhaka, ST=Dhaka, C=BD"
```

You will be prompted for a keystore password and key password. Store both in your password manager.

- [ ] **Step 2: Create key.properties (not committed to git)**

Create `android/key.properties` (already in `.gitignore`):
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=helm-release
storeFile=/Users/rakibulislammehedi/helm-release.jks
```

- [ ] **Step 3: Back up the keystore offline**

Copy `~/helm-release.jks` to a USB drive or password manager attachment. If this file is lost, you cannot update the app on Play Store — ever.

- [ ] **Step 4: Confirm build.gradle.kts signing config loads key.properties**

The signing config is already wired in `android/app/build.gradle.kts` lines ~14-19 via `keystorePropertiesFile`. Verify it exists:

```bash
grep -A 10 "keystorePropertiesFile" /Users/rakibulislammehedi/Helm/android/app/build.gradle.kts
```

Expected: `keystoreProperties.load(FileInputStream(keystorePropertiesFile))` is present.

---

### Task 11: Build release Android App Bundle (AAB)

**Files:**
- Produces: `build/app/outputs/bundle/release/app-release.aab`

- [ ] **Step 1: Build release AAB**

```bash
cd /Users/rakibulislammehedi/Helm && \
  fvm flutter build appbundle --release \
    --obfuscate \
    --split-debug-info=build/debug-info \
    2>&1 | tail -30
```

Expected output ends with:
```
Built build/app/outputs/bundle/release/app-release.aab (XX.X MB).
```

- [ ] **Step 2: Verify minSdk in the bundle**

```bash
aapt2 dump badging \
  /Users/rakibulislammehedi/Helm/build/app/outputs/bundle/release/app-release.aab \
  2>/dev/null | grep sdkVersion || \
bundletool dump manifest \
  --bundle=/Users/rakibulislammehedi/Helm/build/app/outputs/bundle/release/app-release.aab \
  | grep minSdkVersion
```

Expected: `minSdkVersion` = 21

- [ ] **Step 3: Verify applicationId**

```bash
bundletool dump manifest \
  --bundle=/Users/rakibulislammehedi/Helm/build/app/outputs/bundle/release/app-release.aab \
  | grep package
```

Expected: `com.safetospends.helm`

- [ ] **Step 4: Note AAB size**

The file size should be ≤30MB. If larger, run with `--tree-shake-icons` added to the command.

- [ ] **Step 5: Commit debug-info to .gitignore**

```bash
echo "build/debug-info/" >> /Users/rakibulislammehedi/Helm/.gitignore
git add .gitignore
git commit -m "chore(release): add debug-info output dir to gitignore"
```

---

### Task 12: Dispatch e2e-runner — Automated critical flow validation

- [ ] **Step 1: Dispatch e2e-runner**

```
Run end-to-end tests for the Helm Flutter app critical user flows.

Project: /Users/rakibulislammehedi/Helm
Read: CLAUDE.md and docs/core/HELM_BRAIN.md first.

Run existing E2E tests and verify these critical flows pass:
1. Fresh install → onboarding → dashboard (S2S hero visible)
2. Add income entry (Expected status) → verify appears in Pipeline tab
3. Transition income: Expected → Pending → Received
4. S2S recalculates after income status change
5. PIN setup → lock screen → PIN entry → unlock
6. CSV export generates a file
7. Audit log shows events for income transitions

If any critical flow fails, report the exact failure with stack trace.
Do NOT fix failures in this task — report them only.

Output: Summary of PASS/FAIL per flow. If all pass, write PASS to a temp file: /tmp/helm_e2e_gate.txt
```

- [ ] **Step 2: Check gate**

```bash
cat /tmp/helm_e2e_gate.txt 2>/dev/null || echo "E2E gate not passed"
```

---

### Task 13: Dispatch testing-evidence-collector — 10-gate QA

- [ ] **Step 1: Dispatch testing-evidence-collector**

```
Execute the 10-gate QA script for Helm on the release build.

Project: /Users/rakibulislammehedi/Helm
QA script: docs/beta/MANUAL_QA_SCRIPT.md
Previous findings: docs/planning/QA_FIX_DISPATCH.md (9 fixes applied)

Read both files completely before starting.

For each of the 10 QA gates:
1. Execute the gate test
2. Capture a screenshot as evidence (save to docs/qa/screenshots/gate_N_PASS.png or gate_N_FAIL.png)
3. Record PASS/FAIL/CONDITIONAL with finding description

Previous BLOCKER findings to verify as FIXED:
- Fix 1: minSdk now resolves to 21 (was 24) — verify with aapt dump
- Fix 2: google_fonts removed, fonts bundled locally — verify no network calls on fresh install
- All 9 QA_FIX_DISPATCH items must show as FIXED

Output format: docs/qa/QA_RERUN_REPORT_2026-06.md with:
- Gate results table (Gate N | Test | Status | Evidence)
- Overall verdict: GO or NO-GO
- Any new findings with severity
```

- [ ] **Step 2: Read QA report**

```bash
cat /Users/rakibulislammehedi/Helm/docs/qa/QA_RERUN_REPORT_2026-06.md | grep "Overall verdict"
```

---

### Task 14: Dispatch testing-reality-checker — GO/NO-GO verdict

- [ ] **Step 1: Dispatch testing-reality-checker**

```
Produce a production readiness GO/NO-GO verdict for Helm v1.0.0 Play Store release.

Project: /Users/rakibulislammehedi/Helm
Read these docs:
- docs/qa/QA_RERUN_REPORT_2026-06.md
- docs/tracking/S1_REAUDIT_REPORT.md
- docs/core/ARCHITECTURE_RULES.md
- CLAUDE.md

Evaluate against these criteria:
1. All 10 QA gates: PASS (no BLOCKER or HIGH findings)
2. Security: PHASE 1 COMPLETE verdict in S1_REAUDIT_REPORT.md
3. dart analyze: 0/0/0
4. All tests pass
5. Release AAB builds and signs correctly
6. applicationId = com.safetospends.helm
7. minSdkVersion = 21
8. versionName = 1.0.0

Default to NO-GO. Only issue GO if all 8 criteria are met with evidence.
Output: A single line: PHASE 2 VERDICT: GO or PHASE 2 VERDICT: NO-GO [reason]
Append to: docs/qa/QA_RERUN_REPORT_2026-06.md
```

- [ ] **Step 2: Read verdict**

```bash
grep "PHASE 2 VERDICT" /Users/rakibulislammehedi/Helm/docs/qa/QA_RERUN_REPORT_2026-06.md
```

Only continue to Phase 3 if `PHASE 2 VERDICT: GO`.

---

## PHASE 3 — Closed Beta on Play Internal Testing Track (Weeks 5–7)

### Task 15: (HUMAN) Set up Play Console + upload to Internal Testing

- [ ] **Step 1: Create Google Play Console developer account**

Go to play.google.com/console → Create account → Pay $25 one-time fee.

- [ ] **Step 2: Create new app in Play Console**

- App name: Helm — Freelancer Cashflow
- Default language: Bengali (Bangladesh) — bn-BD
- App or game: App
- Free or paid: Free
- Declarations: Accept all

- [ ] **Step 3: Upload AAB to Internal Testing**

- Play Console → Testing → Internal testing → Create new release
- Upload `build/app/outputs/bundle/release/app-release.aab`
- Release name: `1.0.0 Beta`
- Release notes: "Initial closed beta for Bangladeshi freelancers. Report issues via Telegram."
- Save draft (do not publish yet)

- [ ] **Step 4: Add beta testers**

Create a testers list with email addresses of recruited freelancers. Add to Internal Testing track. Maximum 100 testers.

---

### Task 16: Dispatch marketing-growth-hacker — Beta tester recruitment

- [ ] **Step 1: Dispatch marketing-growth-hacker**

```
Write beta tester recruitment content for Helm — a cashflow app for Bangladeshi freelancers.

Context: Helm answers "আমি এখন আসলে কত টাকা খরচ করতে পারব?" for USD-earning freelancers on Payoneer/Upwork. Currently seeking 15–25 beta testers for a 4-week closed beta on Android.

Create these 3 pieces of content (all in Bangla, with English translation):

1. Telegram post for Onyx Traders (50K members):
   - Start with the qualifying pain question: "তোমার কি কখনো এমন হয়েছে যে Payoneer-এ পেমেন্ট আসার আগেই খরচ করে ফেলেছ?"
   - 3–4 lines max
   - End with: "Beta tester হতে চাইলে নিচে কমেন্ট কর অথবা DM কর।"
   - Do NOT mention the app name or share the Play Store link yet

2. Facebook group post (for 3 BD freelancer groups):
   - Same qualifying question
   - 2–3 sentences about what beta testers will get (free Pro access for 3 months, direct influence on features)
   - CTA: "Comment 'interested' below"

3. Direct DM template (to send to qualifying responses):
   - Thank them for responding
   - Brief 2-sentence description of what Helm does
   - Link to Internal Testing opt-in URL (placeholder: [PLAY_STORE_INTERNAL_LINK])
   - What they need to do: install, use for 4 weeks, respond to weekly check-in

Save all 3 pieces to: docs/marketing/beta_recruitment_copy.md
```

- [ ] **Step 2: Review and post content**

Read `docs/marketing/beta_recruitment_copy.md` and post to channels manually.

---

### Task 17: Dispatch marketing-app-store-optimizer — Internal Testing setup optimization

- [ ] **Step 1: Dispatch marketing-app-store-optimizer**

```
Optimize the Internal Testing track listing for Helm in Google Play Console.

App: Helm — Freelancer Cashflow Clarity
Target users: Bangladeshi USD-earning freelancers (Payoneer, Upwork, Fiverr, nsave)
Core value prop: Real-time "how much BDT can I actually spend right now?" answer

Create optimized copy for the Internal Testing listing:
1. App title (30 chars max): must include "Helm" + primary keyword
2. Short description (80 chars): in Bangla, pain-first
3. Internal testing release notes (500 chars): what to test, what to report

Also provide:
- List of 5 high-value Bengali keywords for ASO research (will be used in Task 21 full ASO)
- Recommended app category: Finance
- Content rating recommendation: PEGI 3 / Everyone (Finance app, no violence/adult content)

Save to: docs/marketing/store_listing_draft.md
```

---

### Task 18: Dispatch product-feedback-synthesizer — Week 1–2 beta feedback

*(Execute at end of Week 6, after 2 weeks of beta)*

- [ ] **Step 1: Collect raw feedback**

Gather: weekly check-in responses from beta testers (via Telegram DM or Google Form), any crash reports from Play Console Android vitals, any direct feedback messages.

- [ ] **Step 2: Dispatch product-feedback-synthesizer**

```
Synthesize beta feedback for Helm v1.0.0 beta, Weeks 1–2.

Project: /Users/rakibulislammehedi/Helm
Context: 15–25 Bangladeshi freelancers have been using Helm for 2 weeks. 
Read: docs/strategy/BETA_VALIDATION_PROTOCOL.md and docs/beta/FOUNDER_OBSERVATION_SHEET.md

Raw feedback is provided below (paste actual feedback from testers):
[PASTE RAW FEEDBACK HERE]

Synthesize into:
1. Pipeline compliance rate: % of users who added ≥1 income entry
2. S2S comprehension: % who could explain what the number means
3. Top 3 friction points with frequency count
4. Any KILL signals (fundamental misunderstanding of core value, users deleting app)
5. Recommended fixes before Week 3–4 (ranked by impact)

Output to: docs/beta/BETA_WEEK_1_2_SYNTHESIS.md
```

---

### Task 19: Dispatch product-feedback-synthesizer — Week 3–4 + threshold check

*(Execute at end of Week 7)*

- [ ] **Step 1: Dispatch product-feedback-synthesizer**

```
Synthesize final beta feedback for Helm v1.0.0, Weeks 3–4.

Read:
- docs/beta/BETA_WEEK_1_2_SYNTHESIS.md (prior synthesis)
- docs/strategy/BETA_VALIDATION_PROTOCOL.md
- docs/beta/GO_NO_GO_CRITERIA.md

Raw feedback from Weeks 3–4:
[PASTE RAW FEEDBACK HERE]

Evaluate against the 5 doctrine thresholds:
1. Pipeline compliance ≥85%: [measured value]%
2. Override-equivalent behavior <5%: [measured value]%
3. Day-28 retention ≥60%: [measured value]%
4. Onboarding completion ≥70%: [measured value]%
5. S2S comprehension ≥80%: [measured value]%

Count: How many thresholds pass? How many fail?
If ≥2 fail: Output BETA VERDICT: KILL
If 0–1 fail: Output BETA VERDICT: GO

Save to: docs/beta/BETA_FINAL_SYNTHESIS.md
```

---

### Task 20: Dispatch product-manager — Phase 3 GO/NO-GO

- [ ] **Step 1: Dispatch product-manager**

```
Make the Phase 3 GO/NO-GO decision for Helm Play Store production release.

Read:
- docs/beta/BETA_FINAL_SYNTHESIS.md
- docs/strategy/HELM_FINAL_PRODUCT_DOCTRINE.md §16 (closed beta gates)
- docs/beta/GO_NO_GO_CRITERIA.md

Decision criteria: all 5 doctrine thresholds must pass. 2+ failures = KILL.

If GO: list any UX fixes that must be shipped before production publish (if any).
If KILL: list which thresholds failed, recommend whether to run a second beta or kill the project.

Output: Append PHASE 3 VERDICT: GO or PHASE 3 VERDICT: KILL [reason] to docs/beta/BETA_FINAL_SYNTHESIS.md
```

- [ ] **Step 2: Read verdict**

```bash
grep "PHASE 3 VERDICT" /Users/rakibulislammehedi/Helm/docs/beta/BETA_FINAL_SYNTHESIS.md
```

Only continue to Phase 4 if `PHASE 3 VERDICT: GO`.

---

## PHASE 4 — Play Store Listing & ASO (Week 8)

*Tasks 21–24 can be dispatched in parallel.*

### Task 21: Dispatch marketing-app-store-optimizer — ASO keyword research + metadata

- [ ] **Step 1: Dispatch marketing-app-store-optimizer**

```
Create a complete ASO (App Store Optimization) strategy for Helm on Google Play Store.

App: Helm — Freelancer Cashflow Clarity for Bangladeshi USD earners
Target market: Bangladesh (primary), India (secondary)
Languages: Bengali (bn-BD) primary, English (en-US) secondary
Category: Finance

Deliverables:

1. Primary keyword research (20 keywords with estimated search volume tier: High/Med/Low):
   Focus on: Bangladesh + freelancer + payment/cashflow terms in both Bangla and English
   
2. Optimized app title (30 chars max, EN): must contain top keyword
3. Optimized app title (30 chars max, BN)
4. Short description (80 chars, EN): pain-first hook
5. Short description (80 chars, BN)

6. Competitor analysis: search "freelancer income tracker bangladesh", "payoneer bdt tracker", "ফ্রিল্যান্সার পেমেন্ট" on Play Store. List top 3 results with their titles and what gaps Helm can exploit.

7. Category recommendation: Finance (primary) or Productivity?
8. Tags/keywords to include in long description for indexing

Save to: docs/marketing/aso_strategy.md
```

---

### Task 22: Dispatch marketing-content-creator — Store description copy

- [ ] **Step 1: Dispatch marketing-content-creator**

```
Write complete Play Store listing copy for Helm — Freelancer Cashflow Clarity.

Read first: docs/marketing/aso_strategy.md (keywords to incorporate)
Read also: docs/core/HELM_BRAIN.md (product identity)

Deliverables (save each to store/ directory):

1. store/en/full_description.txt (4000 chars max)
Structure:
- Hook (2 lines): the core pain — "Have you ever spent money thinking a Payoneer payment had cleared, only to find out it hadn't?"
- What Helm does (3 lines): pipeline-aware Safe-to-Spend number
- Key features (bullet list, 6 bullets):
  • Income pipeline: track Expected → Pending → Received status
  • Safe-to-Spend: your real spendable BDT after tax reserve + fixed costs + buffer
  • Works offline — no cloud account needed
  • Audit log: every change tracked and tamper-evident
  • Bilingual: English and বাংলা
  • Built for Bangladeshi freelancers on Payoneer, Upwork, Fiverr, nsave
- Who it's for (2 lines): USD earners $800–$3000/month in Bangladesh
- Privacy statement (1 line): "All data stays on your device. No account required."
- CTA (1 line)

2. store/bn/full_description.txt (4000 chars max) — Bangla version of the above

3. store/en/short_description.txt (80 chars)
4. store/bn/short_description.txt (80 chars)

5. store/release_notes/1.0.0.txt (500 chars, both EN and BN in same file):
"First public release of Helm — cashflow clarity for Bangladeshi freelancers.
• Income pipeline with Expected/Pending/Received tracking
• Safe-to-Spend calculator with BDT conversion
• Full Bangla localization
• Offline-first, no account required"

Rules: No claims like "best" or "#1". No promises about future features. No mention of paid tiers (coming later).
```

---

### Task 23: Dispatch design-ui-designer — Play Store screenshots + feature graphic

- [ ] **Step 1: Dispatch design-ui-designer**

```
Design Play Store screenshot specifications and feature graphic for Helm.

App: Helm — Freelancer Cashflow Clarity
Design system: Paper Ledger — warm paper #F3ECE0 / espresso #1E1813, terracotta #C2603F accent, Fraunces display font
Read: docs/strategy/HELM_GLOBAL_PRODUCT_EXPERIENCE_AND_UI_MIGRATION_BLUEPRINT.md for visual identity

Play Store requires 2–8 screenshots per device type, minimum 320px short side, recommended 1080×1920px (portrait).

Create screenshot specifications for 8 screens (what to show on each, with caption text in English and Bangla):

1. S2S Hero dashboard — caption: "আসল খরচযোগ্য টাকা এক নজরে" / "Your real spendable BDT at a glance"
2. Income Pipeline — caption: "পেমেন্ট ট্র্যাক কর" / "Track every payment"
3. Income status transition (Expected → Received) — caption: "পেমেন্ট স্ট্যাটাস আপডেট" / "Update payment status"
4. Safe-to-Spend breakdown — caption: "কিভাবে হিসাব হয়" / "See exactly how it's calculated"
5. Onboarding qualifier screen — caption: "তোমার জন্যই বানানো" / "Built for you"
6. Audit log / History — caption: "সব লেনদেন সুরক্ষিত" / "Every transaction secured"
7. Settings / STS config — caption: "নিজের মত সাজাও" / "Customize your safety buffer"
8. Dark mode S2S hero — caption: "ডার্ক মোড সাপোর্ট" / "Dark mode supported"

Feature graphic (1024×500px):
- Background: warm paper #F3ECE0
- Large Bangla text: "আসল খরচযোগ্য টাকা কত?"
- Smaller English text: "Helm — Freelancer Cashflow Clarity"
- App icon centered right
- Terracotta accent stripe

Save specifications to: store/screenshots/screenshot_specs.md
Save feature graphic spec to: store/graphics/feature_graphic_spec.md

Note: Actual PNG files must be produced by a designer or screen-recording tool — provide exact specs so a human or image generation tool can produce them.
```

---

### Task 24: Dispatch engineering-technical-writer — Privacy policy

- [ ] **Step 1: Dispatch engineering-technical-writer**

```
Write a privacy policy for Helm that satisfies Google Play Store requirements.

App: Helm — Freelancer Cashflow Clarity
Package: com.safetospends.helm
Developer: Rakibul Islam Mehedi, Bangladesh
Contact: rakibulislammehedi4@gmail.com

Key facts about the app's data practices:
- ALL data is stored locally on the user's device (Hive encrypted database)
- NO data is sent to any server
- NO account is required
- NO analytics SDK — only local event logging
- NO advertising SDK
- NO third-party data sharing
- The only network calls are for Magic Link auth email delivery (user-initiated, email address only)
- Users can delete all data via Settings → Delete Account
- Data retained until user deletion

Write the privacy policy as a complete HTML page at: privacy-policy/index.html

Requirements:
- Compliant with Google Play Store data safety section requirements
- States clearly: what data is collected (none, except email for auth), how it's used, how it's stored, user rights
- Includes: effective date (2026-06-23), contact email, "last updated" date
- Language: English (primary) with a Bangla summary section
- Hostable on GitHub Pages (no server-side code)

Also create: privacy-policy/README.md with instructions for hosting on GitHub Pages.
```

- [ ] **Step 2: Host privacy policy (HUMAN step)**

```bash
# After engineering-technical-writer creates the files:
cd /Users/rakibulislammehedi/Helm/privacy-policy
# Create a separate GitHub repo: helm-privacy-policy
# Push index.html there
# Enable GitHub Pages → Settings → Pages → main branch / root
# Privacy policy URL will be: https://[username].github.io/helm-privacy-policy/
```

- [ ] **Step 3: Commit store assets**

```bash
git add store/ privacy-policy/
git commit -m "docs(store): add Play Store listing copy, screenshots specs, privacy policy"
```

---

## PHASE 5 — Production Launch + Marketing (Weeks 9–12)

### Task 25: (HUMAN) Submit production AAB to Play Console

- [ ] **Step 1: Complete Play Console store listing**

In Play Console:
- App information: title, short description, full description (from `store/en/` and `store/bn/`)
- Graphics: upload 8 screenshots + feature graphic (from `store/screenshots/`)
- Privacy policy URL: paste the GitHub Pages URL
- Data safety section: fill out (all "No" — no data collected, no data shared)

- [ ] **Step 2: Content rating**

Play Console → Content rating → Start questionnaire → Finance category → Complete.

- [ ] **Step 3: Target audience**

Set to: 18+ (Finance app).

- [ ] **Step 4: Promote Internal Testing → Production**

Testing → Internal testing → Promote to Production → 100% rollout.

- [ ] **Step 5: Submit for review**

Google typically reviews within 1–7 days for a new app.

---

### Task 26: Dispatch marketing-growth-hacker — D-7 organic launch sequence

*(Execute 7 days before expected app approval)*

- [ ] **Step 1: Dispatch marketing-growth-hacker**

```
Execute the D-7 organic pre-launch for Helm.

Read: docs/marketing/beta_recruitment_copy.md (prior community posts for context)
Read: docs/core/HELM_BRAIN.md (product identity)

Today is D-7 before Play Store launch. Execute Step 1 of the organic launch sequence:

Write a Telegram post for Onyx Traders (50K members):
- The qualifying pain question, no product mention
- "আগামী সপ্তাহে একটা সমাধান আসছে — watch this space"
- Maximum 3 lines, conversational Bangla

Also write 3 variations of this post for different freelancer Facebook groups (adjust tone slightly for each group's culture).

Save all posts to: docs/marketing/launch_posts/d_minus_7.md

Instructions for posting: post manually to Onyx Traders Telegram and 3 Facebook groups. Monitor for qualifying "yes this happened to me" responses — these are your best launch-day installs.
```

---

### Task 27: Dispatch marketing-social-media-strategist — D-3 founder story

*(Execute 3 days before launch)*

- [ ] **Step 1: Dispatch marketing-social-media-strategist**

```
Write the D-3 founder story post for Helm Play Store launch.

Context: Helm is a cashflow clarity app built for Bangladeshi USD-earning freelancers. The founder (Rakibul Islam Mehedi) built it to solve the real pain of spending money before a Payoneer payment cleared.

Write:
1. LinkedIn post (EN, 300 words max):
   - Personal story: the moment that motivated building Helm
   - What Helm does in 2 sentences
   - "Launching on Play Store in 3 days — link in bio"
   - Professional but personal tone

2. Facebook post in Bangla (150 words max):
   - "আমি কেন Helm বানালাম" narrative
   - Direct, conversational, not marketing-speak
   - Ends with: "৩ দিন পর Play Store-এ আসছে — free download"

3. Personal WhatsApp/Telegram status (1 line each, EN and BN):
   EN: "Built something for BD freelancers tired of surprise cashflow gaps. Dropping Thursday 🚀"
   BN: "বাংলাদেশি ফ্রিল্যান্সারদের জন্য বানিয়েছি। বৃহস্পতিবার আসছে।"

Save to: docs/marketing/launch_posts/d_minus_3.md
```

---

### Task 28: Dispatch marketing-growth-hacker — D0 launch drop

*(Execute on launch day — when Play Store approval received)*

- [ ] **Step 1: Dispatch marketing-growth-hacker**

```
Write the D0 launch posts for Helm — the full launch drop across all channels.

Read: docs/marketing/launch_posts/d_minus_7.md and d_minus_3.md (prior posts for continuity)
The Play Store link is: https://play.google.com/store/apps/details?id=com.safetospends.helm

Write all 5 launch pieces:

1. Onyx Traders Telegram (Bangla, 150 words):
   - "এসে গেছে!" opener
   - What it does in 2 sentences
   - Play Store link
   - "Free — কোনো account লাগবে না"
   - Ask them to share with other freelancers

2. Facebook group post — 3 variations (Bangla, 100 words each):
   One for each major BD freelancer Facebook group — slightly different angle per group

3. LinkedIn launch post (EN, 200 words):
   - Product announcement
   - Key differentiator vs Google Sheets
   - Play Store link
   - Tag: #bangladeshfreelancer #payoneer #helmapp

4. Twitter/X post (EN, 280 chars):
   Short punchy announcement with Play Store link

5. Personal story WhatsApp broadcast (Bangla, 3 lines):
   To your contacts who are freelancers

Save to: docs/marketing/launch_posts/d0_launch.md
```

---

### Task 29: Dispatch paid-media-creative-strategist — 3 Facebook ad creative variants

*(Execute at start of Week 10, 1 week after launch)*

- [ ] **Step 1: Dispatch paid-media-creative-strategist**

```
Create 3 Facebook/Instagram ad creative variants for Helm — a cashflow app for Bangladeshi freelancers.

App: Helm (com.safetospends.helm on Play Store)
Objective: App installs (Android only, Bangladesh)
Budget: ৳3,000 test campaign (Week 10), scale winner with ৳12,000 (Weeks 11–12)
Target: Bangladeshi freelancers, Payoneer/Upwork/Fiverr interest, male 22–35, Android

Read: docs/core/HELM_BRAIN.md for product identity and pain points

Create 3 ad variants — each needs:
- Primary text (125 chars): Bangla
- Headline (40 chars): Bangla
- Description (30 chars): Bangla
- Image concept description (for a designer or AI image tool to produce)
- CTA button: "Install Now"

Variant A — Pain Hook:
Primary text: "Payoneer-এ পেমেন্ট এসেছে মনে করে খরচ করলাম। তারপর দেখি এখনো pending। এই ভুল আর হবে না।"
Headline: "Helm — আসল টাকা জানো"
Description: "Free download করো এখনই"
Image: Split screen — left side: freelancer looking worried at phone showing "pending payment", right side: Helm S2S hero screen showing green "Safe" state with ৳ amount

Variant B — Product Reveal:
Primary text: "তোমার Payoneer-এর পেমেন্টের পর আসলে কত BDT খরচ করতে পারবে? Helm তোমাকে সেকেন্ডে জানিয়ে দেবে।"
Headline: "Safe-to-Spend জানো এখনই"
Description: "১ মিনিটে সেটআপ"
Image: Clean app screenshot of S2S hero on warm paper background, large BDT number visible

Variant C — Social Proof:
Primary text: "[Beta tester quote in Bangla — use this placeholder: 'আগে Excel-এ হিসাব রাখতাম। Helm দিয়ে এখন ৩০ সেকেন্ডে দেখে নিই।']"
Headline: "১০০০+ ফ্রিল্যান্সার ব্যবহার করছে"
Description: "Free — কোনো signup নেই"
Image: Testimonial card design with star rating, warm paper background

Save to: docs/marketing/ad_creatives/facebook_variants.md
Include: Facebook Ads Manager campaign structure recommendations (campaign → ad set → ad)
```

---

### Task 30: Dispatch paid-media-paid-social-strategist — Campaign setup

- [ ] **Step 1: Dispatch paid-media-paid-social-strategist**

```
Create the Facebook/Instagram paid campaign structure for Helm Play Store install campaign.

Read: docs/marketing/ad_creatives/facebook_variants.md (3 creative variants)
App: com.safetospends.helm on Play Store (Android only)

Campaign brief:
- Objective: App installs (Android)
- Total budget: ৳15,000 (৳3,000 Week 10 test, ৳12,000 Weeks 11–12 scale)
- Geography: Bangladesh only
- Primary language: Bangla

Deliver a complete campaign setup document:

1. Campaign level:
   - Campaign name: Helm_Install_BD_2026
   - Objective: App installs
   - Campaign budget optimization: OFF (control at ad set level for testing)
   - Special ad categories: None

2. Week 10 Test — 3 Ad Sets (৳1,000 each):
   Ad Set A: Interest targeting — Payoneer, Upwork, Fiverr, Freelancer.com, Age 22–35, Male+Female, Android, Bangladesh
   Ad Set B: Behavioral targeting — "Engaged shoppers" + Finance interest + Bangladesh + Android
   Ad Set C: Broad — Bangladesh + Android + Age 22–35 only (no interest filters)
   Each ad set runs all 3 creative variants (A/B/C from Task 29)

3. Scaling rule (Week 11 start):
   - Kill ad sets with CPI > ৳50 after 3 days
   - Kill creatives with CTR < 0.8% after 3 days
   - Scale winning ad set + creative to ৳4,000/day cap

4. Pixel/SDK setup:
   - Install Facebook SDK in Flutter app (requires pubspec.yaml approval from Chief Architect first — flag this)
   - OR use server-side conversion API (no SDK needed) — recommended for privacy

5. Tracking:
   - UTM parameters: utm_source=facebook&utm_medium=paid&utm_campaign=helm_install_bd_2026&utm_content=variant_[A/B/C]
   - Install tracking: Play Store referrer API

Save to: docs/marketing/paid_campaign/facebook_campaign_setup.md
Include: Week 10 daily monitoring checklist, scale/kill decision criteria
```

---

### Task 31: Week 10 test campaign monitoring + scale decision

*(Execute at end of Week 10, after 7 days of test campaign)*

- [ ] **Step 1: Pull test campaign results**

From Facebook Ads Manager, export:
- Installs per ad set and creative variant
- CPI (cost per install) per variant
- CTR (click-through rate) per variant
- Day-3 retention (from Play Console → Retention)

- [ ] **Step 2: Dispatch paid-media-paid-social-strategist for scale decision**

```
Analyze Week 10 Facebook test campaign results for Helm and make scale/kill decisions.

Read: docs/marketing/paid_campaign/facebook_campaign_setup.md

Campaign results (paste actual data from Ads Manager):
[PASTE RESULTS HERE]

Apply these rules:
1. Kill: any ad set with CPI > ৳50 after 7 days
2. Kill: any creative with CTR < 0.8% after 7 days
3. Scale: winning ad set + creative to ৳4,000/day for Weeks 11–12
4. If ALL variants have CPI > ৳50: pause paid spend entirely, invest the remaining budget in organic

Output:
- Scale decision: which ad set + creative to scale (or PAUSE ALL)
- Revised Week 11–12 budget allocation
- Any copy changes recommended for the scaled variant

Save to: docs/marketing/paid_campaign/week10_scale_decision.md
```

- [ ] **Step 3: Implement scale decision**

Follow the recommendations from week10_scale_decision.md in Facebook Ads Manager.

- [ ] **Step 4: Commit all marketing docs**

```bash
git add docs/marketing/
git commit -m "docs(marketing): add launch posts, ad creatives, campaign setup, week10 scale decision"
```

---

## Exit Gates Summary

| Phase | Gate | Criteria |
|-------|------|----------|
| P1 | `docs/tracking/S1_REAUDIT_REPORT.md` | PHASE 1 COMPLETE (all CRITICAL + HIGH resolved, ≤10 LOW) |
| P2 | `docs/qa/QA_RERUN_REPORT_2026-06.md` | PHASE 2 VERDICT: GO (all 10 QA gates pass, AAB signed) |
| P3 | `docs/beta/BETA_FINAL_SYNTHESIS.md` | PHASE 3 VERDICT: GO (all 5 doctrine thresholds pass) |
| P4 | Manual check | All store assets complete, privacy policy live, Play Console listing saved |
| P5 | Play Console | App approved + live on Play Store |

---

## Human-Only Steps Checklist

- [ ] Generate release keystore + back up offline (Task 10)
- [ ] Create Google Play Console account — $25 (Task 15)
- [ ] Upload AAB to Internal Testing track (Task 15)
- [ ] Recruit and add 15–25 beta testers (Task 15)
- [ ] Host privacy policy on GitHub Pages (Task 24)
- [ ] Complete Play Console store listing fields (Task 25)
- [ ] Submit for production review (Task 25)
- [ ] Post launch content to Telegram/Facebook/LinkedIn (Tasks 26–28)
- [ ] Set up Facebook Ads Manager campaign (Task 30)
- [ ] Monitor Play Console reviews and respond within 24h (Post-launch, ongoing)
