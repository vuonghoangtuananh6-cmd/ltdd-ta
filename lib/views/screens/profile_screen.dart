// lib/views/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authController = AuthController();
  final _homeController = HomeController();

  void _handleLogout() {
    _authController.logout();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  void _showAvatarSelectionDialog(User user) {
    final isEn = user.language == "EN";
    final avatarPresets = [
      {"url": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80", "label": isEn ? "Mountain" : "Leo núi"},
      {"url": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80", "label": isEn ? "Beach" : "Đi biển"},
      {"url": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80", "label": isEn ? "Resort" : "Thư giãn"},
      {"url": "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=150&q=80", "label": isEn ? "Metropolis" : "Cảnh phố"},
      {"url": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80", "label": isEn ? "Elite" : "Đại gia"}
    ];

    String editAvatarUrl = user.avatarUrl;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: user.isDarkMode ? AppColors.slate800 : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                isEn ? "Select Beautiful Avatar" : "Đổi Ảnh Đại Diện",
                style: TextStyle(color: user.isDarkMode ? Colors.white : AppColors.slate900, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? "Choose from beautiful travel presets:" : "Hãy chọn một ảnh phong cách du lịch:",
                      style: TextStyle(color: user.isDarkMode ? Colors.grey : AppColors.slate500, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 85,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: avatarPresets.length,
                        itemBuilder: (context, index) {
                          final preset = avatarPresets[index];
                          final url = preset["url"]!;
                          final label = preset["label"]!;
                          final isSelected = editAvatarUrl == url;

                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                editAvatarUrl = url;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(url),
                                      radius: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isSelected ? const Color(0xFFF97316) : Colors.grey,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEn ? "Or enter custom image URL link:" : "Hoặc dán địa chỉ đường dẫn link ảnh riêng:",
                      style: TextStyle(color: user.isDarkMode ? Colors.grey : AppColors.slate500, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: editAvatarUrl),
                      onChanged: (val) {
                        editAvatarUrl = val.trim();
                      },
                      style: TextStyle(color: user.isDarkMode ? Colors.white : AppColors.slate900),
                      decoration: InputDecoration(
                        hintText: isEn ? "Custom URL link" : "Link liên kết ảnh",
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: user.isDarkMode ? AppColors.slate600 : AppColors.slate300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFF97316)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isEn ? "Cancel" : "Hủy", style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (editAvatarUrl.isNotEmpty) {
                      _homeController.updateAvatar(editAvatarUrl);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(isEn ? "Apply" : "Áp dụng", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<User>(
      valueListenable: _homeController.currentUserNotifier,
      builder: (context, user, _) {
        final isDark = user.isDarkMode;
        final isEn = user.language == "EN";
        final isAdmin = user.role == "ADMIN";

        final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.primaryBackground;
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final primaryTextColor = isDark ? Colors.white : AppColors.slate900;
        final secondaryTextColor = isDark ? Colors.lightGray : AppColors.slate500;
        final dividerColor = isDark ? const Color(0xFF334155) : AppColors.slate200;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              isEn ? "Member Account" : "Tài Khoản Thành Viên",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Card
                Card(
                  color: cardColor,
                  shadowColor: Colors.black.withOpacity(0.1),
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Center(
                          child: GestureDetector(
                            key: const ValueKey("avatar_container"),
                            onTap: () {
                              _showAvatarSelectionDialog(user);
                            },
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFF97316), width: 3),
                                  ),
                                  child: CircleAvatar(
                                    radius: 42,
                                    backgroundImage: NetworkImage(
                                      user.avatarUrl.isNotEmpty ? user.avatarUrl : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80",
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF97316),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: TextStyle(fontWeight: FontWeight.black, fontSize: 18, color: primaryTextColor),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        // Loyalty Points indicator
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isEn ? "Gold Loyalty Tier" : "Hạng vàng hoàng kim (Gold Tier)",
                                  style: const TextStyle(color: Color(0xFFEAB308), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${user.loyaltyPoints}/1000 Pts",
                                  style: TextStyle(color: secondaryTextColor, fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: user.loyaltyPoints / 1000.0,
                                color: const Color(0xFFEAB308),
                                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Group 1 Settings
                Text(
                  isEn ? "Application Settings" : "Thiết Lập Ứng Dụng",
                  style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),

                Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  child: Column(
                    children: [
                      // Edit profile information
                      _buildClickableRow(
                        icon: Icons.manage_accounts,
                        label: isEn ? "Edit Personal Information" : "Chỉnh sửa thông tin cá nhân",
                        textColor: primaryTextColor,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.editProfile);
                        },
                      ),
                      Divider(color: dividerColor, height: 1),

                      // Wishlist list
                      _buildClickableRow(
                        icon: Icons.favorite,
                        label: isEn ? "Saved Collections" : "Danh sách yêu thích",
                        textColor: primaryTextColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/wishlist');
                        },
                      ),
                      Divider(color: dividerColor, height: 1),

                      // Change password
                      _buildClickableRow(
                        icon: Icons.lock,
                        label: isEn ? "Change Account Password" : "Đổi mật khẩu tài khoản",
                        textColor: primaryTextColor,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.changePassword);
                        },
                      ),
                      Divider(color: dividerColor, height: 1),

                      // Language Toggle Row
                      InkWell(
                        onTap: () {
                          final current = user.language;
                          _homeController.setLanguage(current == "VI" ? "EN" : "VI");
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.language, color: Color(0xFFF97316), size: 22),
                                  const SizedBox(width: 16),
                                  Text(
                                    isEn ? "Preferred Language" : "Ngôn ngữ ưa thích",
                                    style: TextStyle(color: primaryTextColor, fontSize: 14),
                                  ),
                                ],
                              ),
                              Text(
                                user.language == "VI" ? "Tiếng Việt 🇻🇳" : "English 🇺🇸",
                                style: const TextStyle(color: Color(0xFFF97316), fontSize: 13, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                      Divider(color: dividerColor, height: 1),

                      // Dark Mode Switch
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.dark_mode, color: Color(0xFFF97316), size: 22),
                                const SizedBox(width: 16),
                                Text(
                                  isEn ? "Dark Mode" : "Chế độ tối (Dark Mode)",
                                  style: TextStyle(color: primaryTextColor, fontSize: 14),
                                ),
                              ],
                            ),
                            Switch(
                              value: isDark,
                              onChanged: (val) {
                                _homeController.toggleDarkMode(val);
                              },
                              activeColor: const Color(0xFFF97316),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Group 2 Extra Supports (Policies, support chat, admin panel)
                Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  child: Column(
                    children: [
                      if (isAdmin) ...[
                        _buildClickableRow(
                          icon: Icons.supervisor_account,
                          label: isEn ? "System Admin Dashboard" : "Hệ thống quản trị (Admin Dashboard)",
                          tint: const Color(0xFF60A5FA),
                          textColor: primaryTextColor,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.admin);
                          },
                        ),
                        Divider(color: dividerColor, height: 1),
                      ],
                      _buildClickableRow(
                        icon: Icons.support_agent,
                        label: isEn ? "Customer Support Chat" : "Trò chuyện hỗ trợ khách hàng",
                        textColor: primaryTextColor,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.chat);
                        },
                      ),
                      Divider(color: dividerColor, height: 1),
                      _buildClickableRow(
                        icon: Icons.policy,
                        label: isEn ? "Terms of Service & Privacy" : "Điều khoản phục vụ & Bảo mật",
                        textColor: primaryTextColor,
                        onTap: () {},
                      ),
                      Divider(color: dividerColor, height: 1),
                      _buildClickableRow(
                        icon: Icons.help_outline,
                        label: isEn ? "StayEase Help Center Q&A" : "Trung tâm trợ giúp hỏi đáp StayEase",
                        textColor: primaryTextColor,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    key: const ValueKey("logout_profile_btn"),
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.85),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isEn ? "LOGOUT" : "ĐĂNG XUẤT",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClickableRow({
    required IconData icon,
    required String label,
    Color tint = const Color(0xFFF97316),
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: tint, size: 22),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(color: textColor, fontSize: 13.5),
                ),
              ],
            ),
            const Icon(Icons.keyboard_arrow_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
