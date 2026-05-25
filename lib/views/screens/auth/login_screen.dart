import 'package:flutter/material.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: "vuonghoangtuananh6@gmail.com");
  final _passwordController = TextEditingController(text: "123456");
  bool _passwordVisible = false;
  bool _rememberMe = true;
  String _errorMessage = "";
  bool _isLoading = false;

  final _authController = AuthController();

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains("@")) {
      setState(() {
        _errorMessage = "Vui lòng nhập email hợp lệ";
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        _errorMessage = "Mật khẩu không được để trống";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    final emailClean = email.toLowerCase();

    // Check if verification is needed (e.g., if we registered but didn't verify yet)
    final needsVerify = !_authController.isEmailVerified(emailClean);
    if (needsVerify && emailClean != "vuonghoangtuananh6@gmail.com") {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushNamed(context, AppRoutes.verifyEmail, arguments: email);
      return;
    }

    final success = _authController.login(email, password);
    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (emailClean == "vuonghoangtuananh6@gmail.com") {
        Navigator.pushReplacementNamed(context, AppRoutes.admin);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } else {
      setState(() {
        _errorMessage = "Email hoặc mật khẩu không khớp!";
      });
    }
  }

  void _showGoogleAccountBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final googleAccounts = [
          {
            "name": "Vương Hoàng Tuấn Anh",
            "email": "vuonghoangtuananh6@gmail.com",
            "avatar": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80"
          },
          {
            "name": "Tuan Anh Dev",
            "email": "tuananh.dev.vn@gmail.com",
            "avatar": "https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=150&q=80"
          },
          {
            "name": "Nguyen Quoc Anh",
            "email": "quocanhnguyen@gmail.com",
            "avatar": "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=150&q=80"
          }
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                "Chọn tài khoản Google",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Text(
                "đến ứng dụng StayEase & Agoda booking",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...googleAccounts.map((acc) {
                return Card(
                  color: const Color(0xFF334155).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF475569)),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      Navigator.pop(context);
                      setState(() {
                        _isLoading = true;
                      });
                      await Future.delayed(const Duration(milliseconds: 1200));
                      _authController.googleSignIn(acc['email']!, acc['name']!, acc['avatar']!);
                      setState(() {
                        _isLoading = false;
                      });
                      if (acc['email'] == "vuonghoangtuananh6@gmail.com") {
                        Navigator.pushReplacementNamed(context, AppRoutes.admin);
                      } else {
                        Navigator.pushReplacementNamed(context, AppRoutes.main);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(acc['avatar']!),
                            radius: 20,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(acc['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                Text(acc['email']!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.login, color: Color(0xFFF97316)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Banner background
          Opacity(
            opacity: 0.45,
            child: Image.network(
              "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80",
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.38,
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlays
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0F172A).withOpacity(0.3),
                  const Color(0xFF0F172A).withOpacity(0.92),
                  const Color(0xFF0F172A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 0.9],
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
                      "StayEase",
                      style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.black, letterSpacing: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text(
                          "Agoda Premium Partner System",
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.medium),
                        ),
                        const SizedBox(width: 6),
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Card(
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: const BorderSide(color: Color(0xFF334155)),
                      ),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ĐĂNG NHẬP",
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
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
                                    const Icon(Icons.warning, color: Color(0xFFF87171), size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage,
                                        style: const TextStyle(color: Color(0xFFFECACA), fontSize: 13, fontWeight: FontWeight.medium),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Địa chỉ Email",
                                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                hintText: "email@stayease.com",
                                hintStyle: const TextStyle(color: Color(0xFF475569)),
                                prefixIcon: const Icon(Icons.email, color: Color(0xFFF97316)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF475569)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFF97316)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Mật khẩu",
                                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                prefixIcon: const Icon(Icons.lock, color: Color(0xFFF97316)),
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
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF475569)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFF97316)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      activeColor: const Color(0xFFF97316),
                                      checkColor: Colors.white,
                                      onChanged: (val) {
                                        setState(() {
                                          _rememberMe = val ?? true;
                                        });
                                      },
                                    ),
                                    const Text("Ghi nhớ tôi", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, AppRoutes.forgotPassword);
                                  },
                                  child: const Text(
                                    "Quên mật khẩu?",
                                    style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF97316),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                                    : const Text("ĐĂNG NHẬP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Container(height: 1, color: const Color(0xFF334155))),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text("Hoặc tiếp tục với", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        ),
                        Expanded(child: Container(height: 1, color: const Color(0xFF334155))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _showGoogleAccountBottomSheet,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xFF475569)),
                        ),
                        child: const Text("☘ Đăng nhập bằng Google", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Chưa có tài khoản? ", style: TextStyle(color: Color(0xFF64748B), fontSize: 15)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: const Text("Đăng ký ngay", style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 15)),
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
}
