import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/room.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onBook;
  final VoidCallback? onPlaySelected;
  final VoidCallback? onTap;

  const RoomCard({
    super.key,
    required this.room,
    this.onBook,
    this.onPlaySelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: room.imageUrls.isNotEmpty ? room.imageUrls.first : 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=500',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => Image.network(
                'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=500',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
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
                    color: AppColors.slate900,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  room.description,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFeatureChip(Icons.square_foot, '${room.sizeSqm} m²'),
                    const SizedBox(width: 8),
                    _buildFeatureChip(Icons.bed, room.bedType),
                    const SizedBox(width: 8),
                    _buildFeatureChip(Icons.people, 'Tối đa ${room.maxGuests} khách'),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: room.amenities.map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        amenity,
                        style: const TextStyle(
                          color: AppColors.slate600,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Divider(height: 24, thickness: 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatPrice(room.price),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '/đêm (chưa thuế)',
                          style: TextStyle(
                            color: AppColors.slate500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: onTap ?? onBook ?? onPlaySelected,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text(
                        'Chọn phòng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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

  Widget _buildFeatureChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
