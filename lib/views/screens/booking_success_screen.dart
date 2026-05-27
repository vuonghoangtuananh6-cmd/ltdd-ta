import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../controllers/booking_controller.dart';
import '../../repositories/booking_repository.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve bookingId passed in as routing argument
    final bookingId = ModalRoute.of(context)?.settings.arguments as String?;

    // Retrieve details dynamically matching collectAsState pattern
    final booking = BookingRepository.bookings.value.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => Booking(
        id: "UNKNOWN",
        userId: "",
        hotelId: "",
        roomId: "",
        hotelName: "StayEase Hotel",
        roomName: "Standard Room",
        hotelImage: "",
        checkInDate: "2026-06-01",
        checkOutDate: "2026-06-03",
        nights: 2,
        guestsCount: 2,
        pricePerNight: 500000,
        subtotal: 1000000,
        taxFee: 100000,
        serviceFee: 50000,
        discountAmount: 0,
        totalAmount: 1150000,
        appliedCoupon: null,
        status: BookingStatus.CONFIRMED,
        qrCode: "SE-MOCKQR",
        guestName: "Khách hàng",
        guestEmail: "guest@example.com",
        guestPhone: "0123456789",
        paymentMethod: "Momo",
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Đặt phòng thành công",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
          },
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Success header icon and messages
            const SizedBox(height: 12),
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFF16A34A),
              child: Icon(Icons.check, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              "ĐẶT PHÒNG THÀNH CÔNG!",
              style: TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Cảm ơn bạn đã lựa chọn dịch vụ của chúng tôi!",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Invoice summary details card
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF334155)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildRow("Mã hóa đơn", booking.id.length > 8 ? booking.id.substring(0, 8).toUpperCase() : booking.id, isBold: true),
                    const Divider(color: Color(0xFF334155), height: 16),
                    _buildRow("Khách hàng", booking.guestName),
                    const Divider(color: Color(0xFF334155), height: 16),
                    _buildRow("Khách sạn", booking.hotelName, valColor: Colors.white),
                    const Divider(color: Color(0xFF334155), height: 16),
                    _buildRow("Hạng phòng", booking.roomName),
                    const Divider(color: Color(0xFF334155), height: 16),
                    _buildRow("Thời gian lưu trú", "${booking.checkInDate} ⮕ ${booking.checkOutDate}"),
                    const Divider(color: Color(0xFF334155), height: 16),
                    _buildRow("Số đêm / Khách", "${booking.nights} đêm | ${booking.guestsCount} khách"),
                    const Divider(color: Color(0xFF334155), height: 16),
                    _buildRow(
                      "Tổng tiền đặt phòng",
                      formatPrice(booking.totalAmount),
                      valColor: const Color(0xFFFF7E40),
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // QR check-in ticket widget
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF334155)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Mã check-in nhanh tại quầy",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Hãy đưa mã QR này cho tiếp tân khi check-in để làm thủ tục nhận phòng nhanh",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CustomPaint(
                          size: const Size(120, 120),
                          painter: MockQRCodePainter(booking.id),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking.qrCode,
                      style: const TextStyle(
                        fontFamily: "SpaceGrotesk",
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Return home button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                key: const ValueKey("go_to_home_button"),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "VỀ TRANG CHỦ",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color valColor = Colors.lightGrey, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Custom Painter to paint mock QR Codes matching the original design
class MockQRCodePainter extends CustomPainter {
  final String contentId;
  MockQRCodePainter(this.contentId);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintBlack = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Drawing standard QR locator squares at corners:
    // Top Left:
    canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.25, h * 0.25), paintBlack);
    final paintWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.15, h * 0.15), paintWhite);
    canvas.drawRect(Rect.fromLTWH(w * 0.08, h * 0.08, w * 0.09, h * 0.09), paintBlack);

    // Top Right:
    canvas.drawRect(Rect.fromLTWH(w * 0.75, 0, w * 0.25, h * 0.25), paintBlack);
    canvas.drawRect(Rect.fromLTWH(w * 0.80, h * 0.05, w * 0.15, h * 0.15), paintWhite);
    canvas.drawRect(Rect.fromLTWH(w * 0.83, h * 0.08, w * 0.09, h * 0.09), paintBlack);

    // Bottom Left:
    canvas.drawRect(Rect.fromLTWH(0, h * 0.75, w * 0.25, h * 0.25), paintBlack);
    canvas.drawRect(Rect.fromLTWH(w * 0.05, h * 0.80, w * 0.15, h * 0.15), paintWhite);
    canvas.drawRect(Rect.fromLTWH(w * 0.08, h * 0.83, w * 0.09, h * 0.09), paintBlack);

    // Let's paint some mock grid blocks across the QR pattern
    canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.10, w * 0.08, h * 0.08), paintBlack);
    canvas.drawRect(Rect.fromLTWH(w * 0.45, h * 0.20, w * 0.12, h * 0.08), paintBlack);
    canvas.drawRect(Rect.fromLTWH(w * 0.60, h * 0.10, w * 0.08, h * 0.15), paintBlack);

    canvas.drawRect(Rect.fromLTWH(w * 0.10, h * 0.35, w * 0.15, h * 0.08), paintBlack);
    canvas.drawRect(Rect.fromLTWH(w * 0.40, h * 0.40, w * 0.20, h * 0.10), paintBlack);
    canvas.drawRect(Rect.fromLTWH(w * 0.70, h * 0.35, w * 0.08, h * 0.15), paintBlack);

    canvas.drawRect(Rect.fromLTWH(w * 0.30, h * 0.60, w * 0.10, h * 0.08), paintBlack);
    canvas.drawRect(Rect.fromLTWH(w * 0.50, h * 0.55, w * 0.15, h * 0.15), paintBlack);
    canvas.drawRect(Rect.fromLTWH(w * 0.75, h * 0.60, w * 0.12, h * 0.08), paintBlack);

    canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.80, w * 0.15, h * 0.12), paintBlack);
    canvas.drawRect(Rect.fromLTWH(w * 0.60, h * 0.75, w * 0.08, h * 0.15), paintBlack);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
