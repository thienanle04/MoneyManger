// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Money Manager';

  @override
  String get navHome => 'Home';

  @override
  String get navTrans => 'Trans.';

  @override
  String get transEmpty => 'No transactions this month.';

  @override
  String get transAdd => 'Add transaction';

  @override
  String get navInsights => 'Insights';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get navMore => 'More';

  @override
  String get homeWelcome => 'Your personal finance cockpit';

  @override
  String get homeSubtitle => 'Capture fast. See leaks. Track NAV.';

  @override
  String get homeAccounts => 'Accounts';

  @override
  String get homeRecent => 'Recent';

  @override
  String get homeThisMonth => 'This month';

  @override
  String get homeTopCategories => 'Top categories';

  @override
  String get homeNoEvents => 'No transactions yet. Capture your first one.';

  @override
  String get homeEmptyAccounts => 'No accounts yet.';

  @override
  String get captureTitle => 'Quick capture';

  @override
  String get captureComingSoon => 'Transaction capture coming next.';

  @override
  String get captureTypeExpense => 'Expense';

  @override
  String get captureTypeIncome => 'Income';

  @override
  String get captureTypeTransfer => 'Transfer';

  @override
  String get captureAmount => 'Amount';

  @override
  String get captureAccount => 'Account';

  @override
  String get captureFromAccount => 'From';

  @override
  String get captureToAccount => 'To';

  @override
  String get captureCategory => 'Category';

  @override
  String get captureNote => 'Note';

  @override
  String get captureNoteHint => 'Add note…';

  @override
  String get captureSave => 'Save';

  @override
  String get captureContinue => 'Continue';

  @override
  String get captureSaving => 'Saving…';

  @override
  String captureSaved(String amount) {
    return 'Saved $amount';
  }

  @override
  String get captureDescription => 'Description';

  @override
  String get captureDescriptionHint => 'Add details…';

  @override
  String get captureDone => 'Done';

  @override
  String get captureCalculator => 'Calculator';

  @override
  String get captureRepeatLast => 'Repeat last';

  @override
  String get captureDate => 'Date';

  @override
  String get captureNoAccountsTitle => 'No accounts yet';

  @override
  String get captureNoAccountsBody => 'Create an account to start tracking.';

  @override
  String get captureCreateAccount => 'Create account';

  @override
  String get captureNoCategories => 'No categories — add one in Settings.';

  @override
  String get captureInvalidAmount => 'Enter a valid amount greater than zero.';

  @override
  String get captureSelectAccount => 'Select an account.';

  @override
  String get captureSelectDestAccount => 'Select a destination account.';

  @override
  String get captureSelectCategory => 'Select a category.';

  @override
  String get captureSameAccount => 'From and To must be different.';

  @override
  String get captureCrossCurrencyBlocked =>
      'Cross-currency transfers come in a later milestone.';

  @override
  String get captureError => 'Could not save. Try again.';

  @override
  String get insightsTitle => 'Monthly insights';

  @override
  String get insightsComingSoon => 'Leak and change reports coming next.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get baseCurrency => 'Base reporting currency';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get supportedCurrencies => 'Supported currencies';

  @override
  String get settingsAccounts => 'Accounts';

  @override
  String get settingsCategories => 'Categories';

  @override
  String get settingsManageAccounts => 'Manage accounts';

  @override
  String get settingsManageCategories => 'Manage categories';

  @override
  String get accountName => 'Name';

  @override
  String get accountType => 'Type';

  @override
  String get accountCurrency => 'Currency';

  @override
  String get accountIncludeInNav => 'Include in NAV';

  @override
  String get accountOpeningBalance => 'Opening balance';

  @override
  String get accountAdd => 'Add account';

  @override
  String get accountEdit => 'Edit account';

  @override
  String get accountSave => 'Save account';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeEwallet => 'E-wallet';

  @override
  String get accountGroupCash => 'Cash';

  @override
  String get accountGroupBank => 'Bank accounts';

  @override
  String get accountGroupEwallet => 'E-wallets';

  @override
  String get accountGroupCredit => 'Credit';

  @override
  String get accountGroupLoan => 'Loans';

  @override
  String get accountGroupOther => 'Other';

  @override
  String get accountsAssets => 'Assets';

  @override
  String get accountsLiabilities => 'Liabilities';

  @override
  String get accountsTotal => 'Total';

  @override
  String get categoryName => 'Name';

  @override
  String get categoryIsIncome => 'Income category';

  @override
  String get categoryAdd => 'Add category';

  @override
  String get categoryEdit => 'Edit category';

  @override
  String get categorySave => 'Save category';

  @override
  String get dialogOk => 'OK';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String currencyCount(int count) {
    return '$count currencies';
  }
}
