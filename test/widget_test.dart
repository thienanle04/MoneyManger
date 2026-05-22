import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:money_manager/app.dart';

void main() {
  testWidgets('app shell shows home tab', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MoneyManagerApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your personal finance cockpit'), findsOneWidget);
  });
}
