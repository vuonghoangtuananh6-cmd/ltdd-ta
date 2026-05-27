import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import '../../models/room.dart';
import '../../models/review.dart';
import '../../repositories/hotel_repository.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class HotelDetailScreen extends StatefulWidget {
  const HotelDetailScreen({super.key});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final _favoriteController = FavoriteController();
  final _bookingController = BookingController();

  final _scrollState = ScrollController();

  // Add review states
  bool _isWritingReview = false;
  double _reviewRating = 5.0;
  final _reviewCommentCtrl = TextEditingController();

  @override
  void dispose() {
    _scrollState.dispose();
    _reviewCommentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotel = ModalRoute.of(context)!.settings.arguments as Hotel;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hotel.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ListenableBuilder(
            listenable: _favoriteController,
            builder: (context, _) {
              final isFavorited = _favoriteController.isFavorite(hotel.id);
              return IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  _favoriteController.toggleWishlist(hotel.id);
                },
              );
            },
          ),
        ],
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFF0F172A),
        child: ListenableBuilder(
          listenable: Listenable.merge([
            HotelRepository.rooms,
            HotelRepository.reviews,
          ]),
          builder: (context, _) {
            // Retrieve data dynamically matching Kotlin collectAsState
            final rooms = HotelRepository.rooms.value
                .where((r) => r.hotelId == hotel.id)
                .toList();
            final reviews = HotelRepository.reviews.value
                .where((rev) => rev.hotelId == hotel.id)
                .toList();

            return SingleChildScrollView(
              controller: _scrollState,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Swipable Photo Carousel
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: PageView.builder(
                      itemCount: hotel.imageUrls.isNotEmpty ? hotel.imageUrls.length : 1,
                      itemBuilder: (context, idx) {
                        final imgUrl = hotel.imageUrls.isNotEmpty
                            ? hotel.imageUrls[idx]
                            : "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800";
                        return Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: const Color(0xFF1E293B),
                              child: const Center(
                                child: CircularProgressIndicator(color: AppColors.orange),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF1E293B),
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stars & Name Block
                        Row(
                          children: [
                            Row(
                              children: List.generate(
                                hotel.stars,
                                (i) => const Icon(Icons.star, color: Color(0xFFEAB308), size: 16),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${hotel.stars} Sao Luxury",
                              style: const TextStyle(
                                color: Color(0xFFEAB308),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hotel.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                hotel.address,
                                style: const TextStyle(color: Colors.lightGrey, fontSize: 12),
                              ),
                            ),
                          ],
                        ),

                        const Divider(color: Color(0xFF334155), height: 32),

                        // Score overview bar
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${hotel.rating}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hotel.rating >= 9.0 ? "Tuyệt hảo" : "Rất tốt",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        "${reviews.length + 15} đánh giá từ hành khách",
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description Block
                        const Text(
                          "Về khách sạn này",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hotel.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Amenities Horizontal Row
                        const Text(
                          "Tiện nghi nổi bật",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 38,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: hotel.amenities.length,
                            itemBuilder: (context, idx) {
                              final amenity = hotel.amenities[idx];
                              IconData icon = Icons.hotel;
                              switch (amenity) {
                                case "Wifi":
                                  icon = Icons.wifi;
                                  break;
                                case "Pool":
                                  icon = Icons.pool;
                                  break;
                                case "Gym":
                                  icon = Icons.fitness_center;
                                  break;
                                case "Breakfast":
                                  icon = Icons.free_breakfast;
                                  break;
                                case "Parking":
                                  icon = Icons.local_parking;
                                  break;
                                case "Spa":
                                  icon = Icons.spa;
                                  break;
                              }
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(icon, color: const Color(0xFFF97316), size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      amenity,
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const Divider(color: Color(0xFF334155), height: 32),

                        // Custom Vector Canvas map representation
                        const Text(
                          "Bản đồ / Vị trí địa lý",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            color: const Color(0xFF243B55),
                            child: Stack(
                              children: [
                                CustomPaint(
                                  size: Size.infinite,
                                  painter: StreetsCanvasPainter(),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Vĩ độ: ${hotel.latitude} | Kinh độ: ${hotel.longitude}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Divider(color: Color(0xFF334155), height: 32),

                        // Select Rooms List
                        const Text(
                          "Chọn Loại Phòng",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 12),

                        ...rooms.map((room) => RoomItemCard(
                              room: room,
                              onRoomSelect: () {
                                _bookingController.selectRoom(hotel, room);
                                Navigator.pushNamed(context, AppRoutes.checkout);
                              },
                            )),

                        const Divider(color: Color(0xFF334155), height: 32),

                        // Reviews Block
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Đánh giá từ du khách",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isWritingReview = !_isWritingReview;
                                });
                              },
                              child: Text(
                                _isWritingReview ? "Hủy bỏ" : "Viết đánh giá ✍",
                                style: const TextStyle(color: Color(0xFFF97316)),
                              ),
                            ),
                          ],
                        ),

                        if (_isWritingReview) ...[
                          Card(
                            color: const Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFF475569)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Viết trải nghiệm của bạn",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text("Số sao: ", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                      Row(
                                        children: List.generate(5, (i) {
                                          final isChecked = i < _reviewRating.toInt();
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _reviewRating = (i + 1).toDouble();
                                              });
                                            },
                                            child: Icon(
                                              isChecked ? Icons.star : Icons.star_border,
                                              color: const Color(0xFFEAB308),
                                              size: 24,
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _reviewCommentCtrl,
                                    decoration: InputDecoration(
                                      hintText: "Mô tả chất lượng phòng, dịch vụ, giường ngủ...",
                                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                                      fillColor: const Color(0xFF0F172A),
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Color(0xFF475569)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Color(0xFFF97316)),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        final comment = _reviewCommentCtrl.text.trim();
                                        if (comment.isNotEmpty) {
                                          HotelRepository.addReview(hotel.id, _reviewRating, comment);
                                          _reviewCommentCtrl.clear();
                                          setState(() {
                                            _reviewRating = 5.0;
                                            _isWritingReview = false;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Cảm ơn bạn đã gửi đánh giá!')),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF97316),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                      child: const Text("Gửi đánh giá", style: TextStyle(color: Colors.white, fontSize: 13)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Reviews list custom widget implementation
                        ...reviews.map((rev) => Card(
                              color: const Color(0xFF1E293B).withOpacity(0.6),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            ClipOval(
                                              child: Image.network(
                                                rev.userAvatar,
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    const Icon(Icons.account_circle, color: Colors.grey, size: 32),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  rev.userName,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  rev.date,
                                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: List.generate(
                                            rev.rating.toInt(),
                                            (i) => const Icon(Icons.star, color: Color(0xFFEAB308), size: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      rev.comment,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Custom painter matching the streets canvas from the Kotlin screens
class StreetsCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintStreet = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines (Mock streets)
    paintStreet.strokeWidth = 12;
    canvas.drawLine(Offset(0, h * 0.3), Offset(w, h * 0.3), paintStreet);

    paintStreet.strokeWidth = 14;
    canvas.drawLine(Offset(0, h * 0.7), Offset(w, h * 0.7), paintStreet);

    // Draw vertical grid lines
    paintStreet.strokeWidth = 16;
    canvas.drawLine(Offset(w * 0.4, 0), Offset(w * 0.4, h), paintStreet);

    // Draw diagonal curving blue rivers
    final paintRiver = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    final path = Path();
    path.moveTo(0, h);
    path.cubicTo(w * 0.2, h * 0.8, w * 0.6, h * 0.2, w, 0);
    canvas.drawPath(path, paintRiver);

    // Draw center location pin radar ripple
    final centerOffset = Offset(w * 0.4, h * 0.3);

    final paintRipple = Paint()
      ..color = const Color(0xFFF97316).withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(centerOffset, 40, paintRipple);

    final paintPin = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(centerOffset, 10, paintPin);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoomItemCard extends StatelessWidget {
  final Room room;
  final VoidCallback onRoomSelect;

  const RoomItemCard({
    super.key,
    required this.room,
    required this.onRoomSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF334155)),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: room.imageUrls.isNotEmpty
                  ? Image.network(room.imageUrls.first, fit: BoxFit.cover)
                  : Container(color: Colors.amber),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  room.description,
                  style: const TextStyle(color: Colors.lightGrey, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Specifications
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.king_bed, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(room.bedType, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.aspect_ratio, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text("${room.sizeSqm} m²", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.group, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text("${room.maxGuests} Tối đa", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ],
                ),

                const Divider(color: Color(0xFF334155), height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Còn lại ${room.totalAvailable} phòng!",
                          style: const TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatPrice(room.price),
                              style: const TextStyle(
                                color: Color(0xFFFF7E40),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text("/đêm", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      key: ValueKey("book_room_button_${room.id}"),
                      onPressed: onRoomSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text(
                        "ĐẶT PHÒNG",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
