import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/money/money.dart';

void main() {
  group('Money', () {
    test('stores VND as whole minor units', () {
      const m = Money(minorUnits: 1_200_000, currencyCode: 'VND');
      expect(m.majorUnits, 1_200_000);
      expect(Money.minorUnitsPerMajor('VND'), 1);
    });

    test('stores USD with cents', () {
      const m = Money(minorUnits: 1050, currencyCode: 'USD');
      expect(m.majorUnits, 10.5);
    });

    test('parse handles grouped digits', () {
      final m = Money.parse('1,200,000', currencyCode: 'VND');
      expect(m?.minorUnits, 1_200_000);
    });

    test('format places VND symbol after digits', () {
      const m = Money(minorUnits: 5000, currencyCode: 'VND');
      expect(m.format(), '5,000đ');
    });

    test('format places US\$ before digits', () {
      const m = Money(minorUnits: 500, currencyCode: 'USD');
      expect(m.format(), 'US\$5.00');
    });

    test('format distinguishes AUD from USD', () {
      const usd = Money(minorUnits: 1000, currencyCode: 'USD');
      const aud = Money(minorUnits: 1000, currencyCode: 'AUD');
      expect(usd.format(), 'US\$10.00');
      expect(aud.format(), 'AUD\$10.00');
    });
  });
}
