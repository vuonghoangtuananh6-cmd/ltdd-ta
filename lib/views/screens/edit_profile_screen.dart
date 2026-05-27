// lib/views/screens/edit_profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../controllers/home_controller.dart';
import '../../models/user.dart';
import '../../service/media_service.dart';
import '../../utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _homeController = HomeController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    final user = _homeController.currentUser;
    _nameCtrl = TextEditingController(text: user.name);
    _emailCtrl = TextEditingController(text: user.email);
    _phoneCtrl = TextEditingController(text: user.phoneNumber);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final path = await MediaService.pickImage();
    if (path != null) {
      setState(() {
        _localImagePath = path;
      });
      _homeController.updateAvatar(path);
    }
  }

  void _saveProfile(User user) {
    if (_formKey.currentState!.validate()) {
      final name = _nameCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();

      _homeController.updateProfile(name, email, phone);

      final isEn = user.language == "EN";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEn ? "Profile updated successfully!" : "Cập nhật hồ sơ thành công!"),
          backgroundColor: const Color(0xFF22C55E),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<User>(
      valueListenable: _homeController.currentUserNotifier,
      builder: (context, user, _) {
        final isDark = user.isDarkMode;
        final isEn = user.language == "EN";

        final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.primaryBackground;
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final primaryTextColor = isDark ? Colors.white : AppColors.slate900;
        final labelStyle = TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate500);

        ImageProvider avatarImgProvider() {
          if (_localImagePath != null) {
            final file = File(_localImagePath!);
            if (file.existsSync()) {
              return FileImage(file);
            }
          }
          return NetworkImage(
            user.avatarUrl.isNotEmpty ? user.avatarUrl : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80",
          );
        }

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              isEn ? "Edit Information" : "Chỉnh Sửa Hồ Sơ",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Centered Avatar Widget + Picker Icon
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF97316), width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: avatarImgProvider(),
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF97316),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEn ? "Tap camera icon to change photo" : "Nhấp biểu tượng để đổi ảnh",
                    style: TextStyle(color: isDark ? Colors.grey : AppColors.slate500, fontSize: 12),
                  ),
                  const SizedBox(height: 32),

                  // Info Form Card
                  Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? "PERSONAL DETAILS" : "THÔNG TIN CÁ NHÂN",
                            style: TextStyle(
                              color: const Color(0xFFF97316),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Name TextField
                          Text(isEn ? "Full Name" : "Họ và Tên", style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameCtrl,
                            style: TextStyle(color: primaryTextColor, fontSize: 14),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return isEn ? "Name cannot be empty" : "Họ và tên không được để trống";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: isEn ? "e.g. John Doe" : "Ví dụ: Vương Hoàng Tuấn Anh",
                              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                              fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFF97316)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email TextField
                          Text(isEn ? "Email Address" : "Địa chỉ Email", style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailCtrl,
                            style: TextStyle(color: primaryTextColor, fontSize: 14),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return isEn ? "Email cannot be empty" : "Email không được để trống";
                              }
                              final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!regex.hasMatch(val.trim())) {
                                return isEn ? "Invalid email format" : "Email không đúng định dạng";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "example@domain.com",
                              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                              fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFF97316)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Phone Number TextField
                          Text(isEn ? "Phone Number" : "Số Điện Thoại", style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneCtrl,
                            style: TextStyle(color: primaryTextColor, fontSize: 14),
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return isEn ? "Phone cannot be empty" : "Số điện thoại không được để trống";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "e.g. 0987654321",
                              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                              fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey[300]!),
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
                  ),

                  const SizedBox(height: 32),

                  // Form Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _saveProfile(user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: Text(
                        isEn ? "SAVE CHANGES" : "LƯU THAY ĐỔI",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
