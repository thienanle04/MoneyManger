import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums/ledger_event_type.dart';
import '../database/app_database.dart';

/// Append-only ledger writes with local dedupe on [clientRequestId].
class LedgerWriter {
  LedgerWriter(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  Future<String> append({
    required LedgerEventType type,
    required DateTime occurredAt,
    required String currencyCode,
    required int amountMinor,
    String? accountId,
    String? categoryId,
    String? personId,
    String? subscriptionId,
    String payloadJson = '{}',
    String? clientRequestId,
    String? correctedEventId,
  }) async {
    if (clientRequestId != null) {
      final existing = await (_db.select(_db.ledgerEvents)
            ..where((e) => e.clientRequestId.equals(clientRequestId)))
          .getSingleOrNull();
      if (existing != null) return existing.id;
    }

    final id = _uuid.v4();
    await _db.into(_db.ledgerEvents).insert(
          LedgerEventsCompanion.insert(
            id: id,
            eventType: type.storageKey,
            occurredAt: occurredAt,
            currencyCode: currencyCode,
            amountMinor: amountMinor,
            accountId: Value(accountId),
            categoryId: Value(categoryId),
            personId: Value(personId),
            subscriptionId: Value(subscriptionId),
            payloadJson: Value(payloadJson),
            clientRequestId: Value(clientRequestId),
            correctedEventId: Value(correctedEventId),
            createdAt: DateTime.now(),
          ),
        );
    return id;
  }
}
