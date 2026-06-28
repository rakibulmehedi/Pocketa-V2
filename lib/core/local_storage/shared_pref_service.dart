// lib/core/local_storage/shared_pref_service.dart

import 'package:helm/core/constants/app_language.dart';
import 'package:helm/core/utils/input_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefServices {
  static SharedPreferences? _prefs;

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw StateError(
        'SharedPrefServices has not been initialized. '
        'Call SharedPrefServices.init() before any read/write.',
      );
    }
    return _prefs!;
  }

  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _userCurrencyKey = 'user_currency';
  static const String _userLanguageKey = 'user_language';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setUserLanguage(AppLanguage language) async {
    await _instance.setString(_userLanguageKey, language.name);
  }

  static String? getUserLanguageCode() {
    return _instance.getString(_userLanguageKey) ?? 'en';
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    await _instance.setBool(_onboardingCompletedKey, completed);
  }

  static bool getOnboardingCompleted() {
    return _instance.getBool(_onboardingCompletedKey) ?? false;
  }

  static Future<void> setIsDarkMode(bool isDarkMode) async {
    await _instance.setBool(_isDarkModeKey, isDarkMode);
  }

  static bool getIsDarkMode() {
    return _instance.getBool(_isDarkModeKey) ?? false;
  }

  static Future<void> setUserCurrency(String currency) async {
    await _instance.setString(_userCurrencyKey, currency);
  }

  static String getUserCurrency() {
    return _instance.getString(_userCurrencyKey) ?? 'BDT';
  }

  static Future<void> remove(String key) async {
    await _instance.remove(key);
  }

  // ── S2S hint ─────────────────────────────────────────────────────────────
  static const String _stsHintShownKey = 'sts_hint_shown';

  static bool getStsHintShown() {
    return _instance.getBool(_stsHintShownKey) ?? false;
  }

  static Future<void> setStsHintShown(bool shown) async {
    await _instance.setBool(_stsHintShownKey, shown);
  }

  static const String _liquidBalanceBdtKey = 'liquid_balance_bdt';
  static const String _incomePatternKey = 'income_pattern';

  static const String _sessionCountKey = 'session_count';
  static const String _trackingStreakKey = 'tracking_streak';
  static const String _lastActiveDateKey = 'last_active_date';

  static Future<void> setLiquidBalanceBdt(double amount) async {
    await _instance.setDouble(_liquidBalanceBdtKey, amount);
  }

  static double getLiquidBalanceBdt() {
    return _instance.getDouble(_liquidBalanceBdtKey) ?? 0.0;
  }

  static Future<void> setIncomePattern(String pattern) async {
    await _instance.setString(_incomePatternKey, pattern);
  }

  static String getIncomePattern() {
    return _instance.getString(_incomePatternKey) ?? 'marketplace';
  }

  static int getSessionCount() {
    return _instance.getInt(_sessionCountKey) ?? 0;
  }

  static Future<void> incrementSessionCount() async {
    // SharedPreferences has no atomic increment. Use the cached instance to
    // minimize the read-modify-write window; callers should not treat this as
    // strictly atomic under concurrent access.
    final current = _instance.getInt(_sessionCountKey) ?? 0;
    await _instance.setInt(_sessionCountKey, current + 1);
  }

  /// Returns the current consecutive-day tracking streak.
  static int getTrackingStreak() {
    return _instance.getInt(_trackingStreakKey) ?? 0;
  }

  /// Updates the consecutive-day tracking streak based on the last active date.
  /// Returns the new streak value.
  static Future<int> incrementTrackingStreak() async {
    final today = DateTime.now();
    final todayStr = today.toIso8601String().substring(0, 10);
    final lastActiveStr = _instance.getString(_lastActiveDateKey) ?? '';

    final currentStreak = _instance.getInt(_trackingStreakKey) ?? 0;
    int newStreak;
    if (lastActiveStr.isEmpty) {
      newStreak = 1;
    } else {
      final lastDate = DateTime.tryParse(lastActiveStr);
      if (lastDate == null) {
        newStreak = 1;
      } else if (_isSameDay(lastDate, today)) {
        newStreak = currentStreak;
      } else if (_isSameDay(
        lastDate.add(const Duration(days: 1)),
        today,
      )) {
        newStreak = currentStreak + 1;
      } else {
        newStreak = 1;
      }
    }

    await _instance.setInt(_trackingStreakKey, newStreak);
    await _instance.setString(_lastActiveDateKey, todayStr);
    return newStreak;
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static Future<void> setEventFired(String eventKey) async {
    await _instance.setBool('event_fired_$eventKey', true);
  }

  static bool getEventFired(String eventKey) {
    return _instance.getBool('event_fired_$eventKey') ?? false;
  }

  static const String _lastSessionDateKey = 'last_session_date';

  static String getLastSessionDate() {
    return _instance.getString(_lastSessionDateKey) ?? '';
  }

  static Future<void> setLastSessionDate(String dateStr) async {
    await _instance.setString(_lastSessionDateKey, dateStr);
  }

  static const String _lastNotificationOpenedAtKey =
      'last_notification_opened_at';

  static DateTime? getLastNotificationOpenedAt() {
    final millis = _instance.getInt(_lastNotificationOpenedAtKey);
    return InputValidator.dateTimeFromMillis(millis);
  }

  static Future<void> setLastNotificationOpenedAt(DateTime time) async {
    await _instance.setInt(
      _lastNotificationOpenedAtKey,
      time.millisecondsSinceEpoch,
    );
  }

  // ── Magic Link auth ─────────────────────────────────────────────────────
  static const String _magicLinkAuthCompletedKey = 'magic_link_auth_completed';

  static bool getMagicLinkAuthCompleted() {
    return _instance.getBool(_magicLinkAuthCompletedKey) ?? false;
  }

  static Future<void> setMagicLinkAuthCompleted(bool completed) async {
    await _instance.setBool(_magicLinkAuthCompletedKey, completed);
  }

  // ── Guest mode ───────────────────────────────────────────────────────────
  // True when user skipped identity verification via "Use as Guest".
  // Guest users have access to all local data features but are blocked from
  // identity-specific routes (audit log, account deletion).
  static const String _guestModeKey = 'guest_mode';

  static bool getGuestMode() {
    return _instance.getBool(_guestModeKey) ?? false;
  }

  static Future<void> setGuestMode(bool isGuest) async {
    await _instance.setBool(_guestModeKey, isGuest);
  }

  // ── Biometric preference ─────────────────────────────────────────────────
  static const String _biometricEnabledKey = 'biometric_enabled';

  static bool getBiometricEnabled() {
    return _instance.getBool(_biometricEnabledKey) ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _instance.setBool(_biometricEnabledKey, enabled);
  }
}
