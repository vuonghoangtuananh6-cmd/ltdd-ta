import 'package:flutter/material.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String _errorMessage = "";
  bool _isLoading = false;

  final _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    setState(() {}); // trigger rebuild to update strength UI
  }

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUpper => _passwordController.text.codeUnits.any((c) => (c >= 65 && c <= 90)); // A-Z
  bool get _hasNumber => _passwordController.text.codeUnits.any((c) => (c >= 48 && c <= 57)); // 0-9
  bool get _hasSpecial => _passwordController.text.isNotEmpty && _passwordController.text.codeUnits.any((c) => !(c >= 65 && c <= 90) && !(c >= 97 && c <= 122) && !(c >= 48 && c <= 57));

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      setState(() {
        _errorMessage = "Vui lòng nhập đầy đủ thông tin";
      });
      return;
    }
    if (!email.contains("@")) {
      setState(() {
        _errorMessage = "Địa chỉ email không hợp lệ";
      });
      return;
    }
    if (phone.length < 9) {
      setState(() {
        _errorMessage = "Số điện thoại không hợp lệ";
      });
      return;
    }
    if (!_hasMinLength || !_hasUpper || !_hasNumber || !_hasSpecial) {
      setState(() {
        _errorMessage = "Mật khẩu chưa đạt yêu cầu bảo mật!";
      });
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Mật khẩu xác nhận không trùng khớp!";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      _authController.register(name, email, phone, password);
      setState(() {
        _isLoading = false;
      });

      // Navigate to Email Verification simulator
      Navigator.pushNamed(context, AppRoutes.verifyEmail, arguments: email);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Lỗi đăng ký tài khoản!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Upper asset
          Opacity(
            opacity: 0.4,
            child: Image.network(
              "https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=800&q=80",
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.38,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0F172A).withOpacity(0.3),
                  const Color(0xFF0F172A).withOpacity(0.95),
                  const Color(0xFF0F172A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    const Text(
                      "Tạo tài khoản",
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.black),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Gia nhập hệ thống VIP của StayEase & Agoda Partner",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: const BorderSide(color: Color(0xFF334155)),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_errorMessage.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7F1D1D),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFF87171)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning, color: Color(0xFFF87171), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage,
                                        style: const TextStyle(color: Color(0xFFFECACA), fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            _buildField(_nameController, "Họ & Tên", Icons.person, false, null),
                            const SizedBox(height: 12),
                            _buildField(_emailController, "Địa chỉ Email", Icons.email, false, TextInputType.emailAddress),
                            const SizedBox(height: 12),
                            _buildField(_phoneController, "Số điện thoại", Icons.phone, false, TextInputType.phone),
                            const SizedBox(height: 12),
                            _buildField(
                              _passwordController,
                              "Mật khẩu",
                              Icons.lock,
                              !_passwordVisible,
                              null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: const Color(0xFF64748B),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                            // Realtime strength indicator
                            if (_passwordController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text(
                                "Độ mạnh mật khẩu:",
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              _buildCriteriaRow("Tối thiểu 8 ký tự", _hasMinLength),
                              _buildCriteriaRow("Chứa ít nhất 1 chữ hoa", _hasUpper),
                              _buildCriteriaRow("Chứa ít nhất 1 chữ số", _hasNumber),
                              _buildCriteriaRow("Chứa ít nhất 1 ký tự đặc biệt", _hasSpecial),
                            ],
                            const SizedBox(height: 12),
                            _buildField(
                              _confirmPasswordController,
                              "Xác nhận mật khẩu",
                              Icons.lock,
                              !_confirmPasswordVisible,
                              null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: const Color(0xFF64748B),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _confirmPasswordVisible = !_confirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF97316),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                                    : const Text("ĐĂNG KÝ NGAY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Đã có tài khoản? ", style: TextStyle(color: Color(0xFF64748B), fontSize: 15)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Đăng nhập ngay", style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool obscure,
    TextInputType? inputType, {
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, color: const Color(0xFFF97316)),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF97316)),
        ),
      ),
    );
  }

  Widget _buildCriteriaRow(String text, bool satisfied) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            satisfied ? Icons.check_circle : Icons.cancel,
            color: satisfied ? const Color(0xFF22C55E) : const Color(0xFF64748B),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: satisfied ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
