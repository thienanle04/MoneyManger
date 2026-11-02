import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums/ledger_event_type.dart';
import '../database/app_database.dart';
import '../ledger/ledger_writer.dart';

class AccountsRepository {
  AccountsRepository(this._db, this._writer);

  final AppDatabase _db;
  final LedgerWriter _writer;
  final _uuid = const Uuid();

  Stream<List<Account>> watchAll() =>
      (_db.select(_db.accounts)..orderBy([(a) => OrderingTerm.asc(a.name)]))
          .watch();

  Future<Account?> getById(String id) =>
      (_db.select(_db.accounts)..where((a) => a.id.equals(id))).getSingleOrNull();

  /// Creates an account. Optional [openingBalanceMinor] > 0 posts an openingBalance event.
  Future<String> create({
    required String name,
    required String type,
    required String currencyCode,
    bool includeInNav = true,
    int openingBalanceMinor = 0,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.accounts).insert(
          AccountsCompanion.insert(
            id: id,
            name: name.trim(),
            type: type,
            currencyCode: currencyCode,
            includeInNav: Value(includeInNav),
            createdAt: now,
            updatedAt: now,
          ),
        );

    if (openingBalanceMinor > 0) {
      await _writer.append(
        type: LedgerEventType.openingBalance,
        occurredAt: now,
        currencyCode: currencyCode,
        amountMinor: openingBalanceMinor,
        accountId: id,
        clientRequestId: 'opening-$id',
      );
    }

    return id;
  }

  Future<void> update({
    required String id,
    required String name,
    required String type,
    required bool includeInNav,
  }) async {
    final now = DateTime.now();
    final rows = await (_db.update(_db.accounts)..where((a) => a.id.equals(id)))
        .write(
      AccountsCompanion(
        name: Value(name.trim()),
        type: Value(type),
        includeInNav: Value(includeInNav),
        updatedAt: Value(now),
      ),
    );
    if (rows != 1) {
      throw StateError('account not found: $id');
    }
  }

  Future<bool> hasLedgerEvents(String accountId) async {
    final row = await (_db.select(_db.ledgerEvents)
          ..where((e) => e.accountId.equals(accountId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }
}
