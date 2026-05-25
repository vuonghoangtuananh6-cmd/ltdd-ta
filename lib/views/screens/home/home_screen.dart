import 'package:flutter/material.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/search_controller.dart';
import '../../../utils/constants.dart';
import '../../widgets/hotel_card.dart';
import '../../widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = BookingSearchController();
  final _homeController = HomeController();

  final _cityCtrl = TextEditingController(text: "Hà Nội");
  String _checkInDateStr = "2026-06-15";
  String _checkOutDateStr = "2026-06-17";
  int _guests = 2;
  int _rooms = 1;

  @override
  void initState() {
    super.initState();
    _searchController.submitBookingSearch(
      city: "Hà Nội",
      checkIn: _checkInDateStr,
      checkOut: _checkOutDateStr,
      guests: _guests,
      rooms: _rooms,
    );
  }

  void _triggerSearch() {
    _searchController.submitBookingSearch(
      city: _cityCtrl.text.trim(),
      checkIn: _checkInDateStr,
      checkOut: _checkOutDateStr,
      guests: _guests,
      rooms: _rooms,
    );
    setState(() {});
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
            colorScheme: ColorScheme.light(
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
      _triggerSearch();
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
              title: const Text("Chọn số lượng"),
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
                    _triggerSearch();
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

  void _simulateVoiceSearch() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.mic, size: 48, color: AppColors.orange),
          title: const Text("Tìm kiếm bằng giọng nói"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Nói địa điểm bạn muốn tìm (ví dụ: 'Tìm khách sạn tại Sapa')",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.slate500, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Hoặc nhập câu giả lập rác thoại...",
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ["Sapa", "Đà Nẵng", "Phú Quốc"].map((suggestion) {
                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: () {
                      textController.text = "Tôi muốn tìm khách sạn tại $suggestion";
                    },
                  );
                }).toList(),
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
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  _searchController.handleVoiceInput(text);
                  setState(() {
                    _cityCtrl.text = _searchController.searchCity;
                  });
                  _triggerSearch();
                }
                Navigator.pop(context);
              },
              child: const Text("Xử lý"),
            ),
          ],
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
      body: SafeArea(
        child: Column(
          children: [
            // Welcoming Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ValueListenableBuilder(
                valueListenable: _homeController.currentUserNotifier,
                builder: (context, user, child) {
                  return Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          user.avatarUrl.isNotEmpty
                              ? user.avatarUrl
                              : "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100",
                        ),
                        radius: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Chào mừng bạn,",
                              style: TextStyle(color: AppColors.slate500, fontSize: 13),
                            ),
                            Text(
                              user.name.isNotEmpty ? user.name : "Vương Hoàng Tuấn Anh",
                              style: const TextStyle(
                                  color: AppColors.slate900,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: AppColors.slate600),
                        onPressed: () {},
                      ),
                    ],
                  );
                },
              ),
            ),

            // Main Search Form Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  // Destination City with Voice mic integration
                  TextField(
                    controller: _cityCtrl,
                    onSubmitted: (_) => _triggerSearch(),
                    decoration: InputDecoration(
                      labelText: "Địa điểm tìm kiếm",
                      labelStyle: const TextStyle(color: AppColors.slate500),
                      prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.mic, color: AppColors.orange),
                        onPressed: _simulateVoiceSearch,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dates range & Guests
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectDates,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.slate300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Ngày đi - về", style: TextStyle(color: AppColors.slate400, fontSize: 10)),
                                      Text(
                                        "$_checkInDateStr • $_checkOutDateStr",
                                        style: const TextStyle(color: AppColors.slate800, fontSize: 12, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                )
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
                              border: Border.all(color: AppColors.slate300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.people, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Khách & Phòng", style: TextStyle(color: AppColors.slate400, fontSize: 10)),
                                      Text(
                                        "$_guests khách, $_rooms phòng",
                                        style: const TextStyle(color: AppColors.slate800, fontSize: 12, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Sort Order & Filtering Row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Sắp xếp: ${_searchController.searchSortOrder == "POPULAR" ? "Mặc định phổ biến" : _searchController.searchSortOrder == "PRICE_ASC" ? "Giá tốt nhất" : "Điểm đánh giá cao"}",
                          style: const TextStyle(color: AppColors.slate500, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune, color: AppColors.primary),
                        onPressed: _openFilterOptions,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Dynamic results listing
            Expanded(
              child: AnimatedBuilder(
                animation: _searchController,
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
                    padding: const EdgeInsets.only(top: 12, bottom: 24),
                    itemCount: list.length,
                    itemBuilder: (context, rowIndex) {
                      final h = list[rowIndex];
                      return HotelCard(
                        hotel: h,
                        onTap: () {
                          // Navigate to detail screen
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
        ),
      ),
    );
  }
}
