# Responsive Module

Module Responsive cung cấp các tiện ích để tạo giao diện người dùng thích ứng với các kích thước màn hình, hướng và loại thiết bị khác nhau.

## Cấu trúc

- `screen_utils.dart`: Lớp tiện ích chính cung cấp các phương thức và thuộc tính để tạo UI thích ứng
- `responsive_extension.dart`: Các phương thức mở rộng cho BuildContext để dễ dàng sử dụng các tiện ích responsive
- `responsive_widgets.dart`: Các widget thích ứng với kích thước màn hình
- `responsive.dart`: File barrel xuất tất cả các tiện ích responsive

## Cách sử dụng

### Sử dụng ScreenUtils

```dart
import 'package:koro_foundation/foundation.dart';

void main() {
  // Kiểm tra loại thiết bị
  final deviceType = ScreenUtils.getDeviceType(context);

  if (deviceType == DeviceType.mobile) {
    print('Đang chạy trên điện thoại di động');
  } else if (deviceType == DeviceType.tablet) {
    print('Đang chạy trên máy tính bảng');
  } else {
    print('Đang chạy trên máy tính để bàn');
  }

  // Kiểm tra kích thước màn hình
  final screenSize = ScreenUtils.getScreenSize(context);

  // Lấy giá trị thích ứng dựa trên kích thước màn hình
  final padding = ScreenUtils.responsive<EdgeInsets>(
    context,
    xs: EdgeInsets.all(8),
    sm: EdgeInsets.all(12),
    md: EdgeInsets.all(16),
    lg: EdgeInsets.all(20),
    xl: EdgeInsets.all(24),
    xxl: EdgeInsets.all(32),
  );

  // Tính toán kích thước font chữ thích ứng
  final fontSize = ScreenUtils.responsiveFontSize(
    context,
    size: 16,
    minSize: 12,
    maxSize: 20,
  );

  // Tính toán giá trị dựa trên phần trăm chiều rộng màn hình
  final width = ScreenUtils.widthPercent(context, 50); // 50% chiều rộng màn hình

  // Tính toán giá trị dựa trên phần trăm chiều cao màn hình
  final height = ScreenUtils.heightPercent(context, 30); // 30% chiều cao màn hình
}
```

### Sử dụng ResponsiveExtension

```dart
import 'package:flutter/material.dart';
import 'package:koro_foundation/foundation.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final width = context.screenWidth;
    final height = context.screenHeight;

    // Kiểm tra loại thiết bị
    if (context.isMobile) {
      // UI cho điện thoại di động
    } else if (context.isTablet) {
      // UI cho máy tính bảng
    } else if (context.isDesktop) {
      // UI cho máy tính để bàn
    }

    // Kiểm tra kích thước màn hình
    if (context.isSmallScreen) {
      // UI cho màn hình nhỏ
    } else if (context.isMediumScreen) {
      // UI cho màn hình trung bình
    } else if (context.isLargeScreen) {
      // UI cho màn hình lớn
    }

    // Kiểm tra hướng màn hình
    if (context.isLandscape) {
      // UI cho hướng ngang
    } else {
      // UI cho hướng dọc
    }

    // Lấy giá trị thích ứng dựa trên kích thước màn hình
    final padding = context.responsive<EdgeInsets>(
      xs: EdgeInsets.all(8),
      sm: EdgeInsets.all(12),
      md: EdgeInsets.all(16),
      lg: EdgeInsets.all(20),
      xl: EdgeInsets.all(24),
      xxl: EdgeInsets.all(32),
    );

    // Tính toán kích thước font chữ thích ứng
    final fontSize = context.responsiveFontSize(
      size: 16,
      minSize: 12,
      maxSize: 20,
    );

    // Tính toán giá trị dựa trên phần trăm chiều rộng màn hình
    final buttonWidth = context.widthPercent(50); // 50% chiều rộng màn hình

    return Container(
      width: buttonWidth,
      padding: padding,
      child: Text(
        'Hello World',
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}
```

### Sử dụng ResponsiveWidgets

```dart
import 'package:flutter/material.dart';
import 'package:koro_foundation/foundation.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Responsive Demo'),
      ),
      body: Column(
        children: [
          // Widget thích ứng với loại thiết bị
          ResponsiveBuilder(
            mobile: MobileView(),
            tablet: TabletView(),
            desktop: DesktopView(),
          ),

          // Widget thích ứng với kích thước màn hình
          ResponsiveScreenBuilder(
            xs: Text('Extra Small Screen'),
            sm: Text('Small Screen'),
            md: Text('Medium Screen'),
            lg: Text('Large Screen'),
            xl: Text('Extra Large Screen'),
            xxl: Text('Extra Extra Large Screen'),
          ),

          // Widget thích ứng với hướng màn hình
          ResponsiveOrientationBuilder(
            portrait: PortraitView(),
            landscape: LandscapeView(),
          ),

          // Padding thích ứng
          ResponsivePadding(
            xs: EdgeInsets.all(8),
            sm: EdgeInsets.all(12),
            md: EdgeInsets.all(16),
            lg: EdgeInsets.all(20),
            xl: EdgeInsets.all(24),
            xxl: EdgeInsets.all(32),
            child: Text('Responsive Padding'),
          ),

          // Container thích ứng
          ResponsiveContainer(
            xsWidth: 90, // 90% chiều rộng màn hình trên điện thoại nhỏ
            smWidth: 80, // 80% chiều rộng màn hình trên điện thoại
            mdWidth: 70, // 70% chiều rộng màn hình trên máy tính bảng nhỏ
            lgWidth: 60, // 60% chiều rộng màn hình trên máy tính bảng
            xlWidth: 50, // 50% chiều rộng màn hình trên máy tính để bàn
            xxlWidth: 40, // 40% chiều rộng màn hình trên màn hình lớn
            maxWidth: 1200, // Chiều rộng tối đa
            child: Text('Responsive Container'),
          ),

          // Text thích ứng
          ResponsiveText(
            'Responsive Text',
            fontSize: 16,
            minFontSize: 12,
            maxFontSize: 24,
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

## Các giá trị ngưỡng

### DeviceType

- `mobile`: Chiều rộng < 600dp
- `tablet`: Chiều rộng >= 600dp và < 1200dp
- `desktop`: Chiều rộng >= 1200dp

### ScreenSize

- `xs` (Extra Small): Chiều rộng < 360dp
- `sm` (Small): Chiều rộng >= 360dp và < 600dp
- `md` (Medium): Chiều rộng >= 600dp và < 840dp
- `lg` (Large): Chiều rộng >= 840dp và < 1200dp
- `xl` (Extra Large): Chiều rộng >= 1200dp và < 1440dp
- `xxl` (Extra Extra Large): Chiều rộng >= 1440dp
