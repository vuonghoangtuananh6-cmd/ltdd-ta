// lib/views/screens/search_screen.dart

import 'package:flutter/material.dart';
import '../../controllers/search_controller.dart';
import '../../controllers/favorite_controller.dart';
import '../../models/hotel.dart';
import '../../repositories/hotel_repository.dart';
import '../../utils/constants.dart';
import '../widgets/hotel_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = BookingSearchController();
  final _favoriteController = FavoriteController();

  final List<String> _cities = [
    "Hà Nội",
    "Đà Nẵng",
    "Sapa",
    "Phú Quốc",
    "Nha Trang",
    "Đà Lạt",
    "Hạ Long",
    "Huế",
    "Vũng Tàu",
    "Ninh Bình",
    "Quy Nhơn"
  ];

  late String _selectedCity;
  late String _checkInDateStr;
  late String _checkOutDateStr;
  late int _guests;
  late int _rooms;

  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _selectedCity = _searchController.searchCity.isNotEmpty ? _searchController.searchCity : "Hà Nội";
    _checkInDateStr = _searchController.checkInDate;
    _checkOutDateStr = _searchController.checkOutDate;
    _guests = _searchController.guestsCount;
    _rooms = _searchController.roomsCount;
    if (_searchController.searchCity.isNotEmpty) {
      _hasSearched = true;
    }
  }

  void _triggerSearch() {
    _searchController.submitBookingSearch(
      city: _selectedCity,
      checkIn: _checkInDateStr,
      checkOut: _checkOutDateStr,
      guests: _guests,
      rooms: _rooms,
    );
    setState(() {
      _hasSearched = true;
    });
  }

  void _selectDates() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: DateTime.parse(_checkInDateStr),
        end: DateTime.parse(_checkOutDateStr),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.slate900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() {
        _checkInDateStr = range.start.toIso8601String().substring(0, 10);
        _checkOutDateStr = range.end.toIso8601String().substring(0, 10);
      });
    }
  }

  void _showGuestsRoomsPicker() {
    showDialog(
      context: context,
      builder: (context) {
        int tempGuests = _guests;
        int tempRooms = _rooms;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Chọn số lượng khách & phòng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Số khách"),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: tempGuests > 1
                                ? () => setDialogState(() => tempGuests--)
                                : null,
                          ),
                          Text("$tempGuests", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setDialogState(() => tempGuests++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Số phòng"),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: tempRooms > 1
                                ? () => setDialogState(() => tempRooms--)
                                : null,
                          ),
                          Text("$tempRooms", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setDialogState(() => tempRooms++),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _guests = tempGuests;
                      _rooms = tempRooms;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Đồng ý"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterBottomSheet(
          searchController: _searchController,
          onApply: () {
            setState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text("Tìm kiếm phòng"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Elegant search options card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                // Dropdown Thành phố
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: InputDecoration(
                    labelText: "Thành phố",
                    prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  items: _cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedCity = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Date Select & Guest Select
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDates,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.slate200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Ngày nhận - trả", style: TextStyle(color: AppColors.slate400, fontSize: 10)),
                              const SizedBox(height: 4),
                              Text(
                                "$_checkInDateStr • $_checkOutDateStr",
                                style: const TextStyle(color: AppColors.slate800, fontSize: 12, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: _showGuestsRoomsPicker,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.slate200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Khách & Phòng", style: TextStyle(color: AppColors.slate400, fontSize: 10)),
                              const SizedBox(height: 4),
                              Text(
                                "$_guests khách, $_rooms phòng",
                                style: const TextStyle(color: AppColors.slate800, fontSize: 12, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Actions row: Filter & Search Submit
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tune, color: AppColors.primary),
                      onPressed: _openFilterOptions,
                      tooltip: "Bộ lọc",
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _triggerSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 20),
                            SizedBox(width: 8),
                            Text("Tìm kiếm ngay"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search results or recent searches description
          if (!_hasSearched)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Tìm kiếm gần đây",
                      style: TextStyle(color: AppColors.slate800, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<List<String>>(
                      valueListenable: HotelRepository.recentSearches,
                      builder: (context, recent, child) {
                        if (recent.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Chưa có tìm kiếm nào gần đây.",
                              style: TextStyle(color: AppColors.slate400, fontSize: 12),
                            ),
                          );
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: recent.map((city) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCity = city;
                                });
                                _triggerSearch();
                              },
                              child: Chip(
                                label: Text(city),
                                labelStyle: const TextStyle(color: AppColors.slate800, fontSize: 11),
                                backgroundColor: Colors.white,
                                deleteIcon: const Icon(Icons.history, size: 14, color: AppColors.slate400),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.travel_explore, size: 64, color: AppColors.primary.withOpacity(0.2)),
                          const SizedBox(height: 12),
                          const Text(
                            "Hãy nhập thông tin ở trên để tìm thấy nơi nghỉ chân tuyệt hảo nhất StayEase nhé!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.slate500, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Sort Chips Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildSortChip("POPULAR", "Phổ biến"),
                  const SizedBox(width: 8),
                  _buildSortChip("PRICE_ASC", "Giá thấp nhất"),
                  const SizedBox(width: 8),
                  _buildSortChip("RATING_DESC", "Đánh giá cao"),
                ],
              ),
            ),

            // Results Listing
            Expanded(
              child: ListenableBuilder(
                listenable: _searchController,
                builder: (context, child) {
                  final list = _searchController.filteredHotels;

                  if (list.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 60, color: AppColors.slate300),
                          SizedBox(height: 12),
                          Text(
                            "Không tìm thấy khách sạn phù hợp bộ lọc!",
                            style: TextStyle(color: AppColors.slate500, fontSize: 14),
                          )
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final h = list[index];
                      return HotelCard(
                        hotel: h,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.hotelDetail,
                            arguments: h,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final selected = _searchController.searchSortOrder == value;
    return GestureDetector(
      onTap: () {
        _searchController.updateFilters(sortOrder: value);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.slate50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.slate200,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.slate700,
            fontSize: 11,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
