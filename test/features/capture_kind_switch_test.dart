import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/data/database/app_database.dart';
import 'package:money_manager/data/providers/database_provider.dart';
import 'package:money_manager/data/seed/app_seed.dart';

void main() {
  testWidgets('switching capture kinds does not flash loading spinner',
      (tester) async {
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

    // Trans. is leftmost bottom-nav item.
    await tester.tap(find.text('Trans.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Capture opens from FAB, sliding up with amount editor.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Amount'), findsWidgets);
    expect(find.byType(FCircularProgress), findsNothing);

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    expect(find.byType(FCircularProgress), findsNothing);
    expect(find.text('Amount'), findsWidgets);

    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    expect(find.byType(FCircularProgress), findsNothing);
    expect(find.text('Amount'), findsWidgets);

    await tester.tap(find.text('Expense'));
    await tester.pumpAndSettle();
    expect(find.byType(FCircularProgress), findsNothing);
    expect(find.text('Amount'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await db.close();
  });
}
