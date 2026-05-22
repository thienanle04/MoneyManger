import '../money/money.dart';

/// Manual / effective-dated FX for NAV and insights (no live API in v1).
class FxRate {
  const FxRate({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.effectiveAt,
    this.isManual = true,
  });

  final String fromCurrency;
  final String toCurrency;
  /// Multiply [fromCurrency] amount by [rate] to get [toCurrency] major units.
  final double rate;
  final DateTime effectiveAt;
  final bool isManual;
}

class FxConverter {
  const FxConverter({required this.baseCurrency, required this.rates});

  final String baseCurrency;
  final List<FxRate> rates;

  /// Convert [money] into [baseCurrency] using the latest applicable rate.
  Money? toBase(Money money, {DateTime? asOf}) {
    if (money.currencyCode == baseCurrency) return money;

    final when = asOf ?? DateTime.now();
    final direct = _findRate(money.currencyCode, baseCurrency, when);
    if (direct != null) {
      final major = money.majorUnits * direct.rate;
      return Money(
        minorUnits: (major * Money.minorUnitsPerMajor(baseCurrency)).round(),
        currencyCode: baseCurrency,
      );
    }

    final inverse = _findRate(baseCurrency, money.currencyCode, when);
    if (inverse != null && inverse.rate != 0) {
      final major = money.majorUnits / inverse.rate;
      return Money(
        minorUnits: (major * Money.minorUnitsPerMajor(baseCurrency)).round(),
        currencyCode: baseCurrency,
      );
    }

    return null;
  }

  FxRate? _findRate(String from, String to, DateTime asOf) {
    FxRate? best;
    for (final r in rates) {
      if (r.fromCurrency != from || r.toCurrency != to) continue;
      if (r.effectiveAt.isAfter(asOf)) continue;
      if (best == null || r.effectiveAt.isAfter(best.effectiveAt)) {
        best = r;
      }
    }
    return best;
  }
}
