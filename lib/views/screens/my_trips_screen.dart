import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../controllers/booking_controller.dart';
import '../../repositories/booking_repository.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import 'booking_success_screen.dart'; // For MockQRCodePainter usage

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _bookingController = BookingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Lịch trình đặt phòng của tôi",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: const Color(0xFFF97316),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFF97316),
          tabs: const [
            Tab(text: "Sắp đi"),
            Tab(text: "Đã hoàn thành"),
            Tab(text: "Đã hủy"),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _bookingController,
        builder: (context, _) {
          final bookings = _bookingController.userBookings;

          // Filter bookings by status matching Kotlin logic
          final active = bookings.where((b) => b.status == BookingStatus.CONFIRMED).toList();
          final completed = bookings.where((b) => b.status == BookingStatus.COMPLETED).toList();
          final cancelled = bookings.where((b) => b.status == BookingStatus.CANCELLED).toList();

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _buildTripList(active, "Bạn không có chuyến đi sắp tới nào!"),
              _buildTripList(completed, "Chưa có lịch sử chuyến đi hoàn thành!"),
              _buildTripList(cancelled, "Danh sách chuyến đi đã hủy trống!"),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTripList(List<Booking> list, String emptyMsg) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.card_travel, size: 64, color: Color(0xFF334155)),
              const SizedBox(height: 16),
              const Text(
                "Danh sách chuyến đi trống",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                emptyMsg,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final booking = list[index];
        return TicketItemCard(
          booking: booking,
          onTap: () {
            _showTripDetailsSheet(booking);
          },
          onCancel: () {
            _showCancelConfirmationDialog(booking);
          },
        );
      },
    );
  }

  // Shows comprehensive details of booking in custom sheet
  void _showTripDetailsSheet(Booking b) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24.0),
          margin: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "CHI TIẾT CHUYẾN ĐI",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(color: Color(0xFF334155), height: 32),

                // Selected Details
                _buildSheetRow("Mã giao dịch", b.id.toUpperCase().substring(0, 8)),
                _buildSheetRow("Điểm đến", b.hotelName),
                _buildSheetRow("Hạng phòng", b.roomName),
                _buildSheetRow("Ngày nhận phòng", b.checkInDate),
                _buildSheetRow("Ngày trả phòng", b.checkOutDate),
                _buildSheetRow("Thời lượng lưu trú", "${b.nights} đêm"),
                _buildSheetRow("Số lượng khách", "${b.guestsCount} khách"),
                _buildSheetRow("Người liên lạc", b.guestName),
                _buildSheetRow("Số điện thoại", b.guestPhone),
                _buildSheetRow("Email hóa đơn", b.guestEmail),
                _buildSheetRow("Hình thức thanh toán", b.paymentMethod),
                _buildSheetRow("Tổng cộng thanh toán", formatPrice(b.totalAmount), isOrange: true),

                const Divider(color: Color(0xFF334155), height: 32),

                const Center(
                  child: Text(
                    "MÃ COU_CODE QUÉT TẠI QUẦY",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      size: const Size(100, 100),
                      painter: MockQRCodePainter(b.id),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    b.qrCode,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF475569)),
                    child: const Text("Đóng", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCancelConfirmationDialog(Booking b) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text("Xác nhận hủy đặt phòng", style: TextStyle(color: Colors.white)),
          content: Text(
            "Bạn có chắc chắn muốn hủy yêu cầu đặt phòng tại ${b.hotelName} không? Giao dịch này không thể hoàn tác.",
            style: const TextStyle(color: Colors.lightGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Không", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _bookingController.cancelBooking(b.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã hủy đặt phòng thành công!')),
                );
              },
              child: const Text("Đúng, Hủy phòng", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSheetRow(String label, String value, {bool isOrange = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              color: isOrange ? const Color(0xFFFF7E40) : Colors.white,
              fontWeight: isOrange ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class TicketItemCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const TicketItemCard({
    super.key,
    required this.booking,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = const Color(0xFF22C55E);
    String statusText = "SẮP ĐI";

    if (booking.status == BookingStatus.COMPLETED) {
      statusColor = const Color(0xFF3B82F6);
      statusText = "ĐÃ ĐI";
    } else if (booking.status == BookingStatus.CANCELLED) {
      statusColor = Colors.red;
      statusText = "ĐÃ HỦY";
    }

    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF334155)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: booking.hotelImage.isNotEmpty
                          ? Image.network(booking.hotelImage, fit: BoxFit.cover)
                          : Container(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.hotelName,
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
                          booking.roomName,
                          style: const TextStyle(color: Colors.lightGrey, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.grey, size: 12),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${booking.checkInDate} ⮕ ${booking.checkOutDate} (${booking.nights} đêm)",
                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // Dashed boarding pass coupon separator notch
            SizedBox(
              height: 20,
              width: double.infinity,
              child: CustomPaint(
                painter: TicketSeparatorPainter(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatPrice(booking.totalAmount),
                        style: const TextStyle(
                          color: Color(0xFFFF7E40),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (booking.status == BookingStatus.CONFIRMED)
                    ElevatedButton(
                      key: ValueKey("cancel_booking_button_${booking.id}"),
                      onPressed: onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        side: const BorderSide(color: Colors.red, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text(
                        "Hủy đặt phòng",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter to draw left and right cutout semi-circle ticket notches
class TicketSeparatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Drawing left semi-cookie cutout
    final paintNotch = Paint()
      ..color = const Color(0xFF0F172A) // Matches screen background to eat the notch
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, h / 2), radius: 8),
      -1.57, // Start angle
      3.14, // End sweep
      true,
      paintNotch,
    );

    // Drawing right semi-cookie cutout
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w, h / 2), radius: 8),
      1.57,
      3.14,
      true,
      paintNotch,
    );

    // Drawing the beautiful horizontal dashed separating line between notches
    final paintDashed = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double startX = 14;
    double dashWidth = 5;
    double dashSpace = 4;
    double endX = w - 14;

    while (startX < endX) {
      canvas.drawLine(Offset(startX, h / 2), Offset(startX + dashWidth, h / 2), paintDashed);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
