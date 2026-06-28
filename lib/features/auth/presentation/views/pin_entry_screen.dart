// lib/features/auth/presentation/views/pin_entry_screen.dart
//
// PIN entry (unlock) screen for Helm Trust Layer (D1).
// Shows attempt counter, locks after 5 failed attempts.
// Biometric auto-triggers on load if available and enabled.
// Uses custom numpad — no keyboard input. Fully responsive layout.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:helm/config/router/route_names.dart';
import 'package:helm/core/analytics/analytics_service.dart';
import 'package:helm/core/analytics/event_registry.dart';
import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/features/auth/presentation/providers/auth_provider.dart';
import 'package:helm/features/auth/presentation/providers/biometric_provider.dart';
import 'package:helm/l10n/app_localization.dart';

class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({super.key});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  static const int _pinLength = AuthNotifier.pinLength;
  static const int _maxAttempts = AuthNotifier.maxAttempts;

  String _currentInput = '';
  String? _message;
  Timer? _lockoutTimer;
  bool _biometricTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(analyticsProvider).trackEvent(TransactionalEvents.pinGateOpened);
      _maybeAutoTriggerBiometric();
    });
    _startLockoutTimerIfNeeded();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _startLockoutTimerIfNeeded() {
    final authState = ref.read(authProvider);
    if (authState.isLockedOut && _lockoutTimer == null) {
      _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {});
        final current = ref.read(authProvider);
        if (!current.isLockedOut) {
          _lockoutTimer?.cancel();
          _lockoutTimer = null;
          setState(() => _message = null);
        }
      });
    }
  }

  bool get _isLockedOut => ref.read(authProvider).isLockedOut;

  void _maybeAutoTriggerBiometric() {
    if (_biometricTriggered || _isLockedOut) return;
    final biometricState = ref.read(biometricProvider).valueOrNull;
    if (biometricState == null) return;
    if (biometricState.isAvailable && biometricState.isEnabled) {
      _biometricTriggered = true;
      _triggerBiometric();
    }
  }

  Future<void> _triggerBiometric() async {
    unawaited(HapticFeedback.lightImpact());
    final success = await ref.read(authProvider.notifier).unlockViaBiometrics();
    if (!mounted) return;
    if (success) {
      unawaited(HapticFeedback.mediumImpact());
      ref.read(analyticsProvider).trackEvent(TransactionalEvents.pinAuthSuccess);
      context.go(RouteNames.dashboard);
    }
  }

  void _onDigitTap(String digit) {
    HapticFeedback.lightImpact();
    if (_isLockedOut) return;
    if (_currentInput.length >= _pinLength) return;
    setState(() {
      _currentInput += digit;
      _message = null;
    });
    if (_currentInput.length == _pinLength) {
      _handlePinComplete();
    }
  }

  void _onClear() {
    HapticFeedback.lightImpact();
    if (_currentInput.isEmpty) return;
    setState(() {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    });
  }

  Future<void> _handlePinComplete() async {
    final pin = _currentInput;
    setState(() => _currentInput = '');

    final success = await ref.read(authProvider.notifier).authenticate(pin);
    if (!mounted) return;

    if (success) {
      unawaited(HapticFeedback.mediumImpact());
      ref.read(analyticsProvider).trackEvent(TransactionalEvents.pinAuthSuccess);
      context.go(RouteNames.dashboard);
      return;
    }

    final authState = ref.read(authProvider);
    unawaited(HapticFeedback.heavyImpact());
    final remaining = _maxAttempts - authState.failedAttempts;
    ref.read(analyticsProvider).trackEvent(
      TransactionalEvents.pinAuthFailed,
      properties: {
        EventProperties.remainingAttempts: remaining.clamp(0, _maxAttempts),
      },
    );
    final l10n = context.l10n;
    setState(() {
      if (authState.isLockedOut && authState.lockoutUntil != null) {
        _startLockoutTimerIfNeeded();
        _message = _lockoutCountdownText(authState.lockoutUntil!, l10n);
      } else if (authState.failedAttempts >= _maxAttempts) {
        _message = l10n.pinTooManyAttempts;
      } else {
        _message = l10n.pinIncorrectAttempts(remaining);
      }
    });
  }

  String _lockoutCountdownText(DateTime lockoutUntil, AppLocalizations l10n) {
    final remaining = lockoutUntil.difference(DateTime.now());
    if (remaining.isNegative) return l10n.pinTryAgain;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return l10n.pinLockedCountdown(
      minutes.toString(),
      seconds.toString().padLeft(2, '0'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authState = ref.watch(authProvider);
    final lockedOut =
        authState.isLocked && authState.failedAttempts >= _maxAttempts;
    final biometricAsync = ref.watch(biometricProvider);
    final showBiometric =
        biometricAsync.valueOrNull?.let((s) => s.isAvailable && s.isEnabled && !lockedOut) ??
            false;

    final screenHeight = MediaQuery.of(context).size.height;
    final verticalSpacing = screenHeight < 680 ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            _PinEntryHeader(
              message: _message,
              failedAttempts: authState.failedAttempts,
              isLockedOut: lockedOut,
              colors: colors,
            ),
            SizedBox(height: verticalSpacing),
            _PinDots(
              filledCount: _currentInput.length,
              totalCount: _pinLength,
              colors: colors,
            ),
            const Spacer(),
            if (!lockedOut)
              _NumPad(
                onDigit: _onDigitTap,
                onClear: _onClear,
                onBiometric: showBiometric ? _triggerBiometric : null,
                colors: colors,
              ),
            SizedBox(height: verticalSpacing),
          ],
        ),
      ),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}

// ---------------------------------------------------------------------------
// Header: title + feedback message
// ---------------------------------------------------------------------------

class _PinEntryHeader extends StatelessWidget {
  const _PinEntryHeader({
    required this.message,
    required this.failedAttempts,
    required this.isLockedOut,
    required this.colors,
  });

  final String? message;
  final int failedAttempts;
  final bool isLockedOut;
  final HelmColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.l10n.pinEnterTitle,
          style: context.textStyles.headingLg.copyWith(
            color: colors.inkPrimary,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(
            message!,
            style: context.textStyles.bodyMd.copyWith(
              color: isLockedOut ? colors.stateAtRisk : colors.stateTight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PIN dot indicators
// ---------------------------------------------------------------------------

class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.filledCount,
    required this.totalCount,
    required this.colors,
  });

  final int filledCount;
  final int totalCount;
  final HelmColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCount, (i) {
        final filled = i < filledCount;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? colors.interactive : Colors.transparent,
              border: Border.all(
                color: colors.interactive,
                width: 2,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom numpad (3×4 grid + optional biometric key)
// ---------------------------------------------------------------------------

class _NumPad extends StatelessWidget {
  const _NumPad({
    required this.onDigit,
    required this.onClear,
    required this.colors,
    this.onBiometric,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onClear;
  final VoidCallback? onBiometric;
  final HelmColors colors;

  static const List<List<String?>> _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    [null, '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final keySize = math.min(84.0, math.max(60.0, (screenWidth - 80) / 4.2));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: _rows.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key == null) {
                  return AnimatedOpacity(
                    opacity: onBiometric != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: _NumKey(
                      size: keySize,
                      onTap: onBiometric ?? () {},
                      colors: colors,
                      child: Icon(
                        LucideIcons.fingerprint,
                        size: keySize * 0.38,
                        color: colors.inkPrimary,
                      ),
                    ),
                  );
                }
                if (key == 'del') {
                  return _NumKey(
                    size: keySize,
                    label: '⌫',
                    onTap: onClear,
                    colors: colors,
                  );
                }
                return _NumKey(
                  size: keySize,
                  label: key,
                  onTap: () => onDigit(key),
                  colors: colors,
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({
    required this.size,
    required this.onTap,
    required this.colors,
    this.label,
    this.child,
  });

  final double size;
  final String? label;
  final Widget? child;
  final VoidCallback onTap;
  final HelmColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface,
          border: Border.all(color: colors.hairline),
        ),
        child: child ??
            Text(
              label ?? '',
              style: context.textStyles.headingLg.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.inkPrimary,
              ),
            ),
      ),
    );
  }
}
