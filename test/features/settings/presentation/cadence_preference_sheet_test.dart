// test/features/settings/presentation/cadence_preference_sheet_test.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:helm/core/constants/app_box_names.dart';
import 'package:helm/core/themes/app_theme.dart';
import 'package:helm/core/analytics/data/models/nudge_preferences_model.dart';
import 'package:helm/features/settings/presentation/views/cadence_preference_sheet.dart';
import 'package:helm/l10n/app_localization.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(NudgePreferencesModelAdapter());
    }
    await Hive.openBox<NudgePreferencesModel>(AppBoxNames.nudgePreferencesBox);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Widget buildTestableWidget() {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: const CadencePreferenceSheet(),
        ),
      ),
    );
  }

  group('CadencePreferenceSheet UI/Widget Tests', () {
    testWidgets('renders preferences sheet with default state', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Notification Preferences'), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Silent'), findsOneWidget);

      // L-11: Default is Weekly, so check-in time is NOT visible until user selects Daily.
      expect(find.textContaining('9:00 AM'), findsNothing);

      // Verify channel switches are present and true by default
      final pushSwitch = tester.widget<Switch>(find.byType(Switch).at(0));
      final inAppSwitch = tester.widget<Switch>(find.byType(Switch).at(1));
      final quietSwitch = tester.widget<Switch>(find.byType(Switch).at(2));

      expect(pushSwitch.value, isTrue);
      expect(inAppSwitch.value, isTrue);
      expect(quietSwitch.value, isTrue);
    });

    testWidgets('switching cadence updates UI view state', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget());

      // L-11: Weekly is selected by default, check-in time is NOT shown.
      expect(find.textContaining('9:00 AM'), findsNothing);

      // Switch to Daily — check-in time becomes visible.
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();
      expect(find.textContaining('9:00 AM'), findsOneWidget);

      // Switch to Weekly — check-in time is hidden again.
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();
      expect(find.textContaining('9:00 AM'), findsNothing);

      // Switch to Silent — check-in time remains hidden.
      await tester.tap(find.text('Silent'));
      await tester.pumpAndSettle();

      expect(find.textContaining('9:00 AM'), findsNothing);
    });

    testWidgets('toggling switches updates UI', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget());

      // Toggle off Push notifications
      await tester.tap(find.text('Push notifications'));
      await tester.pumpAndSettle();

      // Verify the switch state is updated in the UI
      final pushSwitch = tester.widget<Switch>(find.byType(Switch).at(0));
      expect(pushSwitch.value, isFalse);

      // Verify in-app and quiet remain true
      final inAppSwitch = tester.widget<Switch>(find.byType(Switch).at(1));
      final quietSwitch = tester.widget<Switch>(find.byType(Switch).at(2));
      expect(inAppSwitch.value, isTrue);
      expect(quietSwitch.value, isTrue);
    });

    testWidgets('opens time picker when checking daily and select time', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget());

      // L-11: Default is Weekly — must switch to Daily first to reveal the time picker.
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();

      // Tap the time selector to open time picker
      await tester.tap(find.byIcon(Icons.access_time_rounded));
      await tester.pumpAndSettle();

      // Verify time picker dialog is shown
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });
  });
}
