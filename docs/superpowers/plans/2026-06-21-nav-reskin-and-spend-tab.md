# Nav Reskin + Spend Tab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Material `BottomNavigationBar` with a design-system-correct `HelmNavBar`, restructure the primary tabs to Home·Pipeline·Spend, demote Settings and History out of the nav, and add a doctrine-safe Spend (outflows) tab.

**Architecture:** Add `lucide_icons_flutter` + a `HelmIcon` wrapper as the icon foundation. Build a self-contained `HelmNavBar` enforcing the VIS-024 color+underline active state. Rewire the existing `ShellRoute` in `app_router.dart` to 3 tabs. Settings becomes a Dashboard app-bar gear (push overlay); History becomes a guest-gated "View audit trail" action inside Pipeline. The new `SpendScreen` reuses the existing `transactionsProvider` filtered to expenses — no new data layer.

**Tech Stack:** Flutter (Dart ^3.7.2), Riverpod, GoRouter, Hive (hive_ce), `lucide_icons_flutter` (new), flutter gen-l10n (ARB).

## Global Constraints

- Use `fvm flutter` / `fvm dart` for all commands.
- `dart analyze` must be **0/0/0** (errors/warnings/infos) after every task.
- Use `context.colors` (HelmColors) and `context.textStyles` (HelmTypography) — never raw hex, never `Colors.black`/`Colors.white`.
- Use `withValues(alpha: x)` — never `withOpacity(x)`. No `withValues` on text colors (decorative only).
- No `BoxShadow`, no gradients, no spring/bounce curves.
- Guard all post-async navigation and `setState` with `mounted`.
- Keep every file under 300 lines.
- New user-facing strings are localized via ARB (en + bn) — no new English-only hardcoded copy.
- Spend tab copy MUST NOT use "expense"/"track expenses"/category language. Frame as money spent that reduces Safe-to-Spend. No category UI, charts, or budgets.
- Commit message format: `type(scope): description` (types: feat, fix, refactor, docs, chore, style). No attribution footer.
- Lucide icons are referenced via the `LucideIcons.*` (outline) constant set only — never filled/bold/duotone sets.

---

## File Structure

| File | Responsibility | Action |
|---|---|---|
| `pubspec.yaml` | Add `lucide_icons_flutter` dependency | Modify |
| `lib/core/widgets/helm_icon.dart` | Outline-only, token-sized icon wrapper | Create |
| `lib/core/widgets/helm_nav_bar.dart` | 3-tab bottom nav with VIS-024 active state | Create |
| `lib/config/router/route_names.dart` | Add `spend` route constant | Modify |
| `lib/features/spend/presentation/views/spend_screen.dart` | Outflow list, S2S-anchored | Create |
| `lib/config/router/app_router.dart` | Shell → 3 tabs, `HelmNavBar`, `/spend` route | Modify |
| `lib/core/themes/app_theme.dart` | Remove dead `bottomNavigationBarTheme` block | Modify |
| `lib/features/dashboard/presentation/views/dashboard_screen.dart` | Settings gear in app bar | Modify |
| `lib/features/income/presentation/views/pipeline_screen.dart` | Guest-gated "View audit trail" action | Modify |
| `lib/l10n/app_en.arb`, `lib/l10n/app_bn.arb` | Spend-tab strings | Modify |
| `test/core/widgets/helm_icon_test.dart` | HelmIcon behavior | Create |
| `test/core/widgets/helm_nav_bar_test.dart` | HelmNavBar behavior | Create |
| `test/features/spend/spend_screen_test.dart` | SpendScreen behavior + doctrine guard | Create |
| `test/config/router/app_shell_tabs_test.dart` | Tab labels (3) | Modify |
| `test/config/router/app_shell_signal_nav_test.dart` | Tab source assertions (Lucide, 3 tabs) | Modify |
| `test/features/dashboard/dashboard_settings_gear_test.dart` | Gear pushes /settings | Create |
| `test/features/income/pipeline_audit_link_test.dart` | Guest-gated audit link | Create |
| `test/golden/nav_bar_golden_test.dart` | HelmNavBar goldens | Create |
| `test/golden/spend_golden_test.dart` | SpendScreen goldens | Create |
| `docs/tracking/TASKS.md`, `docs/tracking/DECISION_LOG.md` | Follow-ups + decision record | Modify |

---

## Task 1: Add `lucide_icons_flutter` dependency

**Files:**
- Modify: `pubspec.yaml` (dependencies block, after `supabase_flutter`)
- Test: `test/core/widgets/lucide_smoke_test.dart`

**Interfaces:**
- Produces: `LucideIcons.house`, `LucideIcons.arrowUpDown`, `LucideIcons.wallet`, `LucideIcons.settings`, `LucideIcons.history` — all `IconData` from `package:lucide_icons_flutter/lucide_icons.dart`.

- [ ] **Step 1: Write the failing smoke test**

```dart
// test/core/widgets/lucide_smoke_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  test('lucide regular outline icons resolve to IconData', () {
    expect(LucideIcons.house, isA<IconData>());
    expect(LucideIcons.arrowUpDown, isA<IconData>());
    expect(LucideIcons.wallet, isA<IconData>());
    expect(LucideIcons.settings, isA<IconData>());
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/core/widgets/lucide_smoke_test.dart`
Expected: FAIL — compile error, `package:lucide_icons_flutter` not found.

- [ ] **Step 3: Add the dependency**

In `pubspec.yaml`, under `dependencies:`, add after the `supabase_flutter: ^2.15.0` line:

```yaml
  lucide_icons_flutter: ^3.1.14
```

- [ ] **Step 4: Resolve and verify**

Run: `fvm flutter pub get`
Expected: resolves successfully.
Run: `fvm flutter test test/core/widgets/lucide_smoke_test.dart`
Expected: PASS.
Run: `fvm dart analyze`
Expected: 0/0/0.

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock test/core/widgets/lucide_smoke_test.dart
git commit -m "chore(deps): add lucide_icons_flutter for design-system icons"
```

---

## Task 2: `HelmIcon` widget

**Files:**
- Create: `lib/core/widgets/helm_icon.dart`
- Test: `test/core/widgets/helm_icon_test.dart`

**Interfaces:**
- Consumes: `context.colors.inkPrimary` (HelmColors), `LucideIcons.*` (Task 1).
- Produces:
  - `enum HelmIconSize { sm, md, lg, xl }` → 16/20/24/28 pt
  - `class HelmIcon extends StatelessWidget` with `HelmIcon(IconData icon, {HelmIconSize size = HelmIconSize.md, Color? color})`
  - `double helmIconSizePt(HelmIconSize)` — exposed for tests.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/widgets/helm_icon_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/core/widgets/helm_icon.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  test('size enum maps to correct pt values', () {
    expect(helmIconSizePt(HelmIconSize.sm), 16);
    expect(helmIconSizePt(HelmIconSize.md), 20);
    expect(helmIconSizePt(HelmIconSize.lg), 24);
    expect(helmIconSizePt(HelmIconSize.xl), 28);
  });

  testWidgets('renders the given IconData at the resolved size', (tester) async {
    await tester.pumpWidget(
      _host(const HelmIcon(LucideIcons.house, size: HelmIconSize.lg)),
    );
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, LucideIcons.house);
    expect(icon.size, 24);
  });

  testWidgets('defaults color to inkPrimary when none provided', (tester) async {
    await tester.pumpWidget(_host(const HelmIcon(LucideIcons.settings)));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, AppTheme.light.extension<HelmColors>()!.inkPrimary);
  });
}
```

(Add `import 'package:helm/core/themes/helm_colors.dart';` to the test for `HelmColors`.)

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/core/widgets/helm_icon_test.dart`
Expected: FAIL — `helm_icon.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/widgets/helm_icon.dart
// VIS-041 / VIS-023 — Outline-only, token-sized icon wrapper.
// Single icon entry point for the app. Pass LucideIcons.* (outline) only.

import 'package:flutter/material.dart';

import 'package:helm/core/themes/helm_colors.dart';

/// Icon size tokens (VIS-023).
enum HelmIconSize { sm, md, lg, xl }

/// Resolves a [HelmIconSize] to its pt value.
double helmIconSizePt(HelmIconSize size) {
  switch (size) {
    case HelmIconSize.sm:
      return 16;
    case HelmIconSize.md:
      return 20;
    case HelmIconSize.lg:
      return 24;
    case HelmIconSize.xl:
      return 28;
  }
}

/// Outline-only icon. Always pass a `LucideIcons.*` constant.
class HelmIcon extends StatelessWidget {
  final IconData icon;
  final HelmIconSize size;
  final Color? color;

  const HelmIcon(
    this.icon, {
    super.key,
    this.size = HelmIconSize.md,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: helmIconSizePt(size),
      color: color ?? context.colors.inkPrimary,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/core/widgets/helm_icon_test.dart`
Expected: PASS.
Run: `fvm dart analyze`
Expected: 0/0/0.

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/helm_icon.dart test/core/widgets/helm_icon_test.dart
git commit -m "feat(widgets): add HelmIcon outline icon wrapper (VIS-041)"
```

---

## Task 3: `HelmNavBar` widget

**Files:**
- Create: `lib/core/widgets/helm_nav_bar.dart`
- Test: `test/core/widgets/helm_nav_bar_test.dart`

**Interfaces:**
- Consumes: `HelmIcon` (Task 2), `context.colors` (`canvas`, `interactive`, `inkTertiary`, `hairline`), `context.textStyles.labelSm`.
- Produces:
  - `class HelmNavItem { const HelmNavItem({required IconData icon, required String label}); }`
  - `class HelmNavBar extends StatelessWidget` with `HelmNavBar({required List<HelmNavItem> items, required int currentIndex, required ValueChanged<int> onTap})`
  - Active item underline rendered in a `Container(key: ValueKey('helm-nav-underline-$index'))`.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/widgets/helm_nav_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/widgets/helm_icon.dart';
import 'package:helm/core/widgets/helm_nav_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _items = [
  HelmNavItem(icon: LucideIcons.house, label: 'Home'),
  HelmNavItem(icon: LucideIcons.arrowUpDown, label: 'Pipeline'),
  HelmNavItem(icon: LucideIcons.wallet, label: 'Spend'),
];

Widget _host({required int index, required ValueChanged<int> onTap}) =>
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        bottomNavigationBar:
            HelmNavBar(items: _items, currentIndex: index, onTap: onTap),
      ),
    );

void main() {
  testWidgets('renders one HelmIcon and label per item', (tester) async {
    await tester.pumpWidget(_host(index: 0, onTap: (_) {}));
    expect(find.byType(HelmIcon), findsNWidgets(3));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Pipeline'), findsOneWidget);
    expect(find.text('Spend'), findsOneWidget);
  });

  testWidgets('active item shows underline; inactive items do not',
      (tester) async {
    await tester.pumpWidget(_host(index: 1, onTap: (_) {}));
    expect(find.byKey(const ValueKey('helm-nav-underline-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('helm-nav-underline-0')), findsNothing);
    expect(find.byKey(const ValueKey('helm-nav-underline-2')), findsNothing);
  });

  testWidgets('active icon uses interactive; inactive uses inkTertiary',
      (tester) async {
    await tester.pumpWidget(_host(index: 0, onTap: (_) {}));
    final colors = AppTheme.light.extension<HelmColors>()!;
    final homeIcon =
        tester.widget<HelmIcon>(find.byType(HelmIcon).at(0));
    final spendIcon =
        tester.widget<HelmIcon>(find.byType(HelmIcon).at(2));
    expect(homeIcon.color, colors.interactive);
    expect(spendIcon.color, colors.inkTertiary);
  });

  testWidgets('tapping an item fires onTap with its index', (tester) async {
    int tapped = -1;
    await tester.pumpWidget(_host(index: 0, onTap: (i) => tapped = i));
    await tester.tap(find.text('Spend'));
    expect(tapped, 2);
  });

  testWidgets('each item is a semantic selected/unselected button',
      (tester) async {
    await tester.pumpWidget(_host(index: 0, onTap: (_) {}));
    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.text('Home')),
      matchesSemantics(label: 'Home', isButton: true, isSelected: true),
    );
    handle.dispose();
  });

  testWidgets('nav bar is at least 56pt tall', (tester) async {
    await tester.pumpWidget(_host(index: 0, onTap: (_) {}));
    final size = tester.getSize(find.byType(HelmNavBar));
    expect(size.height, greaterThanOrEqualTo(56));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/core/widgets/helm_nav_bar_test.dart`
Expected: FAIL — `helm_nav_bar.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/widgets/helm_nav_bar.dart
// VIS-013 / VIS-024 / VIS-033 / VIS-034 — Custom bottom navigation.
// Active tab: interactive icon + label + 2pt × 18pt underline 4pt below label.
// Inactive tab: inkTertiary icon + label, no underline.

import 'package:flutter/material.dart';

import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/core/widgets/helm_icon.dart';

/// One destination in the [HelmNavBar].
class HelmNavItem {
  final IconData icon;
  final String label;
  const HelmNavItem({required this.icon, required this.label});
}

class HelmNavBar extends StatelessWidget {
  final List<HelmNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HelmNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.textStyles;

    return Material(
      color: colors.canvas,
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colors.hairline, width: 1),
            ),
          ),
          child: SizedBox(
            height: 56, // VIS-013
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavCell(
                      item: items[i],
                      index: i,
                      active: i == currentIndex,
                      activeColor: colors.interactive,
                      inactiveColor: colors.inkTertiary,
                      labelStyle: typography.labelSm,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  final HelmNavItem item;
  final int index;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final TextStyle labelStyle;
  final VoidCallback onTap;

  const _NavCell({
    required this.item,
    required this.index,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.labelStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;

    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            HelmIcon(item.icon, size: HelmIconSize.lg, color: color),
            const SizedBox(height: 2),
            Text(item.label, style: labelStyle.copyWith(color: color)),
            const SizedBox(height: 4), // VIS-024 underline gap
            if (active)
              Container(
                key: ValueKey('helm-nav-underline-$index'),
                width: 18,
                height: 2,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `fvm flutter test test/core/widgets/helm_nav_bar_test.dart`
Expected: PASS (all 6).
Run: `fvm dart analyze`
Expected: 0/0/0.

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/helm_nav_bar.dart test/core/widgets/helm_nav_bar_test.dart
git commit -m "feat(widgets): add HelmNavBar with VIS-024 underline active state"
```

---

## Task 4: Spend-tab localization strings

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_bn.arb`
- (No standalone test — verified via gen-l10n + Task 5 tests.)

**Interfaces:**
- Produces (on `AppLocalizations` via `context.l10n`): `spendTitle`, `spendSummaryLabel`, `spendEmptyTitle`, `spendEmptyBody`, `spendFabLabel`.

- [ ] **Step 1: Add keys to `app_en.arb`**

Insert before the final closing `}` (after the last existing key):

```json
,
  "spendTitle": "Spend",
  "@spendTitle": { "description": "Spend tab screen title" },
  "spendSummaryLabel": "Spent this month · reduces Safe-to-Spend",
  "@spendSummaryLabel": { "description": "Spend tab summary strip label" },
  "spendEmptyTitle": "Nothing spent yet",
  "@spendEmptyTitle": { "description": "Spend tab empty-state title" },
  "spendEmptyBody": "Record money you have already paid out. Each payment lowers your Safe-to-Spend so the number stays honest.",
  "@spendEmptyBody": { "description": "Spend tab empty-state teaching body" },
  "spendFabLabel": "Add a payment",
  "@spendFabLabel": { "description": "Spend tab add-payment FAB label" }
```

- [ ] **Step 2: Add the same keys to `app_bn.arb`** (authored Bangla, Latin numerals)

Insert before the final closing `}`:

```json
,
  "spendTitle": "খরচ",
  "spendSummaryLabel": "এই মাসে খরচ · Safe-to-Spend কমায়",
  "spendEmptyTitle": "এখনো কিছু খরচ হয়নি",
  "spendEmptyBody": "আপনি ইতিমধ্যে যে টাকা খরচ করেছেন তা যোগ করুন। প্রতিটি খরচ আপনার Safe-to-Spend কমায়, তাই সংখ্যাটি সঠিক থাকে।",
  "spendFabLabel": "খরচ যোগ করুন"
```

- [ ] **Step 3: Regenerate localizations**

Run: `fvm flutter gen-l10n`
Expected: regenerates `lib/l10n/app_localizations*.dart` with no errors.
Run: `fvm dart analyze`
Expected: 0/0/0.

- [ ] **Step 4: Commit**

```bash
git add lib/l10n/
git commit -m "feat(l10n): add Spend tab strings (en + bn)"
```

---

## Task 5: `SpendScreen` + `/spend` route name

**Files:**
- Modify: `lib/config/router/route_names.dart` (add `spend`)
- Create: `lib/features/spend/presentation/views/spend_screen.dart`
- Test: `test/features/spend/spend_screen_test.dart`

**Interfaces:**
- Consumes: `transactionsProvider` (`AsyncValue<List<TransactionEntity>>`), `TransactionType.expense`, `TransactionEntity` (`title`, `amount`, `date`), `HelmLedgerCard`, `HelmAmount` (`amount`, `currency: AmountCurrency.bdt`, `size: AmountSize.md`), `context.l10n`, `RouteNames.addTransaction`.
- Produces: `class SpendScreen extends ConsumerWidget`; `RouteNames.spend == '/spend'`.

- [ ] **Step 1: Add the route constant**

In `lib/config/router/route_names.dart`, in the shell-tabs section after `pipeline`:

```dart
  static const String spend = '/spend';
```

- [ ] **Step 2: Write the failing test**

```dart
// test/features/spend/spend_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/core/widgets/helm_amount.dart';
import 'package:helm/features/spend/presentation/views/spend_screen.dart';
import 'package:helm/features/transactions/domain/entities/transaction_entity.dart';
import 'package:helm/features/transactions/domain/entities/transaction_type.dart';
import 'package:helm/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:helm/l10n/app_localizations.dart';

Widget _app(List<TransactionEntity> txns) => ProviderScope(
      overrides: [
        transactionsProvider.overrideWith(
          (ref) => _StubNotifier(txns),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('bn')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SpendScreen(),
      ),
    );

class _StubNotifier extends TransactionsNotifier {
  _StubNotifier(List<TransactionEntity> txns) : super.test(txns);
}

TransactionEntity _tx(String id, double amt, TransactionType type) =>
    TransactionEntity(
      id: id,
      title: 'tx-$id',
      amount: amt,
      date: DateTime(2026, 6, 1),
      type: type,
    );

void main() {
  testWidgets('shows only expense transactions, not income', (tester) async {
    await tester.pumpWidget(_app([
      _tx('1', 500, TransactionType.expense),
      _tx('2', 999, TransactionType.income),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('tx-1'), findsOneWidget);
    expect(find.text('tx-2'), findsNothing);
  });

  testWidgets('teaches in the empty state', (tester) async {
    await tester.pumpWidget(_app([]));
    await tester.pumpAndSettle();
    expect(find.text('Nothing spent yet'), findsOneWidget);
    expect(find.textContaining('Safe-to-Spend'), findsWidgets);
  });

  testWidgets('renders a summary total amount', (tester) async {
    await tester.pumpWidget(_app([
      _tx('1', 500, TransactionType.expense),
      _tx('2', 300, TransactionType.expense),
    ]));
    await tester.pumpAndSettle();
    // Summary HelmAmount shows the 800 total.
    expect(find.byType(HelmAmount), findsWidgets);
    expect(find.text('Spent this month · reduces Safe-to-Spend'),
        findsOneWidget);
  });

  testWidgets('does not render category chips/labels (doctrine guard)',
      (tester) async {
    await tester.pumpWidget(_app([
      TransactionEntity(
        id: '1',
        title: 'tx-1',
        amount: 500,
        date: DateTime(2026, 6, 1),
        type: TransactionType.expense,
        categoryId: 'Food',
      ),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('Food'), findsNothing);
  });
}
```

> **Note for implementer:** `TransactionsNotifier` currently has only the default constructor that loads from the repository. Add a lightweight test constructor `TransactionsNotifier.test(List<TransactionEntity> seed)` that sets `state = AsyncValue.data(seed)` without touching the repository. See Step 3b.

- [ ] **Step 3a: Run test to verify it fails**

Run: `fvm flutter test test/features/spend/spend_screen_test.dart`
Expected: FAIL — `spend_screen.dart` and `TransactionsNotifier.test` do not exist.

- [ ] **Step 3b: Add the test constructor to `TransactionsNotifier`**

In `lib/features/transactions/presentation/providers/transaction_provider.dart`, add inside the class (after the default constructor):

```dart
  /// Test-only seed constructor — sets state directly, no repository load.
  @visibleForTesting
  TransactionsNotifier.test(List<TransactionEntity> seed)
      : _repository = _UnusedRepository(),
        super(AsyncValue.data(seed));
```

Add `import 'package:flutter/foundation.dart';` for `@visibleForTesting`, and a private no-op repository at the bottom of the file:

```dart
class _UnusedRepository implements TransactionRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('test stub repository');
}
```

> If the analyzer flags `noSuchMethod` typing, implement the repository's methods to throw `UnimplementedError` instead. Keep the file under 300 lines.

- [ ] **Step 3c: Write the `SpendScreen` implementation**

```dart
// lib/features/spend/presentation/views/spend_screen.dart
// Spend tab — outflows that reduce Safe-to-Spend.
// NOT an expense tracker: no categories, no charts, no budgets (Final Doctrine).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:helm/config/router/route_names.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_spacing.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/core/widgets/helm_amount.dart';
import 'package:helm/core/widgets/helm_icon.dart';
import 'package:helm/core/widgets/cards/helm_ledger_card.dart';
import 'package:helm/features/transactions/domain/entities/transaction_entity.dart';
import 'package:helm/features/transactions/domain/entities/transaction_type.dart';
import 'package:helm/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:helm/l10n/app_localization.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SpendScreen extends ConsumerWidget {
  const SpendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.textStyles;
    final l10n = context.l10n;
    final async = ref.watch(transactionsProvider);

    final expenses = (async.valueOrNull ?? const <TransactionEntity>[])
        .where((t) => t.type == TransactionType.expense)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final total =
        expenses.fold<double>(0, (sum, t) => sum + t.amount);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: Text(l10n.spendTitle,
            style: typo.headingMd.copyWith(color: colors.inkPrimary)),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.addTransaction),
        backgroundColor: colors.interactive,
        foregroundColor: colors.surface,
        elevation: 0,
        tooltip: l10n.spendFabLabel,
        child: const HelmIcon(LucideIcons.plus,
            size: HelmIconSize.lg, color: Colors.white),
      ),
      body: SafeArea(
        child: expenses.isEmpty
            ? _Empty(l10n: l10n, typo: typo, colors: colors)
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  HelmSpacing.screenEdge,
                  HelmSpacing.s4,
                  HelmSpacing.screenEdge,
                  100,
                ),
                children: [
                  _SummaryStrip(total: total, l10n: l10n, typo: typo,
                      colors: colors),
                  const SizedBox(height: HelmSpacing.s4),
                  for (final t in expenses) ...[
                    HelmLedgerCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(t.title,
                                style: typo.bodyMd
                                    .copyWith(color: colors.inkPrimary)),
                          ),
                          HelmAmount(amount: t.amount, size: AmountSize.md),
                        ],
                      ),
                    ),
                    const SizedBox(height: HelmSpacing.s3),
                  ],
                ],
              ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  final double total;
  final AppLocalizations l10n;
  final HelmTypography typo;
  final HelmColors colors;
  const _SummaryStrip(
      {required this.total,
      required this.l10n,
      required this.typo,
      required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(l10n.spendSummaryLabel,
              style: typo.labelSm.copyWith(color: colors.inkSecondary)),
        ),
        HelmAmount(amount: total, size: AmountSize.md),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  final AppLocalizations l10n;
  final HelmTypography typo;
  final HelmColors colors;
  const _Empty({required this.l10n, required this.typo, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(HelmSpacing.screenEdge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.spendEmptyTitle,
                style: typo.headingSm.copyWith(color: colors.inkPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: HelmSpacing.s3),
            Text(l10n.spendEmptyBody,
                style: typo.bodyMd.copyWith(color: colors.inkSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
```

> **Implementer note:** confirm `HelmColors`/`HelmTypography` are exported by the imports above (`helm_colors.dart`, `helm_typography.dart`). If `Colors.white` on the FAB icon trips a lint, use `colors.surface` instead.

- [ ] **Step 4: Run tests to verify they pass**

Run: `fvm flutter test test/features/spend/spend_screen_test.dart`
Expected: PASS (all 4).
Run: `fvm dart analyze`
Expected: 0/0/0.

- [ ] **Step 5: Commit**

```bash
git add lib/config/router/route_names.dart lib/features/spend/ lib/features/transactions/presentation/providers/transaction_provider.dart test/features/spend/
git commit -m "feat(spend): add doctrine-safe Spend tab (outflows that reduce S2S)"
```

---

## Task 6: Shell restructure — 3 tabs + HelmNavBar

**Files:**
- Modify: `lib/config/router/app_router.dart` (`_tabs`, `_AppShell`, `ShellRoute` children)
- Modify: `lib/core/themes/app_theme.dart` (remove dead `bottomNavigationBarTheme`)
- Modify: `test/config/router/app_shell_tabs_test.dart`
- Modify: `test/config/router/app_shell_signal_nav_test.dart`

**Interfaces:**
- Consumes: `HelmNavBar`, `HelmNavItem` (Task 3), `SpendScreen` + `RouteNames.spend` (Task 5), `LucideIcons.*`.
- Produces: `debugAppShellTabLabels == ['Home', 'Pipeline', 'Spend']`; `/spend` shell route → `SpendScreen`.

- [ ] **Step 1: Update the tab-label test**

Replace the body of `test/config/router/app_shell_tabs_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:helm/config/router/app_router.dart' show debugAppShellTabLabels;

void main() {
  test('bottom nav has the three primary tabs in order', () {
    expect(debugAppShellTabLabels, equals(['Home', 'Pipeline', 'Spend']));
  });
}
```

- [ ] **Step 2: Rewrite the source-asserting nav test**

Replace the body of `test/config/router/app_shell_signal_nav_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:helm/config/router/route_names.dart';

void main() {
  test('shell exposes Home Pipeline Spend tabs with Lucide icons', () {
    expect(RouteNames.home, equals('/home'));
    expect(RouteNames.pipeline, equals('/pipeline'));
    expect(RouteNames.spend, equals('/spend'));

    final source = File('lib/config/router/app_router.dart').readAsStringSync();
    final tabsStart = source.indexOf('const List<_TabItem> _tabs = [');
    final tabsSource =
        source.substring(tabsStart, source.indexOf('];', tabsStart));

    expect(tabsSource, contains('RouteNames.home'));
    expect(tabsSource, contains("label: 'Home'"));
    expect(tabsSource, contains('LucideIcons.house'));

    expect(tabsSource, contains('RouteNames.pipeline'));
    expect(tabsSource, contains("label: 'Pipeline'"));
    expect(tabsSource, contains('LucideIcons.arrowUpDown'));

    expect(tabsSource, contains('RouteNames.spend'));
    expect(tabsSource, contains("label: 'Spend'"));
    expect(tabsSource, contains('LucideIcons.wallet'));

    // History and Settings are no longer primary tabs.
    expect(tabsSource, isNot(contains('RouteNames.trace')));
    expect(tabsSource, isNot(contains('RouteNames.settings')));
  });
}
```

- [ ] **Step 3: Run both tests to verify they fail**

Run: `fvm flutter test test/config/router/`
Expected: FAIL — old `_tabs` still has 4 entries / Material icons.

- [ ] **Step 4: Update `_tabs` and imports in `app_router.dart`**

Add imports near the top:

```dart
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:helm/core/widgets/helm_nav_bar.dart';
import 'package:helm/features/spend/presentation/views/spend_screen.dart';
```

Replace the entire `const List<_TabItem> _tabs = [ ... ];` block with:

```dart
const List<_TabItem> _tabs = [
  _TabItem(
    path: RouteNames.home,
    icon: LucideIcons.house,
    label: 'Home',
    tooltip: 'Safe-to-Spend',
  ),
  _TabItem(
    path: RouteNames.pipeline,
    icon: LucideIcons.arrowUpDown,
    label: 'Pipeline',
    tooltip: 'Income pipeline',
  ),
  _TabItem(
    path: RouteNames.spend,
    icon: LucideIcons.wallet,
    label: 'Spend',
    tooltip: 'Money spent',
  ),
];
```

- [ ] **Step 5: Replace the `ShellRoute` children**

In the `ShellRoute(... routes: [ ... ])`, replace the four child `GoRoute`s (home, pipeline, trace, settings) with three:

```dart
        GoRoute(
          path: RouteNames.home,
          name: 'home',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.pipeline,
          name: 'pipeline',
          builder: (context, state) => const PipelineScreen(),
        ),
        GoRoute(
          path: RouteNames.spend,
          name: 'spend',
          builder: (context, state) => const SpendScreen(),
        ),
```

> Leave the **standalone** `/trace`, `/audit-log`, `/settings`, `/sts-settings` routes (outside the shell) exactly as they are — they stay reachable via push.

- [ ] **Step 6: Swap the nav widget in `_AppShell.build`**

Replace the `bottomNavigationBar: BottomNavigationBar( ... )` block with:

```dart
      bottomNavigationBar: HelmNavBar(
        items: _tabs
            .map((t) => HelmNavItem(icon: t.icon, label: t.label))
            .toList(growable: false),
        currentIndex: _currentIndex,
        onTap: (i) => context.go(_tabs[i].path),
      ),
```

Remove the now-unused `colors`/`typography` locals in `build` if the analyzer flags them, and drop the unused `helm_typography.dart` import if no longer referenced.

- [ ] **Step 7: Remove the dead theme block**

In `lib/core/themes/app_theme.dart`, delete the entire `bottomNavigationBarTheme: BottomNavigationBarThemeData( ... ),` block.

- [ ] **Step 8: Run tests + analyze**

Run: `fvm flutter test test/config/router/`
Expected: PASS.
Run: `fvm dart analyze`
Expected: 0/0/0.

- [ ] **Step 9: Commit**

```bash
git add lib/config/router/app_router.dart lib/core/themes/app_theme.dart test/config/router/
git commit -m "feat(nav): restructure shell to Home/Pipeline/Spend with HelmNavBar"
```

---

## Task 7: Dashboard settings gear

**Files:**
- Modify: `lib/features/dashboard/presentation/views/dashboard_screen.dart` (AppBar `actions`)
- Test: `test/features/dashboard/dashboard_settings_gear_test.dart`

**Interfaces:**
- Consumes: `HelmIcon`, `LucideIcons.settings`, `RouteNames.settings`, `context.push`.
- Produces: an `IconButton` keyed `ValueKey('dashboard-settings-gear')` that pushes `/settings`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/dashboard/dashboard_settings_gear_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('dashboard source pushes /settings from a gear action', () {
    final src = File(
      'lib/features/dashboard/presentation/views/dashboard_screen.dart',
    ).readAsStringSync();
    expect(src, contains("ValueKey('dashboard-settings-gear')"));
    expect(src, contains('LucideIcons.settings'));
    expect(src, contains('RouteNames.settings'));
  });
}
```

Add `import 'dart:io';` at the top.

> **Why a source test:** `DashboardScreen.initState` wires analytics, nudges, and stopwatch concerns (AR-P1) that are painful to host in a widget test. A source assertion is the proportional check for this small entry-point addition. (A full widget-level nav test is deferred with the AR-P1 cleanup.)

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/dashboard/dashboard_settings_gear_test.dart`
Expected: FAIL — markers absent.

- [ ] **Step 3: Add the gear action**

In `dashboard_screen.dart`, ensure imports include:

```dart
import 'package:helm/core/widgets/helm_icon.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
```

(`RouteNames` and `go_router` are already imported.) In the `AppBar(actions: [ ... ])`, add as the first action (before the `if (kDebugMode)` block):

```dart
          IconButton(
            key: const ValueKey('dashboard-settings-gear'),
            tooltip: context.l10n.settingsTitle,
            icon: const HelmIcon(LucideIcons.settings,
                size: HelmIconSize.lg),
            onPressed: () => context.push(RouteNames.settings),
          ),
```

> If `context.l10n.settingsTitle` does not exist, use a literal `'Settings'` tooltip (matches the existing hardcoded-tooltip pattern in this file).

- [ ] **Step 4: Run test + analyze**

Run: `fvm flutter test test/features/dashboard/dashboard_settings_gear_test.dart`
Expected: PASS.
Run: `fvm dart analyze`
Expected: 0/0/0.

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard/presentation/views/dashboard_screen.dart test/features/dashboard/dashboard_settings_gear_test.dart
git commit -m "feat(dashboard): add settings gear to app bar (Settings demoted from nav)"
```

---

## Task 8: Pipeline guest-gated "View audit trail" action

**Files:**
- Modify: `lib/features/income/presentation/views/pipeline_screen.dart` (AppBar `actions`)
- Test: `test/features/income/pipeline_audit_link_test.dart`

**Interfaces:**
- Consumes: `SharedPrefServices.getGuestMode()`, `HelmIcon`, `LucideIcons.history`, `RouteNames.trace`, `context.push`.
- Produces: an audit `IconButton` keyed `ValueKey('pipeline-audit-link')`, rendered only when `getGuestMode()` is false.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/income/pipeline_audit_link_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pipeline gates the audit-trail link behind non-guest mode', () {
    final src = File(
      'lib/features/income/presentation/views/pipeline_screen.dart',
    ).readAsStringSync();
    expect(src, contains("ValueKey('pipeline-audit-link')"));
    expect(src, contains('SharedPrefServices.getGuestMode()'));
    expect(src, contains('RouteNames.trace'));
    expect(src, contains('LucideIcons.history'));
  });
}
```

> **Why a source test:** `PipelineScreen` partitions live income state from `incomeNotifierProvider` and requires a seeded Hive + Riverpod harness to render. The guest-gating logic is a single conditional on a static flag; a source assertion verifies both the flag check and the route without standing up the full provider graph. A behavioral guest/non-guest widget test can follow when the income provider gains a test seed constructor (tracked follow-up).

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/income/pipeline_audit_link_test.dart`
Expected: FAIL — markers absent.

- [ ] **Step 3: Add the gated action**

In `pipeline_screen.dart`, add imports:

```dart
import 'package:helm/core/local_storage/shared_pref_service.dart';
import 'package:helm/core/widgets/helm_icon.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
```

(`go_router` and `RouteNames` are already imported.) In the `AppBar(...)`, add an `actions:` list (or extend the existing one) with:

```dart
        actions: [
          if (!SharedPrefServices.getGuestMode())
            IconButton(
              key: const ValueKey('pipeline-audit-link'),
              tooltip: l10n.historyTitle,
              icon: const HelmIcon(LucideIcons.history,
                  size: HelmIconSize.lg),
              onPressed: () => context.push(RouteNames.trace),
            ),
        ],
```

> If `l10n.historyTitle` does not exist, use a literal `'View audit trail'` tooltip.

- [ ] **Step 4: Run test + analyze**

Run: `fvm flutter test test/features/income/pipeline_audit_link_test.dart`
Expected: PASS.
Run: `fvm dart analyze`
Expected: 0/0/0.

- [ ] **Step 5: Commit**

```bash
git add lib/features/income/presentation/views/pipeline_screen.dart test/features/income/pipeline_audit_link_test.dart
git commit -m "feat(pipeline): add guest-gated View audit trail action (History demoted from nav)"
```

---

## Task 9: Golden tests — HelmNavBar + SpendScreen

**Files:**
- Create: `test/golden/nav_bar_golden_test.dart`
- Create: `test/golden/spend_golden_test.dart`
- Create: baseline PNGs under `test/golden/goldens/`

**Interfaces:**
- Consumes: `HelmNavBar`/`HelmNavItem`, `SpendScreen` + `transactionsProvider.overrideWith` + `TransactionsNotifier.test` (Task 5), `AppTheme.light`/`dark`.

- [ ] **Step 1: Confirm the existing golden harness is green**

Run: `fvm flutter test test/golden/ --tags golden`
Expected: existing dashboard + history goldens PASS (baseline sanity before adding new ones). If they fail due to pre-existing drift, stop and report — do not mask it with new baselines.

- [ ] **Step 2: Write the nav-bar golden test**

```dart
// test/golden/nav_bar_golden_test.dart
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/core/widgets/helm_nav_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _items = [
  HelmNavItem(icon: LucideIcons.house, label: 'Home'),
  HelmNavItem(icon: LucideIcons.arrowUpDown, label: 'Pipeline'),
  HelmNavItem(icon: LucideIcons.wallet, label: 'Spend'),
];

Widget _app(ThemeData theme) => MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp(
        theme: theme,
        home: Scaffold(
          bottomNavigationBar:
              HelmNavBar(items: _items, currentIndex: 1, onTap: (_) {}),
        ),
      ),
    );

void main() {
  testWidgets('nav bar light golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(AppTheme.light));
    await tester.pumpAndSettle();
    await expectLater(find.byType(HelmNavBar),
        matchesGoldenFile('goldens/nav_bar_light.png'));
  });

  testWidgets('nav bar dark golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(AppTheme.dark));
    await tester.pumpAndSettle();
    await expectLater(find.byType(HelmNavBar),
        matchesGoldenFile('goldens/nav_bar_dark.png'));
  });
}
```

- [ ] **Step 3: Write the Spend golden test**

```dart
// test/golden/spend_golden_test.dart
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/features/spend/presentation/views/spend_screen.dart';
import 'package:helm/features/transactions/domain/entities/transaction_entity.dart';
import 'package:helm/features/transactions/domain/entities/transaction_type.dart';
import 'package:helm/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:helm/l10n/app_localizations.dart';

List<TransactionEntity> _seed() => [
      TransactionEntity(
          id: '1', title: 'Office rent', amount: 12000,
          date: DateTime(2026, 6, 1), type: TransactionType.expense),
      TransactionEntity(
          id: '2', title: 'Internet', amount: 1500,
          date: DateTime(2026, 6, 3), type: TransactionType.expense),
    ];

Widget _app(ThemeData theme, List<TransactionEntity> txns) => ProviderScope(
      overrides: [
        transactionsProvider.overrideWith((ref) => TransactionsNotifier.test(txns)),
      ],
      child: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: theme,
          locale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('bn')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SpendScreen(),
        ),
      ),
    );

void main() {
  testWidgets('spend populated light golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(AppTheme.light, _seed()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(SpendScreen),
        matchesGoldenFile('goldens/spend_light.png'));
  });

  testWidgets('spend empty dark golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(AppTheme.dark, const []));
    await tester.pumpAndSettle();
    await expectLater(find.byType(SpendScreen),
        matchesGoldenFile('goldens/spend_empty_dark.png'));
  });
}
```

- [ ] **Step 4: Generate baselines**

Run: `fvm flutter test test/golden/nav_bar_golden_test.dart test/golden/spend_golden_test.dart --update-goldens --tags golden`
Expected: creates `test/golden/goldens/nav_bar_light.png`, `nav_bar_dark.png`, `spend_light.png`, `spend_empty_dark.png`.

- [ ] **Step 5: Verify baselines match**

Run: `fvm flutter test test/golden/nav_bar_golden_test.dart test/golden/spend_golden_test.dart --tags golden`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add test/golden/nav_bar_golden_test.dart test/golden/spend_golden_test.dart test/golden/goldens/
git commit -m "test(golden): add HelmNavBar + SpendScreen baselines (light + dark)"
```

---

## Task 10: Full suite + tracking docs

**Files:**
- Modify: `docs/tracking/TASKS.md` (follow-ups)
- Modify: `docs/tracking/DECISION_LOG.md` (decision record)

- [ ] **Step 1: Run the entire test suite (excluding goldens for CI parity)**

Run: `fvm flutter test --exclude-tags golden`
Expected: all PASS. Fix any tests that asserted the old 4-tab structure beyond the two already updated (search: `grep -rn "History" test/ | grep -i tab`).

- [ ] **Step 2: Run goldens locally**

Run: `fvm flutter test --tags golden`
Expected: all PASS.

- [ ] **Step 3: Final analyze**

Run: `fvm dart analyze`
Expected: 0/0/0.

- [ ] **Step 4: Record follow-ups in `docs/tracking/TASKS.md`**

Append under the appropriate backlog/section:

```markdown
### Nav Reskin — Follow-ups (filed 2026-06-21)
- [ ] Reskin `AddTransactionScreen` — replace legacy "cash out" language (UX-P5), align to Spend framing ("Add a payment"), reconsider `categoryId` exposure per Final Doctrine.
- [ ] App-wide Lucide migration — migrate remaining ~24 Material-icon files to `HelmIcon`/`LucideIcons`.
- [ ] Route de-duplication — collapse `/settings` vs `/sts-settings`.
- [ ] Behavioral widget tests for Dashboard gear + Pipeline audit link once Dashboard initState (AR-P1) and income provider gain test seams.
```

- [ ] **Step 5: Record the decision in `docs/tracking/DECISION_LOG.md`**

Append a new decision entry (match the existing numbering/format in that file):

```markdown
## Decision 042 — Nav restructure to Home/Pipeline/Spend + HelmNavBar (2026-06-21)

**Context:** 4-tab Material `BottomNavigationBar` did not adopt VIS-024 (color+underline active state) or VIS-022 (Lucide outline icons). Settings and History occupied primary tab slots despite low daily frequency.

**Decision:** 3 primary tabs (Home, Pipeline, Spend) via custom `HelmNavBar` + `HelmIcon`. Settings → Dashboard app-bar gear (push). History → guest-gated Pipeline action (push). Added `lucide_icons_flutter`. New Spend tab reuses the transaction repository, framed as outflows that reduce Safe-to-Spend — NOT an expense tracker (no categories/charts/budgets), per Final Doctrine.

**Scope guard:** `AddTransactionScreen` internals, app-wide Lucide migration, and `/settings` vs `/sts-settings` de-dup are filed as follow-ups (TASKS.md), not in this change.
```

- [ ] **Step 6: Commit**

```bash
git add docs/tracking/TASKS.md docs/tracking/DECISION_LOG.md
git commit -m "docs(tracking): record Decision 042 (nav restructure) + nav follow-ups"
```

---

## Self-Review Notes (already applied)

- **Spec coverage:** §4.1 HelmIcon → T2; §4.2 HelmNavBar → T3; §5 routing/shell → T6; §5 dead theme → T6/S7; §5 guest gating → T8; §6 SpendScreen → T4+T5; §8 tests → T2/T3/T5/T6/T7/T8/T9; §9 follow-ups → T10. Lucide dep → T1.
- **Adjustment from spec:** §6 item 4 said "Trust Strip (VISR-013)". `HelmTrustStrip` is timestamp/l10n-driven and cannot render arbitrary summary text, so the Spend summary uses trust-strip *styling* (`labelSm`/`inkSecondary`) via `_SummaryStrip` instead of that widget. Documented here intentionally.
- **Type consistency:** `transactionsProvider`, `TransactionsNotifier.test`, `HelmNavItem`, `HelmIconSize`, `RouteNames.spend`, `helmIconSizePt` used identically across tasks.
- **Source-assertion tests (T7/T8):** chosen deliberately for entry-point additions on screens with heavy provider/initState setup; behavioral follow-ups filed in T10.
```
