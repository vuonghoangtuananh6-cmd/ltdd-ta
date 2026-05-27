import 'package:flutter/material.dart';
import '../../controllers/booking_controller.dart';
import '../../models/booking.dart';
import '../../utils/constants.dart';

class CancelBookingButton extends StatelessWidget {
  final String? bookingId;
  final Booking? booking;
  final VoidCallback? onCancelSuccess;
  final VoidCallback? onConfirm;

  const CancelBookingButton({
    super.key,
    this.bookingId,
    this.booking,
    this.onCancelSuccess,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    if (booking != null) {
      final status = booking!.status;
      if (status != BookingStatus.CONFIRMED && status != BookingStatus.PENDING) {
        return const SizedBox.shrink();
      }
    }

    final bookingController = BookingController();
    final actualBookingId = bookingId ?? booking?.id ?? '';

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
                  bookingController.cancelBooking(actualBookingId);
                  Navigator.pop(context);
                  if (onConfirm != null) {
                    onConfirm!();
                  }
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
