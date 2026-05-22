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
  String get navCapture => 'Capture';

  @override
  String get navInsights => 'Insights';

  @override
  String get navMore => 'More';

  @override
  String get homeWelcome => 'Your personal finance cockpit';

  @override
  String get homeSubtitle => 'Capture fast. See leaks. Track NAV.';

  @override
  String get captureTitle => 'Quick capture';

  @override
  String get captureComingSoon => 'Transaction capture coming next.';

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
}
