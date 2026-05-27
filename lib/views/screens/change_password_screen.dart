// lib/views/screens/change_password_screen.dart

import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../utils/constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _authController = AuthController();
  final _homeController = HomeController();
  final _formKey = GlobalKey<FormState>();

  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _oldVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

  String _errorMessage = "";
  String _successMessage = "";

  // Password criteria variables
  bool _hasMinLength = false;
  bool _hasUpper = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  @override
  void initState() {
    super.initState();
    _newPassCtrl.addListener(_evaluatePassword);
  }

  @override
  void dispose() {
    _newPassCtrl.removeListener(_evaluatePassword);
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _evaluatePassword() {
    final text = _newPassCtrl.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasUpper = text.contains(RegExp(r'[A-Z]'));
      _hasNumber = text.contains(RegExp(r'[0-9]'));
      _hasSpecial = text.contains(RegExp(r'[^a-zA-Z0-9]'));
    });
  }

  void _submitChange(String email, bool isEn) {
    setState(() {
      _errorMessage = "";
      _successMessage = "";
    });

    final oldPass = _oldPassCtrl.text;
    final newPass = _newPassCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      setState(() {
        _errorMessage = isEn ? "Please fill in all fields!" : "Vui lòng điền đầy đủ tất cả các trường!";
      });
      return;
    }

    if (!_hasMinLength || !_hasUpper || !_hasNumber || !_hasSpecial) {
      setState(() {
        _errorMessage = isEn ? "New password does not meet security requirements!" : "Mật khẩu mới chưa đủ độ bảo mật!";
      });
      return;
    }

    if (newPass != confirmPass) {
      setState(() {
        _errorMessage = isEn ? "Passwords do not match!" : "Mật khẩu xác nhận không trùng khớp!";
      });
      return;
    }

    final success = _authController.changePassword(email, oldPass, newPass);
    if (success) {
      setState(() {
        _successMessage = isEn ? "Password changed successfully!" : "Đổi mật khẩu thành công!";
        _oldPassCtrl.clear();
        _newPassCtrl.clear();
        _confirmPassCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_successMessage),
          backgroundColor: const Color(0xFF22C55E),
        ),
      );
    } else {
      setState(() {
        _errorMessage = isEn ? "Incorrect old password!" : "Mật khẩu cũ không chính xác!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _homeController.currentUser;
    final isDark = user.isDarkMode;
    final isEn = user.language == "EN";

    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.primaryBackground;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : AppColors.slate900;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          isEn ? "Change Password" : "Đổi Mật Khẩu",
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Icon(
                Icons.shield_outlined,
                size: 64,
                color: Color(0xFFF97316),
              ),
              const SizedBox(height: 12),
              Text(
                isEn ? "Secure Your Account" : "Đổi Mật Khẩu Bảo Mật",
                style: TextStyle(color: primaryTextColor, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Đổi mật khẩu định kỳ giúp tăng tính bảo mật tài khoản đáng kể",
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Old Password
                        Text(isEn ? "Old Password" : "Mật khẩu cũ", style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _oldPassCtrl,
                          obscureText: !_oldVisible,
                          style: TextStyle(color: primaryTextColor, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(_oldVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey, size: 18),
                              onPressed: () => setState(() => _oldVisible = !_oldVisible),
                            ),
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

                        // New Password
                        Text(isEn ? "New Password" : "Mật khẩu mới", style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _newPassCtrl,
                          obscureText: !_newVisible,
                          style: TextStyle(color: primaryTextColor, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(_newVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey, size: 18),
                              onPressed: () => setState(() => _newVisible = !_newVisible),
                            ),
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

                        // Password strengths
                        if (_newPassCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              _buildCriteriaRow(isEn ? "At least 8 characters" : "Tối thiểu 8 ký tự", _hasMinLength, isDark),
                              _buildCriteriaRow(isEn ? "At least 1 uppercase letter" : "Chứa ít nhất 1 chữ hoa", _hasUpper, isDark),
                              _buildCriteriaRow(isEn ? "At least 1 digit" : "Chứa ít nhất 1 chữ số", _hasNumber, isDark),
                              _buildCriteriaRow(isEn ? "At least 1 special character" : "Chứa ít nhất 1 ký tự đặc biệt", _hasSpecial, isDark),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Confirm Password
                        Text(isEn ? "Confirm New Password" : "Xác nhận mật khẩu mới", style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmPassCtrl,
                          obscureText: !_confirmVisible,
                          style: TextStyle(color: primaryTextColor, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(_confirmVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey, size: 18),
                              onPressed: () => setState(() => _confirmVisible = !_confirmVisible),
                            ),
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

                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                          )
                        ],

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _submitChange(user.email, isEn),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Text(
                              isEn ? "UPDATE PASSWORD" : "CẬP NHẬT MẬT KHẨU",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "Quay lại trang cá nhân",
                  style: TextStyle(
                    color: Color(0xFFF97316),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCriteriaRow(String text, bool satisfied, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            satisfied ? Icons.check_circle : Icons.cancel,
            color: satisfied ? const Color(0xFF22C55E) : Colors.red,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: satisfied
                  ? (isDark ? Colors.grey[300] : Colors.grey[700])
                  : (isDark ? Colors.grey : Colors.grey[600]),
            ),
          )
        ],
      ),
    );
  }
}
