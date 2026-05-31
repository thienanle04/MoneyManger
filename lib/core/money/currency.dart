/// ISO 4217 currency metadata for money storage and display.
class Currency {
  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimalDigits,
  });

  /// Uppercase ISO 4217 code (e.g. VND, USD).
  final String code;
  final String name;
  final String symbol;

  /// Number of decimal places in the major unit (0 = whole units only).
  final int decimalDigits;

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
