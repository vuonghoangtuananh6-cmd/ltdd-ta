// lib/views/screens/admin_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/home_controller.dart';
import '../../models/hotel.dart';
import '../../models/room.dart';
import '../../repositories/hotel_repository.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _adminController = AdminController();
  final _homeController = HomeController();

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

  // --- dialog helper for ADD HOTEL ---
  void _showAddHotelDialog(BuildContext context, bool isDark, bool isEn) {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    int stars = 3;
    bool isFeatured = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.slate800 : Colors.white,
              title: Text(
                isEn ? "Add New Hotel" : "Thêm Khách Sạn Mới",
                style: TextStyle(color: isDark ? Colors.white : AppColors.slate900, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogField(nameCtrl, isEn ? "Hotel Name" : "Tên khách sạn", isDark),
                    const SizedBox(height: 10),
                    _buildDialogField(addrCtrl, isEn ? "Address" : "Địa chỉ", isDark),
                    const SizedBox(height: 10),
                    _buildDialogField(cityCtrl, isEn ? "City" : "Thành phố (ví dụ: Hà Nội)", isDark),
                    const SizedBox(height: 10),
                    _buildDialogField(descCtrl, isEn ? "Description" : "Mô tả ngắn gọn", isDark),
                    const SizedBox(height: 10),
                    _buildDialogField(priceCtrl, isEn ? "Starting Price (VNĐ)" : "Giá tối thiểu (VNĐ)", isDark, isNum: true),
                    const SizedBox(height: 12),
                    // Stars Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEn ? "Star Rating:" : "Số sao đánh giá:",
                          style: TextStyle(color: isDark ? Colors.grey[300] : AppColors.slate700, fontSize: 13),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  stars = index + 1;
                                });
                              },
                              child: Icon(
                                Icons.star_rounded,
                                color: index < stars ? Colors.amber : Colors.grey,
                                size: 28,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Featured toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEn ? "Is Featured?" : "Nổi bật (Featured)?",
                          style: TextStyle(color: isDark ? Colors.grey[300] : AppColors.slate700, fontSize: 13),
                        ),
                        Switch(
                          value: isFeatured,
                          activeColor: const Color(0xFFF97316),
                          onChanged: (val) {
                            setDialogState(() {
                              isFeatured = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isEn ? "Cancel" : "Hủy", style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final addr = addrCtrl.text.trim();
                    final city = cityCtrl.text.trim();
                    final desc = descCtrl.text.trim();
                    final price = double.tryParse(priceCtrl.text.trim()) ?? 800000.0;

                    if (name.isNotEmpty && addr.isNotEmpty && city.isNotEmpty) {
                      final newHotel = Hotel(
                        id: 'hotel_${const Uuid().v4().substring(0, 5)}',
                        name: name,
                        address: addr,
                        city: city,
                        description: desc,
                        stars: stars,
                        rating: 4.6,
                        reviewCount: 15,
                        priceMin: price,
                        isFeatured: isFeatured,
                        imageUrls: [
                          "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500",
                          "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=500"
                        ],
                        amenities: ["Wifi", "Pool", "Gym", "Breakfast", "Spa"],
                      );
                      _adminController.createAdminHotel(newHotel);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(isEn ? "Create" : "Tạo mớiSign", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- dialog helper for EDIT HOTEL ---
  void _showEditHotelDialog(BuildContext context, Hotel hotel, bool isDark, bool isEn) {
    final nameCtrl = TextEditingController(text: hotel.name);
    final addrCtrl = TextEditingController(text: hotel.address);
    final cityCtrl = TextEditingController(text: hotel.city);
    final descCtrl = TextEditingController(text: hotel.description);
    final priceCtrl = TextEditingController(text: hotel.priceMin.toStringAsFixed(0));

    int stars = hotel.stars;
    bool isFeatured = hotel.isFeatured;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.slate800 : Colors.white,
              title: Text(
                isEn ? "Modify Hotel details" : "Chỉnh Sửa Khách Sạn",
                style: TextStyle(color: isDark ? Colors.white : AppColors.slate900, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogField(nameCtrl, isEn ? "Hotel Name" : "Tên khách sạn", isDark),
                    const SizedBox(height: 10),
                    _buildDialogField(addrCtrl, isEn ? "Address" : "Địa chỉ", isDark),
                    const SizedBox(height: 10),
                    _buildDialogField(cityCtrl, isEn ? "City" : "Thành phố", isDark),
                    const SizedBox(height: 10),
                    _buildDialogField(descCtrl, isEn ? "Description" : "Mô tả", isDark),
                    const SizedBox(height: 10),
                    _buildDialogField(priceCtrl, isEn ? "Starting Price (VNĐ)" : "Giá tối thiểu (VNĐ)", isDark, isNum: true),
                    const SizedBox(height: 12),
                    // Stars Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEn ? "Star Rating:" : "Số sao đánh giá:",
                          style: TextStyle(color: isDark ? Colors.grey[300] : AppColors.slate700, fontSize: 13),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  stars = index + 1;
                                });
                              },
                              child: Icon(
                                Icons.star_rounded,
                                color: index < stars ? Colors.amber : Colors.grey,
                                size: 28,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Featured toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEn ? "Is Featured?" : "Nổi bật?",
                          style: TextStyle(color: isDark ? Colors.grey[300] : AppColors.slate700, fontSize: 13),
                        ),
                        Switch(
                          value: isFeatured,
                          activeColor: const Color(0xFFF97316),
                          onChanged: (val) {
                            setDialogState(() {
                              isFeatured = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isEn ? "Cancel" : "Hủy", style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final addr = addrCtrl.text.trim();
                    final city = cityCtrl.text.trim();
                    final desc = descCtrl.text.trim();
                    final price = double.tryParse(priceCtrl.text.trim()) ?? hotel.priceMin;

                    if (name.isNotEmpty && addr.isNotEmpty && city.isNotEmpty) {
                      final updated = hotel.copyWith(
                        name: name,
                        address: addr,
                        city: city,
                        description: desc,
                        stars: stars,
                        priceMin: price,
                        isFeatured: isFeatured,
                      );
                      _adminController.updateAdminHotel(updated);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(isEn ? "Save" : "Lưu", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- dialog helper for ADD ROOM ---
  void _showAddRoomDialog(BuildContext context, List<Hotel> hotels, bool isDark, bool isEn) {
    if (hotels.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDark ? AppColors.slate800 : Colors.white,
          title: Text(isEn ? "Notice" : "Thông báo", style: TextStyle(color: isDark ? Colors.white : AppColors.slate900)),
          content: Text(isEn ? "Please add at least one hotel first!" : "Vui lòng thêm tối thiểu một khách sạn trước!"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK", style: TextStyle(color: Color(0xFFF97316))))
          ],
        ),
      );
      return;
    }

    String selectedHotelId = hotels.first.id;
    final rNameCtrl = TextEditingController();
    final rDescCtrl = TextEditingController();
    final rPriceCtrl = TextEditingController();
    final rBedCtrl = TextEditingController(text: "King Bed");
    final rGuestsCtrl = TextEditingController(text: "2");
    final rSizeCtrl = TextEditingController(text: "32");

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.slate800 : Colors.white,
              title: Text(
                isEn ? "Add Hotel Room" : "Thêm Phòng Khách Sạn",
                style: TextStyle(color: isDark ? Colors.white : AppColors.slate900, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hotel Dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEn ? "Hotel:" : "Thuộc khách sạn:", style: TextStyle(color: isDark ? Colors.grey[300] : AppColors.slate700, fontSize: 12)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            dropdownColor: isDark ? AppColors.slate800 : Colors.white,
                            value: selectedHotelId,
                            style: TextStyle(color: isDark ? Colors.white : AppColors.slate900, fontSize: 12),
                            decoration: const InputDecoration(border: InputBorder.none),
                            items: hotels.map((h) {
                              return DropdownMenuItem<String>(
                                value: h.id,
                                child: Text(h.name, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  selectedHotelId = val;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildDialogField(rNameCtrl, isEn ? "Room Type/Name" : "Loại phòng (ví dụ: Presidential Deluxe)", isDark),
                    const SizedBox(height: 10),
                    _buildDialogField(rDescCtrl, isEn ? "Room Description" : "Mô tả phòng", isDark),
                    const SizedBox(height: 10),
                    _buildDialogField(rPriceCtrl, isEn ? "Price per night (VNĐ)" : "Giá phòng / đêm (VNĐ)", isDark, isNum: true),
                    const SizedBox(height: 10),
                    _buildDialogField(rBedCtrl, isEn ? "Bed Size Type" : "Loại giường", isDark),
                    const SizedBox(height: 10),
                    _buildDialogField(rGuestsCtrl, isEn ? "Guests Cap." : "Số khách tối đa", isDark, isNum: true),
                    const SizedBox(height: 10),
                    _buildDialogField(rSizeCtrl, isEn ? "Size (Sqm)" : "Diện tích (m²)", isDark, isNum: true),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isEn ? "Cancel" : "Hủy", style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final rName = rNameCtrl.text.trim();
                    final rDesc = rDescCtrl.text.trim();
                    final rPrice = double.tryParse(rPriceCtrl.text.trim()) ?? 1200000.0;
                    final gLimit = int.tryParse(rGuestsCtrl.text.trim()) ?? 2;
                    final sqmSize = int.tryParse(rSizeCtrl.text.trim()) ?? 30;

                    if (rName.isNotEmpty) {
                      final newRoom = Room(
                        id: 'room_${const Uuid().v4().substring(0, 5)}',
                        hotelId: selectedHotelId,
                        name: rName,
                        description: rDesc,
                        price: rPrice,
                        bedType: rBedCtrl.text.trim(),
                        maxGuests: gLimit,
                        sizeSqm: sqmSize,
                        imageUrls: [
                          "https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=500"
                        ],
                        amenities: ["AC", "TV", "King size bed", "Bathtub", "Mini bar"],
                        totalAvailable: 5,
                      );
                      _adminController.createAdminRoom(newRoom);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(isEn ? "Add" : "Thêm mới", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogField(TextEditingController ctrl, String hint, bool isDark, {bool isNum = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: isDark ? Colors.white : AppColors.slate900, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isDark ? AppColors.slate600 : AppColors.slate300),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFF97316)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _homeController.currentUser;
    final isDark = user.isDarkMode;
    final isEn = user.language == "EN";

    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.primaryBackground;
    final primaryTextColor = isDark ? Colors.white : AppColors.slate900;
    final secondaryTextColor = isDark ? Colors.grey : AppColors.slate500;
    final headerColor = isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          isEn ? "StayEase Administration" : "Tổng Trạm Quản Trị StayEase",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        backgroundColor: headerColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFF97316),
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFFF97316),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(text: isEn ? "Dashboard" : "Thống kê"),
            Tab(text: isEn ? "Hotels" : "Khách sạn"),
            Tab(text: isEn ? "Rooms" : "Phòng trống"),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _adminController,
        builder: (context, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              // PANEL 1: DASHBOARD
              _buildStatsTab(isDark, isEn, primaryTextColor, secondaryTextColor),

              // PANEL 2: HOTELS LIST
              _buildHotelsTab(isDark, isEn, primaryTextColor, secondaryTextColor),

              // PANEL 3: ROOMS LIST
              _buildRoomsTab(isDark, isEn, primaryTextColor, secondaryTextColor),
            ],
          );
        },
      ),
    );
  }

  // --- STATS TAB DETAIL ---
  Widget _buildStatsTab(bool isDark, bool isEn, Color primaryTextColor, Color secondaryTextColor) {
    final stats = _adminController.adminStats;
    final revenueVal = stats['revenue'] as double;
    final bookingsVal = stats['bookingsCount'] as int;
    final hotelsVal = stats['hotelsCount'] as int;
    final roomsVal = stats['roomsCount'] as int;
    final activeBookingsVal = stats['activeBookings'] as int;
    final canceledCount = bookingsVal - activeBookingsVal;

    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? "Core Metrics overview" : "Chỉ Số Vận Hành Cơ Bản",
            style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),

          // Core metric row 1 (Revenue & booking count)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: isEn ? "Total Revenue" : "Tổng doanh thu",
                  value: formatPrice(revenueVal),
                  icon: Icons.monetization_on,
                  iconTint: const Color(0xFF22C55E),
                  cardColor: cardColor,
                  txtColor: primaryTextColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: isEn ? "Total Bookings" : "Tổng đặt phòng",
                  value: "$bookingsVal",
                  icon: Icons.luggage,
                  iconTint: const Color(0xFF3B82F6),
                  cardColor: cardColor,
                  txtColor: primaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Core metric row 2 (Active vs Canceled)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: isEn ? "Confirmed Order" : "Đặt phòng thành công",
                  value: "$activeBookingsVal",
                  icon: Icons.verified,
                  iconTint: const Color(0xFF10B981),
                  cardColor: cardColor,
                  txtColor: primaryTextColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: isEn ? "Cancelled/Refund" : "Đã hủy đơn / Hoàn",
                  value: "${max(0, canceledCount)}",
                  icon: Icons.cancel,
                  iconTint: Colors.redAccent,
                  cardColor: cardColor,
                  txtColor: primaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Core metric row 3 (Hotel & rooms)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: isEn ? "Managed Hotels" : "Số lượng khách sạn",
                  value: "$hotelsVal",
                  icon: Icons.hotel,
                  iconTint: const Color(0xFFEAB308),
                  cardColor: cardColor,
                  txtColor: primaryTextColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: isEn ? "Registered Rooms" : "Cơ sở phòng trống",
                  value: "$roomsVal",
                  icon: Icons.meeting_room,
                  iconTint: const Color(0xFFAC58FF),
                  cardColor: cardColor,
                  txtColor: primaryTextColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Visual line chart
          Text(
            isEn ? "Monthly Revenue Growth Analytics" : "Sự Tăng Trưởng Doanh Thu Hàng Tháng",
            style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Card(
            color: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: CustomPaint(
                  painter: RevenueChartPainter(isDark: isDark),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Visual bar chart
          Text(
            isEn ? "Regional Lodging Distribution" : "Phân Bố Cơ Sở Lưu Trú Thống Kê",
            style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Card(
            color: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildCustomBar("Hà Nội", 80, isEn ? "\$8k" : "8 Tr", isDark),
                  _buildCustomBar("Đà Nẵng", 65, isEn ? "\$6k" : "6 Tr", isDark),
                  _buildCustomBar("Phú Quốc", 95, isEn ? "\$12k" : "12 Tr", isDark),
                  _buildCustomBar("Nha Trang", 50, isEn ? "\$5k" : "5 Tr", isDark),
                  _buildCustomBar("Sapa", 40, isEn ? "\$3k" : "3 Tr", isDark),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- HOTELS TAB SCREEN ---
  Widget _buildHotelsTab(bool isDark, bool isEn, Color primaryTextColor, Color secondaryTextColor) {
    final list = HotelRepository.hotels.value;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        key: const ValueKey("add_hotel_admin_fab"),
        onPressed: () => _showAddHotelDialog(context, isDark, isEn),
        backgroundColor: const Color(0xFFF97316),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: list.isEmpty
          ? Center(
              child: Text(
                isEn ? "No hotels registered." : "Chưa có khách sạn nào được tạo.",
                style: TextStyle(color: secondaryTextColor),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final hotel = list[index];

                return Card(
                  color: cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            hotel.imageUrls.isNotEmpty ? hotel.imageUrls.first : "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200",
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(color: Colors.grey, height: 70, width: 70, child: const Icon(Icons.hotel));
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hotel.name,
                                style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 13.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${hotel.address}, ${hotel.city}",
                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(5, (sIdx) {
                                      return Icon(
                                        Icons.star_rounded,
                                        size: 13,
                                        color: sIdx < hotel.stars ? Colors.amber : Colors.grey,
                                      );
                                    }),
                                  ),
                                  const Spacer(),
                                  Text(
                                    formatPrice(hotel.priceMin),
                                    style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Action Buttons
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _showEditHotelDialog(context, hotel, isDark, isEn),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, color: Colors.blueAccent, size: 15),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                _adminController.deleteAdminHotel(hotel.id);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 15),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // --- ROOMS TAB SCREEN ---
  Widget _buildRoomsTab(bool isDark, bool isEn, Color primaryTextColor, Color secondaryTextColor) {
    final listRooms = HotelRepository.rooms.value;
    final listHotels = HotelRepository.hotels.value;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        key: const ValueKey("add_room_admin_fab"),
        onPressed: () => _showAddRoomDialog(context, listHotels, isDark, isEn),
        backgroundColor: const Color(0xFFF97316),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: listRooms.isEmpty
          ? Center(
              child: Text(
                isEn ? "No rooms registered." : "Chưa đăng ký phòng trống nào.",
                style: TextStyle(color: secondaryTextColor),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: listRooms.length,
              itemBuilder: (context, index) {
                final room = listRooms[index];
                final matchingHotel = listHotels.firstWhere((h) => h.id == room.hotelId,
                    orElse: () => Hotel(id: '', name: 'Special StayEase Property', description: '', address: '', city: '', stars: 4, rating: 4, reviewCount: 1, imageUrls: [], amenities: [], priceMin: 0));

                return Card(
                  color: cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room Thumbnail image icon
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Icon(
                            Icons.meeting_room,
                            color: isDark ? const Color(0xFFAC58FF) : const Color(0xFF8B5CF6),
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Room details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.name,
                                style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                matchingHotel.name,
                                style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    "${room.bedType} • Max ${room.maxGuests} ${isEn ? "Guests" : "Khách"}",
                                    style: TextStyle(color: secondaryTextColor, fontSize: 10),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "${formatPrice(room.price)} /đêm",
                                    style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 11),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Action delete button
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              _adminController.deleteAdminRoom(room.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Helper widget for Stats metrics
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconTint,
    required Color cardColor,
    required Color txtColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 10.5, fontWeight: FontWeight.bold),
              ),
              Icon(icon, color: iconTint, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: txtColor, fontWeight: FontWeight.black, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // Custom bar construction helper
  Widget _buildCustomBar(String city, double valHeight, String labelVal, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(labelVal, style: TextStyle(color: isDark ? Colors.white70 : AppColors.slate700, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          height: valHeight,
          width: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEA580C), Color(0xFFF97316)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(city, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}

// Custom Line Chart Painter representing monthly revenue trends
class RevenueChartPainter extends CustomPainter {
  final bool isDark;
  RevenueChartPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Gridlines logic
    final paintGrid = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1).withOpacity(0.5)
      ..strokeWidth = 0.5;

    final double gridDiff = size.height / 3;
    for (int i = 0; i <= 3; i++) {
      final double y = gridDiff * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    // 2. Plot data points Representation: [Jan: 10, Feb: 45, Mar: 30, Apr: 75, May: 60, Jun: 90]
    final List<double> data = [0.1, 0.45, 0.3, 0.75, 0.6, 0.9];
    final double stepX = size.width / (data.length - 1);

    final path = Path();
    final gradientPath = Path();

    // Chart Coordinates coordinates
    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      final double y = size.height - (data[i] * size.height);
      points.add(Offset(x, y));
    }

    // Drawing Curve
    path.moveTo(points[0].dx, points[0].dy);
    gradientPath.moveTo(points[0].dx, size.height);
    gradientPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final ctrlX1 = p0.dx + (p1.dx - p0.dx) / 2;
      final ctrlY1 = p0.dy;
      final ctrlX2 = p0.dx + (p1.dx - p0.dx) / 2;
      final ctrlY2 = p1.dy;

      path.cubicTo(ctrlX1, ctrlY1, ctrlX2, ctrlY2, p1.dx, p1.dy);
      gradientPath.cubicTo(ctrlX1, ctrlY1, ctrlX2, ctrlY2, p1.dx, p1.dy);
    }

    gradientPath.lineTo(points.last.dx, size.height);
    gradientPath.close();

    // Fill curves under the line
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFF97316).withOpacity(0.35),
          const Color(0xFFF97316).withOpacity(0.0)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(gradientPath, fillPaint);

    // Smooth Line details
    final linePaint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Draw solid highlight dots
    final dotPaint = Paint()..color = const Color(0xFFF97316);
    final dotOuterPaint = Paint()..color = Colors.white;

    for (var pt in points) {
      canvas.drawCircle(pt, 5, dotOuterPaint);
      canvas.drawCircle(pt, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
