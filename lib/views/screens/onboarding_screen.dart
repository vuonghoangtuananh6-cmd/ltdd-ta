// lib/views/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isShowingSplash = true;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Tìm kiếm dễ dàng",
      "description": "Tìm mọi phòng ưng ý, khách sạn sang xịn nhất toàn quốc chỉ với vài thao tác chạm.",
      "image": "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80"
    },
    {
      "title": "Ưu đãi cực khủng",
      "description": "Đối tác chiến lược của Agoda với các coupon giảm đến 500K và hoàn tiền linh hoạt cực nhanh.",
      "image": "https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80"
    },
    {
      "title": "Hỗ trợ 24/7 tức thì",
      "description": "Hỗ trợ khách hàng trực tuyến thông lượng nhanh với robot thông minh và chăm sóc viên StayEase.",
      "image": "https://images.unsplash.com/photo-1534536281715-e28d76689b4d?auto=format&fit=crop&w=800&q=80"
    }
  ];

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  void _startSplashTimer() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      setState(() {
        _isShowingSplash = false;
      });
    }
  }

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    if (_isShowingSplash) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "StayEase",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.black,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Agoda Premium Partner System",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.medium,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFFF97316),
                  strokeWidth: 2.5,
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Image with overlays
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _onboardingData[index]["image"]!,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0F172A).withOpacity(0.1),
                          const Color(0xFF0F172A).withOpacity(0.7),
                          const Color(0xFF0F172A),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.5, 0.9],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Content safe area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upper bar (Skip / Header)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "StayEase",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.black,
                          fontSize: 20,
                        ),
                      ),
                      if (_currentPage < _onboardingData.length - 1)
                        TextButton(
                          onPressed: _finishOnboarding,
                          child: const Text(
                            "Bỏ qua",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),

                  // Info card of current slide
                  Card(
                    color: const Color(0xFF1E293B).withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Color(0xFF334155)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _onboardingData[_currentPage]["title"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _onboardingData[_currentPage]["description"]!,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bottom action row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Indicators
                      Row(
                        children: List.generate(
                          _onboardingData.length,
                          (index) => Container(
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? const Color(0xFFF97316)
                                  : const Color(0xFF475569),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      // Next/Get Started button
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _onboardingData.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _finishOnboarding();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == _onboardingData.length - 1
                                  ? "Bắt đầu ngay"
                                  : "Tiếp tục",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
