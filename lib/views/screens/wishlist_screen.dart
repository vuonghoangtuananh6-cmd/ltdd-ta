// lib/views/screens/wishlist_screen.dart

import 'package:flutter/material.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/home_controller.dart';
import '../../models/hotel.dart';
import '../../views/widgets/hotel_card.dart';
import '../../utils/constants.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _favoriteController = FavoriteController();
  final _homeController = HomeController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _homeController.currentUserNotifier,
      builder: (context, user, _) {
        final isDark = user.isDarkMode;
        final isEn = user.language == "EN";

        final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.primaryBackground;
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final primaryTextColor = isDark ? Colors.white : AppColors.slate900;
        final secondaryTextColor = isDark ? Colors.grey : AppColors.slate500;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              isEn ? "Wishlist & Favorites" : "Bộ Sưu Tập Yêu Thích",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListenableBuilder(
            listenable: _favoriteController,
            builder: (context, _) {
              final wishlist = _favoriteController.wishlistHotels;

              if (wishlist.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isEn ? "No saved hotels yet" : "Chưa có khách sạn nào được lưu",
                          style: TextStyle(
                            color: primaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isEn
                              ? "Tap the heart icon when viewing a hotel to save it here!"
                              : "Bấm trái tim thả thương nhớ khi tìm phòng nhé!",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Rendering beautiful 2-column hotel grid as requested in prompt.
              // Utilizing childAspectRatio 0.62 to prevent vertical content clipping inside the small column grid.
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                itemCount: wishlist.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  final hotel = wishlist[index];
                  // Removing massive outer margins of default HotelCard for compact grid layouts
                  return Theme(
                    data: Theme.of(context).copyWith(
                      cardTheme: const CardTheme(
                        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      ),
                    ),
                    child: SizedBox(
                      child: HotelCard(
                        hotel: hotel,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.hotelDetail, arguments: hotel);
                        },
                        onWishlistToggle: () {
                          _favoriteController.toggleWishlist(hotel.id);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
