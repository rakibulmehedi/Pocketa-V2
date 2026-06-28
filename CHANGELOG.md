# Changelog

All notable changes to Helm are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.9.0] — 2026-06-29

### Added
- **Biometric unlock for PIN screen**: fingerprint/face ID via `local_auth`; opt-in sheet after PIN setup; auto-trigger on PIN screen with manual fallback button
- `BiometricDataSource`, `BiometricNotifier`, `biometricProvider`, and `unlockViaBiometrics` on `AuthNotifier` — full clean architecture stack
- Biometric preference persisted to repository and wired into PIN flow
- Biometric localization strings (en + bn)
- **History tab — Paper Ledger reskin**: `AuditLogScreen` rebuilt to Paper Ledger standard with date-grouped event cards, tappable before→after detail sheet (`AuditEventDetailSheet`), and ledger integrity strip
- **Chain re-verification**: `AuditChainService.verifyChain` recomputes SHA-256 over the full event history at read time; `ChainVerification` result surfaced in `LedgerIntegrityStrip`
- **Paper Ledger widget system**: `HelmLedgerHero`, `HelmLedgerRow`, `HelmNextEventCard`, `LedgerState` — shared ledger primitives used across Dashboard and History tab
- **Audit presentation utils**: pure helpers `auditIconFor`, `auditColorFor`, `auditEntityLabel`, `auditTitleFor` covering all 6 event types and 5 entity types
- **History grouping**: date-bucket grouping (Today / This Week / Earlier) with full unit-test coverage
- `auditIntegrityProvider` — chain integrity verified on History tab open, result shown in `LedgerIntegrityStrip`
- Fraunces font family (Regular, Medium, SemiBold) added for Paper Ledger display typography
- Golden baselines for History tab (light + dark)
- Guest mode: users can skip magic-link identity verification and use the app locally; identity-specific routes (audit log, trace, delete account) are blocked for guests
- `errorInvalidEmail` localization key in en/bn (324/324 ARB keys); magic-link screen now shows distinct error for malformed email addresses
- Hive cross-validation for magic-link flag: spoofing SharedPrefs via ADB backup no longer bypasses the identity gate

### Fixed
- **Security (HIGH)**: H-11, H-21, H-24, H-26, H-29, H-35, H-37–H-41 resolved (Phase 1 S1 audit)
- **Security (MEDIUM)**: M-13, M-16–M-17, M-26–M-27, M-30–M-33 resolved
- **Security (LOW)**: L-2, L-4–L-12 resolved
- **CRITICAL**: base64url token regex now accepts `-` and `_`; prior regex rejected all real Supabase OTP tokens, breaking production auth
- Onboarding no longer inserts fake "Initial Balance" income entry (C-10)
- Hardcoded English strings replaced with ARB localization keys (C-9)
- Settings and History accessible from all 3 tab AppBars
- Negative amounts (`formatBDT`, `formatUSD`) no longer render as `-,36,000.00`; sign stripped before grouping and restored after
- `box.get() as bool` crash vector replaced with `== true`; tampered Hive values no longer throw `TypeError` inside `_globalRedirect`
- `logout()` now clears `magic_link_verified` from Hive and `guest_mode` from SharedPrefs; stale identity state no longer persists across sessions
- `onAuthenticated` / `onGuest` callbacks typed as `Future<void> Function()`; auth writes awaited before navigation, eliminating silent write failures
- Dead `guest_mode` Hive write removed from onGuest callback; guest mode is intentionally SharedPrefs-backed

### Changed
- **Dashboard reskin**: Signal Deck replaced by Paper Ledger widgets (`HelmLedgerHero`, `HelmNextEventCard`); ledger state drives safe/tight/atRisk/empty color logic
- **Income list screen removed**: standalone income list and pipeline summary deleted; income managed via pipeline and add-income routes
- Complete UI/UX migration to HelmSpacing, HelmTypography, and HelmColors design tokens across all screens (58 hardcoded radius/spacing values replaced)
- Currency symbols centralized behind `NumberFormatter.symbolForCode` boundary (7 files)
- GoRouter magic-link→onboarding redirect loop fixed: early `null` return prevents gate stacking
- `_identityRoutes` constant introduced for declarative guest route restriction
- Navigation: `BottomNavigationBar` replacing `HelmNavBar` (3-tab, Material icons)
- `/settings` and `/trace` re-registered as push-overlay routes
- Build config: `applicationId com.safetospends.helm`, `minSdk 21`, `targetSdk 35`, Play Store version `1.0.0+1`

### Removed
- Signal Deck widget family (`HelmSignalHero`, `HelmDecisionDeck`, `HelmFlowRoute`, `HelmSignalHorizon`) and associated tests

### Internal
- 238 commits since v0.8.0
- Phase 2 QA gate: GO verdict — all critical flow widget tests passing
- dart analyze: 0 errors / 0 warnings / 0 infos

---

## [Unreleased]

### Next
- User Validation Sprint: 5–10 real freelancer users, 30-day observation
- Post-validation: Phase 9 decision (Subscription Leakage Radar — conditional)
- Hive → Drift migration (deferred pending validation; see Decision 010)
- Cloud sync (requires authentication decision)

---

## [0.8.0] — 2026-05-23

### Phase 8 — Safe-to-Spend Engine (Complete)

**Phase 8e — UX Hardening**
- Fixed: `rawSafeToSpend` now correctly drives "In reserve mode" / "Fully allocated" visual state (was dead code using wrong field)
- Fixed: Tax rate slider maximum capped at 40% (entity asserts `<= 0.40`; slider previously allowed 50%)
- Added: Anxiety buffer validation with explicit SnackBar on invalid input; `FilteringTextInputFormatter` guards numeric field
- Changed: Breakdown deduction rows now use `AppColors.textSecondary` instead of `AppColors.error` (removes anxiety-inducing red)
- Added: USD exclusion transparency row in breakdown when `excludedUsdIncome > 0`
- Added: Reserve-mode context note in breakdown when `rawSafeToSpend < 0`
- Fixed: `Colors.grey` replaced with `AppColors.textSecondary` throughout settings screen

**Phase 8d — Dashboard Safe-to-Spend Hero**
- `SafeToSpendHero` widget replaces raw Total Balance on dashboard
- Transparent math breakdown via bottom sheet
- Pending and expected income excluded from Safe-to-Spend correctly

**Phase 8c — Settings Screen**
- `StsSettingsScreen` with tax rate slider, anxiety buffer input, fixed costs CRUD

**Phase 8b — Calculation Engine**
- `SafeToSpendCalculator` as pure Dart logic (zero Flutter imports)
- 26 unit tests covering all edge cases
- `FixedCostEntry`, `StsSettings`, `SafeToSpendResult` domain value objects
- `FixedCostModel` registered with Hive (typeId: 3)
- Riverpod providers wired

**Phase 8f — QA and Validation Prep**
- Real device QA checklist
- Safe-to-Spend scenario matrix
- Founder validation script and user interview questions
- Validation metrics defined

---

## [0.7.0] — 2026-05-22

### Phase 7 — Freelancer Income Pipeline (Complete)

**Phase 7f — Domain Abstraction**
- `TransactionEntity` created as pure Dart (zero Hive/Flutter imports)
- `TransactionRepository` interface accepts/returns `TransactionEntity`
- `TransactionRepositoryImpl` maps entity↔model at data layer boundary
- `TransactionModel` gains `fromEntity()`, `toEntity()`, `fromJson()`, `toJson()`
- `IncomeModel` gains `fromJson()`, `toJson()`
- Hive imports fully removed from domain and presentation layers

**Phase 7a–7e — Income Pipeline**
- Income domain entity: `IncomeEntryEntity` with status (Expected/Pending/Received)
- Hive model (typeId: 2), local data source, repository, Riverpod providers
- Add/edit income form screen with full validation
- Income list screen with status filter chips, income cards, delete + undo, empty states
- `/income` route with optional `initialFilter` for deep-link from dashboard
- Dashboard income pipeline summary: Expected/Pending/Received totals, tap-to-filter navigation
- Status quick-action transitions: Expected → Pending → Received

---

## [0.1.0] — 2025-08-18

### Initial Foundation

- Flutter project scaffolding
- Riverpod state management setup
- Hive local storage integration
- GoRouter navigation
- Feature-first architecture structure
- Onboarding flow
- Transaction CRUD (add, edit, delete, undo delete)
- Dashboard with summary totals
- Transaction filtering and grouping
- Theme system (AppColors, AppTheme)
- Localization scaffolding (English + Bengali)
- GitHub release workflow (standard-version)
