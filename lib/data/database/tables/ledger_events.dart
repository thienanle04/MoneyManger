import 'package:drift/drift.dart';

class LedgerEvents extends Table {
  TextColumn get id => text()();
  TextColumn get eventType => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get currencyCode => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get accountId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get personId => text().nullable()();
  TextColumn get subscriptionId => text().nullable()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  TextColumn get clientRequestId => text().nullable()();
  TextColumn get correctedEventId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
