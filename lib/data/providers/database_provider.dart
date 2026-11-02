import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/ledger_event_type.dart';
import '../database/app_database.dart';
import '../ledger/ledger_writer.dart';
import '../repositories/accounts_repository.dart';
import '../repositories/categories_repository.dart';
import '../seed/app_seed.dart';

export '../database/app_database.dart' show Account, Category, LedgerEvent;

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Ensures M1 seed ran before feature UI reads data.
final appReadyProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  await seedIfNeeded(db);
});

final ledgerWriterProvider = Provider<LedgerWriter>((ref) {
  return LedgerWriter(ref.watch(appDatabaseProvider));
});

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return AccountsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(ledgerWriterProvider),
  );
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(ref.watch(appDatabaseProvider));
});

final accountsProvider = StreamProvider<List<Account>>((ref) async* {
  await ref.watch(appReadyProvider.future);
  yield* ref.watch(accountsRepositoryProvider).watchAll();
});

final categoriesProvider =
    StreamProvider.family<List<Category>, bool?>((ref, isIncome) async* {
  await ref.watch(appReadyProvider.future);
  yield* ref.watch(categoriesRepositoryProvider).watchAll(isIncome: isIncome);
});

final baseCurrencyProvider = StreamProvider<String>((ref) async* {
  await ref.watch(appReadyProvider.future);
  final db = ref.watch(appDatabaseProvider);
  yield* (db.select(db.appSettings)
        ..where((s) => s.key.equals('base_currency')))
      .watch()
      .map((rows) => rows.isEmpty ? 'VND' : rows.first.value);
});

final recentEventsProvider = StreamProvider<List<LedgerEvent>>((ref) async* {
  await ref.watch(appReadyProvider.future);
  final db = ref.watch(appDatabaseProvider);
  yield* (db.select(db.ledgerEvents)
        ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)])
        ..limit(10))
      .watch();
});

/// Recent ledger events for the Trans. list (larger window than Home).
final transactionEventsProvider = StreamProvider<List<LedgerEvent>>((ref) async* {
  await ref.watch(appReadyProvider.future);
  final db = ref.watch(appDatabaseProvider);
  yield* (db.select(db.ledgerEvents)
        ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)])
        ..limit(200))
      .watch();
});

/// This-month expense total + top categories in [baseCurrency] (account currency match only).
final monthSpendStubProvider =
    StreamProvider<MonthSpendStub>((ref) async* {
  await ref.watch(appReadyProvider.future);
  final db = ref.watch(appDatabaseProvider);
  final base = await ref.watch(baseCurrencyProvider.future);

  yield* db.select(db.ledgerEvents).watch().asyncMap((_) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    final end = DateTime(now.year, now.month + 1);

    final expenses = await (db.select(db.ledgerEvents)
          ..where(
            (e) =>
                e.eventType.equals(LedgerEventType.expense.storageKey) &
                e.currencyCode.equals(base) &
                e.occurredAt.isBiggerOrEqualValue(start) &
                e.occurredAt.isSmallerThanValue(end),
          ))
        .get();

    var total = 0;
    final byCategory = <String, int>{};
    for (final e in expenses) {
      total += e.amountMinor;
      final key = e.categoryId ?? '_none';
      byCategory[key] = (byCategory[key] ?? 0) + e.amountMinor;
    }

    final categories = await db.select(db.categories).get();
    final names = {for (final c in categories) c.id: c.name};

    final top = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return MonthSpendStub(
      baseCurrency: base,
      totalExpenseMinor: total,
      topCategories: top
          .take(3)
          .map(
            (e) => CategorySpend(
              categoryId: e.key == '_none' ? null : e.key,
              name: e.key == '_none' ? '—' : (names[e.key] ?? e.key),
              amountMinor: e.value,
            ),
          )
          .toList(),
    );
  });
});

class MonthSpendStub {
  const MonthSpendStub({
    required this.baseCurrency,
    required this.totalExpenseMinor,
    required this.topCategories,
  });

  final String baseCurrency;
  final int totalExpenseMinor;
  final List<CategorySpend> topCategories;
}

class CategorySpend {
  const CategorySpend({
    required this.categoryId,
    required this.name,
    required this.amountMinor,
  });

  final String? categoryId;
  final String name;
  final int amountMinor;
}

Future<void> setBaseCurrency(AppDatabase db, String code) async {
  await db.into(db.appSettings).insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          key: 'base_currency',
          value: code,
        ),
      );
}
