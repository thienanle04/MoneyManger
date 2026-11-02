/// Whether the currency symbol appears before or after the amount digits.
enum CurrencySymbolPlacement {
  /// e.g. US$5.00, €19.99, A$10.00
  prefix,

  /// e.g. 5,000đ, 12,50 zł
  suffix,
}

/// ISO 4217 currency metadata for money storage and display.
class Currency {
  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimalDigits,
    this.symbolPlacement = CurrencySymbolPlacement.prefix,
  });

  /// Uppercase ISO 4217 code (e.g. VND, USD).
  final String code;
  final String name;

  /// Display symbol (disambiguated for dollar currencies, e.g. US$, A$, S$).
  final String symbol;

  /// Number of decimal places in the major unit (0 = whole units only).
  final int decimalDigits;

  /// Where [symbol] sits relative to the formatted number.
  final CurrencySymbolPlacement symbolPlacement;

  int get minorUnitsPerMajor {
    if (decimalDigits == 0) return 1;
    var factor = 1;
    for (var i = 0; i < decimalDigits; i++) {
      factor *= 10;
    }
    return factor;
  }

  bool get allowsFractions => decimalDigits > 0;
}
