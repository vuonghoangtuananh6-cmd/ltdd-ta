import 'dart:async';
import 'package:flutter/material.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/constants.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  int _countdown = 60;
  Timer? _timer;
  bool _isSending = false;
  String _successMsg = "";

  final _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resendCode() async {
    setState(() {
      _isSending = true;
      _successMsg = "";
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    _startTimer();
    setState(() {
      _isSending = false;
      _successMsg = "Mã xác thực mới đã được gửi thành công.";
    });
  }

  void _simulateVerify() async {
    setState(() {
      _isSending = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    _authController.verifyEmailCode(widget.email);
    setState(() {
      _isSending = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Xác Thực Thành Công!'),
        content: const Text('Tài khoản của bạn đã được kích hoạt thành công.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: const Text('Đăng nhập ngay'),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFF1E293B),
                child: Icon(
                  Icons.mark_email_read,
                  color: Color(0xFFF97316),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Xác thực tài khoản",
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "StayEase đã gửi mã liên kết kích hoạt thật về hòm thư:",
                color: Color(0xFF94A3B8),
                fontSize: 14,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: const TextStyle(color: Color(0xFFF97316), fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Tìm kiếm trong hộp thư đến (Inbox) hoặc hộp thư lọc Spam. Vui lòng nhấn vào liên kết được đính kèm để kích hoạt vĩnh viễn tài khoản của bạn.",
                color: Color(0xFF64748B),
                fontSize: 13,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                color: const Color(0xFF334155).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF475569)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "☘ TRÌNH MÔ PHỎNG KIỂM TRA MÃ HỒM THƯ",
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Thư rác kiểm định được kết nối tự động. Bấm Đã xác thực hoặc nút giả lập liên kết Gmail để kích hoạt tài khoản ngay tức thì.",
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (_successMsg.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(_successMsg, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSending ? null : _simulateVerify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSending
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                              : const Text("ĐÃ XÁC THỰC (MÔ PHỎNG)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _countdown > 0 ? "Gửi lại mã khả dụng sau $_countdown giây" : "Bạn không nhận được liên kết?",
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  if (_countdown == 0)
                    TextButton(
                      onPressed: _isSending ? null : _resendCode,
                      child: const Text("Gửi lại ngay", style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
                    )
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text("Quay lại đăng nhập", style: TextStyle(color: Color(0xFFF97316), fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
