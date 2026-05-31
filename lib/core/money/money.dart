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

  String format({String? locale}) {
    final currency = currencyOf(currencyCode);
    final major = minorUnits / currency.minorUnitsPerMajor;
    final formatter = NumberFormat.currency(
      locale: locale,
      name: currency.code,
      symbol: currency.symbol,
      decimalDigits: currency.decimalDigits,
    );
    return formatter.format(major);
  }
}
