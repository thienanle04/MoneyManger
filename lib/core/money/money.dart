import 'package:intl/intl.dart';

/// Monetary amount stored as integer minor units (e.g. cents, xu).
class Money {
  const Money({required this.minorUnits, required this.currencyCode});

  final int minorUnits;
  final String currencyCode;

  static const vnd = 'VND';
  static const usd = 'USD';

  /// VND has no fractional minor unit in practice; store whole dong.
  static int minorUnitsPerMajor(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case Money.usd:
        return 100;
      case Money.vnd:
      default:
        return 1;
    }
  }

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

  /// Parse user input like "1200000" or "1,200,000.50" into minor units.
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

    final divisor = minorUnitsPerMajor(currencyCode);
    return Money(
      minorUnits: (value * divisor).round(),
      currencyCode: currencyCode,
    );
  }

  String format({String? locale}) {
    final divisor = minorUnitsPerMajor(currencyCode);
    final major = minorUnits / divisor;
    final formatter = NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      symbol: _symbolFor(currencyCode),
      decimalDigits: divisor > 1 ? 2 : 0,
    );
    return formatter.format(major);
  }

  static String _symbolFor(String code) {
    switch (code.toUpperCase()) {
      case Money.usd:
        return r'$';
      case Money.vnd:
        return '₫';
      default:
        return code;
    }
  }
}
