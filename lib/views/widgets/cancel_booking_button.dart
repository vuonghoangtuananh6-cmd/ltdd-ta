import 'package:flutter/material.dart';
import '../../controllers/booking_controller.dart';
import '../../utils/constants.dart';

class CancelBookingButton extends StatelessWidget {
  final String bookingId;
  final VoidCallback? onCancelSuccess;

  const CancelBookingButton({super.key, required this.bookingId, this.onCancelSuccess});

  @override
  Widget build(BuildContext context) {
    final bookingController = BookingController();

    return OutlinedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hủy Đặt Phòng?'),
            content: const Text('Bạn có chắc chắn muốn hủy đặt phòng này? Thao tác này không thể hoàn tác.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Không'),
              ),
              TextButton(
                onPressed: () {
                  bookingController.cancelBooking(bookingId);
                  Navigator.pop(context);
                  if (onCancelSuccess != null) {
                    onCancelSuccess!();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đặt phòng của bạn đã được hủy thành công.')),
                  );
                },
                child: const Text('Có, Hủy', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: const Text('Hủy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
