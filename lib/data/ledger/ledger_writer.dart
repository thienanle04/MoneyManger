import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums/ledger_event_type.dart';
import '../database/app_database.dart';
import 'transfer_payload.dart';

/// Result of [LedgerWriter.append].
class AppendResult {
  const AppendResult({required this.id, required this.wasNew});

  final String id;
  final bool wasNew;
}

/// Append-only ledger writes with local dedupe and transactional balance cache.
class LedgerWriter {
  LedgerWriter(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  /// Inserts a ledger event and updates [Accounts.balanceMinor] in one transaction.
  ///
  /// [amountMinor] must be positive; sign comes from [type].
  /// Expense/income/openingBalance require [accountId] matching [currencyCode].
  /// Transfer requires [transfer] with same-currency source and dest (M1).
  Future<AppendResult> append({
    required LedgerEventType type,
    required DateTime occurredAt,
    required String currencyCode,
    required int amountMinor,
    String? accountId,
    String? categoryId,
    String? personId,
    String? subscriptionId,
    TransferPayload? transfer,
    String payloadJson = '{}',
    String? clientRequestId,
    String? correctedEventId,
  }) async {
    if (amountMinor <= 0) {
      throw ArgumentError.value(amountMinor, 'amountMinor', 'must be > 0');
    }

    return _db.transaction(() async {
      if (clientRequestId != null) {
        final existing = await (_db.select(_db.ledgerEvents)
              ..where((e) => e.clientRequestId.equals(clientRequestId)))
            .getSingleOrNull();
        if (existing != null) {
          return AppendResult(id: existing.id, wasNew: false);
        }
      }

      final resolvedPayload = _resolvePayload(
        type: type,
        amountMinor: amountMinor,
        transfer: transfer,
        payloadJson: payloadJson,
      );

      final String id;
      switch (type) {
        case LedgerEventType.expense:
        case LedgerEventType.income:
        case LedgerEventType.openingBalance:
          id = await _appendSingleAccount(
            type: type,
            occurredAt: occurredAt,
            currencyCode: currencyCode,
            amountMinor: amountMinor,
            accountId: accountId,
            categoryId: categoryId,
            personId: personId,
            subscriptionId: subscriptionId,
            payloadJson: resolvedPayload,
            clientRequestId: clientRequestId,
            correctedEventId: correctedEventId,
          );
        case LedgerEventType.transfer:
          id = await _appendTransfer(
            occurredAt: occurredAt,
            currencyCode: currencyCode,
            amountMinor: amountMinor,
            accountId: accountId,
            transfer: transfer!,
            payloadJson: resolvedPayload,
            clientRequestId: clientRequestId,
            correctedEventId: correctedEventId,
          );
        default:
          id = await _insertEvent(
            type: type,
            occurredAt: occurredAt,
            currencyCode: currencyCode,
            amountMinor: amountMinor,
            accountId: accountId,
            categoryId: categoryId,
            personId: personId,
            subscriptionId: subscriptionId,
            payloadJson: resolvedPayload,
            clientRequestId: clientRequestId,
            correctedEventId: correctedEventId,
          );
      }

      return AppendResult(id: id, wasNew: true);
    });
  }

  String _resolvePayload({
    required LedgerEventType type,
    required int amountMinor,
    required TransferPayload? transfer,
    required String payloadJson,
  }) {
    if (type == LedgerEventType.transfer) {
      if (transfer == null) {
        throw ArgumentError('transfer requires TransferPayload');
      }
      if (transfer.sourceAmountMinor != amountMinor) {
        throw ArgumentError(
          'amountMinor must equal transfer.sourceAmountMinor in M1',
        );
      }
      return transfer.encode();
    }
    return payloadJson;
  }

  Future<String> _appendSingleAccount({
    required LedgerEventType type,
    required DateTime occurredAt,
    required String currencyCode,
    required int amountMinor,
    required String? accountId,
    required String? categoryId,
    required String? personId,
    required String? subscriptionId,
    required String payloadJson,
    required String? clientRequestId,
    required String? correctedEventId,
  }) async {
    if (accountId == null || accountId.isEmpty) {
      throw ArgumentError('$type requires accountId');
    }
    final account = await _requireAccount(accountId);
    if (account.currencyCode != currencyCode) {
      throw ArgumentError(
        'currencyCode $currencyCode does not match account ${account.currencyCode}',
      );
    }

    final id = await _insertEvent(
      type: type,
      occurredAt: occurredAt,
      currencyCode: currencyCode,
      amountMinor: amountMinor,
      accountId: accountId,
      categoryId: categoryId,
      personId: personId,
      subscriptionId: subscriptionId,
      payloadJson: payloadJson,
      clientRequestId: clientRequestId,
      correctedEventId: correctedEventId,
    );

    final delta = type.debitsPrimaryAccount
        ? -amountMinor
        : type.creditsPrimaryAccount
            ? amountMinor
            : 0;
    if (delta != 0) {
      await _applyBalanceDelta(accountId, delta);
    }
    return id;
  }

  Future<String> _appendTransfer({
    required DateTime occurredAt,
    required String currencyCode,
    required int amountMinor,
    required String? accountId,
    required TransferPayload transfer,
    required String payloadJson,
    required String? clientRequestId,
    required String? correctedEventId,
  }) async {
    if (accountId == null || accountId.isEmpty) {
      throw ArgumentError('transfer requires source accountId');
    }
    if (transfer.destAccountId == accountId) {
      throw ArgumentError('transfer source and dest must differ');
    }

    final source = await _requireAccount(accountId);
    final dest = await _requireAccount(transfer.destAccountId);

    if (source.currencyCode != dest.currencyCode) {
      throw ArgumentError(
        'cross-currency transfer is not supported in M1 '
        '(${source.currencyCode} → ${dest.currencyCode})',
      );
    }
    if (source.currencyCode != currencyCode) {
      throw ArgumentError(
        'currencyCode $currencyCode does not match source account ${source.currencyCode}',
      );
    }
    if (transfer.sourceAmountMinor != transfer.destAmountMinor) {
      throw ArgumentError(
        'M1 same-currency transfer requires equal source and dest amounts',
      );
    }

    final id = await _insertEvent(
      type: LedgerEventType.transfer,
      occurredAt: occurredAt,
      currencyCode: currencyCode,
      amountMinor: amountMinor,
      accountId: accountId,
      categoryId: null,
      personId: null,
      subscriptionId: null,
      payloadJson: payloadJson,
      clientRequestId: clientRequestId,
      correctedEventId: correctedEventId,
    );

    await _applyBalanceDelta(accountId, -transfer.sourceAmountMinor);
    await _applyBalanceDelta(transfer.destAccountId, transfer.destAmountMinor);
    return id;
  }

  Future<Account> _requireAccount(String id) async {
    final account = await (_db.select(_db.accounts)
          ..where((a) => a.id.equals(id)))
        .getSingleOrNull();
    if (account == null) {
      throw StateError('account not found: $id');
    }
    return account;
  }

  Future<void> _applyBalanceDelta(String accountId, int deltaMinor) async {
    final now = DateTime.now();
    final rows = await _db.customUpdate(
      'UPDATE accounts SET balance_minor = balance_minor + ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable.withInt(deltaMinor),
        Variable.withDateTime(now),
        Variable.withString(accountId),
      ],
      updates: {_db.accounts},
    );
    if (rows != 1) {
      throw StateError('failed to update balance for account $accountId');
    }
  }

  Future<String> _insertEvent({
    required LedgerEventType type,
    required DateTime occurredAt,
    required String currencyCode,
    required int amountMinor,
    required String? accountId,
    required String? categoryId,
    required String? personId,
    required String? subscriptionId,
    required String payloadJson,
    required String? clientRequestId,
    required String? correctedEventId,
  }) async {
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
