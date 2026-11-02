# Money Manager

Personal finance for one person: accounts, the people they lend to, and the ledger events that record what the money did.

## Language

**Account**:
A cash, bank, or asset balance the user holds.
_Avoid_: User, login, wallet

**Category**:
A label for income or spending.

**Person**:
Someone the user lends to or borrows from.
_Avoid_: Counterparty, contact

**Ledger event**:
One recorded money movement. The history of events is the record.
_Avoid_: Transaction row, entry

**Correction**:
A later ledger event that replaces the effect of an earlier one.

**Reversal**:
A later ledger event that undoes an earlier one.

**Transfer**:
A movement between two accounts.

**Base currency**:
The currency used when combining balances. The default is VND.

**NAV**:
Net worth at a point in time, across the accounts included in it.

**Import batch**:
A file of rows waiting to become ledger events.
