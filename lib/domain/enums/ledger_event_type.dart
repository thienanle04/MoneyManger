/// Immutable ledger write boundary event types.
enum LedgerEventType {
  expense,
  income,
  transfer,
  openingBalance,
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

  /// Types that credit (increase) [Accounts.balanceMinor] for [accountId].
  bool get creditsPrimaryAccount =>
      this == LedgerEventType.income ||
      this == LedgerEventType.openingBalance;

  /// Types that debit (decrease) [Accounts.balanceMinor] for [accountId].
  bool get debitsPrimaryAccount => this == LedgerEventType.expense;
}
