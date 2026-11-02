import 'dart:convert';

/// Typed transfer fields stored in [LedgerEvents.payloadJson].
class TransferPayload {
  const TransferPayload({
    required this.destAccountId,
    required this.sourceAmountMinor,
    required this.destAmountMinor,
    this.rate,
    this.sourceCurrency,
    this.destCurrency,
    this.note,
  });

  final String destAccountId;
  final int sourceAmountMinor;
  final int destAmountMinor;
  final double? rate;
  final String? sourceCurrency;
  final String? destCurrency;
  final String? note;

  Map<String, Object?> toJson() => {
        'destAccountId': destAccountId,
        'sourceAmountMinor': sourceAmountMinor,
        'destAmountMinor': destAmountMinor,
        if (rate != null) 'rate': rate,
        if (sourceCurrency != null) 'sourceCurrency': sourceCurrency,
        if (destCurrency != null) 'destCurrency': destCurrency,
        if (note != null && note!.isNotEmpty) 'note': note,
      };

  String encode() => jsonEncode(toJson());

  static TransferPayload decode(String payloadJson) {
    final map = jsonDecode(payloadJson) as Map<String, dynamic>;
    final destAccountId = map['destAccountId'] as String?;
    final sourceAmountMinor = map['sourceAmountMinor'] as int?;
    final destAmountMinor = map['destAmountMinor'] as int?;
    if (destAccountId == null ||
        destAccountId.isEmpty ||
        sourceAmountMinor == null ||
        destAmountMinor == null) {
      throw ArgumentError(
        'transfer payload requires destAccountId, sourceAmountMinor, destAmountMinor',
      );
    }
    return TransferPayload(
      destAccountId: destAccountId,
      sourceAmountMinor: sourceAmountMinor,
      destAmountMinor: destAmountMinor,
      rate: (map['rate'] as num?)?.toDouble(),
      sourceCurrency: map['sourceCurrency'] as String?,
      destCurrency: map['destCurrency'] as String?,
      note: map['note'] as String?,
    );
  }
}

/// Optional note/description stored in payload for expense/income.
String encodeNotePayload(String? note, {String? description}) {
  final n = note?.trim();
  final d = description?.trim();
  final map = <String, String>{
    if (n != null && n.isNotEmpty) 'note': n,
    if (d != null && d.isNotEmpty) 'description': d,
  };
  if (map.isEmpty) return '{}';
  return jsonEncode(map);
}
