import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import 'cancel_booking_button.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TripCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTapDetail;
  final VoidCallback? onCancelSuccess;

  const TripCard({
    super.key,
    required this.booking,
    this.onTapDetail,
    this.onCancelSuccess,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = AppColors.orange;
    Color statusBg = AppColors.orangeLight;
    String statusText = booking.status.name;

    if (booking.status == BookingStatus.CONFIRMED) {
      statusColor = AppColors.green;
      statusBg = AppColors.greenLight;
      statusText = "Được xác nhận";
    } else if (booking.status == BookingStatus.CANCELLED) {
      statusColor = Colors.red;
      statusBg = Colors.red[50]!;
      statusText = "Đã hủy";
    } else if (booking.status == BookingStatus.COMPLETED) {
      statusColor = AppColors.primary;
      statusBg = AppColors.primaryLight;
      statusText = "Đã hoàn thành";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: onTapDetail,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: booking.hotelImage,
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Image.network(
                    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500',
                    height: 90,
                    width: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '#${booking.id}',
                          style: const TextStyle(
                            color: AppColors.slate400,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      booking.hotelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.slate900,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.roomName,
                      style: const TextStyle(
                        color: AppColors.slate500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 14, color: AppColors.slate400),
                        const SizedBox(width: 4),
                        Text(
                          '${booking.checkInDate} → ${booking.checkOutDate}',
                          style: const TextStyle(
                            color: AppColors.slate600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${booking.nights} đêm • ${booking.guestsCount} khách',
                              style: const TextStyle(
                                color: AppColors.slate400,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              formatPrice(booking.totalAmount),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (booking.status == BookingStatus.CONFIRMED || booking.status == BookingStatus.PENDING)
                          CancelBookingButton(
                            bookingId: booking.id,
                            onCancelSuccess: onCancelSuccess,
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
