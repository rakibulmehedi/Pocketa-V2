// lib/core/utils/number_formatter.dart
// UX-5.11 — Number Formatting Utility
//
// Handles BDT lakh/crore grouping, USD formatting, and FX rate display.
// Pure Dart — no Flutter imports needed.

// ignore_for_file: avoid_classes_with_only_static_members

/// Formats monetary values for display in Helm.
///
/// BDT uses the Indian/Bangladeshi number system:
///   - Groups of 3 for the rightmost digits, then groups of 2.
///   - Prefix: "৳ " (U+09F3 Bengali Rupee Sign with trailing space).
///
/// USD uses standard Western grouping with "$ " prefix.
final class NumberFormatter {
  // ---------------------------------------------------------------------------
  // Currency boundary — the ONLY place a country-specific symbol may live.
  //
  // UI components (input prefixes, inline labels) must resolve symbols through
  // these helpers rather than hardcoding a glyph. Adding a new currency means
  // extending [symbolForCode] here — not editing widgets. This keeps Helm's
  // surfaces global-ready: country assumptions stay behind this boundary.
  // ---------------------------------------------------------------------------

  /// App default currency code. The single source of the BDT-first assumption.
  static const String defaultCurrencyCode = 'BDT';

  /// Bare currency symbol for a [currencyCode] (ISO-style: 'BDT', 'USD').
  ///
  /// Used for input affordances and inline amount labels. Unknown codes fall
  /// back to the uppercased code itself so nothing renders as a country glyph
  /// by accident.
  static String symbolForCode(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return r'$';
      case 'BDT':
        return '৳';
      default:
        return currencyCode.toUpperCase();
    }
  }

  /// Prefix form (`symbol + space`) for [TextField.prefixText] / [InputDecoration].
  static String prefixForCode(String currencyCode) =>
      '${symbolForCode(currencyCode)} ';

  // ---------------------------------------------------------------------------
  // BDT — full form with lakh/crore grouping
  // ---------------------------------------------------------------------------

  /// Formats [amount] as BDT with lakh/crore grouping.
  ///
  /// Examples:
  ///   formatBDT(36000.0)      → "৳ 36,000.00"
  ///   formatBDT(100000.0)     → "৳ 1,00,000.00"
  ///   formatBDT(10000000.0)   → "৳ 1,00,00,000.00"
  ///   formatBDT(1500000.0)    → "৳ 15,00,000.00"
  static String formatBDT(double amount) {
    final String formatted = _formatBDTInternal(amount, decimals: 2);
    return '৳ $formatted';
  }

  /// Compact BDT for tight-space contexts (Trust Strip, sub-labels).
  ///
  /// Examples:
  ///   formatBDTCompact(100000.0)   → "৳ 1.00L"
  ///   formatBDTCompact(10000000.0) → "৳ 1.00Cr"
  ///   formatBDTCompact(36000.0)    → "৳ 36,000"
  static String formatBDTCompact(double amount) {
    if (amount >= 10000000) {
      // Crore threshold: 1,00,00,000
      final double crore = amount / 10000000;
      return '৳ ${crore.toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      // Lakh threshold: 1,00,000
      final double lakh = amount / 100000;
      return '৳ ${lakh.toStringAsFixed(2)}L';
    } else {
      // Below 1 lakh — no decimal suffix, just grouping (no decimals for compact)
      return '৳ ${_formatBDTInternal(amount, decimals: 0)}';
    }
  }

  // ---------------------------------------------------------------------------
  // USD — Western grouping
  // ---------------------------------------------------------------------------

  /// Formats [amount] as USD with standard Western grouping.
  ///
  /// Examples:
  ///   formatUSD(1500.0)   → "$ 1,500.00"
  ///   formatUSD(10000.0)  → "$ 10,000.00"
  static String formatUSD(double amount) {
    final String formatted = _formatWestern(amount, decimals: 2);
    return '\$ $formatted';
  }

  // ---------------------------------------------------------------------------
  // FX rate display
  // ---------------------------------------------------------------------------

  /// Formats an FX rate for display.
  ///
  /// Example: formatFXRate(119.66) → "৳ 119.66"
  static String formatFXRate(double rate) {
    return '৳ ${rate.toStringAsFixed(2)}';
  }

  // ---------------------------------------------------------------------------
  // Parse — round-trip support
  // ---------------------------------------------------------------------------

  /// Parses a formatted BDT string back to a [double].
  ///
  /// Strips "৳ " (or legacy "tk "), all commas, and "L"/"Cr" suffixes before
  /// parsing. Returns null if parsing fails.
  static double? parseBDT(String formatted) {
    try {
      String s = formatted.trim();

      // Remove prefix — support both current (৳ ) and legacy (tk ) formats.
      if (s.startsWith('৳ ')) {
        s = s.substring(2);
      } else if (s.startsWith('tk ')) {
        s = s.substring(3);
      }

      // Handle compact suffixes
      if (s.endsWith('Cr')) {
        final double? val = double.tryParse(s.substring(0, s.length - 2));
        return val != null ? val * 10000000 : null;
      } else if (s.endsWith('L')) {
        final double? val = double.tryParse(s.substring(0, s.length - 1));
        return val != null ? val * 100000 : null;
      }

      // Strip grouping commas
      s = s.replaceAll(',', '');
      return double.tryParse(s);
    } on Exception catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Formats [amount] using Indian/Bangladeshi grouping rules.
  ///
  /// Grouping algorithm:
  ///   1. Split integer and decimal parts.
  ///   2. Rightmost 3 digits form the first group.
  ///   3. Remaining digits are grouped in pairs from the right.
  static String _formatBDTInternal(double amount, {required int decimals}) {
    // Split into integer and fractional parts
    final String raw = amount.toStringAsFixed(decimals);
    final List<String> parts = raw.split('.');
    final String intPart = parts[0]; // digits only, no sign for our use case
    final String fracPart = decimals > 0 ? parts[1] : '';

    final String grouped = _applyBDTGrouping(intPart);

    if (decimals > 0) {
      return '$grouped.$fracPart';
    }
    return grouped;
  }

  /// Applies Indian/Bangladeshi comma grouping to an integer string.
  ///
  /// Rules:
  ///   - < 1,000: no comma (e.g., "500")
  ///   - 1,000–99,999: one comma after first 1–2 digits (e.g., "36,000")
  ///   - 1,00,000–99,99,999: lakh grouping (e.g., "1,00,000")
  ///   - >= 1,00,00,000: crore grouping (e.g., "1,00,00,000")
  static String _applyBDTGrouping(String digits) {
    final bool negative = digits.startsWith('-');
    final String abs = negative ? digits.substring(1) : digits;
    if (abs.length <= 3) return negative ? '-$abs' : abs;

    final String last3 = abs.substring(abs.length - 3);
    String remaining = abs.substring(0, abs.length - 3);

    final List<String> groups = [];
    while (remaining.length > 2) {
      groups.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) {
      groups.insert(0, remaining);
    }

    final String grouped = '${groups.join(',')},$last3';
    return negative ? '-$grouped' : grouped;
  }

  /// Formats [amount] using Western 3-digit grouping.
  static String _formatWestern(double amount, {required int decimals}) {
    final String raw = amount.toStringAsFixed(decimals);
    final List<String> parts = raw.split('.');
    final String intPart = parts[0];
    final String fracPart = decimals > 0 ? parts[1] : '';

    final String grouped = _applyWesternGrouping(intPart);

    if (decimals > 0) {
      return '$grouped.$fracPart';
    }
    return grouped;
  }

  /// Applies Western 3-digit comma grouping to an integer string.
  static String _applyWesternGrouping(String digits) {
    final bool negative = digits.startsWith('-');
    final String abs = negative ? digits.substring(1) : digits;
    if (abs.length <= 3) return negative ? '-$abs' : abs;

    final List<String> groups = [];
    String remaining = abs;
    while (remaining.length > 3) {
      groups.insert(0, remaining.substring(remaining.length - 3));
      remaining = remaining.substring(0, remaining.length - 3);
    }
    if (remaining.isNotEmpty) {
      groups.insert(0, remaining);
    }
    final String grouped = groups.join(',');
    return negative ? '-$grouped' : grouped;
  }
}
