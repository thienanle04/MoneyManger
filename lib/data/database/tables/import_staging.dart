import 'package:drift/drift.dart';

class ImportBatches extends Table {
  TextColumn get id => text()();
  TextColumn get fileName => text()();
  TextColumn get fileType => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get committedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ImportRowStaging extends Table {
  TextColumn get id => text()();
  TextColumn get batchId => text().references(ImportBatches, #id)();
  IntColumn get rowIndex => integer()();
  TextColumn get rawJson => text()();
  TextColumn get normalizedJson => text().nullable()();
  TextColumn get fingerprint => text().nullable()();
  TextColumn get reviewStatus => text()();
  TextColumn get reconciliationJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
