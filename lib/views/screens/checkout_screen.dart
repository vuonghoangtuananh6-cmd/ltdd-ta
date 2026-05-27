import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/hotel.dart';
import '../../models/room.dart';
import '../../models/booking.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/home_controller.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _bookingController = BookingController();
  final _homeController = HomeController();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  final _couponCodeCtrl = TextEditingController();

  int _nights = 2;
  int _guests = 2;
  String _selectedPayment = "Momo";
  String? _appliedCouponResult;
  String _messagePromoError = "";
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
    _couponCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotel = _bookingController.selectedHotel;
    final room = _bookingController.selectedRoom;

    if (hotel == null || room == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Xác nhận thông tin", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF0F172A),
        ),
        body: const Container(
          color: Color(0xFF0F172A),
          child: Center(
            child: Text("Không có thông tin giao dịch", style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }

    final double subtotal = room.price * _nights;
    final double discount = _appliedCouponResult != null
        ? _bookingController.applyCoupon(_appliedCouponResult!, subtotal)
        : 0.0;
    final double tax = subtotal * 0.10;
    final double service = subtotal * 0.05;
    final double total = subtotal + tax + service - discount;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Xác nhận Đặt phòng",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Selected Hotel Summary Card
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        hotel.imageUrls.isNotEmpty
                            ? hotel.imageUrls.first
                            : "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=100",
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey, width: 75, height: 75),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            room.name,
                            style: const TextStyle(color: Colors.lightGrey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$_nights đêm | $_guests khách | ${room.bedType}",
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Nights count adjustment
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Số lượng đêm lưu trú",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.orange),
                          onPressed: _nights > 1 ? () => setState(() => _nights--) : null,
                        ),
                        Text(
                          "$_nights đêm",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.orange),
                          onPressed: () => setState(() => _nights++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Guest Details Form Card
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF334155)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Thông Tin Khách Lưu Trú",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const ValueKey("checkout_name"),
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Họ & Tên liên hệ",
                        labelStyle: TextStyle(color: Colors.grey),
                        fillColor: Color(0xFF0F172A),
                        filled: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      key: const ValueKey("checkout_email"),
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: "Email nhận hóa đơn",
                        labelStyle: TextStyle(color: Colors.grey),
                        fillColor: Color(0xFF0F172A),
                        filled: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      key: const ValueKey("checkout_phone"),
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: "Số điện thoại liên lạc",
                        labelStyle: TextStyle(color: Colors.grey),
                        fillColor: Color(0xFF0F172A),
                        filled: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Coupon Code Form Card
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mã Giảm Giá Ưu Đãi (Coupon)",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponCodeCtrl,
                            decoration: const InputDecoration(
                              hintText: "Mã ví dụ: STAYEASE50",
                              hintStyle: TextStyle(color: Colors.grey),
                              fillColor: Color(0xFF0F172A),
                              filled: true,
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final code = _couponCodeCtrl.text.trim();
                            if (code.isEmpty) return;
                            final disc = _bookingController.applyCoupon(code, subtotal);
                            if (disc > 0.0) {
                              setState(() {
                                _appliedCouponResult = code;
                                _messagePromoError =
                                    "Áp dụng thành công! Đã giảm -${formatPrice(disc)}";
                              });
                            } else {
                              setState(() {
                                _appliedCouponResult = null;
                                _messagePromoError = "Mã giảm giá không hợp lệ";
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text("Áp Dụng", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    if (_messagePromoError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _messagePromoError,
                          style: TextStyle(
                            color: _appliedCouponResult != null ? const Color(0xFF22C55E) : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),

                    // Quick select helper chips
                    Wrap(
                      spacing: 8,
                      children: ["STAYEASE50", "WELCOME500K", "AGODASALE"].map((couponCode) {
                        return GestureDetector(
                          onTap: () {
                            _couponCodeCtrl.text = couponCode;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316).withOpacity(0.15),
                              border: Border.all(color: const Color(0xFFF97316).withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              couponCode,
                              style: const TextStyle(
                                color: Color(0xFFF97316),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Payment Methods Card selection
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF334155)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Phương Thức Thanh Toán",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ...[
                      {"method": "Momo", "desc": "Ví MoMo lướt thanh toán siêu rẻ"},
                      {"method": "ZaloPay", "desc": "Khuyến mại hoàn tiền ZaloPay"},
                      {"method": "VNPay", "desc": "Cổng VNPay quét mã QR Ngân Hàng"},
                      {"method": "Credit Card", "desc": "Thẻ tín dụng Visa / MasterCard / JCB"},
                      {"method": "COD", "desc": "Thanh toán trực tiếp tại quầy tiếp đón"},
                    ].map((item) {
                      final method = item["method"]!;
                      final desc = item["desc"]!;
                      final isSelected = _selectedPayment == method;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPayment = method;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: method,
                                groupValue: _selectedPayment,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedPayment = val;
                                    });
                                  }
                                },
                                activeColor: const Color(0xFFF97316),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      desc,
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Invoicing Breakdown Card
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Chi Tiết Hóa Đơn",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Mức giá gốc $_nights đêm", style: const TextStyle(color: Colors.lightGrey, fontSize: 13)),
                        Text(formatPrice(subtotal), style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Thuế VAT (10%)", style: TextStyle(color: Colors.lightGrey, fontSize: 13)),
                        Text(formatPrice(tax), style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Phí phục vụ & bảo an (5%)", style: TextStyle(color: Colors.lightGrey, fontSize: 13)),
                        Text(formatPrice(service), style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                    if (discount > 0.0) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Khuyến trừ ưu đãi", style: TextStyle(color: Color(0xFF22C55E), fontSize: 13)),
                          Text("-${formatPrice(discount)}",
                              style: const TextStyle(
                                  color: Color(0xFF22C55E), fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                    const Divider(color: Color(0xFF334155), height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "TỔNG TIỀN THANH TOÁN",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          formatPrice(total),
                          style: const TextStyle(
                            color: Color(0xFFFF7E40),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                key: const ValueKey("checkout_confirm_booking_btn"),
                onPressed: _isLoading
                    ? null
                    : () async {
                        final name = _nameCtrl.text.trim();
                        final email = _emailCtrl.text.trim();
                        final phone = _phoneCtrl.text.trim();

                        if (name.isEmpty || email.isEmpty || phone.isEmpty) {
                          setState(() {
                            _messagePromoError = "Vui lòng hoàn thiện đúng thông tin khách liên lạc";
                          });
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        // Simulate API network latency
                        await Future.delayed(const Duration(milliseconds: 1200));

                        final bookingId = const Uuid().v4();
                        final checkInDate = formatDate(DateTime.now().add(const Duration(days: 1)));
                        final checkOutDate = formatDate(DateTime.now().add(Duration(days: 1 + _nights)));

                        final booking = Booking(
                          id: bookingId,
                          userId: _homeController.currentUser.id,
                          hotelId: hotel.id,
                          roomId: room.id,
                          hotelName: hotel.name,
                          roomName: room.name,
                          hotelImage: hotel.imageUrls.isNotEmpty ? hotel.imageUrls.first : "",
                          checkInDate: checkInDate,
                          checkOutDate: checkOutDate,
                          nights: _nights,
                          guestsCount: _guests,
                          pricePerNight: room.price,
                          subtotal: subtotal,
                          taxFee: tax,
                          serviceFee: service,
                          discountAmount: discount,
                          totalAmount: total,
                          appliedCoupon: _appliedCouponResult,
                          status: BookingStatus.CONFIRMED,
                          qrCode: "SE-${bookingId.substring(0, 8).toUpperCase()}",
                          guestName: name,
                          guestEmail: email,
                          guestPhone: phone,
                          paymentMethod: _selectedPayment,
                          timestamp: DateTime.now().millisecondsSinceEpoch,
                        );

                        _bookingController.createBooking(booking);

                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.pushNamed(
                            context,
                            '/booking_success',
                            arguments: bookingId,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "XÁC NHẬN ĐẶT PHÒNG",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
