import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/money/currencies.dart';
import 'package:money_manager/core/money/currency.dart';
import 'package:money_manager/core/money/money.dart';

void main() {
  group('Currencies', () {
    test('resolves known currencies', () {
      expect(Currencies.find('vnd')?.decimalDigits, 0);
      expect(Currencies.find('USD')?.decimalDigits, 2);
      expect(Currencies.find('JPY')?.decimalDigits, 0);
      expect(Currencies.find('KWD')?.decimalDigits, 3);
    });

    test('unknown codes use two-decimal fallback', () {
      final x = Currencies.resolve('XYZ');
      expect(x.code, 'XYZ');
      expect(x.decimalDigits, 2);
      expect(x.minorUnitsPerMajor, 100);
    });

    test('sortedForPicker pins VND and USD first', () {
      final list = Currencies.sortedForPicker();
      expect(list.first.code, 'VND');
      expect(list[1].code, 'USD');
    });

    test('USD uses US\$ symbol with prefix placement', () {
      final usd = Currencies.resolve('USD');
      expect(usd.symbol, 'US\$');
      expect(usd.symbolPlacement, CurrencySymbolPlacement.prefix);
    });

    test('VND uses đ with suffix placement', () {
      final vnd = Currencies.resolve('VND');
      expect(vnd.symbol, 'đ');
      expect(vnd.symbolPlacement, CurrencySymbolPlacement.suffix);
    });
  });

  group('Money with extended currencies', () {
    test('EUR uses cents', () {
      const m = Money(minorUnits: 1999, currencyCode: 'EUR');
      expect(m.majorUnits, 19.99);
    });

    test('JPY has no fractional minor units', () {
      const m = Money(minorUnits: 1500, currencyCode: 'JPY');
      expect(m.majorUnits, 1500);
      expect(Money.minorUnitsPerMajor('JPY'), 1);
    });

    test('IDR stores whole rupiah', () {
      final m = Money.parse('25000', currencyCode: 'IDR');
      expect(m?.minorUnits, 25000);
    });
  });
}
