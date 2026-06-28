// lib/features/auth/presentation/views/pin_setup_screen.dart
//
// PIN setup screen for Helm Trust Layer (D1).
// Two-step flow: enter new PIN → confirm PIN → optional biometric opt-in.
// Uses custom numpad — no keyboard input. Fully responsive layout.

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

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  static const int _pinLength = AuthNotifier.pinLength;

  String _firstPin = '';
  String _currentInput = '';
  bool _isConfirmStep = false;
  String? _errorMessage;

  void _onDigitTap(String digit) {
    HapticFeedback.lightImpact();
    if (_currentInput.length >= _pinLength) return;
    setState(() {
      _currentInput += digit;
      _errorMessage = null;
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

  void _handlePinComplete() {
    if (!_isConfirmStep) {
      setState(() {
        _firstPin = _currentInput;
        _currentInput = '';
        _isConfirmStep = true;
      });
    } else {
      if (_currentInput == _firstPin) {
        HapticFeedback.mediumImpact();
        _finishSetup(_currentInput);
      } else {
        setState(() {
          _errorMessage = context.l10n.pinMismatchError;
          _currentInput = '';
          _firstPin = '';
          _isConfirmStep = false;
        });
      }
    }
  }

  Future<void> _finishSetup(String pin) async {
    await ref.read(authProvider.notifier).setupPin(pin);
    ref.read(analyticsProvider).trackEvent(TransactionalEvents.pinSetupCompleted);
    if (!mounted) return;

    final biometricState = ref.read(biometricProvider).valueOrNull;
    if (biometricState != null && biometricState.isAvailable) {
      await _showBiometricSheet();
    }
    if (!mounted) return;
    context.go(RouteNames.dashboard);
  }

  Future<void> _showBiometricSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _BiometricEnableSheet(
        colors: context.colors,
        onEnable: () async {
          await ref.read(biometricProvider.notifier).setEnabled(true);
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
        onSkip: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final keySize = math.min(84.0, math.max(60.0, (screenWidth - 80) / 4.2));
    final verticalSpacing = screenHeight < 680 ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            _PinHeader(
              title: _isConfirmStep
                  ? context.l10n.pinConfirmTitle
                  : context.l10n.pinCreateTitle,
              errorMessage: _errorMessage,
              colors: colors,
            ),
            SizedBox(height: verticalSpacing),
            _PinDots(
              filledCount: _currentInput.length,
              totalCount: _pinLength,
              colors: colors,
            ),
            const Spacer(),
            _NumPad(
              keySize: keySize,
              onDigit: _onDigitTap,
              onClear: _onClear,
              colors: colors,
            ),
            SizedBox(height: verticalSpacing),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Biometric enable bottom sheet
// ---------------------------------------------------------------------------

class _BiometricEnableSheet extends StatelessWidget {
  const _BiometricEnableSheet({
    required this.colors,
    required this.onEnable,
    required this.onSkip,
  });

  final HelmColors colors;
  final VoidCallback onEnable;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.hairline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Icon(
            LucideIcons.fingerprint,
            size: 48,
            color: colors.interactive,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.biometricEnableTitle,
            style: context.textStyles.headingMd.copyWith(
              color: colors.inkPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.biometricEnableSubtitle,
            style: context.textStyles.bodyMd.copyWith(
              color: colors.inkSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onEnable,
              style: FilledButton.styleFrom(
                backgroundColor: colors.interactive,
                foregroundColor: colors.canvas,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.l10n.biometricEnableButton,
                style: context.textStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.canvas,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onSkip,
            child: Text(
              context.l10n.biometricSkipButton,
              style: context.textStyles.bodyMd.copyWith(
                color: colors.inkTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PIN header
// ---------------------------------------------------------------------------

class _PinHeader extends StatelessWidget {
  const _PinHeader({
    required this.title,
    required this.errorMessage,
    required this.colors,
  });

  final String title;
  final String? errorMessage;
  final HelmColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: context.textStyles.headingLg.copyWith(
            color: colors.inkPrimary,
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: context.textStyles.bodyMd.copyWith(
              color: colors.stateAtRisk,
            ),
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
// Custom numpad (3×4 grid)
// ---------------------------------------------------------------------------

class _NumPad extends StatelessWidget {
  const _NumPad({
    required this.keySize,
    required this.onDigit,
    required this.onClear,
    required this.colors,
  });

  final double keySize;
  final ValueChanged<String> onDigit;
  final VoidCallback onClear;
  final HelmColors colors;

  static const List<List<String?>> _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    [null, '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
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
                  return SizedBox(width: keySize, height: keySize);
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
    required this.label,
    required this.onTap,
    required this.colors,
  });

  final double size;
  final String label;
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
        child: Text(
          label,
          style: context.textStyles.headingLg.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.inkPrimary,
          ),
        ),
      ),
    );
  }
}
