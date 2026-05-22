import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/data/database/app_database.dart';
import 'package:money_manager/data/ledger/ledger_writer.dart';
import 'package:money_manager/domain/enums/ledger_event_type.dart';

void main() {
  late AppDatabase db;
  late LedgerWriter writer;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    writer = LedgerWriter(db);
  });

  tearDown(() => db.close());

  test('dedupes on clientRequestId', () async {
    const requestId = 'req-1';
    final id1 = await writer.append(
      type: LedgerEventType.expense,
      occurredAt: DateTime(2026, 5, 1),
      currencyCode: 'VND',
      amountMinor: -50_000,
      clientRequestId: requestId,
    );
    final id2 = await writer.append(
      type: LedgerEventType.expense,
      occurredAt: DateTime(2026, 5, 1),
      currencyCode: 'VND',
      amountMinor: -50_000,
      clientRequestId: requestId,
    );
    expect(id1, id2);

    final rows = await db.select(db.ledgerEvents).get();
    expect(rows, hasLength(1));
  });
}
