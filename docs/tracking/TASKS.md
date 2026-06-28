# HELM — TASKS

> Reference: `docs/planning/100_PERCENT_MASTER_PLAN.md` (adopted 2026-06-12)

## Current Sprint

**Sprint S1 — Security Hardening (Adversarial Audit Remediation)** (🔄 IN PROGRESS, ~40h, depends on Phase 4 ✅)

> Audit: `.commandcode/adversarial_audit_report.md` — 97 vulnerabilities across 12 domains
> Dispatch: `docs/planning/TDD_DISPATCH_SPRINT_S1_SECURITY_HARDENING.md` (per-agent domain dispatch)

## In Progress

*Sprint S1 code-evidence mapping complete (2026-06-14) — 43/97 tasks verified done in source/tests, 54/97 remain pending. See §Recently Completed for S1-W4 record and §Implementation Sequence for wave-by-wave status.*

### Approved Design Awaiting Implementation Plan

- [x] Approve Helm Signal Deck mobile UI/UX architecture proposal.
- [x] Write canonical design spec: `docs/superpowers/specs/2026-06-16-helm-signal-deck-design.md`.
- [x] Review and approve written Signal Deck spec before implementation planning.
- [x] Create phased Signal Deck implementation plan: `docs/superpowers/plans/2026-06-16-helm-signal-deck-implementation.md`.
- [x] Implement Signal Deck UI slice with TDD.

> Note: Dispatch file `docs/planning/TDD_DISPATCH_SPRINT_S1_SECURITY_HARDENING.md` is referenced but does not exist. Use `docs/tracking/S1_CODEBASE_TASK_MAPPING.md` for the code-evidence-based status of each S1 task.

## Active Focus (Top 5 Criticals — Immediate)

- [x] **C-1** Entire auth trust chain client-side → trivial bypass on rooted device [Agent: AUTH_CRACKER, V-1–V-4 chained, §C-1]
- [x] **C-2** Token prefix `valid_` predictable → 1M token brute force [Agent: AUTH_CRACKER, V-1 + V-7, `auth_remote_data_source.dart:32-33`]
- [x] **C-3** PIN attempt counter not persisted → infinite cold-start retry [Agent: AUTH_CRACKER, V-2, `auth_provider.dart:25-28`]
- [x] **C-4** Zero at-rest encryption on all Hive boxes [Agent: STORAGE_RAIDER, §4, `hive_service.dart:33`]
- [x] **C-5** No app lifecycle handling → PIN bypass on app resume [Agent: NAVIGATION_HIJACKER, F-3, `main.dart`]
- [x] **C-6** Release build signed with debug keys [Agent: PLATFORM_ABUSER, §8, `build.gradle.kts:41`]
- [x] **C-7** PIN gate fail-open when Hive box unavailable [Agent: AUTH_CRACKER, V-5, `app_router.dart:323`]
- [x] **C-8** Hive is abandoned → migrate to hive_ce [Agent: DEPENDENCY_POISONER, §4, `pubspec.yaml`]
- [x] **C-9** ~180 hardcoded English strings bypass localization [Agent: UI_PSYOP_AGENT, §1, all widget files]
- [ ] **C-10** Silent data fabrication — fake "Initial Balance" income entry [Agent: UI_PSYOP_AGENT, §3, `onboarding_screen.dart:137-146`]
- [x] **C-11** `_isSaving` guards on StateNotifiers bypassable after provider disposal [Agent: STATE_CORRUPTOR, §2, 4 notifiers]
- [x] **C-12** CSV formula injection in export [Agent: INPUT_WEAPONIZER, §1, `export_service.dart:158-164`]
- [x] **C-13** `AuditEventModel` uses `late` fields → crash on corrupt read [Agent: STORAGE_RAIDER, §1, `audit_event_model.dart:30-54`]
- [x] **C-14** Negative tax rate & buffer percent in release mode [Agent: STATE_CORRUPTOR/BUSINESS_LOGIC_BREAKER, `sts_settings.dart:17-19`]
- [x] **C-15** `s2s_calc_failure` passes `e.toString()` → potential PII in analytics [Agent: DATA_EXFILTRATOR, §2, `safe_to_spend_providers.dart:132`]
- [ ] **C-16** `google_fonts` downloads fonts at runtime over internet [Agent: DEPENDENCY_POISONER, §4, `pubspec.yaml`]
- [x] **C-17** SDK constraint mismatch — declared `^3.7.2`, resolved `>=3.11.0` [Agent: DEPENDENCY_POISONER, §3, `pubspec.yaml`]

## HIGH — Fix Before Next Release (35 tasks)

### Domain: Auth (AUTH_CRACKER)
- [x] **H-1** `setMagicLinkAuthCompleted` not awaited → redirect loop race [M-1, `app_router.dart:137-139`]
- [x] **H-2** Fix 4-digit PIN → 6-digits minimum for financial app [V-8, `pin_setup_screen.dart:26`, `pin_entry_screen.dart:27`]
- [x] **H-3** Email regex allows double dots, special chars — tighten validation [V-10, `auth_repository_impl.dart:72-74`]
- [x] **H-4** `_usedTokens` in-memory → persist or accept limitation [V-11, `auth_remote_data_source.dart:14`]
- [x] **H-5** `logout()` doesn't clear Magic Link session/SharedPrefs flag [V-12, `auth_provider.dart:83-89`]
- [x] **H-6** Rate limit global per-instance → make per-email [V-13, `auth_remote_data_source.dart:21-23`]

### Domain: Storage (STORAGE_RAIDER)
- [x] **H-7** `TransactionTypeAdapter.read()` silently defaults unknown bytes to `income` [§2, `transaction_type_adapter.dart:28-34`]
- [x] **H-8** `AuditEventModel.toEntity()` — no bounds check on enum index → RangeError [§2, `audit_event_model.dart:57-60`]
- [x] **H-9** Session token + email in unencrypted Hive `session_box` [§4, `hive_service.dart`]
- [x] **H-10** No schema version tracking anywhere — add migration framework [§7, all Hive models]
- [x] **H-11** STS buffer migration silently replaces user's absolute BDT with 15% [§7, `sts_settings_data_source.dart:65-71`]
- [x] **H-12** `SharedPreferences._prefs` nullable → errors silently discarded if init fails [§10, `shared_pref_service.dart`]

### Domain: Input (INPUT_WEAPONIZER)
- [x] **H-13** No input sanitization on any free-text field — RTL override, null byte injection [§2, 9 text fields]
- [x] **H-14** No maxLength on any text field → storage bloat, CSV distortion [§8, all screens]

### Domain: State (STATE_CORRUPTOR)
- [x] **H-15** `safeToSpendProvider` uses `[]` fallback during loading → inflated S2S [§2, `safe_to_spend_providers.dart:125`]
- [x] **H-16** Calculator errors silently return `SafeToSpendResult.zero()` [§2, `safe_to_spend_providers.dart:127-138`]
- [x] **H-17** `FixedCostEntry` dueDayOfMonth assert bypassed in release → wrong month [§3, `fixed_cost_entry.dart:24`]
- [x] **H-18** `trackingStreak` uses session count, not consecutive-day streak [§3, `nudge_providers.dart:173`]
- [x] **H-19** `IncomeNotifier.updateIncome` TOCTOU race — delete between write and state update [§3, `income_providers.dart:108-114`]
- [x] **H-20** `FixedCostNotifier.addFixedCost` — no duplicate ID check [§3, `safe_to_spend_providers.dart:63-66`]

### Domain: Navigation (NAVIGATION_HIJACKER)
- [x] **H-21** `/onboarding` screen has no guard checking if already completed [F-2, `onboarding_screen.dart`]
- [x] **H-22** `_AddEditFixedCostSheet._save()` — save not awaited before Navigator.pop [F-10, `sts_settings_screen.dart:385-401`]

### Domain: Data Exfiltration (DATA_EXFILTRATOR)
- [ ] **H-23** Session token + email stored unencrypted in Hive [§1, `session_box`]
- [ ] **H-24** Client names, amounts, notes in plaintext CSV export — add warning [§4, `export_screen.dart`]

### Domain: Business Logic (BUSINESS_LOGIC_BREAKER)
- [x] **H-25** Negative fxRate silently subtracts from S2S — add calculator guard [V-5, `safe_to_spend_calculator.dart:39`]
- [ ] **H-26** `saveSettings` — two non-atomic SharedPrefs writes → torn settings [V-12, `sts_settings_repository_impl.dart:22-26`]

### Domain: Race Conditions (RACE_CONDITION_EXPLOITER)
- [x] **H-27** SplashScreen Timer not cancelled in dispose [§4, `splash_screen.dart:51`]
- [x] **H-28** `setupPin`/`clearPin` — 3 non-atomic Hive writes → corrupt auth state [§3, `auth_provider.dart:52-59, 88-93`]
- [ ] **H-29** `_deleteAllData` — no transactional rollback → partial data loss [§3, `delete_account_screen.dart:49-63`]

### Domain: Platform (PLATFORM_ABUSER)
- [x] **H-30** No root/jailbreak detection [§10, all native layers]
- [x] **H-31** No code obfuscation — DART_OBFUSCATION=false [§8, `Generated.xcconfig`]
- [x] **H-32** No ProGuard/R8 custom rules [§11, `android/app/`]
- [x] **H-33** Bundle ID is `com.example.helm` — Google/Apple reserved domain [§2, manifest+plist]

### Domain: Code Quality (CODE_QUALITY_BREACH_DETECTOR)
- [x] **H-34** 4 empty `catch(_){}` blocks in delete_account_screen → silent failures [§1A, `delete_account_screen.dart:59,65,82,94`]
- [ ] **H-35** 122+ null-assert `!` on theme extensions → crash if missing [§2A, 52 files]

### Domain: Dependencies (DEPENDENCY_POISONER)
- [ ] **H-36** `http`, `web_socket_channel`, `url_launcher_*` in transitive deps — audit network surface [§2, `pubspec.lock`]
- [ ] **H-37** No custom lint rules — enable strict lint for financial app [§8, `analysis_options.yaml`]

### Domain: UI/UX (UI_PSYOP_AGENT)
- [ ] **H-38** 4 label-action mismatches (First Pipeline button, Skip, Pipeline FAB, Welcome CTA) [§2, 4 screens]
- [ ] **H-39** Undo-toast for income/fixed-cost deletion is fragile — add confirmation [§4, 2 screens]
- [ ] **H-40** USD-without-FX silent exclusion — add warning badge [§5, `safe_to_spend_calculator.dart`]
- [ ] **H-41** Currency symbol inconsistency: `tk` vs `৳` in 3 formats [§5, 4 files]

## MEDIUM — Fix Within 2 Sprints (33 tasks)

### Domain: Storage
- [x] **M-1** Generated .g.dart cast failures on corrupted boxes — add defensive reads [§1, all .g.dart files]
- [x] **M-2** Audit event ID collision — `millisecondsSinceEpoch.toString()` [§3, 6 files]
- [x] **M-3** `delete_account` hardcodes box names — use `AppBoxNames` constants [§7, `delete_account_screen.dart:47-54`]
- [x] **M-4** `_prefs` nullable → silent no-op if uninitialized [§10, `shared_pref_service.dart`]

### Domain: Input
- [x] **M-5** `_escapeCsv` missing RTL override protection [§2, `export_service.dart:158-164`]
- [x] **M-6** No input formatters on text fields — add `FilteringTextInputFormatter` [§2, 9 fields]

### Domain: State
- [x] **M-7** Currency string case-sensitive — `"bdt"`/`"usd"` silently uncounted [§4, `safe_to_spend_calculator.dart:36-38`]
- [x] **M-8** `fxRate=0` silently zeroes USD contribution [§4, `safe_to_spend_calculator.dart:40`]
- [x] **M-9** No state machine enforcement on IncomeStatus transitions [§5, `income_entry_entity.dart:24-32`]
- [x] **M-10** `ExportNotifier.lastResult` mutable field across async gap [§7, `export_provider.dart:11`]
- [x] **M-11** `AuthNotifier.sessionAuthenticated` static mutable field [§6, `auth_provider.dart:25`]

### Domain: Navigation
- [x] **M-12** `CadencePreferenceSheet._selectTime()` no mounted check [F-9, `cadence_preference_sheet.dart:54-59`]
- [ ] **M-13** Missing GoRoute for `/history` path [F-4, `route_names.dart:19`]

### Domain: Data Exfiltration
- [x] **M-14** `FLAG_SECURE` not set — PIN screens visible in app switcher [§6, `MainActivity.kt`]
- [x] **M-15** Lock screen notifications visible — set `visibility: secret` [§7, `notification_service.dart:88-94`]
- [ ] **M-16** `debugPrint` of analytics properties + notification payloads in debug builds [§1, `analytics_service.dart:54,67`]

### Domain: Business Logic
- [ ] **M-17** `excludedUsdIncome` tracking skip for excluded entries — contradiction [V-4, `safe_to_spend_calculator.dart:32`]
- [x] **M-18** No amount upper-bound → MAX_DOUBLE cascades to Infinity [V-2, §2]

### Domain: Race Conditions
- [x] **M-19** `verifyMagicLink` token reuse — dual concurrent calls both pass [§1, `auth_remote_data_source.dart:48-52`]
- [x] **M-20** `sendMagicLink` rate limit TOCTOU bypass [§1, `auth_remote_data_source.dart:24-29`]
- [x] **M-21** `markRead`/`markActioned` zombie entry — deleted entry re-inserted [§1, `nudge_data_source.dart:68-98`]
- [x] **M-22** `ExportNotifier` missing double-submit guard [§2, `export_provider.dart:16`]
- [x] **M-23** `saveSettings`/`getSettings` torn reads/writes [§3, `sts_settings_repository_impl.dart:17-26`]

### Domain: Platform
- [x] **M-24** Export CSVs never cleaned up — accumulate in documents dir [§9b, `export_service.dart`]
- [x] **M-25** iOS `ITSAppUsesNonExemptEncryption` missing — Apple may reject [§4, `Info.plist`]

### Domain: Dependencies
- [ ] **M-26** All versions use caret `^` ranges — pin critical deps [§1, `pubspec.yaml`]
- [ ] **M-27** No integration tests for data integrity or export flow [§9, `test/`]

### Domain: Code Quality
- [x] **M-28** `AuditEventModel` 6 `late` fields — only model without constructor params [§3B, `audit_event_model.dart:31-54`]
- [x] **M-29** Hardcoded defaults (taxRate 10%, buffer 15%) mask errors [§7, `sts_settings_repository_impl.dart:19-20`]
- [ ] **M-30** Debug-only dev reset button on dashboard — add confirmation [§5A, `dashboard_screen.dart:207`]

### Domain: UI/UX
- [ ] **M-31** `inkTertiary` color fails WCAG AA contrast at 11pt [§6, `helm_colors.dart`]
- [ ] **M-32** Bangla translations: 7 quality issues (transliteration vs translation) [§7, `app_localizations_bn.dart`]
- [ ] **M-33** 3 unhelpful error messages (rate limit, lockout, export) [§8, 3 files]

## LOW — Backlog (12 tasks)

- [x] **L-1** `addFixedCost` silent overwrite on duplicate ID [`fixed_cost_local_data_source.dart:27`]
- [ ] **L-2** No referential integrity between audit log and entities [cross-box]
- [x] **L-3** `double.parse` instead of `tryParse` in add_transaction_screen [`add_transaction_screen.dart:98`]
- [ ] **L-4** `TransactionsNotifier` wasteful full Hive re-read on every mutation [`transaction_provider.dart:56-63`]
- [ ] **L-5** Nudge `[Client]` literal text — never interpolated [`nudge_evaluator.dart:108`]
- [ ] **L-6** Path parameter `:id` not format-validated [`app_router.dart:100,119`]
- [ ] **L-7** `dailyActiveSession` dedup non-atomic [`analytics_service.dart:41-48`]
- [ ] **L-8** `trackEvent` unawaited Future — silent analytics failures [`analytics_service.dart:56`]
- [ ] **L-9** `share_plus` temp file exposure — warn user before sharing [`export_screen.dart`]
- [ ] **L-10** `share_plus` pulls `url_launcher_*` on desktop — accept or suppress [`pubspec.lock`]
- [ ] **L-11** Notification opt-out friction — defaults to daily push post-onboarding [`cadence_preference_sheet.dart`]
- [ ] **L-12** Dead `PopScope` code in `add_income_screen.dart` [`add_income_screen.dart:243-250`]

## Implementation Sequence (7 Waves)

**Wave 1 — Critical Auth + Storage (S1.1-S1.8):** C-1 to C-8, C-13, C-14, C-17
**Wave 2 — Navigation + Data (S1.9-S1.15):** C-5, C-9, C-10, C-11, C-12, C-15, C-16
**Wave 3 — High Auth/Storage/Input (S1.16-S1.24):** H-1 to H-14
**Wave 4 — High State/Nav/Race (S1.25-S1.35):** H-15 to H-29
**Wave 5 — High Platform/Code/UI (S1.36-S1.43):** H-30 to H-41
**Wave 6 — All Medium (S1.44-S1.76):** M-1 to M-33
**Wave 7 — All Low + Final Verification (S1.77-S1.97):** L-1 to L-12 + regression + re-audit

## Sprint S1 Exit Gates
- [ ] `dart analyze` 0/0/0
- [ ] All 325+ existing tests pass (no regression)
- [ ] New security tests: ~40 (auth brute-force, CSV injection, type confusion, race)
- [ ] Hive encryption enabled with platform keystore
- [ ] Android release signing configured (human)
- [ ] Bundle ID changed from `com.example.helm`
- [ ] DART_OBFUSCATION=true in release config
- [ ] FLAG_SECURE on PIN screens
- [ ] CSV formula injection guard in export
- [ ] 52/97 critical+high resolved (remaining: MEDIUM + LOW only)
- [ ] Security re-audit: remaining findings ≤ 10 (LOW only)

---

## Recently Completed

**Sub-Project B: History Tab Paper Ledger + Trust Layer Surfacing** ✅ [2026-06-21] — `dart analyze` 0/0/0, 444 pass / 1 skip (non-golden) (branch: `paper-ledger-reskin`)
- [x] Task 1–9 (implementation commits 449fb56..b19a28f): `AuditLogScreen` reskinned to Paper Ledger (canvas appbar, date-grouped tappable cards, themed loading/error/empty). Per-event detail sheet with description, before→after diff, record hash. `AuditChainService.verifyChain()`, `auditIntegrityProvider`, `LedgerIntegrityStrip` (verify-on-open tamper-evidence). Retention footer. Dark-mode goldens (2 new).
- [x] Task 10 (docs): recorded Decision 041, updated `DECISION_LOG.md`, `PROJECT_STATE.md`, `TASKS.md`, verified `ROADMAP.md`
- See `docs/tracking/DECISION_LOG.md` Decision 041
- See `docs/superpowers/plans/2026-06-21-history-tab-paper-ledger-trust.md`

**Income View Consolidation — Decision 040** ✅ [2026-06-21] — `dart analyze` 0/0/0, 422 tests pass (1 skipped) (branch: `paper-ledger-reskin`)
- [x] Task 1 (c22cffc): deleted orphaned `IncomePipelineSummary` widget
- [x] Task 2 (dd44f56): removed `/income` GoRoute, `IncomeListScreen`, `RouteNames.income`; added permanent guard test (`test/config/router/income_route_removed_test.dart`)
- [x] Task 3 (8d12cd2): removed 15 income-list-only l10n keys from en/bn ARB files + regenerated
- [x] Task 4: recorded Decision 040, updated `PROJECT_STATE.md` + `TASKS.md`
- See `docs/tracking/DECISION_LOG.md` Decision 040

**UI/UX Migration — P6 Final Coherence** ✅ [2026-06-20] — `dart analyze` 0/0/0, 325/325 tests pass (branch: `feat/ui-ux-migration`)
- [x] P6a: Currency symbol centralization (`NumberFormatter.symbolForCode/prefixForCode/defaultCurrencyCode`) — 7 hardcoded `৳` across 6 files eliminated (commit `7abc03d`)
- [x] P6b: Typography token purity (3 screens) — 5 raw `TextStyle(...)` replaced with `HelmTypography` tokens in audit_log, sts_settings, add_income (commit `2add3fc`)
- Prior phases P1–P5c complete: deprecated API removal, HelmLocaleText + ARB infra (320 keys), Dashboard Reality Stack, income/pipeline localization, settings/onboarding/auth/transaction/export screen migration, full 320/320 en/bn localization pass

**Sprint S1-W4 — Security Hardening (6 phases)** ✅ [2026-06-14] — `dart analyze` 0 issues, 251/251 tests pass
- 4A Secret Hygiene: `.gitignore`, release workflow email, agent docs
- 4E Platform Hardening: Android manifest/config, iOS privacy/entitlements/backup, root/jailbreak detection wiring
- 4C Trust-Layer Bugs: PIN lockout expiry, delete-account PIN salt, auth provider hardening
- 4D Crypto & Storage: PIN KDF (SHA-256 + salt), secure storage, box wipe on deletion, secure keyboard flags
- 4B Input Validation & Sanitization: `InputValidator`, CSV hardening, model deserialization, route param validation, magic-link validation, nudge route whitelist
- 4G Audit Log Hardening: schema version, unique ids, previousValue, SHA-256 chain hash, retention, exported event, CSV schema column
- 4F Lint Final Sweep: catch clauses, unawaited futures, deprecated APIs, test helper deps
- Operational docs updated: `CURRENT_SPRINT.md`, `PROJECT_STATE.md`

**Helm Signal Deck UI slice** ✅ [2026-06-16] — `dart analyze` 0 issues, `flutter test` 307/307 pass, merged to `main` in `6773be4`
- Signal Hero, Signal Horizon, Decision Deck, Flow route, calculation trace sheet, dashboard home, shell nav, confirm haptics
- Reviewer fixes: unavailable amount dash fallback, pending label correction, pulse restart on update, 320dp overflow fix
- Responsiveness patch: compact LayoutBuilder sizing on Signal Hero + Decision Deck for 320dp / large text
- Docs updated: `CURRENT_SPRINT.md`, `PROJECT_STATE.md`, `ROADMAP.md`

**Phase 2 — Analytics Infrastructure** ✅ [2026-06-12] — 34 tests, dart analyze 0/0/0, 4 groups done
- Group 2A — Hive event persistence + repository + dual-write + session dedup + event registry
- Group 2B — NextBestActionCard (4 variants + Semantics)
- Group 2C — Semantics coverage (8+ tests across FAB, nav, buttons, fields, switches, sliders)
- Group 2D — NudgeEventLogger + CadencePreferenceSheet (Hive-persisted + Settings UI + post-onboarding)
- Spike: NudgeEventLogger (P2.5) created + tested — 5 lifecycle events
- Spike: Semantics labels added to LiquidBalancePage TextField + AddIncome exclude switch
- Spike: CadencePreferenceSheet deprecated `activeColor` → `activeThumbColor`, unused imports cleaned
- Files created: `nudge_event_logger.dart`, `nudge_event_logger_test.dart`
- Files modified: `liquid_balance_page.dart`, `add_income_screen.dart`, `cadence_preference_sheet.dart`, `analytics_service.dart`, `HIVE_TYPEID_REGISTRY.md`
- Operational docs updated: CURRENT_SPRINT.md, TASKS.md, ROADMAP.md

**Phase 1 — Behavioral Foundation** ✅ [2026-06-13] — 104 tests, dart analyze 0/0/0, 7 groups done

## TDD Dispatch Plans (All Phases — per-phase separate documents)

> Phase 1: `docs/planning/TDD_DISPATCH_PHASE_1_BEHAVIORAL_FOUNDATION.md` — 7 groups, 18 tasks, 25+ tests
> Phase 2: `docs/planning/TDD_DISPATCH_PHASE_2_ANALYTICS_INFRASTRUCTURE.md` — 4 groups, ~8h
> Phase 3: `docs/planning/TDD_DISPATCH_PHASE_3_NOTIFICATION_SYSTEM.md` — 5 groups, ~12h
> Phase 4: `docs/planning/TDD_DISPATCH_PHASE_4_DOCTRINE_GAP_CLOSURE.md` — 5 groups, ~20h
> Phase 5: `docs/planning/TDD_DISPATCH_PHASE_5_V1_FEATURES.md` — 3 groups, ~15h (gated)
> Phase 6: `docs/planning/TDD_DISPATCH_PHASE_6_V2_FEATURES.md` — 6 groups, ~20h (gated)
>
> Full implementation details (TDD approach, test files, patterns, exit gates) are in each per-phase document.

### Phase 1 — Behavioral Foundation — COMPLETE ✅

See `docs/planning/TDD_DISPATCH_PHASE_1_BEHAVIORAL_FOUNDATION.md`

### Phase 2 — Analytics Infrastructure (4 groups, 21 tasks, ~8h) — COMPLETE ✅

See `docs/planning/TDD_DISPATCH_PHASE_2_ANALYTICS_INFRASTRUCTURE.md`

### Phase 3 — Notification System (5 groups, 30 tasks, ~12h) — PENDING

See `docs/planning/TDD_DISPATCH_PHASE_3_NOTIFICATION_SYSTEM.md`

### Phase 4 — Doctrine Gap Closure (28 tasks, ~20h) — COMPLETE ✅

See `docs/planning/TDD_DISPATCH_PHASE_4_DOCTRINE_GAP_CLOSURE.md`

### Phase 5 — V1 Features (3 groups, 15 tasks, ~15h) — BLOCKED

See `docs/planning/TDD_DISPATCH_PHASE_5_V1_FEATURES.md`

### Phase 6 — V2 Features (6 groups, 28 tasks, ~20h) — BLOCKED

See `docs/planning/TDD_DISPATCH_PHASE_6_V2_FEATURES.md`


## Completed UX Canon Sprints (16 sprints, 2026-05-22 to 2026-06-07)

1. [x] Sprint 1: UX-5 Visual Identity / Design System (12 tasks) — **COMPLETE [2026-06-05]**
2. [x] Sprint 2: UX-1 Dashboard Cockpit Redesign (14 tasks) — **COMPLETE [2026-06-05]**
3. [x] Sprint 3: UX-2 Onboarding Redesign (8/11 tasks) — **COMPLETE [2026-06-05]** (3 deferred)
4. [x] Sprint 4: UX-3 Pipeline Quick-Update (13 tasks) — **COMPLETE [2026-06-05]**
5. [x] Sprint 5: UX-4 Microcopy Replacement (8 tasks) — **COMPLETE [2026-06-06]**
6. [x] Sprint 6: D1 Trust Layer Foundation (11/12 tasks) — **COMPLETE [2026-06-06]** (D1.04 biometric deferred)
7. [x] Sprint 7: D2 Beta Instrumentation (6 tasks) — **COMPLETE [2026-06-06]**
8. [x] Sprint 8: D3 Closed Beta Readiness (8 tasks) — **COMPLETE [2026-06-06]**
9. [x] Sprint A1: Internal Alpha Maturity Audit — **COMPLETE [2026-06-07]**
10. [x] Sprint A2: Beta Blocker Resolution (8 tasks) — **COMPLETE [2026-06-07]**
11. [x] Sprint A3: First Impression Polish (3 tasks) — **COMPLETE [2026-06-07]**
12. [x] Sprint A4: Test Coverage + Design Stabilization (9 tasks) — **COMPLETE [2026-06-07]**
13. [x] Phase 1: Behavioral Foundation (7 groups, 26 tests added) — **COMPLETE [2026-06-13]**
14. [x] Phase 4: Doctrine Gap Closure (5 groups, 48 tests added, 11 new source files) — **COMPLETE [2026-06-13]**

## Phase 0 — Beta Launch Readiness (A5) — IN PROGRESS 🔄 [2026-06-14]

- [x] A5.1 Author native Bangla strings (app_bn.arb) — 96 keys, native Bangla, 0/0/0 ✅
- [~] A5.2 Build release APK — build config fixed (version 0.3.0-beta.1+1, label "Helm"); needs keystore + `flutter build apk --release` (human action) ⏳
- [ ] A5.3 Test on Samsung Galaxy A14 (or equivalent) — blocked on A5.2 APK build
- [x] A5.4 Verify Android minSdkVersion compatibility — minSdk 21, Galaxy A14 API 33, fully compatible ✅
- [x] A5.5 Verify app icon and branded splash — splash #FAFAF6, iOS name "Helm", VISR-029 branded icon installed across Android/iOS/macOS/web; no package added ✅

## VCI — Version Control Infrastructure — PENDING (runs before beta APK)

- [ ] VCI-1 Create `develop` branch from `main`
- [ ] VCI-2 Create `release/v0.3-beta` branch from `main`
- [ ] VCI-3 Tag v0.3-beta.1, update pubspec.yaml to `0.3.0-beta.1+1`
- [ ] VCI-4 Write HOTFIX_PROTOCOL.md
- [ ] VCI-5 Write VERSIONING_POLICY.md
- [ ] VCI-6 Configure GitHub branch protection (main + release/*)

## Phase 1 — Behavioral Foundation — COMPLETE ✅ [2026-06-13]

- [x] P1.1-P1.4 Wire 4 boundary events (sts_at_risk_entered, reserve_depleted, first_pipeline_entry, pipeline_state_changed)
- [x] P1.5-P1.8 Add haptic feedback (PIN taps, confirm/delete, errors, card tap)
- [x] P1.9-P1.11 Fix 3 contrast ratios (stateSafe→#3D6B3C, stateTight→#8B6500, dark interactive→#4DA09C)
- [x] P1.12 Add active/pressed visual states to buttons
- [x] P1.13-P1.14 Add ±1% stepper buttons to tax rate + buffer sliders
- [x] P1.15 Add global "Set up later" skip to onboarding
- [x] P1.16-P1.18 Add quiet affirmation signals (pipeline up to date, 7/14 days tracked)

## Phase 2 — Analytics Infrastructure — COMPLETE ✅ [2026-06-12]

- [x] P2.1-P2.7 Analytics infrastructure (Hive persistence, query methods, dedup, session tracking)
- [x] P2.8-P2.11 Dashboard "next best action" card (4 state variants, Semantics)
- [x] P2.12-P2.17 Semantics coverage (FAB, nav items, forms, switches, sliders)
- [x] P2.18-P2.21 Cadence preference discovery (Hive model, preference sheet, post-onboarding, Settings link)

## Phase 3 — Notification System — COMPLETE ✅ [2026-06-12]

- [x] P3.1-P3.6 Notification infrastructure (flutter_local_notifications, init, schedule daily/periodic)
- [x] P3.7-P3.13 Nudge evaluator engine (rules provider, overdue/S2S/re-engagement/affirmation rules)
- [x] P3.14-P3.18 In-app notification center (grouped list, Hive storage, badge, swipe-to-dismiss, tap-nav)
- [x] P3.19-P3.25 Nudge copy (7 copy strings in Helm brand voice — Brand Guardian review)
- [x] P3.26-P3.30 Nudge effectiveness tracking (SENT/OPENED/DISMISSED/ACTIONED + report)

## Phase 4 — Doctrine Gap Closure — COMPLETE ✅ [2026-06-13]

- [x] P4.1-P4.9 Auth system (Magic Link + PIN/biometric, 41 tests, mock backend swappable to real API)
- [x] P4.10-P4.15 Conversational onboarding rebuild (pain-point qualifier, Bangla rephrase, 8 widget tests)
- [x] P4.16-P4.19 FX rate field + exclude-entry toggle per pipeline entry (exclude toggle on card, 0 new tests needed)
- [x] P4.20-P4.23 Buffer as percentage (5-30%, default 15%) — COMPLETED in D1.11
- [x] P4.24-P4.28 Instrumentation hardening (7 new events, 2 property keys) — COMPLETED in Phase 4 Group 4E

## Phase 5 — V1 Features — BLOCKED (requires beta thresholds cleared)

### Group 5A — Multi-Wallet (~8h, 15+ tests)
- [ ] P5.1 WalletEntity + Hive model (typeId 10) — name, currency, balance, icon, order
- [ ] P5.2 WalletDataSource + WalletRepository + Hive box + CRUD
- [ ] P5.3 WalletProvider (Riverpod) — active wallet selector, balance aggregation
- [ ] P5.4 Wallet picker UI in dashboard header
- [ ] P5.5 Intra-wallet transfer screen (record-only, audit-logged)
- [ ] P5.6 Migrate S2S calc to active wallet balance

### Group 5B — Dashboard State Colors (~3h, 4+ tests)
- [ ] P5.7 Compute S2S state: Safe / Tight / At Risk
- [ ] P5.8 Display state pill/chip in dashboard header

### Group 5C — UX Polish (~4h, 8+ tests)
- [ ] P5.9 Duplicate-last-entry pipeline template
- [ ] P5.10 Skeleton screens (dashboard + income list on cold start)
- [ ] P5.11 Illustrated empty states + retry on calc failure
- [ ] P5.12 Transactional ETA notifications
- [ ] P5.13 Manual USD→BDT conversion with sanity bounds

## Phase 6 — V2 Features — BLOCKED (requires V1 stable + legal L5 + pricing validation)

### Group 6A — Invoice-Lite Sprint 1: Form + List (~5h)
- [ ] P6.1 InvoiceEntity — sequential numbering, client, TIN, BDT-equivalent, status
- [ ] P6.2 Invoice form screen
- [ ] P6.3 Invoice list screen (grouped by status)

### Group 6B — Invoice-Lite Sprint 2: PDF + Email (~5h)
- [ ] P6.4 PDF generation (pdf package)
- [ ] P6.5 Email/send via share sheet
- [ ] P6.6 Audit log invoice events

### Group 6C — Invoice-Lite Sprint 3: Pipeline Cascade (~5h)
- [ ] P6.7 Sent invoice → auto-creates Expected pipeline entry
- [ ] P6.8 Marked paid → auto-creates Received entry
- [ ] P6.9 Client profile (name, email, currency, payment terms)
- [ ] P6.10 Overdue flagging + follow-up template

### Group 6D — Tax Reserve (~3h)
- [ ] P6.11 TaxReserveEntity (user-declared %, disclaimed)
- [ ] P6.12 Tax reserve UI in STS Settings (audit-logged)
- [ ] P6.13 Tax reserve row in S2S breakdown

### Group 6E — Paid Tiers (~2h)
- [ ] P6.14 Feature gate system (Free/Pro/Power)
- [ ] P6.15 Subscription screen + payment mock

### Group 6F — Final 100% Polish (~5h)
- [ ] P6.16 Full a11y audit (15+ screens)
- [ ] P6.17 Dark mode OLED pass
- [ ] P6.18 Haptic audit (no double-fire)
- [ ] P6.19 Semantics audit (every interactive element)
- [ ] P6.20 Performance (rebuild count, provider disposal)
- [ ] P6.21 Test coverage to 300+
- [ ] P6.22 Update all docs to V2 state

## Backlog (Post-Beta / Deferred)

### Nav Reskin — Follow-ups (filed 2026-06-21)
- [ ] Reskin `AddTransactionScreen` — replace legacy "cash out" language (UX-P5), align to Spend framing ("Add a payment"), reconsider `categoryId` exposure per Final Doctrine.
- [ ] App-wide Lucide migration — migrate remaining ~24 Material-icon files to `HelmIcon`/`LucideIcons`.
- [ ] Route de-duplication — collapse `/settings` vs `/sts-settings`.
- [ ] Behavioral widget tests for Dashboard gear + Pipeline audit link once Dashboard initState (AR-P1) and income provider gain test seams.

- [ ] Virtual Wallets (V1 — after beta clears)
- [ ] Tax reserve (V2)
- [ ] Invoice-Lite (V2)
- [ ] Multi-currency conversion (V1)
- [ ] Supabase sync (V1+)
- [ ] Push notifications (V1 transactional only)
- [ ] CHORE: Token reference cleanup — 58 `BorderRadius.circular(N)` + 8 `EdgeInsets.all(N)` use correct pixel values but not token constant names (non-blocking)
- [ ] CHORE: Expand golden tests to onboarding, income form, STS settings (currently 1 screen — dashboard only)
- [ ] FUTURE: Extend `NumberFormatter.symbolForCode` with EUR/SGD/GBP before Experiment 16.1 prototypes (requires founder ratification)

## Killed (Per Doctrine)

- ~~Custom categories~~ — generic expense tracker territory
- ~~Client/project profitability tracking~~ — different product
- ~~Budget goals~~ — banned concept
- ~~Savings buckets~~ — not in doctrine
- ~~AI smart insights~~ — hallucination risk
- ~~Subscription Leakage Radar~~ — not in doctrine scope

## Blocked

- None

## Done

> Completed sprint archive removed. See `docs/tracking/CURRENT_SPRINT.md` for full sprint history records.
