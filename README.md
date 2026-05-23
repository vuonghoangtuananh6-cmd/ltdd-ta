# 🏨 StayEase - Agoda Style Premium Hotel Booking Android System

Chào mừng đến với **StayEase**, hệ thống đặt phòng khách sạn cao cấp được thiết kế theo phong cách Agoda hiện đại. Ứng dụng được xây dựng hoàn toàn bằng **Kotlin** gốc và **Jetpack Compose (Material M3)** hoạt động mượt mà với hiệu năng tối ưu.

Tài liệu này hướng dẫn chi tiết cách cài đặt, cấu hình Firebase và chạy ứng dụng hoàn chỉnh thực tế trên Android Emulator.

---

## 📌 Các Tính Năng Đã Hoàn Thiện (Production-Ready Auth Flow)

Hệ thống Authentication của StayEase đã được hoàn thiện đầy đủ các nghiệp vụ thực tế giống Agoda:

1. **Đăng ký tài khoản mới**:
   - Nhập Họ & Tên, Email, Số điện thoại và Mật khẩu.
   - **Xác thực mật khẩu thông minh thực tế**: Trình chấm điểm độ mạnh mật khẩu hiển thị thời gian thực (đảm bảo độ dài ≥ 8 ký tự, có chữ hoa, chữ thường, số, ký tự đặc biệt).
   - Kiểm định xác nhận mật khẩu (Confirm Password).
   - Sau khi đăng ký thành công, tài khoản khởi tạo ở trạng thái **Chưa xác thực (isVerified = false)** và dẫn trực tiếp tới `VerifyEmailScreen`.

2. **Kích hoạt & Xác thực Mail (Verify Email)**:
   - Gửi liên kết xác thực thật đến hòm thư Gmail của khách hàng.
   - Nút kiểm tra trạng thái kích hoạt thời gian thực.
   - Bộ đếm ngược (Countdown) 60 giây trước khi cho phép Gửi lại Email (Resend).
   - **Trình giả lập thư rác & Kích hoạt mô phỏng**: Cho phép nhà phát triển / kiểm thử viên bấm nút để gửi tín hiệu xác thực thành công ngay lập tức để tiếp tục trải nghiệm ứng dụng mà không bị nghẽn bởi API bên ngoài.

3. **Đăng nhập nâng cao**:
   - Nhập Email và Mật khẩu với chức năng ẩn/hiện mật khẩu (Password eye visibility toggle).
   - Lựa chọn **Ghi nhớ tôi (Remember Me)** để duy trì trạng thái đăng nhập.
   - Ràng buộc an toàn: Chỉ cho phép tài khoản đã xác thực Email được đăng nhập vào ứng dụng (Ngăn chặn đăng nhập rác).
   - Xử lý các lỗi chuyên nghiệp (Sai mật khẩu, Tài khoản không tồn tại, Email chưa được kích hoạt, lỗi mất mạng, Spam quá số lần).

4. **Đăng nhập Google (Google Sign-In)**:
   - Tích hợp Bottom Sheet hiển thị danh sách tài khoản Google của thiết bị để lựa chọn.
   - Đăng nhập và tự động tạo thông tin người dùng trong cơ sở dữ liệu (lưu trữ Email, Họ tên hiển thị và Ảnh đại diện liên kết trực tiếp).
   - Trạng thái đăng nhập Google được mặc định kích hoạt (isVerified = true).

5. **Lấy lại mật khẩu (Forgot Password)**:
   - Nhập Email đăng ký nhận OTP.
   - Gửi yêu cầu và xác thực bằng 6 chữ số OTP thực tế.
   - Cho phép đặt lại mật khẩu mới với đầy đủ quy tắc bảo mật.

6. **Quản lý Session & Tự động Đăng nhập**:
   - Sử dụng `SharedPreferences` bảo mật cao lưu trữ token phiên đăng nhập.
   - Tự động bỏ qua màn hình chào và Login để đi thẳng vào Trang chủ (Auto-login) khi mở lại ứng dụng nếu Session còn hoạt động.
   - Chức năng Đăng xuất (Logout) xóa sạch hoàn toàn dấu vết phiên đã ghi nhớ.

---

## 🛠️ Hướng Dẫn Thiết Lập Firebase Đầy Đủ (Firebase Setup Guide)

Để kết nối mã nguồn ứng dụng với dự án Firebase của bạn, vui lòng thực hiện từng bước sau:

### Bước 1: Tạo Dự án trên Firebase Console
1. Truy cập [Firebase Console](https://console.firebase.google.com/).
2. Nhấn **Add project**, đặt tên dự án là `StayEase Hotel Booking` và nhấn tiếp tục để tạo.

### Bước 2: Thêm Ứng dụng Android vào Firebase Project
1. Tại màn hình tổng quan của dự án, nhấn chọn biểu tượng **Android**.
2. Điền thông tin đăng ký ứng dụng:
   - **Android package name**: `com.example` (Trùng khớp với cấu hình `namespace` nội bộ trong dự án Android của bạn).
   - **App nickname (optional)**: `StayEase Hotel`
3. Nhập hai mã chứng chỉ kí SHA (Rất quan trọng cho tính năng **Google Sign-In**):
   - Để lấy mã SHA-1 và SHA-256 từ máy của bạn, hãy mở Terminal ngay tại thư mục gốc của dự án này và chạy:
     ```bash
     gradle signingReport
     ```
   - Cuộn lên tìm khối kết quả của nhánh `:app` (thường là cấu hình `debug`). Ví dụ:
     ```text
     Variant: debugAndroidTest
     Config: debug
     Store: ~/.android/debug.keystore
     Alias: AndroidDebugKey
     SHA-1: 5E:8F:16:B0:1F:53:E8:F2:77:D2:C3:7C:1E:E0:9F:5B:3C:99:6E:CD
     SHA-256: F1:5C:DE:2E:39:7C:DF:A8:14:1D:64:1B:77:B8:31:AA:BD:CF:7E:11:0C:03:7E:C1:AA:45:B6:7C:2A:F3:17:F1
     ```
   - Sao chép chính xác hai dòng **SHA-1** và **SHA-256** này dán vào ô đăng ký tương ứng trên Firebase Console.
4. Nhấn **Register app**.

### Bước 3: Tải và Tích Hợp Tập Tin Cấu Hình `google-services.json`
1. Tải tập tin `google-services.json` được cấp từ Firebase.
2. Di chuyển tập tin vừa tải vào thư mục ứng dụng theo đường dẫn biểu mẫu:
   `[MÃ_NGUỒN_STAYEASE]/app/google-services.json`
3. Nhấn Tiếp tục (Next) và tiến hành đồng bộ hóa Gradle để Firebase kích hoạt.

### Bước 4: Kích Hoạt Các Dịch Vụ Authentication trên Firebase
1. Tại menu bên trái của Firebase Console, di chuyển tới mục **Build** -> chọn **Authentication**.
2. Nhấn **Get Started** để kích hoạt dịch vụ.
3. Chuyển sang thẻ **Sign-in method**:
   - **Email/Password**: Nhấn Bật (Enable) -> Lưu lại.
   - **Google**: Nhấn Bật (Enable) -> Điền email hỗ trợ dự án của bạn từ danh sách sổ xuống -> Lưu lại.

---

## 💻 Hướng Dẫn Chạy Thực Tế Trên Android Emulator

Để kiểm thử hiệu năng và toàn bộ giao diện tương tác đặt phòng của StayEase:

### 1. Khởi động Máy ảo Android Emulator
1. Mở phần mềm **Android Studio**.
2. Truy cập công cụ **Device Manager** ở góc bên phải màn hình.
3. Chọn thiết bị ảo của bạn (khuyên dùng thiết bị mức API từ 30 trở lên như Pixel 6/7) -> Nhấp chuột vào nút **Play** để khởi động máy ảo độc lập.

### 2. Tải và Build Ứng dựng
Mở ứng dụng dòng lệnh Terminal của hệ thống để tiến hành kích hoạt cài đặt:

```bash
# Đồng bộ hóa và tải tài nguyên Gradle bổ sung
gradle --no-daemon assembleDebug

# Cài đặt file APK hoàn chỉnh phát hành vào máy ảo đang chạy
gradle installDebug
```

---

## 🏛️ Clean Architecture & Cấu Trúc Thư Mục Dự Án

StayEase kế thừa mô hình thiết kế **MVVM (Model - View - ViewModel)** chuẩn mực, phân tách rõ vai trò của từng tầng nghiệp vụ:

* **`com.example.data.model`**: Chứa toàn bộ các cấu trúc thực thể như `UserModel` (với các trường `id`, `email`, `name`, `phoneNumber`, `loyaltyPoints`, `isVerified`, `createdAt`, `role`).
* **`com.example.data.repository`**: `HotelRepository` đảm nhiệm chức năng lưu trữ ngoại tuyến (`SharedPreferences`), mã hóa mật khẩu bảo mật và duy trì cấu trúc xác thực.
* **`com.example.presentation.viewmodel`**: `HotelViewModel` quản lý trạng thái Reactive Flow (`AuthResult` SUCCESS/ERROR) và phân phối luồng cho các Composables.
* **`com.example.presentation.screens`**: `AuthScreens.kt` chứa toàn bộ 100% mã nguồn UI/UX mang phong cách Agoda sang trọng với các Gradient mượt mà, bộ gõ xác thực trực quan và các nút phản hồi tức thời.
