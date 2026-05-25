import 'package:flutter/material.dart';
import '../../controllers/search_controller.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class FilterBottomSheet extends StatefulWidget {
  final BookingSearchController searchController;
  final VoidCallback onApply;

  const FilterBottomSheet({super.key, required this.searchController, required this.onApply});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late Set<int> _stars;
  late Set<String> _amenities;
  late String _sortOrder;

  final List<String> _availableAmenities = ["Wifi", "Pool", "Gym", "Breakfast", "Parking", "Spa"];

  @override
  void initState() {
    super.initState();
    _minPrice = widget.searchController.filterPriceMin;
    _maxPrice = widget.searchController.filterPriceMax;
    _stars = Set<int>.from(widget.searchController.filterStars);
    _amenities = Set<String>.from(widget.searchController.filterAmenities);
    _sortOrder = widget.searchController.searchSortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc tìm kiếm',
                style: TextStyle(
                  color: AppColors.slate900,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _minPrice = 0.0;
                    _maxPrice = 20000000.0;
                    _stars.clear();
                    _amenities.clear();
                    _sortOrder = "POPULAR";
                  });
                },
                child: const Text('Thiết lập lại', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sorted By
          const Text('Sắp xếp theo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSortChip("POPULAR", "Phổ biến"),
                const SizedBox(width: 8),
                _buildSortChip("PRICE_ASC", "Giá tăng dần"),
                const SizedBox(width: 8),
                _buildSortChip("RATING_DESC", "Đánh giá cao"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Price Range
          Text(
            'Khoảng giá: ${formatPrice(_minPrice)} - ${formatPrice(_maxPrice)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0.0,
            max: 20000000.0,
            divisions: 20,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.slate200,
            onChanged: (values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },
          ),
          const SizedBox(height: 16),
          // Stars Rating
          const Text('Hạng khách sạn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [3, 4, 5].map((s) {
              final selected = _stars.contains(s);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_stars.contains(s)) {
                        _stars.remove(s);
                      } else {
                        _stars.add(s);
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryLight : AppColors.slate50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.slate200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$s ', style: TextStyle(color: selected ? AppColors.primary : AppColors.slate700, fontWeight: FontWeight.bold)),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Amenities
          const Text('Tiện nghi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableAmenities.map((amenity) {
              final selected = _amenities.contains(amenity);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_amenities.contains(amenity)) {
                      _amenities.remove(amenity);
                    } else {
                      _amenities.add(amenity);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryLight : AppColors.slate50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.slate200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    amenity,
                    style: TextStyle(
                      color: selected ? AppColors.primary : AppColors.slate700,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                widget.searchController.updateFilters(
                  minPrice: _minPrice,
                  maxPrice: _maxPrice,
                  stars: _stars,
                  amenities: _amenities,
                  sortOrder: _sortOrder,
                );
                Navigator.pop(context);
                widget.onApply();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Áp dụng bộ lọc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final selected = _sortOrder == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortOrder = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.slate50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.slate200,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.slate700,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
