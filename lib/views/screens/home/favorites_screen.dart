import 'package:flutter/material.dart';
import '../../../controllers/favorite_controller.dart';
import '../../../utils/constants.dart';
import '../../widgets/hotel_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favoriteController = FavoriteController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text("Khách sạn yêu thích"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              _favoriteController.syncFavoritesWithServer();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đồng bộ danh sách yêu thích!')),
              );
            },
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: _favoriteController,
        builder: (context, _) {
          final list = _favoriteController.favorites;

          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: AppColors.slate300),
                  SizedBox(height: 16),
                  Text(
                    "Danh mục trống!",
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate700, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Hãy lưu lại những khách sạn bạn yêu thích nhé.",
                    style: TextStyle(color: AppColors.slate400, fontSize: 13),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: list.length,
            itemBuilder: (context, idx) {
              final h = list[idx];
              return HotelCard(
                hotel: h,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.hotelDetail, arguments: h);
                },
              );
            },
          );
        },
      ),
    );
  }
}
