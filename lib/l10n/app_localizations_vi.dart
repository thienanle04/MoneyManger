// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Quản lý tiền';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navCapture => 'Ghi nhanh';

  @override
  String get navInsights => 'Phân tích';

  @override
  String get navMore => 'Thêm';

  @override
  String get homeWelcome => 'Bảng điều khiển tài chính cá nhân';

  @override
  String get homeSubtitle => 'Ghi nhanh. Thấy chỗ rò rỉ. Theo dõi NAV.';

  @override
  String get captureTitle => 'Ghi nhanh';

  @override
  String get captureComingSoon => 'Ghi giao dịch sẽ có trong bước tiếp theo.';

  @override
  String get insightsTitle => 'Phân tích tháng';

  @override
  String get insightsComingSoon =>
      'Báo cáo rò rỉ và thay đổi sẽ có trong bước tiếp theo.';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get baseCurrency => 'Tiền tệ báo cáo';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Theo hệ thống';
}
