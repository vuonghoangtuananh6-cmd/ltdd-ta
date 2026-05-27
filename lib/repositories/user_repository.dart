import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../service/prefs_helper.dart';

class UserRepository {
  static final currentUser = ValueNotifier<User>(User());
  static final recentSearches = ValueNotifier<List<String>>(["Hà Nội", "Đà Nẵng", "Phú Quốc"]);
  static final chatMessages = ValueNotifier<List<Message>>([]);
  static bool _isInitialized = false;

  static void init() {
    if (!_isInitialized) {
      final savedUser = PrefsHelper.loadUser();
      if (savedUser != null) {
        final finalUser = savedUser.email.trim().toLowerCase() == "vuonghoangtuananh6@gmail.com"
            ? savedUser.copyWith(role: "ADMIN")
            : savedUser;
        currentUser.value = finalUser;
      } else {
        currentUser.value = User();
      }

      final savedSearches = PrefsHelper.prefs.getStringList("recent_searches");
      if (savedSearches != null) {
        recentSearches.value = savedSearches;
      }

      chatMessages.value = [
        Message(
          id: 'msg_welcome',
          senderId: 'admin',
          senderName: 'StayEase Support',
          isFromAdmin: true,
          content: 'Xin chào! StayEase rất hân hạnh được hỗ trợ bạn. Bạn cần tìm phòng tại địa điểm nào ạ?',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        )
      ];

      _isInitialized = true;
    }
  }

  static void addChatMessage(String content) {
    init();
    final user = currentUser.value;
    final userMsg = Message(
      id: const Uuid().v4(),
      senderId: user.id,
      senderName: user.name,
      isFromAdmin: false,
      content: content,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    chatMessages.value = [...chatMessages.value, userMsg];

    final String botResponse;
    final text = content.toLowerCase();
    if (text.contains("đặt phòng") || text.contains("booking")) {
      botResponse = "Bạn có thể đặt phòng trực tiếp qua trang chi tiết của mỗi khách sạn! Chọn ngày nhận/trả và phòng mong muốn, sau đó click Đặt Ngay.";
    } else if (text.contains("khuyến mãi") || text.contains("mã giảm") || text.contains("sale")) {
      botResponse = "StayEase đang áp dụng mã giảm giá ưu đãi 'STAYEASE200K' (giảm 200k) và 'WELCOME500K' (giảm 500k). Nhập mã khi thanh toán để được giảm trừ nhé!";
    } else if (text.contains("hà nội") || text.contains("hanoi")) {
      botResponse = "Hà Nội đang có khách sạn sang trọng *Sofitel Legend Metropole Hanoi* cực kì cổ kính và cuốn hút. Bạn có muốn đặt phòng tại đây?";
    } else if (text.contains("hoàn tiền") || text.contains("hủy phòng")) {
      botResponse = "Chính sách hủy phòng linh hoạt áp dụng trước 24 giờ kể từ ngày check-in. Bạn có thể bấm nút Hủy trực tiếp trong Lịch Sử Đặt Phòng.";
    } else {
      botResponse = "Cảm ơn câu hỏi từ quý khách. Đội ngũ StayEase đã nhận được thông tin yêu cầu tư vấn đặt phòng của bạn và sẽ liên hệ ngay qua SĐT: ${user.phoneNumber}. Bạn còn cần hỗ trợ gì khác không?";
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      final adminMsg = Message(
        id: const Uuid().v4(),
        senderId: 'admin',
        senderName: 'StayEase Support',
        isFromAdmin: true,
        content: botResponse,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      chatMessages.value = [...chatMessages.value, adminMsg];
    });
  }

  static void saveUser() {
    PrefsHelper.saveUser(currentUser.value);
  }

  static String getPassword(String email) {
    final emailClean = email.trim().toLowerCase();
    return PrefsHelper.prefs.getString("password_$emailClean") ?? "123456";
  }

  static void savePassword(String email, String pass) {
    final emailClean = email.trim().toLowerCase();
    PrefsHelper.prefs.setString("password_$emailClean", pass);
  }

  static User registerUserAccount(String name, String email, String phone, String pass) {
    final emailClean = email.trim().toLowerCase();
    final isKeyAdmin = emailClean == "vuonghoangtuananh6@gmail.com";
    final newUser = User(
      id: "user_${const Uuid().v4().substring(0, 5)}",
      email: email,
      name: name,
      phoneNumber: phone,
      loyaltyPoints: 500,
      isVerified: isKeyAdmin,
      createdAt: DateTime.now().toIso8601String().substring(0, 19).replaceAll('T', ' '),
      role: isKeyAdmin ? "ADMIN" : "USER",
    );
    currentUser.value = newUser;
    saveUser();
    savePassword(emailClean, pass);
    PrefsHelper.prefs.setString("profile_name_$emailClean", name);
    PrefsHelper.prefs.setString("profile_phone_$emailClean", phone);
    PrefsHelper.prefs.setBool("verified_$emailClean", isKeyAdmin);
    return newUser;
  }

  static bool isEmailVerified(String email) {
    final emailClean = email.trim().toLowerCase();
    if (emailClean == "vuonghoangtuananh6@gmail.com") return true;
    return PrefsHelper.prefs.getBool("verified_$emailClean") ?? false;
  }

  static void markEmailVerified(String email) {
    final emailClean = email.trim().toLowerCase();
    PrefsHelper.prefs.setBool("verified_$emailClean", true);
    if (currentUser.value.email.trim().toLowerCase() == emailClean) {
      currentUser.value = currentUser.value.copyWith(isVerified: true);
      saveUser();
    }
  }

  static bool loginUserAccount(String email, String pass) {
    final emailClean = email.trim().toLowerCase();
    final savedPass = getPassword(emailClean);
    if (savedPass == pass) {
      final name = PrefsHelper.prefs.getString("profile_name_$emailClean") ?? "Vương Hoàng Tuấn Anh";
      final phone = PrefsHelper.prefs.getString("profile_phone_$emailClean") ?? "0987654321";
      final isVerifiedStatus = isEmailVerified(emailClean);
      final isKeyAdmin = emailClean == "vuonghoangtuananh6@gmail.com";
      final loadedUser = User(
        id: "user_${emailClean.hashCode.toString().substring(0, 5)}",
        email: emailClean,
        name: name,
        phoneNumber: phone,
        loyaltyPoints: 450,
        isVerified: isVerifiedStatus,
        createdAt: "2026-05-23",
        role: isKeyAdmin ? "ADMIN" : "USER",
      );
      currentUser.value = loadedUser;
      saveUser();
      return true;
    }
    return false;
  }

  static void googleSignInAccount(String email, String name, String avatarUrl) {
    final emailClean = email.trim().toLowerCase();
    final isKeyAdmin = emailClean == "vuonghoangtuananh6@gmail.com";
    final newUser = User(
      id: "google_${const Uuid().v4().substring(0, 5)}",
      email: emailClean,
      name: name,
      avatarUrl: avatarUrl,
      loyaltyPoints: 500,
      isVerified: true,
      createdAt: DateTime.now().toIso8601String().substring(0, 19).replaceAll('T', ' '),
      role: isKeyAdmin ? "ADMIN" : "USER",
    );
    currentUser.value = newUser;
    saveUser();
    PrefsHelper.prefs.setString("profile_name_$emailClean", name);
    PrefsHelper.prefs.setString("profile_phone_$emailClean", "0987654321");
    PrefsHelper.prefs.setBool("verified_$emailClean", true);
  }

  static void updateProfile(String name, String email, String phone) {
    currentUser.value = currentUser.value.copyWith(name: name, email: email, phoneNumber: phone);
    saveUser();
  }

  static void updateAvatarUrl(String url) {
    currentUser.value = currentUser.value.copyWith(avatarUrl: url);
    saveUser();
  }

  static void setLanguage(String lang) {
    currentUser.value = currentUser.value.copyWith(language: lang);
    saveUser();
  }

  static void setDarkMode(bool enabled) {
    currentUser.value = currentUser.value.copyWith(isDarkMode: enabled);
    saveUser();
  }

  static void rewardLoyaltyPoints(int pts) {
    currentUser.value = currentUser.value.copyWith(loyaltyPoints: currentUser.value.loyaltyPoints + pts);
    saveUser();
  }
}
