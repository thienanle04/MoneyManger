import 'currency.dart';

/// Known currencies for v1. Schema stores any `currencyCode` string; unknown
/// codes fall back to [defaultUnknownCurrency] rules (2 decimals, code as symbol).
class Currencies {
  Currencies._();

  static const defaultBase = 'VND';

  /// ISO 4217 codes the app knows how to format and parse precisely.
  static const List<Currency> supported = [
  Currency(code: 'VND', name: 'Vietnamese Dong', symbol: '₫', decimalDigits: 0),
  Currency(code: 'USD', name: 'US Dollar', symbol: r'$', decimalDigits: 2),
  Currency(code: 'EUR', name: 'Euro', symbol: '€', decimalDigits: 2),
  Currency(code: 'GBP', name: 'British Pound', symbol: '£', decimalDigits: 2),
  Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', decimalDigits: 0),
  Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', decimalDigits: 2),
  Currency(code: 'SGD', name: 'Singapore Dollar', symbol: r'S$', decimalDigits: 2),
  Currency(code: 'THB', name: 'Thai Baht', symbol: '฿', decimalDigits: 2),
  Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩', decimalDigits: 0),
  Currency(code: 'AUD', name: 'Australian Dollar', symbol: r'A$', decimalDigits: 2),
  Currency(code: 'CAD', name: 'Canadian Dollar', symbol: r'C$', decimalDigits: 2),
  Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', decimalDigits: 2),
  Currency(code: 'HKD', name: 'Hong Kong Dollar', symbol: r'HK$', decimalDigits: 2),
  Currency(code: 'NZD', name: 'New Zealand Dollar', symbol: r'NZ$', decimalDigits: 2),
  Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', decimalDigits: 2),
  Currency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', decimalDigits: 2),
  Currency(code: 'PHP', name: 'Philippine Peso', symbol: '₱', decimalDigits: 2),
  Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', decimalDigits: 0),
  Currency(code: 'TWD', name: 'New Taiwan Dollar', symbol: r'NT$', decimalDigits: 2),
  Currency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', decimalDigits: 2),
  Currency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼', decimalDigits: 2),
  Currency(code: 'BRL', name: 'Brazilian Real', symbol: r'R$', decimalDigits: 2),
  Currency(code: 'MXN', name: 'Mexican Peso', symbol: r'M$', decimalDigits: 2),
  Currency(code: 'PLN', name: 'Polish Złoty', symbol: 'zł', decimalDigits: 2),
  Currency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr', decimalDigits: 2),
  Currency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', decimalDigits: 2),
  Currency(code: 'DKK', name: 'Danish Krone', symbol: 'kr', decimalDigits: 2),
  Currency(code: 'RUB', name: 'Russian Ruble', symbol: '₽', decimalDigits: 2),
  Currency(code: 'TRY', name: 'Turkish Lira', symbol: '₺', decimalDigits: 2),
  Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R', decimalDigits: 2),
  Currency(code: 'BHD', name: 'Bahraini Dinar', symbol: 'BD', decimalDigits: 3),
  Currency(code: 'KWD', name: 'Kuwaiti Dinar', symbol: 'KD', decimalDigits: 3),
  Currency(code: 'OMR', name: 'Omani Rial', symbol: 'OMR', decimalDigits: 3),
  ];

  static final Map<String, Currency> _byCode = {
    for (final c in supported) c.code: c,
  };

  static Currency? find(String code) => _byCode[normalizeCode(code)];

  static bool isKnown(String code) => find(code) != null;

  static String normalizeCode(String code) => code.trim().toUpperCase();

  /// Metadata for [code], or a conservative default for uncommon ISO codes.
  static Currency resolve(String code) {
    final normalized = normalizeCode(code);
    if (normalized.isEmpty) {
      throw ArgumentError.value(code, 'code', 'Currency code cannot be empty');
    }
    return find(normalized) ?? Currency(
      code: normalized,
      name: normalized,
      symbol: normalized,
      decimalDigits: defaultUnknownCurrency.decimalDigits,
    );
  }

  static const Currency defaultUnknownCurrency = Currency(
    code: '???',
    name: 'Unknown',
    symbol: '?',
    decimalDigits: 2,
  );

  static List<String> get codes =>
      supported.map((c) => c.code).toList(growable: false);

  /// Common codes shown first in pickers (rest follow alphabetically).
  static const List<String> pinnedCodes = ['VND', 'USD', 'EUR', 'SGD', 'THB'];

  static List<Currency> sortedForPicker() {
    final pinned = <Currency>[];
    final rest = <Currency>[];
    for (final code in pinnedCodes) {
      final c = find(code);
      if (c != null) pinned.add(c);
    }
    for (final c in supported) {
      if (!pinnedCodes.contains(c.code)) rest.add(c);
    }
    rest.sort((a, b) => a.code.compareTo(b.code));
    return [...pinned, ...rest];
  }
}
