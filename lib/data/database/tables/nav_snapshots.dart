import 'package:drift/drift.dart';

class NavSnapshots extends Table {
  TextColumn get id => text()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get baseCurrency => text()();
  IntColumn get navMinor => integer()();
  TextColumn get fxContextJson => text()();
  TextColumn get breakdownJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
