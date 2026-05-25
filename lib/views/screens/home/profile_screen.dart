import 'package:flutter/material.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authController = AuthController();
  final _homeController = HomeController();

  bool _isEnglish = false;
  bool _isDarkMode = false;

  void _handleLogout() {
    _authController.logout();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  void _editPhoneNumber() {
    final curUser = _homeController.currentUser;
    final textCtrl = TextEditingController(text: curUser.phoneNumber);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cập nhật số điện thoại"),
          content: TextField(
            controller: textCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Số điện thoại mới",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                final phone = textCtrl.text.trim();
                if (phone.isNotEmpty) {
                  _authController.updateProfilePhone(phone);
                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: _homeController.currentUserNotifier,
        builder: (context, user, _) {
          final isAdmin = user.email == "vuonghoangtuananh6@gmail.com" || user.role == "ADMIN";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar, loyalty points, and email banner card
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            user.avatarUrl.isNotEmpty ? user.avatarUrl : "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100"
                          ),
                          radius: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.slate900),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(color: AppColors.slate500, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "${user.loyaltyPoints}",
                                  style: const TextStyle(color: AppColors.orange, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const Text("Điểm tích lũy", style: TextStyle(color: AppColors.slate500, fontSize: 12)),
                              ],
                            ),
                            Container(width: 1, height: 35, color: AppColors.slate200),
                            Column(
                              children: [
                                Text(
                                  user.phoneNumber.isNotEmpty ? user.phoneNumber : "Chưa cập nhật",
                                  style: const TextStyle(color: AppColors.slate800, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: _editPhoneNumber,
                                  child: const Text(
                                    "Sửa số điện thoại",
                                    style: TextStyle(color: AppColors.primary, fontSize: 11, decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Settings list
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Language toggle
                      SwitchListTile(
                        title: const Text("Ngôn ngữ tiếng Anh"),
                        value: _isEnglish,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _isEnglish = val;
                          });
                          _homeController.toggleLanguage(val ? "EN" : "VI");
                        },
                      ),
                      const Divider(height: 1),
                      // Dark mode toggle
                      SwitchListTile(
                        title: const Text("Chế độ tối (Dark Mode)"),
                        value: _isDarkMode,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _isDarkMode = val;
                          });
                          _homeController.toggleDarkMode();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Console and support actions list
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      if (isAdmin) ...[
                        ListTile(
                          leading: const Icon(Icons.admin_panel_settings, color: Colors.purple),
                          title: const Text("Bàng điều khiển Admin"),
                          subtitle: const Text("Quản lý khách sạn & số liệu thống kê"),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.admin);
                          },
                        ),
                        const Divider(height: 1),
                      ],
                      ListTile(
                        leading: const Icon(Icons.support_agent, color: AppColors.orange),
                        title: const Text("Trò chuyện hỗ trợ khách hàng"),
                        subtitle: const Text("Hỏi trợ lý ảo hoặc hỗ trợ viên"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.chat);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text("Đăng xuất tài khoản"),
                        onTap: _handleLogout,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
