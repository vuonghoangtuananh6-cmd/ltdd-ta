// lib/views/screens/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/search_controller.dart';
import '../../controllers/favorite_controller.dart';
import '../../models/hotel.dart';
import '../../models/coupon.dart';
import '../../repositories/hotel_repository.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../widgets/hotel_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _homeController = HomeController();
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

  bool _showVoiceDialog = false;
  String _voiceMessageState = "Đang nghe...";
  Timer? _voiceMockTimer;

  @override
  void initState() {
    super.initState();
    _selectedCity = _searchController.searchCity.isNotEmpty ? _searchController.searchCity : "Hà Nội";
    _checkInDateStr = _searchController.checkInDate;
    _checkOutDateStr = _searchController.checkOutDate;
    _guests = _searchController.guestsCount;
    _rooms = _searchController.roomsCount;
  }

  @override
  void dispose() {
    _voiceMockTimer?.cancel();
    super.dispose();
  }

  void _triggerSearch({String? overrideCity}) {
    final finalCity = overrideCity ?? _selectedCity;
    _searchController.submitBookingSearch(
      city: finalCity,
      checkIn: _checkInDateStr,
      checkOut: _checkOutDateStr,
      guests: _guests,
      rooms: _rooms,
    );

    // Navigate to Search tab (Tab index 1 in MainScreen value, but we can also just push custom push or let user know)
    // For general flow, the user prompts say: "Search bar shortcut (khi tap → navigate sang SearchScreen)"
    Navigator.pushNamed(context, '/search_destination'); 
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

  void _triggerVoiceMock() {
    setState(() {
      _showVoiceDialog = true;
      _voiceMessageState = "Đang nghe...";
    });

    _voiceMockTimer?.cancel();
    _voiceMockTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _voiceMessageState = "Hành khách đang muốn tìm phòng ở...";
      });

      _voiceMockTimer = Timer(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _voiceMessageState = '"Sapa" 🌫️';
        });

        _voiceMockTimer = Timer(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          setState(() {
            _selectedCity = "Sapa";
            _showVoiceDialog = false;
          });
          _triggerSearch(overrideCity: "Sapa");
        });
      });
    });
  }

  void _showFlightsComboDialog() {
    String originCity = "Hải Phòng";
    String selectedAirline = "Vietnam Airlines";
    bool bookingSuccess = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.flight_takeoff, color: AppColors.green, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Combo Bay + Ở StayEase",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Đồng hành cùng đối tác hàng không để nhận ưu đãi giảm 15% gói combo thẳng vào dịch vụ nghỉ dưỡng của bạn.",
                    style: TextStyle(color: AppColors.slate600, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  if (bookingSuccess)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 36),
                          SizedBox(height: 8),
                          Text("Đã giữ chỗ Combo Bay!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
                          SizedBox(height: 4),
                          Text(
                            "Đã đăng ký giảm thêm 15% vào hóa đơn phòng khách sạn của bạn khi checkout.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Colors.green),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Khởi hành", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate700)),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    originCity = originCity == "Hải Phòng"
                                        ? "TP. Hồ Chí Minh"
                                        : originCity == "TP. Hồ Chí Minh"
                                            ? "Hà Nội"
                                            : "Hải Phòng";
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(originCity, style: const TextStyle(fontSize: 13, color: AppColors.slate900)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Điểm đến", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate700)),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.slate100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(_selectedCity, style: const TextStyle(fontSize: 13, color: AppColors.slate900)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text("Hãng bay đối tác", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate700)),
                    const SizedBox(height: 6),
                    Row(
                      children: ["Vietnam Airlines", "VietJet Air", "Bamboo Airways"].map((airline) {
                        final isSel = selectedAirline == airline;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedAirline = airline;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.green[50] : AppColors.slate100,
                                border: Border.all(color: isSel ? Colors.green : AppColors.slate200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.Center,
                              child: Text(
                                airline,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? Colors.green[700] : AppColors.slate700,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              actions: [
                if (bookingSuccess)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Đóng"),
                  )
                else ...[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setDialogState(() {
                        bookingSuccess = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                    child: const Text("Áp Combo & Giữ vé", style: TextStyle(color: Colors.white)),
                  ),
                ]
              ],
            );
          },
        );
      },
    );
  }

  void _showDealsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<List<Coupon>>(
          valueListenable: _homeController.couponsNotifier,
          builder: (context, coupons, child) {
            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.card_giftcard, color: AppColors.purple, size: 24),
                  SizedBox(width: 8),
                  Text("Ưu Đãi Đặc Biệt & Coupons", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hành khách sao chép coupon để áp giảm giá VND khi đặt phòng nghỉ dưỡng:",
                      style: TextStyle(color: AppColors.slate600, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: coupons.length,
                        itemBuilder: (context, idx) {
                          final coupon = coupons[idx];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: AppColors.purple, width: 0.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(coupon.code, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.purple, fontSize: 14)),
                                      InkWell(
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Đã sao chép coupon: ${coupon.code}")),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.purple.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text("Sao chép", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.purple)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(coupon.description, style: const TextStyle(fontSize: 11, color: AppColors.slate700)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Tối đa: ${formatPrice(coupon.maxDiscount)} | Toàn đơn tối thiểu: ${formatPrice(coupon.minSpend)}",
                                    style: const TextStyle(fontSize: 10, color: AppColors.slate500, fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Đóng"),
                ),
              ],
            );
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
        child: ValueListenableBuilder(
          valueListenable: HotelRepository.hotels,
          builder: (context, allHotels, child) {
            final featuredHotels = allHotels.where((h) => h.isFeatured).toList();
            final recommendedHotels = allHotels.where((h) => !h.isFeatured).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Sleek Greeting Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                                    "Xin chào, 👋",
                                    style: TextStyle(color: AppColors.slate500, fontSize: 13),
                                  ),
                                  Text(
                                    user.name.isNotEmpty ? user.name : "Vương Hoàng Tuấn Anh",
                                    style: const TextStyle(
                                      color: AppColors.slate900,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline, color: AppColors.slate700),
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.chat);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_none, color: AppColors.slate700),
                              onPressed: () {},
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // 2. Flight & Deals Category Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _showFlightsComboDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.green.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.greenLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.flight_takeoff, color: AppColors.green, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Combo Flight", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                                        Text("Giảm ngay 15%", style: TextStyle(fontSize: 10, color: AppColors.slate600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _showDealsDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.purple[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.purple.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.purpleLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.card_giftcard, color: AppColors.purple, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Hot Deals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple)),
                                        Text("Coupons đặc biệt", style: TextStyle(fontSize: 10, color: AppColors.slate600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Carousel Banner Promotion
                  const PromotionCarouselBanner(),

                  const SizedBox(height: 16),

                  // 4. Main Booking Search Form Container
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
                      border: Border.all(color: AppColors.slate200, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Đặt Phòng Khách Sạn & Resort",
                          style: TextStyle(color: AppColors.slate900, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // Destination Input & Mic voice
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCity,
                                decoration: InputDecoration(
                                  labelText: "Điểm đến / Tên khách sạn",
                                  prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: _triggerVoiceMock,
                              child: Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.mic, color: AppColors.primary),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Date Pickers Row
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _selectDates,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.slate200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Nhận phòng", style: TextStyle(color: AppColors.slate500, fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, color: AppColors.primary, size: 14),
                                          const SizedBox(width: 6),
                                          Text(_checkInDateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.slate900)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: _selectDates,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.slate200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Trả phòng", style: TextStyle(color: AppColors.slate500, fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, color: AppColors.primary, size: 14),
                                          const SizedBox(width: 6),
                                          Text(_checkOutDateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.slate900)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Guest selector block
                        InkWell(
                          onTap: _showGuestsRoomsPicker,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.slate200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Khách & Phòng", style: TextStyle(color: AppColors.slate500, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.people, color: AppColors.primary, size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          "$_guests khách, $_rooms phòng",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate900),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Icon(Icons.keyboard_arrow_down, color: AppColors.slate500),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Find Rooms Submit
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _triggerSearch(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("TÌM PHÒNG NGAY", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. AI Recommendation Widget
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCity = "Sapa";
                      });
                      _triggerSearch(overrideCity: "Sapa");
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Gợi ý AI StayEase", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryMedium)),
                                SizedBox(height: 4),
                                Text(
                                  "Hôm nay mát mẻ, Sa Pa đang có tuyết rơi mây phủ rất săn ảnh đẹp đó nhé!",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: AppColors.slate600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCity = "Sapa";
                              });
                              _triggerSearch(overrideCity: "Sapa");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: const Size(60, 32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Chọn", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 6. Featured Hotels
                  _buildSectionHeader("Khách sạn nổi bật 🔥", () {
                    _searchController.submitBookingSearch(city: "", checkIn: _checkInDateStr, checkOut: _checkOutDateStr, guests: _guests, rooms: _rooms);
                    Navigator.pushNamed(context, '/search_destination');
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 250,
                    child: featuredHotels.isEmpty
                        ? const Center(child: Text("Không có khách sạn nổi bật nào.", style: TextStyle(color: AppColors.slate400)))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: featuredHotels.length,
                            itemBuilder: (context, idx) {
                              final hotel = featuredHotels[idx];
                              return _buildHorizontalHotelCard(hotel);
                            },
                          ),
                  ),

                  const SizedBox(height: 24),

                  // 7. Popular Locations
                  _buildSectionHeader("Gợi ý điểm đến phổ biến", () {}),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildCitySticker("Hà Nội", "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=150&q=80"),
                        _buildCitySticker("Đà Nẵng", "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=150&q=80"),
                        _buildCitySticker("Sapa", "https://images.unsplash.com/photo-1495365200479-c4ed1d35e1aa?auto=format&fit=crop&w=150&q=80"),
                        _buildCitySticker("Phú Quốc", "https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=150&q=80"),
                        _buildCitySticker("Nha Trang", "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=150&q=80"),
                        _buildCitySticker("Đà Lạt", "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=150&q=80"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 8. Recommended For You
                  _buildSectionHeader("Dành cho bạn gần đây", () {
                    _searchController.submitBookingSearch(city: "", checkIn: _checkInDateStr, checkOut: _checkOutDateStr, guests: _guests, rooms: _rooms);
                    Navigator.pushNamed(context, '/search_destination');
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: recommendedHotels.isEmpty
                        ? const Center(child: Text("Bản tin trống.", style: TextStyle(color: AppColors.slate400)))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: recommendedHotels.length,
                            itemBuilder: (context, idx) {
                              final hotel = recommendedHotels[idx];
                              return _buildHorizontalMiniCard(hotel);
                            },
                          ),
                  ),

                  const SizedBox(height: 24),

                  // 9. All Hotels (Danh sách tất cả)
                  _buildSectionHeader("Tất cả khách sạn 🏨", () {
                    _searchController.submitBookingSearch(city: "", checkIn: _checkInDateStr, checkOut: _checkOutDateStr, guests: _guests, rooms: _rooms);
                    Navigator.pushNamed(context, '/search_destination');
                  }),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allHotels.length,
                    itemBuilder: (context, idx) {
                      final hotel = allHotels[idx];
                      return HotelCard(
                        hotel: hotel,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.hotelDetail, arguments: hotel);
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),

      // Voice Dialog Mock Overlay
      if (_showVoiceDialog)
        Stack(
          children: [
            ModalBarrier(
              color: Colors.black.withOpacity(0.7),
              dismissible: false,
            ),
            Center(
              child: Card(
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Tìm kiếm giọng nói AI",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.orange.withOpacity(0.2),
                        child: const Icon(Icons.mic, color: Colors.orange, size: 40),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _voiceMessageState,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.slate900, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onViewAll,
            child: const Text(
              "Xem tất cả",
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalHotelCard(Hotel hotel) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
        border: Border.all(color: AppColors.slate200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.hotelDetail, arguments: hotel);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 120,
                width: double.infinity,
                color: AppColors.slate100,
                child: CachedNetworkImage(
                  imageUrl: hotel.imageUrls.isNotEmpty ? hotel.imageUrls.first : 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, err) => const Icon(Icons.broken_image, color: AppColors.slate400),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hotel.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.slate500),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (idx) => Icon(
                            Icons.star,
                            size: 12,
                            color: idx < hotel.stars ? Colors.amber : Colors.grey[300],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text("${hotel.reviewCount} đánh giá", style: const TextStyle(fontSize: 10, color: AppColors.slate500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Giá bình quân", style: TextStyle(fontSize: 11, color: AppColors.slate500)),
                      Text("${formatPrice(hotel.priceMin)}/đêm", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalMiniCard(Hotel hotel) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(color: AppColors.slate200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.hotelDetail, arguments: hotel);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 90,
                width: double.infinity,
                color: AppColors.slate100,
                child: CachedNetworkImage(
                  imageUrl: hotel.imageUrls.isNotEmpty ? hotel.imageUrls.first : 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, err) => const Icon(Icons.broken_image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.slate900),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 10),
                      const SizedBox(width: 2),
                      Text("${hotel.rating} (${hotel.reviewCount})", style: const TextStyle(fontSize: 10, color: AppColors.slate500)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${formatPrice(hotel.priceMin)}/đêm",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCitySticker(String destName, String destImg) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCity = destName;
        });
        _triggerSearch(overrideCity: destName);
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: destImg,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, err) => Container(color: Colors.grey[300]),
              ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.4),
              ),
              alignment: Alignment.Center,
              child: Text(
                destName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PromotionCarouselBanner extends StatefulWidget {
  const PromotionCarouselBanner({super.key});

  @override
  State<PromotionCarouselBanner> createState() => _PromotionCarouselBannerState();
}

class _PromotionCarouselBannerState extends State<PromotionCarouselBanner> {
  final List<Map<String, String>> banners = [
    {"title": "Ưu đãi khai hè: Giảm 20% đặt phòng", "subtitle": "Nhập mã: STAYHUBSALE"},
    {"title": "Tích Gold Point gấp 3 ngày vàng", "subtitle": "Hot deal đặt phòng nghỉ mát"},
    {"title": "Săn Voucher Chào mừng \$100", "subtitle": "Thời hạn áp dụng hữu hạn"}
  ];

  int _currentSlide = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentSlide = (_currentSlide + 1) % banners.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = banners[_currentSlide];

    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F172A).withOpacity(0.9), // Slate 900 feel
            AppColors.primary,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            banner["title"]!,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.black),
          ),
          const SizedBox(height: 4),
          Text(
            banner["subtitle"]!,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              banners.length,
              (idx) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 5,
                width: _currentSlide == idx ? 12 : 5,
                decoration: BoxDecoration(
                  color: _currentSlide == idx ? Colors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
