
/// Enum định nghĩa các kiểu theme có sẵn
enum AppThemeStyle {
  /// Theme xanh dương (mặc định)
  blue,

  /// Theme xanh lá
  green,

  /// Theme tím
  purple,

  /// Theme cam
  orange,

  /// Theme hồng
  pink,
}

/// Lớp dữ liệu cho cấu hình theme ứng dụng
class AppThemeData {
  /// Kiểu theme (bảng màu)
  final AppThemeStyle themeStyle;

  /// Tạo một instance [AppThemeData] mới
  const AppThemeData({
    this.themeStyle = AppThemeStyle.blue,
  });

  /// Tạo một bản sao của dữ liệu theme này với các trường được thay thế
  AppThemeData copyWith({
    AppThemeStyle? themeStyle,
  }) {
    return AppThemeData(
      themeStyle: themeStyle ?? this.themeStyle,
    );
  }

  /// Dữ liệu theme mặc định
  static const AppThemeData defaultTheme = AppThemeData();

  /// Toán tử so sánh bằng
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppThemeData && other.themeStyle == themeStyle;
  }

  /// Mã hash
  @override
  int get hashCode => themeStyle.hashCode;
}
