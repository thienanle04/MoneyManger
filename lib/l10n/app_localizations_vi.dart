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
  String get navTrans => 'Giao dịch';

  @override
  String get transEmpty => 'Chưa có giao dịch tháng này.';

  @override
  String get transAdd => 'Thêm giao dịch';

  @override
  String get navInsights => 'Phân tích';

  @override
  String get navAccounts => 'Tài khoản';

  @override
  String get navMore => 'Thêm';

  @override
  String get homeWelcome => 'Bảng điều khiển tài chính cá nhân';

  @override
  String get homeSubtitle => 'Ghi nhanh. Thấy chỗ rò rỉ. Theo dõi NAV.';

  @override
  String get homeAccounts => 'Tài khoản';

  @override
  String get homeRecent => 'Gần đây';

  @override
  String get homeThisMonth => 'Tháng này';

  @override
  String get homeTopCategories => 'Danh mục nhiều nhất';

  @override
  String get homeNoEvents => 'Chưa có giao dịch. Hãy ghi giao dịch đầu tiên.';

  @override
  String get homeEmptyAccounts => 'Chưa có tài khoản.';

  @override
  String get captureTitle => 'Ghi nhanh';

  @override
  String get captureComingSoon => 'Ghi giao dịch sẽ có trong bước tiếp theo.';

  @override
  String get captureTypeExpense => 'Chi';

  @override
  String get captureTypeIncome => 'Thu';

  @override
  String get captureTypeTransfer => 'Chuyển';

  @override
  String get captureAmount => 'Số tiền';

  @override
  String get captureAccount => 'Tài khoản';

  @override
  String get captureFromAccount => 'Từ';

  @override
  String get captureToAccount => 'Đến';

  @override
  String get captureCategory => 'Danh mục';

  @override
  String get captureNote => 'Ghi chú';

  @override
  String get captureNoteHint => 'Thêm ghi chú…';

  @override
  String get captureSave => 'Lưu';

  @override
  String get captureContinue => 'Tiếp tục';

  @override
  String get captureSaving => 'Đang lưu…';

  @override
  String captureSaved(String amount) {
    return 'Đã lưu $amount';
  }

  @override
  String get captureDescription => 'Mô tả';

  @override
  String get captureDescriptionHint => 'Thêm chi tiết…';

  @override
  String get captureDone => 'Xong';

  @override
  String get captureCalculator => 'Máy tính';

  @override
  String get captureRepeatLast => 'Lặp giao dịch trước';

  @override
  String get captureDate => 'Ngày';

  @override
  String get captureNoAccountsTitle => 'Chưa có tài khoản';

  @override
  String get captureNoAccountsBody => 'Tạo tài khoản để bắt đầu theo dõi.';

  @override
  String get captureCreateAccount => 'Tạo tài khoản';

  @override
  String get captureNoCategories => 'Chưa có danh mục — thêm trong Cài đặt.';

  @override
  String get captureInvalidAmount => 'Nhập số tiền hợp lệ lớn hơn 0.';

  @override
  String get captureSelectAccount => 'Chọn tài khoản.';

  @override
  String get captureSelectDestAccount => 'Chọn tài khoản đích.';

  @override
  String get captureSelectCategory => 'Chọn danh mục.';

  @override
  String get captureSameAccount => 'Tài khoản nguồn và đích phải khác nhau.';

  @override
  String get captureCrossCurrencyBlocked =>
      'Chuyển khác loại tiền sẽ có ở bước sau.';

  @override
  String get captureError => 'Không lưu được. Thử lại.';

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

  @override
  String get supportedCurrencies => 'Loại tiền hỗ trợ';

  @override
  String get settingsAccounts => 'Tài khoản';

  @override
  String get settingsCategories => 'Danh mục';

  @override
  String get settingsManageAccounts => 'Quản lý tài khoản';

  @override
  String get settingsManageCategories => 'Quản lý danh mục';

  @override
  String get accountName => 'Tên';

  @override
  String get accountType => 'Loại';

  @override
  String get accountCurrency => 'Loại tiền';

  @override
  String get accountIncludeInNav => 'Tính vào NAV';

  @override
  String get accountOpeningBalance => 'Số dư đầu';

  @override
  String get accountAdd => 'Thêm tài khoản';

  @override
  String get accountEdit => 'Sửa tài khoản';

  @override
  String get accountSave => 'Lưu tài khoản';

  @override
  String get accountTypeCash => 'Tiền mặt';

  @override
  String get accountTypeBank => 'Ngân hàng';

  @override
  String get accountTypeEwallet => 'Ví điện tử';

  @override
  String get accountGroupCash => 'Tiền mặt';

  @override
  String get accountGroupBank => 'Tài khoản ngân hàng';

  @override
  String get accountGroupEwallet => 'Ví điện tử';

  @override
  String get accountGroupCredit => 'Thẻ tín dụng';

  @override
  String get accountGroupLoan => 'Khoản vay';

  @override
  String get accountGroupOther => 'Khác';

  @override
  String get accountsAssets => 'Tài sản';

  @override
  String get accountsLiabilities => 'Nợ';

  @override
  String get accountsTotal => 'Tổng';

  @override
  String get categoryName => 'Tên';

  @override
  String get categoryIsIncome => 'Danh mục thu';

  @override
  String get categoryAdd => 'Thêm danh mục';

  @override
  String get categoryEdit => 'Sửa danh mục';

  @override
  String get categorySave => 'Lưu danh mục';

  @override
  String get dialogOk => 'Đóng';

  @override
  String get dialogCancel => 'Hủy';

  @override
  String currencyCount(int count) {
    return '$count loại tiền';
  }
}
