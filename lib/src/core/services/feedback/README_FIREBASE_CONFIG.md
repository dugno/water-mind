# Cấu hình Firebase Firestore cho tính năng Feedback

Nếu bạn gặp lỗi "The caller does not have permission to execute the specified operation" khi sử dụng tính năng gửi phản hồi, đây là lỗi liên quan đến quyền truy cập trong Firebase Firestore. Bạn cần cấu hình quy tắc bảo mật (security rules) để cho phép ứng dụng ghi dữ liệu vào Firestore.

## Bước 1: Truy cập Firebase Console

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Chọn dự án của bạn (water-mind-bd0ec)
3. Trong menu bên trái, chọn "Firestore Database"

## Bước 2: Cấu hình Security Rules

1. Trong Firestore Database, chọn tab "Rules"
2. Cập nhật quy tắc bảo mật như sau:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Cho phép đọc và ghi vào collection feedback
    match /feedback/{document=**} {
      allow read: if request.auth != null;  // Chỉ cho phép người dùng đã xác thực đọc
      allow write: if true;                 // Cho phép tất cả người dùng ghi
    }

    // Quy tắc mặc định - từ chối tất cả
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

3. Nhấn "Publish" để lưu quy tắc

## Bước 3: Tạo collection (nếu chưa có)

1. Trong Firestore Database, chọn "Start collection" hoặc "Add collection"
2. Đặt Collection ID là "feedback"
3. Bạn có thể tạo một document mẫu hoặc bỏ qua bước này

## Lưu ý về bảo mật

Quy tắc trên cho phép bất kỳ ai cũng có thể gửi phản hồi mà không cần xác thực. Trong môi trường sản xuất, bạn có thể muốn thêm các biện pháp bảo mật bổ sung như:

- Giới hạn tần suất gửi phản hồi
- Yêu cầu xác thực người dùng
- Thêm xác thực dữ liệu

Ví dụ về quy tắc bảo mật nâng cao:

```
match /feedback/{document=**} {
  allow read: if request.auth != null;
  allow create: if
    // Kiểm tra cấu trúc dữ liệu
    request.resource.data.keys().hasOnly(['message', 'userId', 'appVersion', 'deviceInfo', 'language', 'createdAt']) &&
    // Đảm bảo message không trống và có độ dài hợp lý
    request.resource.data.message is string &&
    request.resource.data.message.size() > 0 &&
    request.resource.data.message.size() < 1000;
}
```

## Sử dụng Firebase Emulator (Tùy chọn)

Để phát triển và kiểm tra cục bộ:

1. Cài đặt Firebase CLI: `npm install -g firebase-tools`
2. Đăng nhập: `firebase login`
3. Khởi tạo dự án: `firebase init`
4. Chọn Firestore và Emulators
5. Khởi động emulator: `firebase emulators:start`

## Xử lý lỗi trong ứng dụng

Ứng dụng đã được cập nhật để xử lý lỗi quyền truy cập và lưu phản hồi cục bộ khi không thể gửi lên Firebase. Bạn có thể kiểm tra logs để xem thông tin chi tiết về lỗi.

## Giải pháp tạm thời

Nếu bạn không thể cấu hình Firebase ngay lập tức, ứng dụng đã được cập nhật để:

1. Hiển thị thông báo lỗi thân thiện với người dùng
2. Ghi log lỗi để debug
3. Lưu phản hồi cục bộ (hiện tại chỉ ghi log, nhưng có thể mở rộng để lưu vào database cục bộ)

Bạn có thể tiếp tục sử dụng ứng dụng và cấu hình Firebase sau.
