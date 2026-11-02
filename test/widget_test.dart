import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/data/database/app_database.dart';
import 'package:money_manager/data/providers/database_provider.dart';
import 'package:money_manager/data/seed/app_seed.dart';

void main() {
  testWidgets('app shell shows home tab', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await seedIfNeeded(db);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const MoneyManagerApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Your personal finance cockpit'), findsOneWidget);
    expect(find.text('Accounts'), findsWidgets);

    // Dispose Riverpod/Drift streams before closing the DB.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });
}
