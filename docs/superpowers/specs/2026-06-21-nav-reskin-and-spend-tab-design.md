# Nav Reskin + Spend Tab — Design Spec

> **Status:** Approved design, pending written-spec review
> **Date:** 2026-06-21
> **Branch:** `paper-ledger-reskin`
> **Author:** Claude Code (senior implementation agent)
> **Scope:** Adopt the Helm design system in the bottom navigation, restructure the
> primary tabs, and add a doctrine-safe Spend tab. Net-new foundation widget
> (`HelmIcon`) + Phosphor adoption begins here.

---

## 1. Problem Statement

Two confirmed problems with the current 4-tab shell:

1. **Design-system adoption gap in the nav.** The shell uses Material 2
   `BottomNavigationBar`. Active state is a color change only. The Helm visual
   identity (VIS-024) mandates active tab = Phosphor outline icon turning
   `interactive` **plus** a 2pt × 18pt underline 4pt below the label. Icons are
   Material (`Icons.*`), but VIS-022 mandates Phosphor outline icons. The widget
   does not enforce the 56pt height (VIS-013) or doctrine-correct active treatment.

2. **Flow friction in tab structure.**
   - **Settings occupies a primary tab slot** (peer to Home), despite being a
     low-frequency configuration destination, not a daily workflow.
   - **History (audit log) occupies a primary tab slot**, despite being a trust
     feature surfaced occasionally — not a daily destination.

The user (Chief Architect) selected:
- 3-tab structure (not 2).
- Settings demoted out of the nav.
- History demoted out of the nav.
- Third tab = a **Spend / outflows** view that makes the Safe-to-Spend (S2S)
  number auditable from the outflow side.
- Icon strategy = **add `phosphor_flutter` and build the `HelmIcon` wrapper**
  (VIS-041) now, so the nav and all future icon work route through one
  doctrine-enforcing widget. (This selection is the Chief Architect's package
  approval per CLAUDE.md.)

---

## 2. Goals & Non-Goals

### Goals
- Replace `BottomNavigationBar` with a custom `HelmNavBar` that mechanically
  enforces VIS-013, VIS-024, VIS-033, VIS-034.
- Add `phosphor_flutter` and a `HelmIcon` wrapper (VIS-041, VIS-023).
- Restructure primary tabs to **Home · Pipeline · Spend**.
- Demote Settings → Dashboard app-bar gear icon (push overlay).
- Demote History → "View audit trail" secondary action inside Pipeline (push overlay).
- Add a doctrine-safe `SpendScreen` built on the existing transaction repository.
- Maintain quality gates: `dart analyze` 0/0/0, all tests green.

### Non-Goals (explicitly out of scope)
- Migrating the other 24 files from Material → Phosphor icons (separate app-wide effort).
- Redesigning Dashboard / Pipeline / Settings **internals** — only their entry points change.
- Changing the S2S calculation, transaction data model, or persistence.
- Building the 6 custom money-state icons (VISR-021) — Phosphor base only for now.
- Reskinning `AddTransactionScreen` (legacy "cash out" language, exposes `categoryId`)
  — filed as a follow-up (see §9).
- De-duplicating the `/settings` vs `/sts-settings` route overlap (pre-existing).

---

## 3. Current State (verified in code)

| Area | Finding |
|---|---|
| Shell | `_AppShell` in `app_router.dart` wraps 4 tabs via inline `BottomNavigationBar` |
| Tabs | Home (`/home`), Pipeline (`/pipeline`), History (`/trace`), Settings (`/settings`) |
| Icons | Material `Icons.*`; used across 24 files; no `HelmIcon` abstraction exists |
| Phosphor | **Not** a dependency in `pubspec.yaml` |
| Theme | `app_theme.dart` defines a `bottomNavigationBarTheme` block (becomes dead config) |
| Guards | `_identityRoutes` blocks guests from `/trace` + `/audit-log` |
| Spend data | `transactionsProvider` exposes `AsyncValue<List<TransactionEntity>>`; `TransactionType.{income, expense}`; entity carries `categoryId` (e.g. "Food", "Transport") |
| S2S link | `safe_to_spend_calculator.dart` consumes `transactions` and reduces S2S by expense totals — confirmed expenses feed S2S |
| Settings dup | `RouteNames.settings` (`/settings`) and `RouteNames.stsSettings` (`/sts-settings`) both resolve to `StsSettingsScreen` |

---

## 4. Design — Widgets

### 4.1 `HelmIcon` (new — `lib/core/widgets/helm_icon.dart`)

Doctrine-enforcing icon wrapper (VIS-041, VIS-023). The single way icons enter the
UI going forward.

```dart
enum HelmIconSize { sm, md, lg, xl } // 16 / 20 / 24 / 28 pt (VIS-023)

class HelmIcon extends StatelessWidget {
  const HelmIcon(this.icon, {this.size = HelmIconSize.md, this.color, super.key});
  final IconData icon;        // a PhosphorIcon (regular/outline weight)
  final HelmIconSize size;
  final Color? color;         // defaults to context.colors.inkPrimary
}
```

- Size enum resolves to pt value; color defaults to `context.colors.inkPrimary`.
- **Outline-only enforcement:** only the Phosphor *regular* (outline) weight is
  reachable through this API — filled variants are unreachable (VIS-022/VIS-024 rule 1).
- No intrinsic semantics label; callers wrap in `Semantics` where meaningful.

### 4.2 `HelmNavBar` (new — `lib/core/widgets/helm_nav_bar.dart`)

Replaces `BottomNavigationBar` inside `_AppShell`. Self-contained, ~120 lines.

```
┌─────────────────────────────────────────────┐
│   [icon]      [icon]        [icon]           │  ← 56pt + bottom safe inset
│   Home       Pipeline       Spend            │     canvas bg, 1pt top hairline
│  ──────                                       │  ← active: 2pt × 18pt interactive
└─────────────────────────────────────────────┘     underline, 4pt below label
```

API:
```dart
class HelmNavBar extends StatelessWidget {
  const HelmNavBar({required this.currentIndex, required this.onTap, super.key});
  final int currentIndex;
  final ValueChanged<int> onTap;
}
```

Per item (`Expanded` → `InkWell` → centered `Column`):
- **Active:** Phosphor icon `interactive` + label `labelSm` in `interactive`
  + 2pt × 18pt `interactive` underline 4pt below label (VIS-024 exactly).
- **Inactive:** icon + label in `inkTertiary`; no underline.
- Min 56pt height → 44×44 touch target met (VIS-033).
- `Semantics(button: true, selected: isActive, label: tab.label)` per item
  (VIS-034 rule 4 — no unlabeled icon button).

Tokens: `colors.canvas`, `colors.interactive`, `colors.inkTertiary`,
`colors.hairline`, `typography.labelSm`, `HelmSpacing` for offsets.

Icons (Phosphor regular, outline): `house` (Home), `arrowsDownUp` (Pipeline),
`wallet` (Spend). Final Spend-icon pick during implementation; must be outline.

---

## 5. Design — Shell & Routing (`app_router.dart`)

New `ShellRoute` children (3 tabs):

| Tab | Route | Screen | Change |
|---|---|---|---|
| Home | `/home` | `DashboardScreen` | route unchanged; app bar gains settings gear |
| Pipeline | `/pipeline` | `PipelineScreen` | route unchanged; gains "View audit trail" action |
| Spend | `/spend` | `SpendScreen` *(new)* | new route + new screen |

Demoted routes (leave the shell, stay registered + reachable):
- **`/settings`** — still a registered route (deep links / existing tests still
  work), no longer a shell tab. Reached via Dashboard app-bar gear →
  `context.push('/settings')` (overlay with back button, not a tab swap).
- **`/trace`** (History / `AuditLogScreen`) — still registered. Reached via
  Pipeline's "View audit trail" → `context.push('/trace')`.

Shell mechanics:
- `_tabs` const list shrinks from 4 → 3 entries; `IconData` entries become Phosphor.
- `debugAppShellTabLabels` updates automatically (used by tests).
- `_currentIndex` logic (`location.startsWith(t.path)`) unchanged; `/spend` does
  not collide with any existing prefix.
- `_AppShell.bottomNavigationBar` swaps to
  `HelmNavBar(currentIndex: _currentIndex, onTap: (i) => context.go(_tabs[i].path))`.
- Remove the now-dead `bottomNavigationBarTheme` block from `app_theme.dart`
  (avoids a misleading "two systems" signal).

Guard implications:
- `_identityRoutes` still lists `trace` + `auditLog`; the guard fires on
  navigation regardless of entry point — no guard change needed.
- **The "View audit trail" button must be hidden for guests** (read
  `SharedPrefServices.getGuestMode()` in Pipeline) so guests never tap into a redirect.

---

## 6. Design — Spend Tab (doctrine-safe)

`SpendScreen` (new — `lib/features/spend/presentation/views/spend_screen.dart`).
Reuses `transactionsProvider`, filtered to `TransactionType.expense`. **No new data layer.**

The Final Doctrine permanently kills generic expense tracking and categorization.
The existing transaction feature is flagged legacy (AR-P4) with `categoryId`
examples ("Food", "Transport") that are exactly the killed pattern. The Spend tab
must therefore be framed as **cashflow reality**, not a categorized ledger.

Framing rules (VISR-023, VISR-027, VIS kill list):
1. **Not "expenses" — "what you've spent that reduced Safe-to-Spend."** Title and
   copy frame outflows as cashflow reality, tied to the S2S number.
2. **Categories are NOT surfaced.** `categoryId` stays in data but the Spend tab
   does not show/filter/feature category chips. No "Food / Transport" breakdown.
3. **Rows use the design system:** `HelmLedgerCard` + `HelmAmount` (mono BDT) +
   date in `inkSecondary`. Title + amount + date only.
4. **Trust Strip at top** (VISR-013): e.g. "Total spent this month: ৳X — reduces
   your Safe-to-Spend." Ties every outflow back to the S2S number.
5. **Empty state teaches** (VISR-014): explains recording payments keeps S2S
   honest — not "no expenses yet."
6. **FAB** (VIS-021 rule 5): 56pt, `interactive`, outline "+", routes to existing
   `/add-transaction`. Label "Add a payment" (not "Add expense").

Explicitly NOT built: categorization UI, charts, budget bars, month-over-month
comparison, spending insights (all on the kill list).

Honesty caveat: tapping the FAB still lands on the legacy `AddTransactionScreen`
("cash out" language, exposes `categoryId`). Reskinning that form is out of scope
here and filed as a follow-up (§9).

---

## 7. Units & Boundaries

| Unit | Purpose | Depends on |
|---|---|---|
| `HelmIcon` | Outline-only, token-sized icon | `phosphor_flutter`, `HelmColors` |
| `HelmNavBar` | 3-tab nav with VIS-024 active state | `HelmIcon`, `HelmColors`, `HelmTypography`, `HelmSpacing` |
| `_AppShell` (edit) | Hosts `HelmNavBar`, owns `_tabs` (3) | `HelmNavBar`, router |
| `SpendScreen` | Outflow list, S2S-anchored | `transactionsProvider`, `HelmLedgerCard`, `HelmAmount`, `HelmTrustStrip` |
| Pipeline (edit) | Adds guest-gated "View audit trail" action | `SharedPrefServices`, router |
| Dashboard (edit) | Adds settings gear `IconButton` | `HelmIcon`, router |
| `app_theme.dart` (edit) | Remove dead `bottomNavigationBarTheme` | — |

Each unit is independently testable; the nav widgets hold no business logic.

---

## 8. Testing & Verification

Widget tests (new):
- `helm_icon_test.dart` — size enum → pt mapping; default color resolves to
  `inkPrimary`; outline weight only.
- `helm_nav_bar_test.dart` — renders 3 items; active shows underline + `interactive`;
  inactive shows `inkTertiary` + no underline; tap fires `onTap` with correct index;
  each item exposes `Semantics(button, selected, label)`; 56pt height + 44pt targets.
- `spend_screen_test.dart` — filters to expense type only; empty state teaches;
  Trust Strip renders total; FAB routes to `/add-transaction`; **no category chips
  rendered** (doctrine guard test).

Navigation/shell tests (update existing):
- `debugAppShellTabLabels` returns `[Home, Pipeline, Spend]` — update old 4-label asserts.
- Pipeline shows "View audit trail" for verified users, hidden for guests.
- Dashboard app bar exposes settings gear → pushes `/settings`.

Golden tests (project has golden infra):
- New: `HelmNavBar` active/inactive, light + dark.
- New: `SpendScreen` populated + empty, light + dark.
- Confirm the golden harness is green before adding baselines
  (`test/golden/failures/` currently untracked).

Quality gates (CLAUDE.md):
- `dart analyze` → 0/0/0.
- `flutter test` → all green.
- No `withOpacity` on text; no raw hex; no `BoxShadow`; files < 300 lines.
- After adding `phosphor_flutter`: `flutter pub get` + confirm build compiles
  before wiring icons.

---

## 9. Follow-Up Work (filed, not in this scope)

- **Reskin `AddTransactionScreen`** — replace legacy "cash out" language (UX-P5),
  align with Spend-tab framing ("Add a payment"), reconsider `categoryId` exposure
  per doctrine. To be recorded in `docs/tracking/TASKS.md`.
- **App-wide Phosphor migration** — migrate the remaining ~24 Material-icon files
  to `HelmIcon`/Phosphor.
- **Route de-duplication** — collapse `/settings` vs `/sts-settings`.

---

## 10. Doctrine & Design-System References

- VIS-013 (bottom nav 56pt), VIS-022 (Phosphor outline icons), VIS-023 (icon
  sizes), VIS-024 (active tab = color + underline, outline-only), VIS-033 (touch
  targets), VIS-034 (screen-reader labels), VIS-041 (critical custom widgets incl.
  `HelmIcon`).
- VISR-013 (Trust Strip), VISR-014 (teaching empty states), VISR-023 (local
  financial vocabulary), VISR-027 (real-vs-hopeful money test).
- Final Product Doctrine: generic expense tracking + categorization permanently killed.
- Audit findings: AR-P4 (legacy transaction feature), UX-P5 ("cash out" language).
