import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

class CategoriesRepository {
  CategoriesRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  Stream<List<Category>> watchAll({bool? isIncome}) {
    final query = _db.select(_db.categories)
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);
    if (isIncome != null) {
      query.where((c) => c.isIncome.equals(isIncome));
    }
    return query.watch();
  }

  Future<String> create({
    required String name,
    required bool isIncome,
    String? parentId,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            id: id,
            name: name.trim(),
            parentId: Value(parentId),
            isIncome: Value(isIncome),
            createdAt: DateTime.now(),
          ),
        );
    return id;
  }

  Future<void> update({
    required String id,
    required String name,
    required bool isIncome,
  }) async {
    final rows =
        await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(name.trim()),
        isIncome: Value(isIncome),
      ),
    );
    if (rows != 1) {
      throw StateError('category not found: $id');
    }
  }

  Future<bool> hasLedgerEvents(String categoryId) async {
    final row = await (_db.select(_db.ledgerEvents)
          ..where((e) => e.categoryId.equals(categoryId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }
}
