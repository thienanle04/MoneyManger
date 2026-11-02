import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Money Manager'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTrans.
  ///
  /// In en, this message translates to:
  /// **'Trans.'**
  String get navTrans;

  /// No description provided for @transEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transactions this month.'**
  String get transEmpty;

  /// No description provided for @transAdd.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get transAdd;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get navAccounts;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Your personal finance cockpit'**
  String get homeWelcome;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture fast. See leaks. Track NAV.'**
  String get homeSubtitle;

  /// No description provided for @homeAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get homeAccounts;

  /// No description provided for @homeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homeRecent;

  /// No description provided for @homeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get homeThisMonth;

  /// No description provided for @homeTopCategories.
  ///
  /// In en, this message translates to:
  /// **'Top categories'**
  String get homeTopCategories;

  /// No description provided for @homeNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet. Capture your first one.'**
  String get homeNoEvents;

  /// No description provided for @homeEmptyAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet.'**
  String get homeEmptyAccounts;

  /// No description provided for @captureTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick capture'**
  String get captureTitle;

  /// No description provided for @captureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Transaction capture coming next.'**
  String get captureComingSoon;

  /// No description provided for @captureTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get captureTypeExpense;

  /// No description provided for @captureTypeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get captureTypeIncome;

  /// No description provided for @captureTypeTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get captureTypeTransfer;

  /// No description provided for @captureAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get captureAmount;

  /// No description provided for @captureAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get captureAccount;

  /// No description provided for @captureFromAccount.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get captureFromAccount;

  /// No description provided for @captureToAccount.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get captureToAccount;

  /// No description provided for @captureCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get captureCategory;

  /// No description provided for @captureNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get captureNote;

  /// No description provided for @captureNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add note…'**
  String get captureNoteHint;

  /// No description provided for @captureSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get captureSave;

  /// No description provided for @captureContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get captureContinue;

  /// No description provided for @captureSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get captureSaving;

  /// No description provided for @captureSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved {amount}'**
  String captureSaved(String amount);

  /// No description provided for @captureDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get captureDescription;

  /// No description provided for @captureDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add details…'**
  String get captureDescriptionHint;

  /// No description provided for @captureDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get captureDone;

  /// No description provided for @captureCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get captureCalculator;

  /// No description provided for @captureRepeatLast.
  ///
  /// In en, this message translates to:
  /// **'Repeat last'**
  String get captureRepeatLast;

  /// No description provided for @captureDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get captureDate;

  /// No description provided for @captureNoAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get captureNoAccountsTitle;

  /// No description provided for @captureNoAccountsBody.
  ///
  /// In en, this message translates to:
  /// **'Create an account to start tracking.'**
  String get captureNoAccountsBody;

  /// No description provided for @captureCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get captureCreateAccount;

  /// No description provided for @captureNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories — add one in Settings.'**
  String get captureNoCategories;

  /// No description provided for @captureInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than zero.'**
  String get captureInvalidAmount;

  /// No description provided for @captureSelectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select an account.'**
  String get captureSelectAccount;

  /// No description provided for @captureSelectDestAccount.
  ///
  /// In en, this message translates to:
  /// **'Select a destination account.'**
  String get captureSelectDestAccount;

  /// No description provided for @captureSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category.'**
  String get captureSelectCategory;

  /// No description provided for @captureSameAccount.
  ///
  /// In en, this message translates to:
  /// **'From and To must be different.'**
  String get captureSameAccount;

  /// No description provided for @captureCrossCurrencyBlocked.
  ///
  /// In en, this message translates to:
  /// **'Cross-currency transfers come in a later milestone.'**
  String get captureCrossCurrencyBlocked;

  /// No description provided for @captureError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get captureError;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly insights'**
  String get insightsTitle;

  /// No description provided for @insightsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Leak and change reports coming next.'**
  String get insightsComingSoon;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @baseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Base reporting currency'**
  String get baseCurrency;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @supportedCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Supported currencies'**
  String get supportedCurrencies;

  /// No description provided for @settingsAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get settingsAccounts;

  /// No description provided for @settingsCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get settingsCategories;

  /// No description provided for @settingsManageAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage accounts'**
  String get settingsManageAccounts;

  /// No description provided for @settingsManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get settingsManageCategories;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get accountName;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get accountType;

  /// No description provided for @accountCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get accountCurrency;

  /// No description provided for @accountIncludeInNav.
  ///
  /// In en, this message translates to:
  /// **'Include in NAV'**
  String get accountIncludeInNav;

  /// No description provided for @accountOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get accountOpeningBalance;

  /// No description provided for @accountAdd.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get accountAdd;

  /// No description provided for @accountEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get accountEdit;

  /// No description provided for @accountSave.
  ///
  /// In en, this message translates to:
  /// **'Save account'**
  String get accountSave;

  /// No description provided for @accountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// No description provided for @accountTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get accountTypeBank;

  /// No description provided for @accountTypeEwallet.
  ///
  /// In en, this message translates to:
  /// **'E-wallet'**
  String get accountTypeEwallet;

  /// No description provided for @accountGroupCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountGroupCash;

  /// No description provided for @accountGroupBank.
  ///
  /// In en, this message translates to:
  /// **'Bank accounts'**
  String get accountGroupBank;

  /// No description provided for @accountGroupEwallet.
  ///
  /// In en, this message translates to:
  /// **'E-wallets'**
  String get accountGroupEwallet;

  /// No description provided for @accountGroupCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get accountGroupCredit;

  /// No description provided for @accountGroupLoan.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get accountGroupLoan;

  /// No description provided for @accountGroupOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountGroupOther;

  /// No description provided for @accountsAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get accountsAssets;

  /// No description provided for @accountsLiabilities.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get accountsLiabilities;

  /// No description provided for @accountsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get accountsTotal;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryName;

  /// No description provided for @categoryIsIncome.
  ///
  /// In en, this message translates to:
  /// **'Income category'**
  String get categoryIsIncome;

  /// No description provided for @categoryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get categoryAdd;

  /// No description provided for @categoryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoryEdit;

  /// No description provided for @categorySave.
  ///
  /// In en, this message translates to:
  /// **'Save category'**
  String get categorySave;

  /// No description provided for @dialogOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialogOk;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @currencyCount.
  ///
  /// In en, this message translates to:
  /// **'{count} currencies'**
  String currencyCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
