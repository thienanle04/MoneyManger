import 'package:intl/intl.dart';

import 'currencies.dart';
import 'currency.dart';

/// Monetary amount stored as integer minor units (e.g. cents, whole dong).
class Money {
  const Money({required this.minorUnits, required this.currencyCode});

  final int minorUnits;
  final String currencyCode;

  static Currency currencyOf(String code) => Currencies.resolve(code);

  static int minorUnitsPerMajor(String currencyCode) =>
      currencyOf(currencyCode).minorUnitsPerMajor;

  double get majorUnits => minorUnits / minorUnitsPerMajor(currencyCode);

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(
      minorUnits: minorUnits + other.minorUnits,
      currencyCode: currencyCode,
    );
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(
      minorUnits: minorUnits - other.minorUnits,
      currencyCode: currencyCode,
    );
  }

  void _assertSameCurrency(Money other) {
    if (currencyCode != other.currencyCode) {
      throw ArgumentError(
        'Cannot combine $currencyCode with ${other.currencyCode}',
      );
    }
  }

  /// Parse user input like "1200000" or "10.50" into minor units.
  static Money? parse(
    String input, {
    required String currencyCode,
  }) {
    final cleaned = input
        .replaceAll(RegExp(r'[^\d.,\-]'), '')
        .replaceAll(',', '');
    if (cleaned.isEmpty) return null;

    final value = double.tryParse(cleaned);
    if (value == null) return null;

    final currency = currencyOf(currencyCode);
    return Money(
      minorUnits: (value * currency.minorUnitsPerMajor).round(),
      currencyCode: currency.code,
    );
  }

  /// Formats with currency symbol placement, e.g. `5,000đ` or `US$5.00`.
  String format({String? locale}) {
    final currency = currencyOf(currencyCode);
    final digits = _formatDigits(majorUnits, currency, locale: locale);
    return _withSymbol(digits, currency);
  }

  /// Formats a still-being-typed major-unit string with the currency symbol.
  ///
  /// Falls back to raw digits + symbol when [majorText] is not yet a complete
  /// number (e.g. `"5."`).
  static String formatMajorInput(
    String majorText, {
    required String currencyCode,
    String? locale,
  }) {
    final currency = currencyOf(currencyCode);
    final trimmed = majorText.trim();
    if (trimmed.isEmpty) return '';

    final parsed = parse(trimmed, currencyCode: currencyCode);
    if (parsed != null && !trimmed.endsWith('.')) {
      return parsed.format(locale: locale);
    }

    return _withSymbol(trimmed, currency);
  }

  static String _formatDigits(
    double major,
    Currency currency, {
    String? locale,
  }) {
    final formatter = NumberFormat.decimalPatternDigits(
      locale: locale ?? 'en_US',
      decimalDigits: currency.decimalDigits,
    );
    return formatter.format(major);
  }

  static String _withSymbol(String digits, Currency currency) {
    return switch (currency.symbolPlacement) {
      CurrencySymbolPlacement.prefix => '${currency.symbol}$digits',
      CurrencySymbolPlacement.suffix => '$digits${currency.symbol}',
    };
  }
}
