// lib/core/security/views/compromised_device_screen.dart
//
// Non-dismissible blocking screen shown when the device appears rooted or
// jailbroken. Helm does not run on compromised devices because local encryption
// keys and financial data could be exposed.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helm/core/themes/helm_colors.dart';
import 'package:helm/core/themes/helm_spacing.dart';
import 'package:helm/core/themes/helm_typography.dart';
import 'package:helm/l10n/app_localization.dart';

class CompromisedDeviceScreen extends StatelessWidget {
  const CompromisedDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.textStyles;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HelmSpacing.screenEdge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: colors.stateAtRisk,
              ),
              const SizedBox(height: HelmSpacing.s5),
              Text(
                context.l10n.compromisedDeviceTitle,
                style: typography.headingMd.copyWith(
                  color: colors.inkPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: HelmSpacing.s3),
              Text(
                context.l10n.compromisedDeviceBody,
                style: typography.bodyMd.copyWith(
                  color: colors.inkSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: HelmSpacing.s5),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.stateAtRisk,
                  foregroundColor: colors.surface,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(HelmSpacing.cardRadius),
                  ),
                ),
                onPressed: () => SystemNavigator.pop(),
                child: Text(context.l10n.closeHelm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
