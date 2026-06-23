// lib/features/safe_to_spend/domain/entities/safe_to_spend_result.dart

/// Value object representing the computed Safe-to-Spend breakdown and result.
class SafeToSpendResult {
  /// Liquid Cash = receivedIncomeBdt - totalExpenses
  final double liquidCash;
  
  /// Total received income in BDT
  final double totalReceivedIncomeBdt;
  
  /// Total amount of expense transactions
  final double totalExpenses;
  
  /// liquidCash from income × taxRate
  final double taxReserve;
  
  /// Total of fixed costs due within the 30-day window
  final double fixedCostsDue;
  
  /// User-set floor
  final double anxietyBuffer;
  
  /// Final result (clamped to 0.0 minimum for display)
  final double safeToSpend;
  
  /// Actual computed value (can be negative)
  final double rawSafeToSpend;
  
  /// For Horizon Number calculation only
  final double pendingIncome;
  
  /// For Horizon Number calculation only
  final double expectedIncome;
  
  /// safeToSpend + (pending × 0.8) + (expected × 0.3)
  final double horizonNumber;
  
  /// USD received entries (not counted in Safe-to-Spend, but shown for transparency)
  final double excludedUsdIncome;
  
  /// How many USD entries were excluded
  final int excludedUsdEntryCount;

  /// Non-null when the calculation failed. The numeric fields may be zero
  /// but should not be trusted; callers should display [error] instead.
  final String? error;

  /// H-40: Human-readable warnings for entries excluded from Safe-to-Spend
  /// due to missing or invalid FX rates. Each entry is formatted as
  /// "${clientName}: missing FX rate".
  final List<String> excludedWarnings;

  const SafeToSpendResult({
    required this.liquidCash,
    required this.totalReceivedIncomeBdt,
    required this.totalExpenses,
    required this.taxReserve,
    required this.fixedCostsDue,
    required this.anxietyBuffer,
    required this.safeToSpend,
    required this.rawSafeToSpend,
    required this.pendingIncome,
    required this.expectedIncome,
    required this.horizonNumber,
    required this.excludedUsdIncome,
    required this.excludedUsdEntryCount,
    this.error,
    this.excludedWarnings = const [],
  });

  const SafeToSpendResult.zero()
      : liquidCash = 0,
        totalReceivedIncomeBdt = 0,
        totalExpenses = 0,
        taxReserve = 0,
        fixedCostsDue = 0,
        anxietyBuffer = 0,
        safeToSpend = 0,
        rawSafeToSpend = 0,
        pendingIncome = 0,
        expectedIncome = 0,
        horizonNumber = 0,
        excludedUsdIncome = 0,
        excludedUsdEntryCount = 0,
        error = null,
        excludedWarnings = const [];

  /// Factory that surfaces a calculation failure instead of hiding it as zero.
  const SafeToSpendResult._failure(this.error)
      : liquidCash = 0,
        totalReceivedIncomeBdt = 0,
        totalExpenses = 0,
        taxReserve = 0,
        fixedCostsDue = 0,
        anxietyBuffer = 0,
        safeToSpend = 0,
        rawSafeToSpend = 0,
        pendingIncome = 0,
        expectedIncome = 0,
        horizonNumber = 0,
        excludedUsdIncome = 0,
        excludedUsdEntryCount = 0,
        excludedWarnings = const [];

  /// Named factory for callers that want to construct a failure result.
  factory SafeToSpendResult.failure(String error) =>
      SafeToSpendResult._failure(error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafeToSpendResult &&
          runtimeType == other.runtimeType &&
          liquidCash == other.liquidCash &&
          totalReceivedIncomeBdt == other.totalReceivedIncomeBdt &&
          totalExpenses == other.totalExpenses &&
          taxReserve == other.taxReserve &&
          fixedCostsDue == other.fixedCostsDue &&
          anxietyBuffer == other.anxietyBuffer &&
          safeToSpend == other.safeToSpend &&
          rawSafeToSpend == other.rawSafeToSpend &&
          pendingIncome == other.pendingIncome &&
          expectedIncome == other.expectedIncome &&
          horizonNumber == other.horizonNumber &&
          excludedUsdIncome == other.excludedUsdIncome &&
          excludedUsdEntryCount == other.excludedUsdEntryCount;

  @override
  int get hashCode =>
      liquidCash.hashCode ^
      totalReceivedIncomeBdt.hashCode ^
      totalExpenses.hashCode ^
      taxReserve.hashCode ^
      fixedCostsDue.hashCode ^
      anxietyBuffer.hashCode ^
      safeToSpend.hashCode ^
      rawSafeToSpend.hashCode ^
      pendingIncome.hashCode ^
      expectedIncome.hashCode ^
      horizonNumber.hashCode ^
      excludedUsdIncome.hashCode ^
      excludedUsdEntryCount.hashCode;

  @override
  String toString() {
    return 'SafeToSpendResult(safeToSpend: $safeToSpend, rawSafeToSpend: $rawSafeToSpend)';
  }
}
