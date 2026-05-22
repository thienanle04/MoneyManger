import 'package:drift/drift.dart';

import 'connection.dart';
import 'tables/accounts.dart';
import 'tables/categories.dart';
import 'tables/exchange_rates.dart';
import 'tables/import_staging.dart';
import 'tables/ledger_events.dart';
import 'tables/nav_snapshots.dart';
import 'tables/people.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    People,
    LedgerEvents,
    ExchangeRates,
    ImportBatches,
    ImportRowStaging,
    NavSnapshots,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(appSettings).insert(
            AppSettingsCompanion.insert(
              key: 'base_currency',
              value: 'VND',
            ),
          );
        },
      );
}
