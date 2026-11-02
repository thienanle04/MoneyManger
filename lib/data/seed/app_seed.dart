import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

const _seedFlagKey = 'did_seed_m1';

/// Seeds a cash account + starter categories once per database.
Future<void> seedIfNeeded(AppDatabase db) async {
  final existing = await (db.select(db.appSettings)
        ..where((s) => s.key.equals(_seedFlagKey)))
      .getSingleOrNull();
  if (existing?.value == 'true') return;

  const uuid = Uuid();
  final now = DateTime.now();

  await db.transaction(() async {
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            id: uuid.v4(),
            name: 'Cash',
            type: 'cash',
            currencyCode: 'VND',
            createdAt: now,
            updatedAt: now,
          ),
        );

    Future<void> addCategory(String name, {required bool isIncome}) async {
      await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              id: uuid.v4(),
              name: name,
              isIncome: Value(isIncome),
              createdAt: now,
            ),
          );
    }

    await addCategory('Food', isIncome: false);
    await addCategory('Transport', isIncome: false);
    await addCategory('Bills', isIncome: false);
    await addCategory('Income', isIncome: true);

    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: _seedFlagKey,
            value: 'true',
          ),
        );
  });
}
