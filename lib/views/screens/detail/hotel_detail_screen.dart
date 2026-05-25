import 'package:flutter/material.dart';
import '../../../models/hotel.dart';
import '../../../controllers/favorite_controller.dart';
import '../../../controllers/booking_controller.dart';
import '../../../utils/constants.dart';
import '../../widgets/room_card.dart';

class HotelDetailScreen extends StatefulWidget {
  const HotelDetailScreen({super.key});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final _favoriteController = FavoriteController();
  final _bookingController = BookingController();

  @override
  Widget build(BuildContext context) {
    final hotel = ModalRoute.of(context)!.settings.arguments as Hotel;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top collapses banner
                Stack(
                  children: [
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: PageView.builder(
                        itemCount: hotel.imageUrls.isNotEmpty ? hotel.imageUrls.length : 1,
                        itemBuilder: (context, idx) {
                          final img = hotel.imageUrls.isNotEmpty ? hotel.imageUrls[idx] : "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600";
                          return Image.network(img, fit: BoxFit.cover);
                        },
                      ),
                    ),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),

                // Informational container
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hotel.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.slate900),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${hotel.rating} • ${hotel.reviewCount} đánh giá",
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.slate700),
                                    ),
                                    const SizedBox(width: 8),
                                    ...List.generate(hotel.stars, (index) => const Icon(Icons.star, color: Colors.orange, size: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${hotel.address}, ${hotel.city}",
                              style: const TextStyle(color: AppColors.slate500, fontSize: 13),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Description
                      const Text("Giới thiệu khách sạn", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.slate900)),
                      const SizedBox(height: 8),
                      Text(
                        hotel.description,
                        style: const TextStyle(color: AppColors.slate600, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 20),

                      // Amenities tags
                      const Text("Tiện ích nổi bật", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.slate900)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: hotel.amenities.map((a) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              a,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Available Rooms
                      const Text("Phòng còn trống", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.slate900)),
                      const SizedBox(height: 12),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: hotel.rooms.length,
                        itemBuilder: (context, rIdx) {
                          final room = hotel.rooms[rIdx];
                          return RoomCard(
                            room: room,
                            onBook: () {
                              _bookingController.setSelectedHotelAndRoom(hotel, room);
                              Navigator.pushNamed(context, AppRoutes.checkout);
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Guest Reviews list
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Phản hồi & Đánh giá", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.slate900)),
                          Text("${hotel.rating} / 5", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.orange, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (hotel.reviews.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text("Chưa có đánh giá nào cho khách sạn này.", style: TextStyle(color: AppColors.slate400, fontSize: 13)),
                        )
                      else
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: hotel.reviews.length,
                          itemBuilder: (context, reviewIdx) {
                            final rev = hotel.reviews[reviewIdx];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.slate100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(rev.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 14),
                                          const SizedBox(width: 4),
                                          Text("${rev.rating}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(rev.comment, style: const TextStyle(color: AppColors.slate700, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(rev.createdAt, style: const TextStyle(color: AppColors.slate400, fontSize: 11)),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Custom back & favorite buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.slate800, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              radius: 20,
              child: StatefulBuilder(
                builder: (context, setFavState) {
                  final favorited = _favoriteController.isFavorite(hotel.id);
                  return IconButton(
                    icon: Icon(
                      favorited ? Icons.favorite : Icons.favorite_border,
                      color: favorited ? Colors.red : AppColors.slate800,
                      size: 20,
                    ),
                    onPressed: () {
                      _favoriteController.toggleFavorite(hotel.id);
                      setFavState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            !favorited ? 'Đã lưu khách sạn thành công!' : 'Đã hủy lưu khách sạn thành công!'
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
