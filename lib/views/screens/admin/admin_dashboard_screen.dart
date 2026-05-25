import 'package:flutter/material.dart';
import '../../../controllers/admin_controller.dart';
import '../../../utils/constants.dart';
import '../../../utils/formatters.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _adminController = AdminController();
  String _activeTab = "DASHBOARD"; // "DASHBOARD", "HOTELS", "ROOMS"

  // Add Hotel form states
  final _hotelNameCtrl = TextEditingController();
  String _hotelCity = "Hà Nội";
  final _hotelAddressCtrl = TextEditingController();
  int _hotelStars = 5;
  final _hotelPriceCtrl = TextEditingController(text: "1500000");
  final _hotelDescCtrl = TextEditingController();

  // Add Room form states
  String? _selectedHotelIdForRoom;
  final _roomNameCtrl = TextEditingController();
  final _roomPriceCtrl = TextEditingController(text: "800000");
  int _roomGuests = 2;
  int _roomSize = 40;
  final _roomDescCtrl = TextEditingController();

  @override
  void dispose() {
    _hotelNameCtrl.dispose();
    _hotelAddressCtrl.dispose();
    _hotelPriceCtrl.dispose();
    _hotelDescCtrl.dispose();
    _roomNameCtrl.dispose();
    _roomPriceCtrl.dispose();
    _roomDescCtrl.dispose();
    super.dispose();
  }

  void _showAddHotelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text("Thêm Khách Sạn Mới", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _hotelNameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Tên khách sạn", labelStyle: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _hotelCity,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      items: ["Hà Nội", "Hồ Chí Minh", "Đà Nẵng", "Sapa", "Phú Quốc"].map((c) {
                        return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _hotelCity = val);
                      },
                      decoration: const InputDecoration(labelText: "Thành phố", labelStyle: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _hotelAddressCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Địa chỉ", labelStyle: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Số sao", style: TextStyle(color: Colors.white)),
                        Row(
                          children: [3, 4, 5].map((s) {
                            final sel = _hotelStars == s;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text("$s ⭐", style: const TextStyle(color: Colors.white)),
                                selected: sel,
                                backgroundColor: const Color(0xFF334155),
                                selectedColor: AppColors.primary,
                                onSelected: (_) {
                                  setState(() => _hotelStars = s);
                                },
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _hotelPriceCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Giá phòng tối thiểu (VNĐ)", labelStyle: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _hotelDescCtrl,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Mô tả bài đăng", labelStyle: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    final name = _hotelNameCtrl.text.trim();
                    final address = _hotelAddressCtrl.text.trim();
                    final price = double.tryParse(_hotelPriceCtrl.text) ?? 1000000.0;
                    final desc = _hotelDescCtrl.text.trim();

                    if (name.isNotEmpty && address.isNotEmpty) {
                      _adminController.addHotel(
                        name: name,
                        city: _hotelCity,
                        address: address,
                        stars: _hotelStars,
                        priceMin: price,
                        description: desc,
                        amenities: ["Wifi", "Gym", "Breakfast"],
                      );
                      _hotelNameCtrl.clear();
                      _hotelAddressCtrl.clear();
                      _hotelDescCtrl.clear();
                      Navigator.pop(context);
                      super.setState(() {}); // refresh list view outer
                    }
                  },
                  child: const Text("Thêm", style: TextStyle(color: AppColors.primary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddRoomDialog() {
    final hotels = _adminController.hotels;
    if (hotels.isEmpty) return;
    _selectedHotelIdForRoom ??= hotels.first.id;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text("Thêm Phòng Trống Mới", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedHotelIdForRoom,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      items: hotels.map((h) {
                        return DropdownMenuItem(value: h.id, child: Text(h.name, style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedHotelIdForRoom = val);
                      },
                      decoration: const InputDecoration(labelText: "Chọn Khách Sạn", labelStyle: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _roomNameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Tên phòng (ví dụ: Deluxe King)", labelStyle: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _roomPriceCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Giá phòng đêm (VNĐ)", labelStyle: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Số lượng khách tối đa", style: TextStyle(color: Colors.white, fontSize: 12)),
                        Row(
                          children: [2, 3, 4].map((g) {
                            final sel = _roomGuests == g;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: ChoiceChip(
                                label: Text("$g👤", style: const TextStyle(color: Colors.white, fontSize: 11)),
                                selected: sel,
                                backgroundColor: const Color(0xFF334155),
                                selectedColor: AppColors.primary,
                                onSelected: (_) {
                                  setState(() => _roomGuests = g);
                                },
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Kích thước phòng (m²)", style: TextStyle(color: Colors.white, fontSize: 12)),
                        Row(
                          children: [30, 45, 60].map((s) {
                            final sel = _roomSize == s;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: ChoiceChip(
                                label: Text("$s m²", style: const TextStyle(color: Colors.white, fontSize: 11)),
                                selected: sel,
                                backgroundColor: const Color(0xFF334155),
                                selectedColor: AppColors.primary,
                                onSelected: (_) {
                                  setState(() => _roomSize = s);
                                },
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _roomDescCtrl,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Mô tả phòng", labelStyle: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    final name = _roomNameCtrl.text.trim();
                    final price = double.tryParse(_roomPriceCtrl.text) ?? 800000.0;
                    final desc = _roomDescCtrl.text.trim();

                    if (name.isNotEmpty && _selectedHotelIdForRoom != null) {
                      _adminController.addRoom(
                        hotelId: _selectedHotelIdForRoom!,
                        name: name,
                        price: price,
                        maxGuests: _roomGuests,
                        sizeSqM: _roomSize,
                        bedType: "Classic Double Bed",
                        description: desc,
                        amenities: ["TV", "Air Conditioning", "Bathtub"],
                      );
                      _roomNameCtrl.clear();
                      _roomDescCtrl.clear();
                      Navigator.pop(context);
                      super.setState(() {}); // refresh outer list view
                    }
                  },
                  child: const Text("Thêm", style: TextStyle(color: AppColors.primary)),
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
    final stats = _adminController.stats;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("Trang Quản Trị KPI & CRUD", style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Nav bar selector header
          Container(
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton("TỐNG QUAN", "DASHBOARD"),
                _buildTabButton("KHÁCH SẠN", "HOTELS"),
                _buildTabButton("PHÒNG TRỐNG", "ROOMS"),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: _buildActiveTabView(stats),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String tab) {
    final selected = _activeTab == tab;
    return TextButton(
      onPressed: () {
        setState(() {
          _activeTab = tab;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFFF97316) : Colors.white60,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          if (selected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 25,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(1.5),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildActiveTabView(Map<String, dynamic> stats) {
    switch (_activeTab) {
      case "DASHBOARD":
        return _buildDashboardTab(stats);
      case "HOTELS":
        return _buildHotelsTab();
      case "ROOMS":
        return _buildRoomsTab();
      default:
        return _buildDashboardTab(stats);
    }
  }

  Widget _buildDashboardTab(Map<String, dynamic> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("KPI Doanh Nghiệp Thống Kê", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),

          // Grid stats overview
          Row(
            children: [
              Expanded(
                child: _buildStatsCard(
                  "DOANH THU",
                  formatPrice(stats["totalRevenue"] ?? 0.0),
                  Icons.monetization_on,
                  const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatsCard(
                  "BOOKING MỚI",
                  "${stats["bookingsCount"] ?? 0}",
                  Icons.bookmark_added,
                  const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatsCard(
                  "ĐANG KHẢO SÁT",
                  "${stats["activeBookings"] ?? 0}",
                  Icons.timelapse,
                  const Color(0xFFEAB308),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatsCard(
                  "TỈ LỆ HỦY",
                  "${stats["cancelledBookings"] ?? 0} phòng",
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text("Sự tăng trưởng Doanh thu ($)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),

          // Custom visual painter
          Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: CustomPaint(
                  painter: LineChartPainter(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.black)),
        ],
      ),
    );
  }

  Widget _buildHotelsTab() {
    final list = _adminController.hotels;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHotelDialog,
        backgroundColor: const Color(0xFFF97316),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, idx) {
          final h = list[idx];
          return Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  h.imageUrls.isNotEmpty ? h.imageUrls.first : "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=50",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(h.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text("${h.city} • ${formatPrice(h.priceMin)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  _adminController.deleteHotel(h.id);
                  setState(() {});
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomsTab() {
    final list = _adminController.roomsAvailable;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        backgroundColor: const Color(0xFFF97316),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: list.isEmpty
          ? const Center(child: Text("Không có phòng trống nào!", style: TextStyle(color: Colors.white60)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, idx) {
                final r = list[idx];
                return Card(
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF334155)),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(r.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text("${formatPrice(r.price)} • tối đa ${r.maxGuests} khách • ${r.sizeSqM} m²", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        _adminController.deleteRoom(r.id);
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintGrid = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final paintLine = Paint()
      ..color = const Color(0xFFF97316)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;

    // Draw horizontal grids
    for (int i = 1; i <= 3; i++) {
      double y = h * (i * 0.25);
      canvas.drawLine(Offset(0, y), Offset(w, y), paintGrid);
    }

    final points = [
      Offset(0, h * 0.8),
      Offset(w * 0.2, h * 0.55),
      Offset(w * 0.4, h * 0.68),
      Offset(w * 0.6, h * 0.3),
      Offset(w * 0.8, h * 0.45),
      Offset(w, h * 0.15),
    ];

    // Draw lines connecting points
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paintLine);
    }

    // Draw points dots
    for (final p in points) {
      canvas.drawCircle(p, 4, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
