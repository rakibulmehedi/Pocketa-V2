# Task 6 Report — Shell restructure: 3 tabs + HelmNavBar

## STATUS: DONE

## Files Modified
- `lib/config/router/app_router.dart` — replaced 4-tab shell with 3-tab (Home/Pipeline/Spend), swapped BottomNavigationBar → HelmNavBar, replaced Material icons with LucideIcons, added imports for lucide_icons_flutter/HelmNavBar/SpendScreen, removed unused helm_colors + helm_typography imports
- `lib/core/themes/app_theme.dart` — removed dead `bottomNavigationBarTheme` block
- `test/config/router/app_shell_tabs_test.dart` — rewritten to assert `['Home', 'Pipeline', 'Spend']`
- `test/config/router/app_shell_signal_nav_test.dart` — rewritten to assert Lucide icons + absence of trace/settings tabs

## Test Results
`fvm flutter test test/config/router/` → 3/3 passed (app_shell_signal_nav_test, app_shell_tabs_test, income_route_removed_test)

## Analyze
`fvm dart analyze lib/ test/` → No issues found (0/0/0)

## Commit
`9f09610` feat(nav): restructure shell to Home/Pipeline/Spend with HelmNavBar

## Concerns
None. The standalone `/trace`, `/audit-log`, `/settings`, `/sts-settings` routes outside the shell were left untouched. `_identityRoutes` guard logic unchanged.
