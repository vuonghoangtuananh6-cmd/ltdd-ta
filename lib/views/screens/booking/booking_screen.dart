import 'package:flutter/material.dart';
import '../../../models/hotel.dart';
import '../../../models/room.dart';
import '../../../models/booking.dart';
import '../../../controllers/booking_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../utils/constants.dart';
import '../../../utils/formatters.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _bookingController = BookingController();
  final _authController = AuthController();
  final _homeController = HomeController();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  final _couponCtrl = TextEditingController();

  int _nights = 2;
  int _guests = 2;
  String _selectedPayment = "Momo";
  String _couponCode = "";
  double _couponDiscount = 0.0;
  String _couponMessage = "";
  bool _isSuccess = false;
  bool _isLoading = false;

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
    _couponCtrl.dispose();
    super.dispose();
  }

  void _applyCouponCode() {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) return;

    final match = _bookingController.availableCoupons.firstWhere(
      (c) => c.code.toLowerCase() == code.toLowerCase(),
      orElse: () => Coupon(code: "", name: "", discount: 0, minSpend: 0),
    );

    if (match.code.isNotEmpty) {
      final subtotal = _bookingController.selectedRoom!.price * _nights;
      if (subtotal >= match.minSpend) {
        setState(() {
          _couponCode = match.code;
          _couponDiscount = match.discount;
          _couponMessage = "Áp dụng thành công! Đã giảm -${formatPrice(_couponDiscount)}";
        });
      } else {
        setState(() {
          _couponCode = "";
          _couponDiscount = 0.0;
          _couponMessage = "Đơn phòng tối thiểu phải đạt ${formatPrice(match.minSpend)}";
        });
      }
    } else {
      setState(() {
        _couponCode = "";
        _couponDiscount = 0.0;
        _couponMessage = "Mã giảm giá không hợp lệ";
      });
    }
  }

  void _submitBooking() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin liên hệ!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    final checkIn = DateTime.now().add(const Duration(days: 1)).toIso8601String().substring(0, 10);
    final checkOut = DateTime.now().add(Duration(days: 1 + _nights)).toIso8601String().substring(0, 10);

    final b = _bookingController.createBooking(
      checkIn: checkIn,
      checkOut: checkOut,
      guests: _guests,
      nightsCount: _nights,
      guestName: name,
      guestEmail: email,
      guestPhone: phone,
      paymentMethod: _selectedPayment,
      couponApplied: _couponCode.isNotEmpty ? _couponCode : null,
      couponDiscount: _couponDiscount,
    );

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_bookingController.selectedHotel == null || _bookingController.selectedRoom == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Xác nhận thông tin")),
        body: const Center(
          child: Text("Không tìm thấy thông tin giao dịch đặt phòng!"),
        ),
      );
    }

    final hotel = _bookingController.selectedHotel!;
    final room = _bookingController.selectedRoom!;

    final subtotal = room.price * _nights;
    final tax = subtotal * 0.10;
    final service = subtotal * 0.05;
    final total = subtotal + tax + service - _couponDiscount;

    if (_isSuccess) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.greenLight,
                  child: Icon(Icons.check_circle, size: 56, color: AppColors.green),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Đặt phòng Thành Công!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.slate900),
                ),
                const SizedBox(height: 12),
                Text(
                  "Chúc mừng! Yêu cầu đặt phòng tại ${hotel.name} của bạn đã được xác định thành công.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.slate500, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Card(
                  color: AppColors.slate100,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSummaryRow("Mã giao dịch", "SE-${hotel.id.substring(0, 4).toUpperCase()}"),
                        const Divider(),
                        _buildSummaryRow("Hạng phòng", room.name),
                        const Divider(),
                        _buildSummaryRow("Số lượng đêm", "$_nights đêm"),
                        const Divider(),
                        _buildSummaryRow("Tổng tiền đã thanh toán", formatPrice(total)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
                    },
                    child: const Text("Về trang chủ"),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text("Xác nhận Đặt phòng", style: TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Selected Hotel detail Summary
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        hotel.imageUrls.isNotEmpty ? hotel.imageUrls.first : "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=100",
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.slate900),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            room.name,
                            style: const TextStyle(color: AppColors.slate600, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$_nights đêm | $_guests khách • ${room.bedType}",
                            style: const TextStyle(color: AppColors.slate400, fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Number of Nights Adjustment
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Số lượng đêm lưu trú",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                          onPressed: _nights > 1 ? () => setState(() => _nights--) : null,
                        ),
                        Text("$_nights đêm", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                          onPressed: () => setState(() => _nights++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Contact Form
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Thông Tin Khách Lưu Trú",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: "Họ & Tên liên hệ"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: "Email nhận hóa đơn"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: "Số điện thoại liên lạc"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Coupons Promos
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mã Giảm Giá Ưu Đãi (Coupon)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponCtrl,
                            decoration: const InputDecoration(
                              hintText: "Mã ví dụ: STAYEASE50",
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _applyCouponCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text("Áp Dụng", style: TextStyle(color: Colors.white, fontSize: 13)),
                        )
                      ],
                    ),
                    if (_couponMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _couponMessage,
                          style: TextStyle(
                            color: _couponCode.isNotEmpty ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _bookingController.availableCoupons.map((c) {
                        return ActionChip(
                          label: Text(c.code, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                          backgroundColor: AppColors.primaryLight,
                          side: BorderSide.none,
                          onPressed: () {
                            _couponCtrl.text = c.code;
                            _applyCouponCode();
                          },
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Payment Methods
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Phương Thức Thanh Toán",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900),
                    ),
                    const SizedBox(height: 12),
                    ...[
                      {"id": "Momo", "title": "Ví MoMo lướt thanh toán siêu rẻ", "icon": Icons.wallet},
                      {"id": "ZaloPay", "title": "Khuyến mại hoàn tiền ZaloPay", "icon": Icons.payment},
                      {"id": "VNPay", "title": "Cổng VNPay quét mã QR Ngân Hàng", "icon": Icons.qr_code},
                      {"id": "Credit", "title": "Thẻ tín dụng Visa / MasterCard", "icon": Icons.credit_card},
                      {"id": "COD", "title": "Thanh toán trực tiếp tại quầy tiếp đón", "icon": Icons.storefront},
                    ].map((method) {
                      final selected = _selectedPayment == method['id'];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryLight : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: selected ? AppColors.primary : AppColors.slate200),
                        ),
                        child: ListTile(
                          leading: Icon(method['icon'] as IconData, color: selected ? AppColors.primary : AppColors.slate500),
                          title: Text(method['title'] as String, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                          trailing: selected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                          onTap: () {
                            setState(() {
                              _selectedPayment = method['id'] as String;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Pricing Detail Breakdown
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Chi tiết giá thanh toán",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900),
                    ),
                    const SizedBox(height: 12),
                    _buildPricingRow("Giá gốc phòng (x $_nights đêm)", formatPrice(subtotal)),
                    _buildPricingRow("Thuế VAT (10%)", formatPrice(tax)),
                    _buildPricingRow("Phí dịch vụ & tiện ích Agoda (5%)", formatPrice(service)),
                    if (_couponDiscount > 0)
                      _buildPricingRow("Giảm trừ mã khuyến mãi", "-${formatPrice(_couponDiscount)}", isDiscount: true),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("TỔNG TIỀN ĐẶT PHÒNG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(formatPrice(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.orange)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("XÁC NHẬN & ĐẶT PHÒNG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String field, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(field, style: const TextStyle(color: AppColors.slate500, fontSize: 13)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate800)),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String val, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.slate500, fontSize: 12)),
          Text(
            val,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDiscount ? Colors.green : AppColors.slate800,
            ),
          ),
        ],
      ),
    );
  }
}
