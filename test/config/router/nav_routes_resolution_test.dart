import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:helm/config/router/app_router.dart' show appRouter;
import 'package:helm/config/router/route_names.dart';

/// Flattens the router tree (GoRoute + ShellRoute children) into GoRoutes.
List<GoRoute> _allGoRoutes(List<RouteBase> routes) {
  final result = <GoRoute>[];
  for (final r in routes) {
    if (r is GoRoute) result.add(r);
    result.addAll(_allGoRoutes(r.routes));
  }
  return result;
}

void main() {
  late List<String> registeredPaths;

  setUp(() {
    registeredPaths =
        _allGoRoutes(appRouter.configuration.routes).map((r) => r.path).toList();
  });

  test('/settings push-overlay route is registered', () {
    expect(registeredPaths, contains(RouteNames.settings),
        reason: 'Dashboard gear and notification-centre push RouteNames.settings; '
            'it must resolve to StsSettingsScreen.');
  });

  test('/trace push-overlay route is registered', () {
    expect(registeredPaths, contains(RouteNames.trace),
        reason: 'Pipeline audit link and _identityRoutes guest-gating '
            'both reference RouteNames.trace; it must resolve to AuditLogScreen.');
  });

  test('/spend shell tab route is registered', () {
    expect(registeredPaths, contains(RouteNames.spend),
        reason: 'Third shell tab (Spend) must have a registered GoRoute.');
  });
}
