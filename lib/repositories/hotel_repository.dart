import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/hotel.dart';
import '../models/room.dart';
import '../models/review.dart';
import '../models/coupon.dart';
import '../models/message.dart';
import '../service/prefs_helper.dart';
import '../service/api_service.dart';
import '../service/database_helper.dart';
import 'user_repository.dart';
import 'favorite_repository.dart';

class HotelRepository {
  static final hotels = ValueNotifier<List<Hotel>>([]);
  static final rooms = ValueNotifier<List<Room>>([]);
  static final reviews = ValueNotifier<List<Review>>([]);
  static final coupons = ValueNotifier<List<Coupon>>([]);
  static final chatMessages = ValueNotifier<List<Message>>([]);
  static final recentSearches = ValueNotifier<List<String>>([]);

  static bool _isInitialized = false;

  static void init() {
    if (!_isInitialized) {
      // Initialize Favorite Repository
      FavoriteRepository.init();

      // Load Hotels
      final savedHotels = DatabaseHelper.loadList<Hotel>('saved_hotels', (json) => Hotel.fromJson(json));
      if (savedHotels.isNotEmpty) {
        hotels.value = savedHotels;
      } else {
        _loadDefaultHotels();
      }

      // Load Rooms
      final savedRooms = DatabaseHelper.loadList<Room>('saved_rooms', (json) => Room.fromJson(json));
      if (savedRooms.isNotEmpty) {
        rooms.value = savedRooms;
      } else {
        _loadDefaultRooms();
      }

      // Load Reviews
      final savedReviews = DatabaseHelper.loadList<Review>('saved_reviews', (json) => Review.fromJson(json));
      if (savedReviews.isNotEmpty) {
        reviews.value = savedReviews;
      } else {
        _loadDefaultReviews();
      }

      // Load Coupons
      final savedCoupons = DatabaseHelper.loadList<Coupon>('saved_coupons', (json) => Coupon.fromJson(json));
      if (savedCoupons.isNotEmpty) {
        coupons.value = savedCoupons;
      } else {
        coupons.value = _loadDefaultCoupons();
        _saveCoupons();
      }

      // Chat
      chatMessages.value = [
        Message(
          id: 'msg_welcome',
          senderId: 'admin',
          senderName: 'StayEase Support',
          isFromAdmin: true,
          content: 'Xin chào! StayEase rất hân hạnh được hỗ trợ bạn. Bạn cần tìm phòng tại địa điểm nào ạ?',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        )
      ];

      // Searches
      recentSearches.value = ["Hà Nội", "Đà Nẵng", "Phú Quốc"];

      _isInitialized = true;

      // Async fetchMockApiData
      fetchMockApiData();
    }
  }

  // Save helpers
  static void _saveHotels() => DatabaseHelper.saveList<Hotel>('saved_hotels', hotels.value, (item) => item.toJson());
  static void _saveRooms() => DatabaseHelper.saveList<Room>('saved_rooms', rooms.value, (item) => item.toJson());
  static void _saveReviews() => DatabaseHelper.saveList<Review>('saved_reviews', reviews.value, (item) => item.toJson());
  static void _saveCoupons() => DatabaseHelper.saveList<Coupon>('saved_coupons', coupons.value, (item) => item.toJson());

  static Future<void> fetchMockApiData() async {
    try {
      final remoteHotels = await ApiService.fetchHotelsFromApi();
      if (remoteHotels != null) {
        final List<Hotel> newHotels = [];
        final List<Room> newRooms = [];

        for (var item in remoteHotels) {
          final idStr = (item['id']?.toString() ?? '').split('.').first;
          final name = item['name']?.toString() ?? '';
          final city = item['city']?.toString() ?? '';
          final address = item['address']?.toString() ?? '';
          final description = item['description']?.toString() ?? '';
          final priceMin = double.tryParse(item['price_per_night']?.toString() ?? '') ?? 100.0;
          final rating = double.tryParse(item['rating']?.toString() ?? '') ?? 4.5;
          final imageAsset = item['image_asset']?.toString() ?? '';

          final galleryImages = (item['gallery_images'] as List?)?.map((e) => e.toString()).toList() ?? [];
          final amenities = (item['amenities'] as List?)?.map((e) => e.toString()).toList() ?? [];

          int stars = 3;
          if (rating >= 4.9) {
            stars = 5;
          } else if (rating >= 4.7) {
            stars = 4;
          }

          final hotel = Hotel(
            id: 'hotel_$idStr',
            name: name,
            description: description,
            address: address,
            city: city,
            stars: stars,
            rating: rating,
            reviewCount: 20,
            imageUrls: imageAsset.isNotEmpty ? [imageAsset, ...galleryImages] : galleryImages,
            amenities: amenities,
            priceMin: priceMin,
            latitude: 16.0 + (int.tryParse(idStr) ?? 1) * 0.1,
            longitude: 108.0 + (int.tryParse(idStr) ?? 1) * 0.1,
            isFeatured: idStr == '1' || idStr == '2' || idStr == '4',
          );
          newHotels.add(hotel);

          final roomsArr = item['rooms'] as List?;
          if (roomsArr != null) {
            for (var rItem in roomsArr) {
              if (rItem is Map) {
                final rId = (rItem['id']?.toString() ?? '').split('.').first;
                final rName = rItem['name']?.toString() ?? '';
                final rDescription = rItem['description']?.toString() ?? '';
                final rPrice = double.tryParse(rItem['price']?.toString() ?? '') ?? priceMin;
                final rBedType = rItem['bed_type']?.toString() ?? '1 Giường đôi lớn';
                final rSizeStr = rItem['room_size']?.toString() ?? '30 m²';
                final rSize = int.tryParse(rSizeStr.replaceAll('m²', '').trim()) ?? 30;
                final capacity = double.tryParse(rItem['capacity']?.toString() ?? '')?.toInt() ?? 2;

                final room = Room(
                  id: 'room_$rId',
                  hotelId: 'hotel_$idStr',
                  name: rName,
                  description: rDescription,
                  price: rPrice,
                  bedType: rBedType,
                  maxGuests: capacity,
                  sizeSqm: rSize,
                  imageUrls: imageAsset.isNotEmpty ? [imageAsset] : [],
                  amenities: amenities,
                  totalAvailable: 5,
                );
                newRooms.add(room);
              }
            }
          }
        }

        if (newHotels.isNotEmpty) {
          hotels.value = newHotels;
          _saveHotels();
        }
        if (newRooms.isNotEmpty) {
          rooms.value = newRooms;
          _saveRooms();
        }
      }
    } catch (e) {
      print("Error fetching MockAPI: $e");
    }
  }

  static void addReview(String hotelId, double rating, String comment) {
    UserRepository.init();
    final user = UserRepository.currentUser.value;
    final newReview = Review(
      id: const Uuid().v4(),
      hotelId: hotelId,
      userName: user.name,
      userAvatar: user.avatarUrl,
      rating: rating,
      comment: comment,
      date: 'Hôm nay',
    );

    reviews.value = [newReview, ...reviews.value];
    _saveReviews();

    final hotelReviews = reviews.value.where((it) => it.hotelId == hotelId).toList();
    final avgRating = hotelReviews.isNotEmpty
        ? hotelReviews.map((it) => it.rating).reduce((a, b) => a + b) / hotelReviews.length
        : 4.5;
    final roundedRating = (avgRating * 10).round() / 10;

    hotels.value = hotels.value.map((it) {
      if (it.id == hotelId) {
        return it.copyWith(rating: roundedRating, reviewCount: hotelReviews.length + 15);
      }
      return it;
    }).toList();
    _saveHotels();
  }

  static String searchByVoiceMock(String voiceText) {
    final text = voiceText.toLowerCase();
    if (text.contains("sapa")) return "Sapa";
    if (text.contains("hà nội") || text.contains("ha noi")) return "Hà Nội";
    if (text.contains("đà nẵng") || text.contains("da nang")) return "Đà Nẵng";
    if (text.contains("phú quốc") || text.contains("phu quoc")) return "Phú Quốc";
    if (text.contains("sài gòn") || text.contains("hồ chí minh")) return "Hồ Chí Minh";
    return voiceText;
  }

  static void addChatMessage(String content) {
    UserRepository.init();
    final user = UserRepository.currentUser.value;
    final userMsg = Message(
      id: const Uuid().v4(),
      senderId: user.id,
      senderName: user.name,
      isFromAdmin: false,
      content: content,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    chatMessages.value = [...chatMessages.value, userMsg];

    final String botResponse;
    final text = content.toLowerCase();
    if (text.contains("đặt phòng") || text.contains("booking")) {
      botResponse = "Bạn có thể đặt phòng trực tiếp qua trang chi tiết của mỗi khách sạn! Chọn ngày nhận/trả và phòng mong muốn, sau đó click Đặt Ngay.";
    } else if (text.contains("khuyến mãi") || text.contains("mã giảm") || text.contains("sale")) {
      botResponse = "StayEase đang áp dụng mã giảm giá ưu đãi 'STAYEASE200K' (giảm 200k) và 'WELCOME500K' (giảm 500k). Nhập mã khi thanh toán để được giảm trừ nhé!";
    } else if (text.contains("hà nội") || text.contains("hanoi")) {
      botResponse = "Hà Nội đang có khách sạn sang trọng *Sofitel Legend Metropole Hanoi* cực kì cổ kính và cuốn hút. Bạn có muốn đặt phòng tại đây?";
    } else if (text.contains("hoàn tiền") || text.contains("hủy phòng")) {
      botResponse = "Chính sách hủy phòng linh hoạt áp dụng trước 24 giờ kể từ ngày check-in. Bạn có thể bấm nút Hủy trực tiếp trong Lịch Sử Đặt Phòng.";
    } else {
      botResponse = "Cảm ơn câu hỏi từ quý khách. Đội ngũ StayEase đã nhận được thông tin yêu cầu tư vấn đặt phòng của bạn và sẽ liên hệ ngay qua SĐT: ${user.phoneNumber}. Bạn còn cần hỗ trợ gì khác không?";
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      final adminMsg = Message(
        id: const Uuid().v4(),
        senderId: 'admin',
        senderName: 'StayEase Support',
        isFromAdmin: true,
        content: botResponse,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      chatMessages.value = [...chatMessages.value, adminMsg];
    });
  }

  // Admin CRUD
  static void addHotel(Hotel hotel) {
    hotels.value = [hotel, ...hotels.value];
    _saveHotels();
  }

  static void updateHotel(Hotel hotel) {
    hotels.value = hotels.value.map((it) => it.id == hotel.id ? hotel : it).toList();
    _saveHotels();
  }

  static void deleteHotel(String hotelId) {
    hotels.value = hotels.value.where((it) => it.id != hotelId).toList();
    _saveHotels();
  }

  static void addRoom(Room room) {
    rooms.value = [room, ...rooms.value];
    _saveRooms();
  }

  static void updateRoom(Room room) {
    rooms.value = rooms.value.map((it) => it.id == room.id ? room : it).toList();
    _saveRooms();
  }

  static void deleteRoom(String roomId) {
    rooms.value = rooms.value.where((it) => it.id != roomId).toList();
    _saveRooms();
  }

  // Defaults loading functions
  static void _loadDefaultHotels() {
    hotels.value = [
      Hotel(
        id: "hotel_1",
        name: "Sofitel Legend Metropole Hanoi",
        description: "Biểu tượng lịch sử cổ kính tọa lạc tại trung tâm Hà Nội, cách Hồ Hoàn Kiếm bước đi bộ. Trải nghiệm dịch vụ xa hoa đẳng cấp thế giới kết hợp phong cách thuộc địa Pháp sang trọng bậc nhất.",
        address: "15 Phố Ngô Quyền, Tràng Tiền, Hoàn Kiếm, Hà Nội",
        city: "Hà Nội",
        stars: 5,
        rating: 9.6,
        reviewCount: 145,
        imageUrls: [
          "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80",
          "https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=800&q=80",
          "https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80"
        ],
        amenities: ["Wifi", "Pool", "Gym", "Breakfast", "Parking", "Spa"],
        priceMin: 4200000.0,
        latitude: 21.0253,
        longitude: 105.8569,
        isFeatured: true,
      ),
      Hotel(
        id: "hotel_2",
        name: "InterContinental Danang Resort",
        description: "Nằm tách biệt trên bán đảo Sơn Trà thơ mộng với tầm nhìn panorama biển Đông tuyệt đẹp. Nổi tiếng với kiến trúc độc đáo của kiến trúc sư lừng danh Bill Bensley và ẩm thực Michelin tuyệt hảo.",
        address: "Bán đảo Sơn Trà, Thọ Quang, Sơn Trà, Đà Nẵng",
        city: "Đà Nẵng",
        stars: 5,
        rating: 9.8,
        reviewCount: 98,
        imageUrls: [
          "https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=800&q=80",
          "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=800&q=80"
        ],
        amenities: ["Wifi", "Pool", "Gym", "Breakfast", "Spa"],
        priceMin: 6800000.0,
        latitude: 16.1219,
        longitude: 108.2801,
        isFeatured: true,
      ),
      Hotel(
        id: "hotel_3",
        name: "Hotel de la Coupole - MGallery Sapa",
        description: "Kiệt tác nghỉ dưỡng hòa quyện giữa nét văn hóa rực rỡ của các dân tộc Sapa truyền thống và thời trang lộng lẫy những năm 1930 nước Pháp. Tầm nhìn thẳng ra thung lũng Mường Hoa kỳ vĩ.",
        address: "1 Đường Hoàng Liên, Sa Pa, Lào Cai",
        city: "Sapa",
        stars: 5,
        rating: 9.3,
        reviewCount: 112,
        imageUrls: [
          "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80",
          "https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=800&q=80"
        ],
        amenities: ["Wifi", "Pool", "Gym", "Breakfast"],
        priceMin: 2400000.0,
        latitude: 22.3364,
        longitude: 103.8438,
        isFeatured: false,
      ),
      Hotel(
        id: "hotel_4",
        name: "La Veranda Resort Phu Quoc",
        description: "Khu nghỉ dưỡng phong cách biệt thự Pháp thế kỷ 19 quyến rũ bên làn nước xanh lục bảo của đảo Ngọc Phú Quốc. Khuôn viên tràn ngập hoa lá nhiệt đới thanh tịnh và bãi cát trắng mịn riêng tư.",
        address: "Trần Hưng Đạo, Dương Đông, Phú Quốc, Kiên Giang",
        city: "Phú Quốc",
        stars: 5,
        rating: 9.1,
        reviewCount: 82,
        imageUrls: [
          "https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=800&q=80",
          "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80"
        ],
        amenities: ["Wifi", "Pool", "Breakfast", "Parking", "Spa"],
        priceMin: 3200000.0,
        latitude: 10.1985,
        longitude: 103.9593,
        isFeatured: true,
      ),
      Hotel(
        id: "hotel_5",
        name: "The Reverie Saigon Hotel",
        description: "Trải nghiệm rực rỡ xa xỉ đỉnh cao mang đậm dấu ấn phong cách hoàng gia Ý ngay tại trung tâm Sài Gòn. Tận hưởng tầm nhìn vô cực ngắm trọn khúc sông Sài Gòn uốn lượn tuyệt đẹp.",
        address: "22-36 Đường Nguyễn Huệ, Bến Nghé, Quận 1, TP. Hồ Chí Minh",
        city: "Hồ Chí Minh",
        stars: 5,
        rating: 9.5,
        reviewCount: 76,
        imageUrls: [
          "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=800&q=80",
          "https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=800&q=80"
        ],
        amenities: ["Wifi", "Pool", "Gym", "Breakfast", "Parking"],
        priceMin: 5900000.0,
        latitude: 10.7749,
        longitude: 106.7034,
        isFeatured: false,
      ),
      Hotel(
        id: "hotel_6",
        name: "Sapa Jade Hill Resort",
        description: "Ẩn mình giữa rừng samu ngát xanh và sương mờ mây phủ, khu resort sinh thái thiết kế như bản làng vùng cao vô cùng mộc mạc thanh bình nhưng đầy tinh tế, ấm cúng lò sưởi củi.",
        address: "Cầu Mây, Sa Pa, Lào Cai",
        city: "Sapa",
        stars: 4,
        rating: 8.7,
        reviewCount: 54,
        imageUrls: [
          "https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=800&q=80"
        ],
        amenities: ["Wifi", "Pool", "Breakfast", "Parking"],
        priceMin: 1800000.0,
        latitude: 22.3275,
        longitude: 103.8582,
        isFeatured: false,
      ),
    ];
    _saveHotels();
  }

  static void _loadDefaultRooms() {
    rooms.value = [
      Room(id: "r1_1", hotelId: "hotel_1", name: "Classic Luxury King Room", description: "Phòng cổ điển sang trọng mang đậm dấu ấn phong cách Đông Dương. Ban công rộng ngắm trọn vẹn khu vườn trung tâm yên tĩnh.", price: 4200000.0, bedType: "1 King Bed", maxGuests: 2, sizeSqm: 32, imageUrls: ["https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=600&q=80"], amenities: ["Wifi", "Breakfast", "Mini Bar", "Bathtub"]),
      Room(id: "r1_2", hotelId: "hotel_1", name: "Opera Suite Deluxe", description: "Cần Suite lộng lẫy thiết kế theo phong cách nhà hát Opera cổ kính, dành riêng cho trải nghiệm hoàng gia cao cấp.", price: 7500000.0, bedType: "1 Premium King Bed", maxGuests: 3, sizeSqm: 55, imageUrls: ["https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=600&q=80"], amenities: ["Wifi", "Breakfast", "Butler Service", "Living Room", "Jacuzzi"]),
      Room(id: "r2_1", hotelId: "hotel_2", name: "Resort Classic Oceanview", description: "Thức giấc cùng tiếng sóng vỗ rì rào và làn gió biển mát rượi tại ban công lộng gió ngắm trọn vịnh Sơn Trà tuyệt đẹp.", price: 6800000.0, bedType: "1 King Bed", maxGuests: 2, sizeSqm: 48, imageUrls: ["https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=600&q=80"], amenities: ["Wifi", "Breakfast", "Ocean View", "Balcony", "Coffee Maker"]),
      Room(id: "r2_2", hotelId: "hotel_2", name: "Penthouse Seaside with Private Pool", description: "Trải nghiệm xa xỉ đỉnh cao tại căn biệt thự biển có sân hiên rộng, hồ bơi vô cực riêng tư dài 15m ngắm hoàng hôn rực rỡ.", price: 15200000.0, bedType: "1 Super King Bed", maxGuests: 4, sizeSqm: 120, imageUrls: ["https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=600&q=80"], amenities: ["Wifi", "Breakfast", "Private Pool", "Kitchen", "Wine Cellar", "Living Area"]),
      Room(id: "r3_1", hotelId: "hotel_3", name: "Classic Indochine Room", description: "Căn phòng ngập tràn sắc màu thời trang Pháp quyến rũ kết hợp tinh tế cùng hoa văn thêu tay Sapa sặc sỡ.", price: 2400000.0, bedType: "1 King Bed", maxGuests: 2, sizeSqm: 30, imageUrls: ["https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=600&q=80"], amenities: ["Wifi", "Breakfast", "Heater", "Balcony"]),
      Room(id: "r3_2", hotelId: "hotel_3", name: "Superior Double Twin Room", description: "Thiết kế giường đôi êm ái thích hợp cho các cặp bạn bè khám phá xứ sở sương mù Sapa thanh bình tuyệt diệu.", price: 2900000.0, bedType: "2 Single Beds", maxGuests: 2, sizeSqm: 35, imageUrls: ["https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=600&q=80"], amenities: ["Wifi", "Breakfast", "Heater", "Mountain View"])
    ];
    _saveRooms();
  }

  static void _loadDefaultReviews() {
    reviews.value = [
      Review(
        id: 'rev_1',
        hotelId: "hotel_1",
        userName: "Minh Hằng",
        userAvatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=100&q=80",
        rating: 5.0,
        comment: "Phòng vô cùng thượng hoàng, dịch vụ Metropole chưa bao giờ làm tôi thất vọng. Sẽ quay lại nhiều lần!",
        date: "2026-04-12",
      ),
      Review(
        id: 'rev_2',
        hotelId: "hotel_1",
        userName: "Alex Smith",
        userAvatar: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=100&q=80",
        rating: 4.5,
        comment: "Historic French elegance in the heart of Hanoi. Breakfast was unbelievable.",
        date: "2026-05-03",
      ),
      Review(
        id: 'rev_3',
        hotelId: "hotel_2",
        userName: "Tấn Dũng",
        userAvatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80",
        rating: 5.0,
        comment: "Thiên đường hạ giới! Cách bài trí từng lầu Sông - Đất - Sky cực mỹ lệ. Quán Citron ăn sáng ngon.",
        date: "2026-05-20",
      ),
    ];
    _saveReviews();
  }

  static List<Coupon> _loadDefaultCoupons() {
    return [
      Coupon(code: "STAYEASE200K", description: "Giảm ngay 200.000đ cho mọi phòng đặt", discountPercent: 10, maxDiscount: 200000.0, minSpend: 1000000.0),
      Coupon(code: "WELCOME500K", description: "Chào mừng hành khách mới giảm ngay 500.000đ từ StayEase Co.", discountPercent: 15, maxDiscount: 500000.0, minSpend: 3000000.0),
      Coupon(code: "SUPERDEAL800K", description: "Siêu khuyến mãi giảm trực tiếp 800.000đ thẳng hóa đơn", discountPercent: 20, maxDiscount: 800000.0, minSpend: 5000000.0)
    ];
  }
}
