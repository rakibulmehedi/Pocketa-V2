// lib/features/safe_to_spend/domain/safe_to_spend_calculator.dart

import 'dart:math';

import 'package:helm/features/income/domain/entities/income_entry_entity.dart';
import 'package:helm/features/safe_to_spend/domain/entities/fixed_cost_entry.dart';
import 'package:helm/features/safe_to_spend/domain/entities/safe_to_spend_result.dart';
import 'package:helm/features/safe_to_spend/domain/entities/sts_settings.dart';
import 'package:helm/features/transactions/domain/entities/transaction_entity.dart';
import 'package:helm/features/transactions/domain/entities/transaction_type.dart';

class SafeToSpendCalculator {
  /// Computes the Safe-to-Spend breakdown.
  /// 
  /// The fixed costs due window is based on [now].
  static SafeToSpendResult calculate({
    required List<IncomeEntryEntity> incomeEntries,
    required List<TransactionEntity> transactions,
    required StsSettings settings,
    required List<FixedCostEntry> fixedCosts,
    required DateTime now,
  }) {
    double totalReceivedIncomeBdt = 0.0;
    double pendingIncome = 0.0;
    double expectedIncome = 0.0;
    // Entries excluded by user toggle (excludeFromCalculation=true).
    // Distinct from excludedWarnings which tracks entries missing fxRate.
    double excludedUsdIncome = 0.0;
    int excludedUsdEntryCount = 0;
    // H-40: collect human-readable warnings for entries excluded due to
    // missing or invalid FX rates.
    final List<String> excludedWarnings = [];

    for (final entry in incomeEntries) {
      // UX-3.08: skip entries explicitly excluded by the user
      if (entry.excludeFromCalculation) continue;

      if (entry.status == IncomeStatus.received) {
        final currency = entry.currency.toUpperCase();
        if (currency == 'BDT') {
          totalReceivedIncomeBdt += entry.amount;
        } else if (currency == 'USD') {
          // UX-3.08: per-entry conservative FX → counts in liquid BDT.
          // Reject zero/negative FX rates as invalid (M-8).
          if (entry.fxRate != null && entry.fxRate! > 0) {
            totalReceivedIncomeBdt += entry.amount * entry.fxRate!;
          } else {
            // No FX rate set or invalid rate → excluded (shown for transparency)
            excludedUsdIncome += entry.amount;
            excludedUsdEntryCount++;
            // H-40: record a human-readable warning for dashboard display.
            excludedWarnings.add('${entry.clientName}: missing FX rate');
          }
        }
      } else if (entry.status == IncomeStatus.pending) {
        pendingIncome += entry.amount;
      } else if (entry.status == IncomeStatus.expected) {
        expectedIncome += entry.amount;
      }
    }

    double totalExpenses = 0.0;
    for (final tx in transactions) {
      if (tx.type == TransactionType.expense) {
        totalExpenses += tx.amount;
      }
    }

    final double liquidCash = totalReceivedIncomeBdt - totalExpenses;
    final double taxReserve = totalReceivedIncomeBdt * settings.taxRate;

    double fixedCostsDue = 0.0;
    for (final cost in fixedCosts) {
      if (_isDueInNext30Days(cost.dueDayOfMonth, now)) {
        fixedCostsDue += cost.amount;
      }
    }

    // Buffer is a percentage of total received income (D1.11).
    // No formula logic change — only how the buffer value is derived changes.
    final double computedBuffer =
        (settings.bufferPercent / 100.0) * totalReceivedIncomeBdt;

    final double rawSafeToSpend =
        liquidCash - taxReserve - fixedCostsDue - computedBuffer;
    final double safeToSpend = max(0.0, rawSafeToSpend);

    final double horizonNumber =
        safeToSpend + (pendingIncome * 0.8) + (expectedIncome * 0.3);

    return SafeToSpendResult(
      liquidCash: liquidCash,
      totalReceivedIncomeBdt: totalReceivedIncomeBdt,
      totalExpenses: totalExpenses,
      taxReserve: taxReserve,
      fixedCostsDue: fixedCostsDue,
      anxietyBuffer: computedBuffer,
      safeToSpend: safeToSpend,
      rawSafeToSpend: rawSafeToSpend,
      pendingIncome: pendingIncome,
      expectedIncome: expectedIncome,
      horizonNumber: horizonNumber,
      excludedUsdIncome: excludedUsdIncome,
      excludedUsdEntryCount: excludedUsdEntryCount,
      excludedWarnings: excludedWarnings,
    );
  }

  static bool _isDueInNext30Days(int dueDayOfMonth, DateTime today) {
    // We check if the next occurrence of dueDayOfMonth is within 30 days.
    // If dueDayOfMonth is >= today.day, it occurs this month.
    // If dueDayOfMonth < today.day, it occurs next month.
    
    DateTime nextDueDate;
    if (dueDayOfMonth >= today.day) {
      nextDueDate = DateTime(today.year, today.month, dueDayOfMonth);
    } else {
      int nextMonth = today.month + 1;
      int year = today.year;
      if (nextMonth > 12) {
        nextMonth = 1;
        year++;
      }
      nextDueDate = DateTime(year, nextMonth, dueDayOfMonth);
    }

    final difference = nextDueDate.difference(DateTime(today.year, today.month, today.day)).inDays;
    return difference <= 30;
  }
}
