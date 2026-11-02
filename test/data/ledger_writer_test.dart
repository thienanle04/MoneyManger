import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/data/database/app_database.dart';
import 'package:money_manager/data/ledger/ledger_writer.dart';
import 'package:money_manager/data/ledger/transfer_payload.dart';
import 'package:money_manager/domain/enums/ledger_event_type.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late LedgerWriter writer;
  const uuid = Uuid();

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    writer = LedgerWriter(db);
  });

  tearDown(() => db.close());

  Future<String> insertAccount({
    required String name,
    String currencyCode = 'VND',
    int balanceMinor = 0,
  }) async {
    final id = uuid.v4();
    final now = DateTime.now();
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            id: id,
            name: name,
            type: 'cash',
            currencyCode: currencyCode,
            balanceMinor: Value(balanceMinor),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<Account> accountOf(String id) =>
      (db.select(db.accounts)..where((a) => a.id.equals(id))).getSingle();

  test('dedupes on clientRequestId without double balance', () async {
    final accountId = await insertAccount(name: 'Cash', balanceMinor: 100_000);
    const requestId = 'req-1';

    final first = await writer.append(
      type: LedgerEventType.expense,
      occurredAt: DateTime(2026, 5, 1),
      currencyCode: 'VND',
      amountMinor: 50_000,
      accountId: accountId,
      clientRequestId: requestId,
    );
    final second = await writer.append(
      type: LedgerEventType.expense,
      occurredAt: DateTime(2026, 5, 1),
      currencyCode: 'VND',
      amountMinor: 50_000,
      accountId: accountId,
      clientRequestId: requestId,
    );

    expect(first.id, second.id);
    expect(first.wasNew, isTrue);
    expect(second.wasNew, isFalse);

    final rows = await db.select(db.ledgerEvents).get();
    expect(rows, hasLength(1));
    expect((await accountOf(accountId)).balanceMinor, 50_000);
  });

  test('expense decreases balanceMinor', () async {
    final accountId = await insertAccount(name: 'Cash', balanceMinor: 200_000);
    await writer.append(
      type: LedgerEventType.expense,
      occurredAt: DateTime(2026, 5, 1),
      currencyCode: 'VND',
      amountMinor: 30_000,
      accountId: accountId,
    );
    expect((await accountOf(accountId)).balanceMinor, 170_000);
  });

  test('income increases balanceMinor', () async {
    final accountId = await insertAccount(name: 'Cash', balanceMinor: 10_000);
    await writer.append(
      type: LedgerEventType.income,
      occurredAt: DateTime(2026, 5, 1),
      currencyCode: 'VND',
      amountMinor: 40_000,
      accountId: accountId,
    );
    expect((await accountOf(accountId)).balanceMinor, 50_000);
  });

  test('openingBalance credits without being income type confusion', () async {
    final accountId = await insertAccount(name: 'Cash');
    final result = await writer.append(
      type: LedgerEventType.openingBalance,
      occurredAt: DateTime(2026, 1, 1),
      currencyCode: 'VND',
      amountMinor: 1_000_000,
      accountId: accountId,
    );
    expect(result.wasNew, isTrue);
    expect((await accountOf(accountId)).balanceMinor, 1_000_000);
    final row = await (db.select(db.ledgerEvents)
          ..where((e) => e.id.equals(result.id)))
        .getSingle();
    expect(row.eventType, LedgerEventType.openingBalance.storageKey);
  });

  test('transfer moves balance between accounts', () async {
    final cash = await insertAccount(name: 'Cash', balanceMinor: 500_000);
    final bank = await insertAccount(name: 'Bank', balanceMinor: 100_000);

    await writer.append(
      type: LedgerEventType.transfer,
      occurredAt: DateTime(2026, 5, 1),
      currencyCode: 'VND',
      amountMinor: 80_000,
      accountId: cash,
      transfer: TransferPayload(
        destAccountId: bank,
        sourceAmountMinor: 80_000,
        destAmountMinor: 80_000,
        sourceCurrency: 'VND',
        destCurrency: 'VND',
      ),
    );

    expect((await accountOf(cash)).balanceMinor, 420_000);
    expect((await accountOf(bank)).balanceMinor, 180_000);
  });

  test('rejects expense without accountId', () async {
    expect(
      () => writer.append(
        type: LedgerEventType.expense,
        occurredAt: DateTime(2026, 5, 1),
        currencyCode: 'VND',
        amountMinor: 10_000,
      ),
      throwsArgumentError,
    );
  });

  test('rejects non-positive amountMinor', () async {
    final accountId = await insertAccount(name: 'Cash');
    expect(
      () => writer.append(
        type: LedgerEventType.expense,
        occurredAt: DateTime(2026, 5, 1),
        currencyCode: 'VND',
        amountMinor: 0,
        accountId: accountId,
      ),
      throwsArgumentError,
    );
  });

  test('rejects currency mismatch', () async {
    final accountId = await insertAccount(name: 'Cash', currencyCode: 'VND');
    expect(
      () => writer.append(
        type: LedgerEventType.expense,
        occurredAt: DateTime(2026, 5, 1),
        currencyCode: 'USD',
        amountMinor: 100,
        accountId: accountId,
      ),
      throwsArgumentError,
    );
  });

  test('rejects cross-currency transfer', () async {
    final vnd = await insertAccount(name: 'VND Cash', currencyCode: 'VND');
    final usd = await insertAccount(name: 'USD Cash', currencyCode: 'USD');
    expect(
      () => writer.append(
        type: LedgerEventType.transfer,
        occurredAt: DateTime(2026, 5, 1),
        currencyCode: 'VND',
        amountMinor: 10_000,
        accountId: vnd,
        transfer: TransferPayload(
          destAccountId: usd,
          sourceAmountMinor: 10_000,
          destAmountMinor: 10_000,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('rolls back when account missing', () async {
    expect(
      () => writer.append(
        type: LedgerEventType.expense,
        occurredAt: DateTime(2026, 5, 1),
        currencyCode: 'VND',
        amountMinor: 10_000,
        accountId: 'missing-id',
      ),
      throwsA(isA<StateError>()),
    );
    final rows = await db.select(db.ledgerEvents).get();
    expect(rows, isEmpty);
  });
}
