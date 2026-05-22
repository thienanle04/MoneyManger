import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../ledger/ledger_writer.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final ledgerWriterProvider = Provider<LedgerWriter>((ref) {
  return LedgerWriter(ref.watch(appDatabaseProvider));
});
