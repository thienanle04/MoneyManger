/// Immutable ledger write boundary event types.
enum LedgerEventType {
  expense,
  income,
  transfer,
  lend,
  borrow,
  debtRepayment,
  loanRepaymentReceived,
  subscriptionPayment,
  subscriptionAdjustment,
  assetValueUpdate,
  importCommit,
  correction,
  reversal,
}

extension LedgerEventTypeX on LedgerEventType {
  String get storageKey => name;
}
