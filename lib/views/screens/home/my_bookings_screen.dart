import 'package:flutter/material.dart';
import '../../../controllers/booking_controller.dart';
import '../../../utils/constants.dart';
import '../../widgets/trip_card.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _bookingController = BookingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text("Lịch trình đặt phòng"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.slate500,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "Sắp đi"),
            Tab(text: "Đã đi"),
            Tab(text: "Đã hủy"),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _bookingController,
        builder: (context, _) {
          final bookings = _bookingController.userBookings;

          // Filter bookings by status
          final active = bookings.where((b) => b.status.name == "CONFIRMED" || b.status.name == "PENDING").toList();
          final completed = bookings.where((b) => b.status.name == "COMPLETED").toList();
          final cancelled = bookings.where((b) => b.status.name == "CANCELLED").toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(active, "Bạn không có chuyến đi sắp tới nào! Hãy đặt phòng ngay."),
              _buildList(completed, "Không có lịch sử đặt phòng đã hoàn thành!"),
              _buildList(cancelled, "Danh sách đặt phòng bị hủy trống!"),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List bookings, String emptyMsg) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.card_travel, size: 64, color: AppColors.slate300),
              const SizedBox(height: 16),
              Text(
                emptyMsg,
                style: const TextStyle(color: AppColors.slate500, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];
        return TripCard(
          booking: b,
          onCancelSuccess: () {
            setState(() {});
          },
        );
      },
    );
  }
}
