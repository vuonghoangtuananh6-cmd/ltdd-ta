package com.example.data.repository

import android.content.Context
import android.content.SharedPreferences
import com.example.data.model.*
import com.squareup.moshi.Moshi
import com.squareup.moshi.Types
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.UUID

class HotelRepository(context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("StayEase_Prefs", Context.MODE_PRIVATE)
    private val moshi = Moshi.Builder().addLast(KotlinJsonAdapterFactory()).build()

    // State flows
    private val _hotels = MutableStateFlow<List<HotelModel>>(emptyList())
    val hotels: StateFlow<List<HotelModel>> = _hotels.asStateFlow()

    private val _rooms = MutableStateFlow<List<RoomModel>>(emptyList())
    val rooms: StateFlow<List<RoomModel>> = _rooms.asStateFlow()

    private val _bookings = MutableStateFlow<List<BookingModel>>(emptyList())
    val bookings: StateFlow<List<BookingModel>> = _bookings.asStateFlow()

    private val _reviews = MutableStateFlow<List<ReviewModel>>(emptyList())
    val reviews: StateFlow<List<ReviewModel>> = _reviews.asStateFlow()

    private val _wishlist = MutableStateFlow<Set<String>>(emptySet())
    val wishlist: StateFlow<Set<String>> = _wishlist.asStateFlow()

    private val _chatMessages = MutableStateFlow<List<MessageModel>>(emptyList())
    val chatMessages: StateFlow<List<MessageModel>> = _chatMessages.asStateFlow()

    private val _currentUser = MutableStateFlow<UserModel>(UserModel())
    val currentUser: StateFlow<UserModel> = _currentUser.asStateFlow()

    private val _coupons = MutableStateFlow<List<CouponModel>>(emptyList())
    val coupons: StateFlow<List<CouponModel>> = _coupons.asStateFlow()

    private val _recentSearches = MutableStateFlow<List<String>>(emptyList())
    val recentSearches: StateFlow<List<String>> = _recentSearches.asStateFlow()

    init {
        loadData()
    }

    private fun loadData() {
        // Load wishlisted hotels
        val wishlistSet = prefs.getStringSet("wishlist_hotel_ids", emptySet()) ?: emptySet()
        _wishlist.value = wishlistSet

        // Load user info
        val userJson = prefs.getString("current_user", null)
        if (userJson != null) {
            try {
                val adapter = moshi.adapter(UserModel::class.java)
                val user = adapter.fromJson(userJson)
                if (user != null) {
                    _currentUser.value = user
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        // Initialize lists (from prefs if saved, otherwise load default mocks)
        val hotelJson = prefs.getString("saved_hotels", null)
        if (hotelJson != null) {
            try {
                val type = Types.newParameterizedType(List::class.java, HotelModel::class.java)
                val list: List<HotelModel>? = moshi.adapter<List<HotelModel>>(type).fromJson(hotelJson)
                if (list != null) {
                    _hotels.value = list
                }
            } catch (e: Exception) {
                loadDefaultHotels()
            }
        } else {
            loadDefaultHotels()
        }

        val roomJson = prefs.getString("saved_rooms", null)
        if (roomJson != null) {
            try {
                val type = Types.newParameterizedType(List::class.java, RoomModel::class.java)
                val list: List<RoomModel>? = moshi.adapter<List<RoomModel>>(type).fromJson(roomJson)
                if (list != null) {
                    _rooms.value = list
                }
            } catch (e: Exception) {
                loadDefaultRooms()
            }
        } else {
            loadDefaultRooms()
        }

        val bookingJson = prefs.getString("saved_bookings", null)
        if (bookingJson != null) {
            try {
                val type = Types.newParameterizedType(List::class.java, BookingModel::class.java)
                val list: List<BookingModel>? = moshi.adapter<List<BookingModel>>(type).fromJson(bookingJson)
                if (list != null) {
                    _bookings.value = list
                }
            } catch (e: Exception) {}
        } else {
            _bookings.value = loadDefaultBookings()
        }

        val reviewJson = prefs.getString("saved_reviews", null)
        if (reviewJson != null) {
            try {
                val type = Types.newParameterizedType(List::class.java, ReviewModel::class.java)
                val list: List<ReviewModel>? = moshi.adapter<List<ReviewModel>>(type).fromJson(reviewJson)
                if (list != null) {
                    _reviews.value = list
                }
            } catch (e: Exception) {}
        } else {
            loadDefaultReviews()
        }

        val couponJson = prefs.getString("saved_coupons", null)
        if (couponJson != null) {
            try {
                val type = Types.newParameterizedType(List::class.java, CouponModel::class.java)
                val list: List<CouponModel>? = moshi.adapter<List<CouponModel>>(type).fromJson(couponJson)
                if (list != null) {
                    _coupons.value = list
                }
            } catch (e: Exception) {}
        } else {
            _coupons.value = loadDefaultCoupons()
        }

        // Default local chats
        _chatMessages.value = listOf(
            MessageModel(senderId = "admin", senderName = "StayEase Support", isFromAdmin = true, content = "Xin chào! StayEase rất hân hạnh được hỗ trợ bạn. Bạn cần tìm phòng tại địa điểm nào ạ?"),
        )
        
        // Recent searches
        _recentSearches.value = listOf("Hà Nội", "Đà Nẵng", "Phú Quốc")

        // Trigger live MockAPI load
        fetchMockApiData()
    }

    fun fetchMockApiData() {
        kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.IO).launch {
            try {
                // Fetch Hotels
                val urlHotels = java.net.URL("https://6a0c97985aa893e1015c1b6e.mockapi.io/hotels")
                val connectionHotels = urlHotels.openConnection() as java.net.HttpURLConnection
                connectionHotels.requestMethod = "GET"
                connectionHotels.connectTimeout = 10000
                connectionHotels.readTimeout = 10000
                
                if (connectionHotels.responseCode == 200) {
                    val rawJson = connectionHotels.inputStream.bufferedReader().use { it.readText() }
                    
                    val type = Types.newParameterizedType(List::class.java, Map::class.java)
                    val listMaps = moshi.adapter<List<Map<String, Any>>>(type).fromJson(rawJson)
                    if (listMaps != null) {
                        val newHotelsList = mutableListOf<HotelModel>()
                        val newRoomsList = mutableListOf<RoomModel>()
                        
                        for (item in listMaps) {
                            val id = (item["id"]?.toString() ?: "").substringBefore(".")
                            val name = item["name"]?.toString() ?: ""
                            val city = item["city"]?.toString() ?: ""
                            val address = item["address"]?.toString() ?: ""
                            val description = item["description"]?.toString() ?: ""
                            val priceMin = (item["price_per_night"]?.toString()?.toDoubleOrNull()) ?: 100.0
                            val rating = (item["rating"]?.toString()?.toDoubleOrNull()) ?: 4.5
                            val imageAsset = item["image_asset"]?.toString() ?: ""
                            
                            val galleryImages = (item["gallery_images"] as? List<*>)?.mapNotNull { it?.toString() } ?: emptyList()
                            val amenities = (item["amenities"] as? List<*>)?.mapNotNull { it?.toString() } ?: emptyList()
                            
                            val stars = when {
                                rating >= 4.9 -> 5
                                rating >= 4.7 -> 4
                                else -> 3
                            }
                            
                            val hotel = HotelModel(
                                id = "hotel_$id",
                                name = name,
                                description = description,
                                address = address,
                                city = city,
                                stars = stars,
                                rating = rating,
                                reviewCount = 20,
                                imageUrls = if (imageAsset.isNotEmpty()) listOf(imageAsset) + galleryImages else galleryImages,
                                amenities = amenities,
                                priceMin = priceMin,
                                latitude = 16.0 + (id.toIntOrNull() ?: 1) * 0.1,
                                longitude = 108.0 + (id.toIntOrNull() ?: 1) * 0.1,
                                isFeatured = id == "1" || id == "2" || id == "4"
                            )
                            newHotelsList.add(hotel)
                            
                            // Parse rooms within this hotel
                            val roomsArr = item["rooms"] as? List<*>
                            if (roomsArr != null) {
                                for (roomObj in roomsArr) {
                                    val rMap = roomObj as? Map<String, Any> ?: continue
                                    val rId = (rMap["id"]?.toString() ?: "").substringBefore(".")
                                    val rName = rMap["name"]?.toString() ?: ""
                                    val rDescription = rMap["description"]?.toString() ?: ""
                                    val rPrice = (rMap["price"]?.toString()?.toDoubleOrNull()) ?: priceMin
                                    val rBedType = rMap["bed_type"]?.toString() ?: "1 Giường đôi lớn"
                                    val rSizeStr = rMap["room_size"]?.toString() ?: "30 m²"
                                    val rSize = rSizeStr.replace("m²", "").trim().toIntOrNull() ?: 30
                                    val capacity = (rMap["capacity"]?.toString()?.toDoubleOrNull()?.toInt()) ?: 2
                                    
                                    val room = RoomModel(
                                        id = "room_$rId",
                                        hotelId = "hotel_$id",
                                        name = rName,
                                        description = rDescription,
                                        price = rPrice,
                                        bedType = rBedType,
                                        maxGuests = capacity,
                                        sizeSqm = rSize,
                                        imageUrls = if (imageAsset.isNotEmpty()) listOf(imageAsset) else emptyList(),
                                        amenities = amenities,
                                        totalAvailable = 5
                                    )
                                    newRoomsList.add(room)
                                }
                            }
                        }
                        
                        if (newHotelsList.isNotEmpty()) {
                            _hotels.value = newHotelsList
                            saveHotels()
                        }
                        if (newRoomsList.isNotEmpty()) {
                            _rooms.value = newRoomsList
                            saveRooms()
                        }
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
            
            try {
                // Fetch bookings
                val urlBookings = java.net.URL("https://6a0c97985aa893e1015c1b6e.mockapi.io/booking")
                val connectionBookings = urlBookings.openConnection() as java.net.HttpURLConnection
                connectionBookings.requestMethod = "GET"
                connectionBookings.connectTimeout = 10000
                connectionBookings.readTimeout = 10000
                
                if (connectionBookings.responseCode == 200) {
                    val rawJson = connectionBookings.inputStream.bufferedReader().use { it.readText() }
                    val type = Types.newParameterizedType(List::class.java, Map::class.java)
                    val listMaps = moshi.adapter<List<Map<String, Any>>>(type).fromJson(rawJson)
                    if (listMaps != null) {
                        val newBookingsList = mutableListOf<BookingModel>()
                        for (item in listMaps) {
                            val id = item["id"]?.toString() ?: ""
                            val name = item["name"]?.toString() ?: ""
                            val avatar = item["avatar"]?.toString() ?: ""
                            val checkInStr = item["check_in"]?.toString() ?: ""
                            val checkOutStr = item["check_out"]?.toString() ?: ""
                            val totalPrice = (item["total_price"]?.toString()?.toDoubleOrNull()) ?: 1250000.0
                            val hotelName = item["hotel_name"]?.toString() ?: "Mường Thanh Luxury"
                            val roomName = item["room_name"]?.toString() ?: "Phòng Superior"
                            val statusStr = item["status"]?.toString() ?: "Đã thanh toán"
                            val roomId = (item["room_id"]?.toString() ?: "").substringBefore(".")
                            
                            val formatIn = checkInStr.substringBefore("T")
                            val formatOut = checkOutStr.substringBefore("T")
                            
                            val status = if (statusStr == "Đã hủy" || statusStr.lowercase().contains("huy")) {
                                BookingStatus.CANCELLED
                            } else {
                                BookingStatus.CONFIRMED
                            }
                            
                            val booking = BookingModel(
                                id = id.ifEmpty { "B" + UUID.randomUUID().toString().substring(0, 5).uppercase() },
                                userId = "user_123",
                                hotelId = "hotel_1",
                                roomId = "room_$roomId",
                                hotelName = hotelName,
                                roomName = roomName,
                                hotelImage = "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500",
                                checkInDate = formatIn,
                                checkOutDate = formatOut,
                                nights = 1,
                                guestsCount = 2,
                                pricePerNight = totalPrice,
                                subtotal = totalPrice,
                                taxFee = 0.0,
                                serviceFee = 0.0,
                                discountAmount = 0.0,
                                totalAmount = totalPrice,
                                appliedCoupon = null,
                                status = status,
                                guestName = name,
                                guestEmail = name.lowercase().replace(" ", "") + "@gmail.com",
                                guestPhone = "0987654" + (100 + (id.toIntOrNull() ?: 1)),
                                paymentMethod = "Momo"
                            )
                            newBookingsList.add(booking)
                        }
                        
                        if (newBookingsList.isNotEmpty()) {
                            _bookings.value = newBookingsList
                            saveBookings()
                        }
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun loadDefaultHotels() {
        val h1 = HotelModel(
            id = "hotel_1",
            name = "Sofitel Legend Metropole Hanoi",
            description = "Biểu tượng lịch sử cổ kính tọa lạc tại trung tâm Hà Nội, cách Hồ Hoàn Kiếm bước đi bộ. Trải nghiệm dịch vụ xa hoa đẳng cấp thế giới kết hợp phong cách thuộc địa Pháp sang trọng bậc nhất.",
            address = "15 Phố Ngô Quyền, Tràng Tiền, Hoàn Kiếm, Hà Nội",
            city = "Hà Nội",
            stars = 5,
            rating = 9.6,
            reviewCount = 145,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Parking", "Spa"),
            priceMin = 4200000.0,
            latitude = 21.0253,
            longitude = 105.8569,
            isFeatured = true
        )

        val h2 = HotelModel(
            id = "hotel_2",
            name = "InterContinental Danang Resort",
            description = "Nằm tách biệt trên bán đảo Sơn Trà thơ mộng với tầm nhìn panorama biển Đông tuyệt đẹp. Nổi tiếng với kiến trúc độc đáo của kiến trúc sư lừng danh Bill Bensley và ẩm thực Michelin tuyệt hảo.",
            address = "Bán đảo Sơn Trà, Thọ Quang, Sơn Trà, Đà Nẵng",
            city = "Đà Nẵng",
            stars = 5,
            rating = 9.8,
            reviewCount = 98,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Spa"),
            priceMin = 6800000.0,
            latitude = 16.1219,
            longitude = 108.2801,
            isFeatured = true
        )

        val h3 = HotelModel(
            id = "hotel_3",
            name = "Hotel de la Coupole - MGallery Sapa",
            description = "Kiệt tác nghỉ dưỡng hòa quyện giữa nét văn hóa rực rỡ của các dân tộc Sapa truyền thống và thời trang lộng lẫy những năm 1930 nước Pháp. Tầm nhìn thẳng ra thung lũng Mường Hoa kỳ vĩ.",
            address = "1 Đường Hoàng Liên, Sa Pa, Lào Cai",
            city = "Sapa",
            stars = 5,
            rating = 9.3,
            reviewCount = 112,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast"),
            priceMin = 2400000.0,
            latitude = 22.3364,
            longitude = 103.8438,
            isFeatured = false
        )

        val h4 = HotelModel(
            id = "hotel_4",
            name = "La Veranda Resort Phu Quoc",
            description = "Khu nghỉ dưỡng phong cách biệt thự Pháp thế kỷ 19 quyến rũ bên làn nước xanh lục bảo của đảo Ngọc Phú Quốc. Khuôn viên tràn ngập hoa lá nhiệt đới thanh tịnh và bãi cát trắng mịn riêng tư.",
            address = "Trần Hưng Đạo, Dương Đông, Phú Quốc, Kiên Giang",
            city = "Phú Quốc",
            stars = 5,
            rating = 9.1,
            reviewCount = 82,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Breakfast", "Parking", "Spa"),
            priceMin = 3200000.0,
            latitude = 10.1985,
            longitude = 103.9593,
            isFeatured = true
        )

        val h5 = HotelModel(
            id = "hotel_5",
            name = "The Reverie Saigon Hotel",
            description = "Trải nghiệm rực rỡ xa xỉ đỉnh cao mang đậm dấu ấn phong cách hoàng gia Ý ngay tại trung tâm Sài Gòn. Tận hưởng tầm nhìn vô cực ngắm trọn khúc sông Sài Gòn uốn lượn tuyệt đẹp.",
            address = "22-36 Đường Nguyễn Huệ, Bến Nghé, Quận 1, TP. Hồ Chí Minh",
            city = "Hồ Chí Minh",
            stars = 5,
            rating = 9.5,
            reviewCount = 76,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Parking"),
            priceMin = 5900000.0,
            latitude = 10.7749,
            longitude = 106.7034,
            isFeatured = false
        )

        val h6 = HotelModel(
            id = "hotel_6",
            name = "Sapa Jade Hill Resort",
            description = "Ẩn mình giữa rừng samu ngát xanh và sương mờ mây phủ, khu resort sinh thái thiết kế như bản làng vùng cao vô cùng mộc mạc thanh bình nhưng đầy tinh tế, ấm cúng lò sưởi củi.",
            address = "Cầu Mây, Sa Pa, Lào Cai",
            city = "Sapa",
            stars = 4,
            rating = 8.7,
            reviewCount = 54,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1495365200479-c4ed1d35e1aa?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Breakfast", "Parking"),
            priceMin = 1850000.0,
            latitude = 22.3195,
            longitude = 103.8550,
            isFeatured = false
        )

        val h7 = HotelModel(
            id = "hotel_7",
            name = "Vinpearl Resort & Spa Nha Trang",
            description = "Cung điện nghỉ dưỡng lộng lẫy ôm trọn vịnh biển Nha Trang tuyệt đẹp. Nổi bật với b bơi vô l cực khổng lồ, bãi tắm cát trắng mịn màng tư và rạp chiếu phim bãi biển hoàng hôn.",
            address = "Đảo Hòn Tre, Vĩnh Nguyên, Nha Trang",
            city = "Nha Trang",
            stars = 5,
            rating = 9.4,
            reviewCount = 208,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Spa", "Kids Club"),
            priceMin = 2900000.0,
            isFeatured = true
        )

        val h8 = HotelModel(
            id = "hotel_8",
            name = "Dalat Palace Heritage Hotel",
            description = "Tòa dinh thự thuộc địa sang trọng bậc nhất Đà Lạt với tầm nhìn ngắm Hồ Xuân Hương nên thơ. Được bao bọc bởi vườn hoa rực rỡ và đồi thông xanh ngát quanh năm mát lạnh.",
            address = "2 Đường Trần Phú, Phường 3, Đà Lạt",
            city = "Đà Lạt",
            stars = 5,
            rating = 9.2,
            reviewCount = 135,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Breakfast", "Parking", "Golf Course", "Garden"),
            priceMin = 2500000.0,
            isFeatured = false
        )

        val h9 = HotelModel(
            id = "hotel_9",
            name = "Muong Thanh Luxury Quang Ninh",
            description = "Khách sạn hiện đại vươn tầm cao ngắm trọn kỳ quan thiên nhiên thế giới Vịnh Hạ Long. Dịch vụ lưu trú cao cấp, vị trí trực diện quảng trường Sun World sầm uất.",
            address = "Đường Hạ Long, Bãi Cháy, Hạ Long",
            city = "Hạ Long",
            stars = 5,
            rating = 8.9,
            reviewCount = 312,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Parking"),
            priceMin = 1600000.0,
            isFeatured = true
        )

        val h10 = HotelModel(
            id = "hotel_10",
            name = "Azerai La Residence Hue",
            description = "Biệt thự art deco cổ kính nép mình duyên dáng bên dòng sông Hương thơ mộng của xứ Huế cổ kính. Phong cảnh yên bình tĩnh lặng, kiến trúc đỉnh cao và ẩm thực Huế cung đình xa xưa.",
            address = "5 Lê Lợi, Vĩnh Ninh, Huế",
            city = "Huế",
            stars = 5,
            rating = 9.5,
            reviewCount = 88,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Spa"),
            priceMin = 3450000.0,
            isFeatured = false
        )

        val h11 = HotelModel(
            id = "hotel_11",
            name = "The Imperial Hotel Vung Tau",
            description = "Khách sạn 5 sao mang phong cách thiết kế mĩ lệ đậm chất nghệ thuật hoàng gia phương Tây cổ điển. Nằm cạnh bờ biển Bãi Sau tuyệt đẹp tràn ngập sóng vỗ rực rỡ.",
            address = "159 Thùy Vân, Thắng Tam, Vũng Tàu",
            city = "Vũng Tàu",
            stars = 5,
            rating = 9.1,
            reviewCount = 274,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Spa", "Beach Access"),
            priceMin = 2100000.0,
            isFeatured = true
        )

        val h12 = HotelModel(
            id = "hotel_12",
            name = "Amanoi Resort Vinh Hy",
            description = "Tuyệt phẩm nghỉ dưỡng ẩn dật sáu sao giữa rừng xanh núi đá Vườn Quốc gia Núi Chúa và vịnh Vĩnh Hy trong vắt. Nơi riêng tư tối thượng, xa xỉ bậc nhất Việt Nam.",
            address = "Thôn Vĩnh Hy, Vĩnh Hải, Ninh Hải, Ninh Thuận",
            city = "Ninh Thuận",
            stars = 5,
            rating = 9.9,
            reviewCount = 42,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=800&q=80",
                "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Breakfast", "Spa", "Private Beach", "Butler"),
            priceMin = 22000000.0,
            isFeatured = true
        )

        val h13 = HotelModel(
            id = "hotel_13",
            name = "Banyan Tree Lăng Cô",
            description = "Khu nghỉ dưỡng biệt thự có hồ bơi riêng biệt lập, nép mình bên vịnh biển Lăng Cô nguyên sơ hoang dã vĩ đại bậc nhất miền Trung Việt Nam.",
            address = "Cù Dù, Lộc Vĩnh, Phú Lộc, Thừa Thiên Huế",
            city = "Lăng Cô",
            stars = 5,
            rating = 9.7,
            reviewCount = 65,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Spa", "Private Beach", "Golf Course"),
            priceMin = 8500000.0,
            isFeatured = true
        )

        val h14 = HotelModel(
            id = "hotel_14",
            name = "Legacy Yên Tử - MGallery",
            description = "Khu tĩnh dưỡng tâm linh đỉnh cao mang đậm kiến trúc cung đình nhà Trần thế kỷ 13, đắm mình trong sự huyền bí cô tịch linh thiêng của thánh địa Yên Tử.",
            address = "Thượng Yên Công, Uông Bí, Quảng Ninh",
            city = "Uông Bí",
            stars = 5,
            rating = 9.4,
            reviewCount = 189,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Spa", "Garden", "Yoga Deck"),
            priceMin = 3100000.0,
            isFeatured = false
        )

        val h15 = HotelModel(
            id = "hotel_15",
            name = "Flamingo Đại Lải Resort",
            description = "Ốc đảo xanh mát rực rỡ với tổ hợp biệt thự rừng thông sinh thái và tòa nhà rừng xanh trên cao Forest in the Sky độc nhất vô nhị cận kề Hà Nội.",
            address = "Ngọc Thanh, Phúc Yên, Vĩnh Phúc",
            city = "Đại Lải",
            stars = 5,
            rating = 8.8,
            reviewCount = 422,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Spa", "Parking", "Kids Play Area"),
            priceMin = 1900000.0,
            isFeatured = true
        )

        val h16 = HotelModel(
            id = "hotel_16",
            name = "FLC Quy Nhơn Beach & Golf Resort",
            description = "Thiên đường nghỉ dưỡng 5 sao ôm trọn bờ biển Nhơn Lý tuyệt đẹp và sân golf 36 hố dạng bán sa mạc thách thức đầy ấn tượng.",
            address = "Khu 4, Nhơn Lý, Quy Nhơn, Bình Định",
            city = "Quy Nhơn",
            stars = 5,
            rating = 8.6,
            reviewCount = 295,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Parking", "Golf Course"),
            priceMin = 1700000.0,
            isFeatured = false
        )

        val h17 = HotelModel(
            id = "hotel_17",
            name = "Four Seasons Resort The Nam Hai",
            description = "Ốc đảo di sản xa hoa lộng lẫy nép mình duyên dáng bên bờ cát trắng mịn Hà My, nâng niu hành trình kết nối tâm hồn của bạn.",
            address = "Khối Hà My Đông B, Điện Bàn, Quảng Nam",
            city = "Hội An",
            stars = 5,
            rating = 9.9,
            reviewCount = 57,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Spa", "Private Beach", "Butler"),
            priceMin = 18000000.0,
            isFeatured = true
        )

        val h18 = HotelModel(
            id = "hotel_18",
            name = "Anantara Mui Ne Resort",
            description = "Khu vườn nhiệt đới thanh tịnh bên bờ biển Phan Thiết lộng gió, nơi nét đẹp truyền thống Việt Nam hòa quyện tinh tế cùng dịch vụ đẳng cấp quốc tế.",
            address = "12A Nguyễn Đình Chiểu, Hàm Tiến, Phan Thiết, Bình Thuận",
            city = "Mũi Né",
            stars = 5,
            rating = 9.2,
            reviewCount = 143,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Spa", "Beach Access"),
            priceMin = 3500000.0,
            isFeatured = false
        )

        val h19 = HotelModel(
            id = "hotel_19",
            name = "Melia Ba Vi Mountain Retreat",
            description = "Thiên đường nghỉ dưỡng ẩn dật giữa sương mây lãng đãng của vườn quốc gia Ba Vì, bao bọc bởi phế tích Pháp cổ kính nhuốm màu rêu phong cổ tích.",
            address = "Vườn Quốc gia Ba Vì, Tản Lĩnh, Ba Vì, Hà Nội",
            city = "Ba Vì",
            stars = 5,
            rating = 9.3,
            reviewCount = 94,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Gym", "Breakfast", "Spa", "Mountain View"),
            priceMin = 2800000.0,
            isFeatured = true
        )

        val h20 = HotelModel(
            id = "hotel_20",
            name = "Emeralda Resort Ninh Binh",
            description = "Tái hiện trọn vẹn không gian làng quê Bắc Bộ xưa cũ thanh bình, nép mình bên khu bảo tồn thiên nhiên ngập nước Vân Long thơ mộng rực rỡ.",
            address = "Khu bảo tồn Vân Long, Gia Vân, Gia Viễn, Ninh Bình",
            city = "Ninh Bình",
            stars = 4,
            rating = 8.9,
            reviewCount = 211,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Breakfast", "Parking", "Spa", "Garden"),
            priceMin = 1500000.0,
            isFeatured = false
        )

        _hotels.value = listOf(h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20)
        saveHotels()
    }

    private fun loadDefaultRooms() {
        val rList = mutableListOf<RoomModel>()
        
        // Rooms for hotel_1
        rList.add(RoomModel("r1_1", "hotel_1", "Classic Luxury King Room", "Phòng cổ điển sang trọng mang tông ấm ấm cúng, lát sàn gỗ lim đỏ, cửa sổ cao đón ánh sáng tự nhiên tuyệt đẹp và phòng tắm đá cẩm thạch hoàn mỹ.", 4200000.0, "1 King-size Bed", 2, 38, listOf("https://images.unsplash.com/photo-1611891405112-700df06ad678?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Minibar", "Bathtub")))
        rList.add(RoomModel("r1_2", "hotel_1", "Grand Prestige Opera Suite", "Căn Suite thượng lưu đối diện Nhà Hát Lớn, phòng tiếp khách biệt lập hoàn toàn và quản gia Metropole phục vụ riêng tư 24/7.", 7500000.0, "1 Super King Bed", 3, 75, listOf("https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Minibar", "Bathtub", "Spa Access", "Lounge Access")))

        // Rooms for hotel_2
        rList.add(RoomModel("r2_1", "hotel_2", "Resort Classic Ocean Terrace", "Trải nghiệm thiên đường lộng lẫy mây gió bán đảo Sơn Trà. Ban công rộng phóng tầm mắt ngắm trọn vẹn biển xanh.", 6800000.0, "1 King Bed", 2, 70, listOf("https://images.unsplash.com/photo-1568495248636-6432b97bd949?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Sea View", "Balcony", "Bathtub")))
        rList.add(RoomModel("r2_2", "hotel_2", "Heavenly Peninsula Suite", "Tọa lạc đỉnh đồi Heavenly cao quý, tột bậc tinh hoa sang trọng với hồ bơi vô cực sục khí tràn bờ tuyệt mỹ riêng cho căn hộ.", 12500000.0, "1 Presidential Bed", 4, 130, listOf("https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Sea View", "Private Pool", "Bathtub", "Premium Butler")))

        // Rooms for hotel_3
        rList.add(RoomModel("r3_1", "hotel_3", "Classic Indochine Room", "Hơi thở thời trang Pháp tân cổ điển sang quý phối cùng hoa văn rực rỡ Dao, H'mông thơ mộng giữa thung lũng mây.", 2400000.0, "1 King Bed or 2 Twin Beds", 2, 40, listOf("https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Mountain View")))
        rList.add(RoomModel("r3_2", "hotel_3", "Executive Sapa Valley View", "Ban công ngắm tuyết rơi Sapa bồng bềnh mây trôi. Nội thất nhung lụa Pháp cực kỳ tráng lệ thanh lịch đẳng cấp.", 3600000.0, "1 Super King Bed", 2, 52, listOf("https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Mountain View", "Balcony", "Bathtub")))

        // Rooms for hotel_4
        rList.add(RoomModel("r4_1", "hotel_4", "Classic Garden Villa Room", "Ẩn mình giữa vườn dừa xào xạc, tiếng sóng vỗ dịu êm. Sân vườn hiên đón mây gió nghỉ dưỡng lãng mạn.", 3200000.0, "1 King Bed", 2, 45, listOf("https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Garden Access")))
        rList.add(RoomModel("r4_2", "hotel_4", "Ocean Front Sea Bungalow", "Bungalow sát bãi biển cát trắng chỉ 5 bước chân chạm nước biển. Ngắm hoàng hôn Phú Quoc tuyệt mỹ từ giường nằm.", 4800000.0, "1 King Bed", 2, 55, listOf("https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Sea View", "Direct Beach Access", "Balcony")))

        // Rooms for hotel_5
        rList.add(RoomModel("r5_1", "hotel_5", "Deluxe Panorama Room", "Khúc sông Sài Gòn uốn lượn dưới chân qua khung kính vô cực từ sàn tới trần. Thiết kế dát vàng Ý hoa lệ lấp lánh.", 5900000.0, "1 King Bed", 2, 43, listOf("https://images.unsplash.com/photo-1584132967334-10e028bd69f7?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "City View", "Gym & Pool")))

        // Rooms for hotel_6
        rList.add(RoomModel("r6_1", "hotel_6", "Bungalow Garden View Mountain", "Ngôi nhà đá lợp mái tranh mộc mạc bên luống hoa cẩm tú cầu. Lò sưởi củi khói đốt gỗ thông ấm nồng Sa Pa.", 1850000.0, "1 Double Bed", 2, 40, listOf("https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Valley View", "Fireplace")))

        // Rooms for hotel_7
        rList.add(RoomModel("r7_1", "hotel_7", "Deluxe Ocean View Room", "Tầm nhìn đại dương ngập nắng ấm Nha Trang, ban công lộng gió lý tưởng ngắm bình minh trên vịnh.", 2900000.0, "1 King-size Bed", 2, 42, listOf("https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Pool Access", "Sea View")))

        // Rooms for hotel_8
        rList.add(RoomModel("r8_1", "hotel_8", "Palace Indochine Deluxe", "Hơi thở quý tộc Pháp sang trọng tuyệt đỉnh kết hợp khuôn viên hoa hồng tuyệt sắc Sapa mây phủ.", 2500000.0, "1 King-size Bed", 2, 48, listOf("https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Golf View", "Garden View")))

        // Rooms for hotel_9
        rList.add(RoomModel("r9_1", "hotel_9", "Executive Bay View Suite", "Căn hộ hiện đại nhìn trực diện ra toàn vịnh biển lung linh thuyền cá bồng bềnh mây trôi.", 1600000.0, "1 King Bed", 2, 45, listOf("https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Parking")))

        // Rooms for hotel_10
        rList.add(RoomModel("r10_1", "hotel_10", "Colonial Deluxe Room", "Ấm cúng mang trong mình dấu ấn thời gian diễm lệ của xứ kinh kỳ cổ kính bên sông Hương.", 3450000.0, "1 King Bed", 2, 36, listOf("https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "River View")))

        // Rooms for hotel_11
        rList.add(RoomModel("r11_1", "hotel_11", "Imperial King Beachside", "Trang hoàng mĩ lệ phong cách hoàng gia Pháp lộng lẫy xa xỉ quý tộc sát bờ cát lộng gió biển.", 2100000.0, "1 King Bed", 2, 40, listOf("https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Sea View", "Beach Access")))

        // Rooms for hotel_12
        rList.add(RoomModel("r12_1", "hotel_12", "Ocean Pavilion Villa", "Quần thể villa biệt lập nằm nhô ra vách đá vịnh Vĩnh Hy siêu cao cấp riêng tư, hồ bơi tràn bờ lung tinh tú.", 22000000.0, "1 Super King Bed", 2, 120, listOf("https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Ocean View", "Private Pool", "Butler Service")))

        // Rooms for hotel_13
        rList.add(RoomModel("r13_1", "hotel_13", "Lagoon Pool Villa", "Biệt thự lộng lẫy nép mình bên đầm nước yên bình với hồ bơi riêng biệt độc đáo.", 8500000.0, "1 King Bed", 2, 88, listOf("https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Private Pool", "Bathtub")))
        rList.add(RoomModel("r13_2", "hotel_13", "Beachfront Pool Villa", "Biệt thự sát biển với hồ bơi vô cực riêng tư hướng biển ngập tràn sóng vỗ.", 13500000.0, "1 Super King Bed", 2, 124, listOf("https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Private Pool", "Sea View", "Bathtub")))

        // Rooms for hotel_14
        rList.add(RoomModel("r14_1", "hotel_14", "Superior King Room", "Không gian gỗ trầm ấm cúng với những họa tiết cổ kính mang đậm chất tâm linh.", 3100000.0, "1 King Bed", 2, 40, listOf("https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast")))
        rList.add(RoomModel("r14_2", "hotel_14", "Deluxe Forest View Suite", "Căn Suite cao cấp phóng tầm nhìn bao trọn cánh rừng nguyên sinh linh thiêng mờ sương.", 4800000.0, "1 Super King Bed", 3, 62, listOf("https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Forest View", "Bathtub")))

        // Rooms for hotel_15
        rList.add(RoomModel("r15_1", "hotel_15", "Forest In The Sky Villa", "Căn biệt thự rạng rỡ được thiết kế phủ đầy cây xanh rực rỡ từ ban công tới phòng ngủ.", 1900000.0, "1 King Bed", 2, 50, listOf("https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Balcony")))
        rList.add(RoomModel("r15_2", "hotel_15", "Luxury Hilltop Pool Villa", "Biệt thự biệt lập nằm ẩn hiện trên sườn đồi bao quanh bởi rừng thông thơ mộng.", 3600000.0, "1 Super King Bed", 2, 90, listOf("https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Private Pool", "Bathtub", "Pine Hill View")))

        // Rooms for hotel_16
        rList.add(RoomModel("r16_1", "hotel_16", "Studio Suite Garden View", "Phòng Suite tiện nghi hiện đại với ban công rộng mở, gió mát rượi thổi qua rặng dừa.", 1700000.0, "1 King Bed", 2, 50, listOf("https://images.unsplash.com/photo-1584132967334-10e028bd69f7?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Garden View")))
        rList.add(RoomModel("r16_2", "hotel_16", "Grand Ocean View Suite", "Phòng căn hộ cao cấp ngắm toàn cảnh bình minh rực rỡ trên vùng biển Quy Nhơn.", 2900000.0, "1 Super King Bed", 2, 80, listOf("https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Sea View", "Bathtub", "Balcony")))

        // Rooms for hotel_17
        rList.add(RoomModel("r17_1", "hotel_17", "One-Bedroom Villa", "Thiết kế biệt lập hoàn mỹ giữa rặng dừa ngát xanh rực rỡ tầm nhìn biển Đông.", 18000000.0, "1 King Bed", 2, 80, listOf("https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Ocean View", "Private Garden")))
        rList.add(RoomModel("r17_2", "hotel_17", "Beachfront Pool Villa 1BR", "Trải nghiệm xa hoa tột đỉnh với quản gia chu đáo và hồ bơi vô cực hướng thẳng ra đại dương xanh.", 26000000.0, "1 Super King Bed", 2, 104, listOf("https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Ocean View", "Private Pool", "Butler")))

        // Rooms for hotel_18
        rList.add(RoomModel("r18_1", "hotel_18", "Deluxe Chamber Room", "Sự kết hợp tinh xảo giữa gỗ mật tông ấm cúng và ban công lộng ngập tràn hoa sứ.", 3500000.0, "1 King Bed", 2, 57, listOf("https://images.unsplash.com/photo-1611891405112-700df06ad678?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Balcony")))
        rList.add(RoomModel("r18_2", "hotel_18", "Beachfront Pool Villa", "Tọa lạc ngay bên thềm cát phẳng lặng, tiếng sóng biển rì rào vỗ về giấc ngủ yên bình.", 6200000.0, "1 Super King Bed", 2, 92, listOf("https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Sea View", "Private Pool")))

        // Rooms for hotel_19
        rList.add(RoomModel("r19_1", "hotel_19", "Deluxe Forest Retreat", "Bao bọc bởi thiên nhiên nguyên rực rỡ và tiếng chim hót líu lo chào ngày mới.", 2800000.0, "1 King Bed", 2, 45, listOf("https://images.unsplash.com/photo-1568495248636-6432b97bd949?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Mountain View")))
        rList.add(RoomModel("r19_2", "hotel_19", "Premium Mountain Suite", "Không gian ấm áp sang quý với bồn tắm gỗ thơm phảng phất mùi trầm hương hoang dã.", 4500000.0, "1 Super King Bed", 2, 65, listOf("https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Mountain View", "Wooden Tub")))

        // Rooms for hotel_20
        rList.add(RoomModel("r20_1", "hotel_20", "Superior King Garden", "Ngôi nhà ba gian mái ngói cổ truyền ấm cúng với vườn tược tĩnh mịch bình lãng.", 1500000.0, "1 King Bed", 2, 40, listOf("https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Garden Access")))
        rList.add(RoomModel("r20_2", "hotel_20", "Duplex Family View", "Căn hai tầng rộng rãi thiết kế hoài cổ mây tre giản dị, hoàn hảo cho kỳ nghỉ gia đình.", 2800000.0, "2 Queen Beds", 4, 65, listOf("https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Garden View", "Balcony")))

        _rooms.value = rList
        saveRooms()
    }

    private fun loadDefaultBookings(): List<BookingModel> {
        val b1 = BookingModel(
            id = "B5201A",
            userId = "user_123",
            hotelId = "hotel_1",
            roomId = "r1_1",
            hotelName = "Sofitel Legend Metropole Hanoi",
            roomName = "Classic Luxury King Room",
            hotelImage = "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=300&q=80",
            checkInDate = "2026-06-15",
            checkOutDate = "2026-06-17",
            nights = 2,
            guestsCount = 2,
            pricePerNight = 4200000.0,
            subtotal = 8400000.0,
            taxFee = 84000.0,
            serviceFee = 42000.0,
            discountAmount = 200000.0,
            totalAmount = 8326000.0,
            appliedCoupon = "STAYEASE200K",
            status = BookingStatus.CONFIRMED,
            guestName = "Vương Hoàng Tuấn Anh",
            guestEmail = "vuonghoangtuananh6@gmail.com",
            guestPhone = "0987654321",
            paymentMethod = "Momo"
        )
        val b2 = BookingModel(
            id = "B8721C",
            userId = "user_123",
            hotelId = "hotel_3",
            roomId = "r3_1",
            hotelName = "Hotel de la Coupole - MGallery Sapa",
            roomName = "Classic Indochine Room",
            hotelImage = "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=300&q=80",
            checkInDate = "2026-05-01",
            checkOutDate = "2026-05-04",
            nights = 3,
            guestsCount = 2,
            pricePerNight = 2400000.0,
            subtotal = 7200000.0,
            taxFee = 72000.0,
            serviceFee = 36000.0,
            discountAmount = 0.0,
            totalAmount = 7308000.0,
            appliedCoupon = null,
            status = BookingStatus.COMPLETED,
            guestName = "Vương Hoàng Tuấn Anh",
            guestEmail = "vuonghoangtuananh6@gmail.com",
            guestPhone = "0987654321",
            paymentMethod = "VNPay"
        )
        return listOf(b1, b2)
    }

    private fun loadDefaultReviews() {
        val list = listOf(
            ReviewModel(UUID.randomUUID().toString(), "hotel_1", "Minh Hằng", "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=100&q=80", 5.0f, "Phòng vô cùng thượng hoàng, dịch vụ Metropole chưa bao giờ làm tôi thất vọng. Sẽ quay lại nhiều lần!", "2026-04-12"),
            ReviewModel(UUID.randomUUID().toString(), "hotel_1", "Alex Smith", "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=100&q=80", 4.5f, "Historic French elegance in the heart of Hanoi. Breakfast was unbelievable.", "2026-05-03"),
            ReviewModel(UUID.randomUUID().toString(), "hotel_2", "Tấn Dũng", "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80", 5.0f, "Thiên đường hạ giới! Cách bài trí từng lầu Sông - Đất - Sky cực mỹ lệ. Quán Citron ăn sáng ngon.", "2026-05-20")
        )
        _reviews.value = list
        saveReviews()
    }

    private fun loadDefaultCoupons(): List<CouponModel> {
        return listOf(
            CouponModel("STAYEASE200K", "Giảm ngày 200.000đ cho mọi phòng đặt", 10, 200000.0, 1000000.0),
            CouponModel("WELCOME500K", "Chào mừng hành khách mới giảm ngay 500.000đ từ StayEase Co.", 15, 500000.0, 3000000.0),
            CouponModel("SUPERDEAL800K", "Siêu khuyến mãi giảm trực tiếp 800.000đ thẳng hóa đơn", 20, 800000.0, 5000000.0)
        )
    }

    // Persist changes
    private fun saveHotels() {
        val type = Types.newParameterizedType(List::class.java, HotelModel::class.java)
        prefs.edit().putString("saved_hotels", moshi.adapter<List<HotelModel>>(type).toJson(_hotels.value)).apply()
    }

    private fun saveRooms() {
        val type = Types.newParameterizedType(List::class.java, RoomModel::class.java)
        prefs.edit().putString("saved_rooms", moshi.adapter<List<RoomModel>>(type).toJson(_rooms.value)).apply()
    }

    fun saveBookings() {
        val type = Types.newParameterizedType(List::class.java, BookingModel::class.java)
        prefs.edit().putString("saved_bookings", moshi.adapter<List<BookingModel>>(type).toJson(_bookings.value)).apply()
    }

    private fun saveReviews() {
        val type = Types.newParameterizedType(List::class.java, ReviewModel::class.java)
        prefs.edit().putString("saved_reviews", moshi.adapter<List<ReviewModel>>(type).toJson(_reviews.value)).apply()
    }

    private fun saveUser() {
        prefs.edit().putString("current_user", moshi.adapter(UserModel::class.java).toJson(_currentUser.value)).apply()
    }

    fun getPassword(email: String): String {
        return prefs.getString("password_$email", "123456") ?: "123456"
    }

    fun savePassword(email: String, pass: String) {
        prefs.edit().putString("password_$email", pass).apply()
    }

    fun registerUserAccount(name: String, email: String, phone: String, pass: String): UserModel {
        val newUser = UserModel(
            id = "user_" + UUID.randomUUID().toString().substring(0, 5),
            email = email,
            name = name,
            phoneNumber = phone,
            loyaltyPoints = 500,
            isVerified = false,
            createdAt = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date())
        )
        _currentUser.value = newUser
        saveUser()
        savePassword(email, pass)
        prefs.edit().putString("profile_name_$email", name).apply()
        prefs.edit().putString("profile_phone_$email", phone).apply()
        prefs.edit().putBoolean("verified_$email", false).apply()
        return newUser
    }

    fun isEmailVerified(email: String): Boolean {
        if (email.trim().lowercase() == "vuonghoangtuananh6@gmail.com") return true
        return prefs.getBoolean("verified_${email.trim().lowercase()}", false)
    }

    fun markEmailVerified(email: String) {
        val emailClean = email.trim().lowercase()
        prefs.edit().putBoolean("verified_$emailClean", true).apply()
        if (_currentUser.value.email.trim().lowercase() == emailClean) {
            _currentUser.value = _currentUser.value.copy(isVerified = true)
            saveUser()
        }
    }

    fun loginUserAccount(email: String, pass: String): Boolean {
        val savedPass = getPassword(email)
        if (savedPass == pass) {
            val name = prefs.getString("profile_name_$email", "Vương Hoàng Tuấn Anh") ?: "Vương Hoàng Tuấn Anh"
            val phone = prefs.getString("profile_phone_$email", "0987654321") ?: "0987654321"
            val isVerifiedStatus = isEmailVerified(email)
            val loadedUser = UserModel(
                id = "user_" + email.hashCode().toString().take(5),
                email = email,
                name = name,
                phoneNumber = phone,
                loyaltyPoints = 450,
                isVerified = isVerifiedStatus,
                createdAt = "2026-05-23"
            )
            _currentUser.value = loadedUser
            saveUser()
            return true
        }
        return false
    }

    fun googleSignInAccount(email: String, name: String, avatarUrl: String) {
        val newUser = UserModel(
            id = "google_" + UUID.randomUUID().toString().substring(0, 5),
            email = email,
            name = name,
            avatarUrl = avatarUrl,
            loyaltyPoints = 500,
            isVerified = true,
            createdAt = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date())
        )
        _currentUser.value = newUser
        saveUser()
        prefs.edit().putString("profile_name_$email", name).apply()
        prefs.edit().putString("profile_phone_$email", "0987654321").apply()
        prefs.edit().putBoolean("verified_${email.trim().lowercase()}", true).apply()
    }

    // Wishlist API
    fun toggleWishlist(hotelId: String) {
        val updated = _wishlist.value.toMutableSet()
        if (updated.contains(hotelId)) {
            updated.remove(hotelId)
        } else {
            updated.add(hotelId)
        }
        _wishlist.value = updated
        prefs.edit().putStringSet("wishlist_hotel_ids", updated).apply()
    }

    // User Profile API
    fun updateProfile(name: String, email: String, phone: String) {
        val updatedUser = _currentUser.value.copy(name = name, email = email, phoneNumber = phone)
        _currentUser.value = updatedUser
        saveUser()
    }

    fun setLanguage(lang: String) {
        val updatedUser = _currentUser.value.copy(language = lang)
        _currentUser.value = updatedUser
        saveUser()
    }

    fun setDarkMode(enabled: Boolean) {
        val updatedUser = _currentUser.value.copy(isDarkMode = enabled)
        _currentUser.value = updatedUser
        saveUser()
    }

    fun rewardLoyaltyPoints(pts: Int) {
        val updatedUser = _currentUser.value.copy(loyaltyPoints = _currentUser.value.loyaltyPoints + pts)
        _currentUser.value = updatedUser
        saveUser()
    }

    // Support messenger chat engine
    fun addChatMessage(message: String) {
        val userMsg = MessageModel(
            senderId = _currentUser.value.id,
            senderName = _currentUser.value.name,
            isFromAdmin = false,
            content = message
        )
        val list = _chatMessages.value.toMutableList()
        list.add(userMsg)
        _chatMessages.value = list

        // Auto fake AI assistant replay response simulating real service
        val aiMessage = when {
            message.lowercase().contains("đặt phòng") || message.lowercase().contains("booking") -> {
                "Bạn có thể đặt phòng trực tiếp qua trang chi tiết của mỗi khách sạn! Chọn ngày nhận/trả và phòng mong muốn, sau đó click Đặt Ngay."
            }
            message.lowercase().contains("khuyến mãi") || message.lowercase().contains("mã giảm") || message.lowercase().contains("sale") -> {
                "StayEase đang áp dụng mã giảm giá ưu đãi 'STAYEASE50' (giảm $50) và 'AGODASALE' (giảm tối đa 20%). Nhập mã khi thanh toán để được giảm trừ nhé!"
            }
            message.lowercase().contains("hà nội") || message.lowercase().contains("hanoi") -> {
                "Hà Nội đang có khách sạn sang trọng *Sofitel Legend Metropole Hanoi* cực kì cổ kính và cuốn hút. Bạn có muốn đặt phòng tại đây?"
            }
            message.lowercase().contains("hoàn tiền") || message.lowercase().contains("hủy phòng") -> {
                "Chính sách hủy phòng linh hoạt áp dụng trước 24 giờ kể từ ngày check-in. Bạn có thể bấm nút Hủy trực tiếp trong Lịch Sử Đặt Phòng."
            }
            else -> {
                "Cảm ơn câu hỏi từ quý khách. Đội ngũ StayEase đã nhận được thông tin yêu cầu tư vấn đặt phòng của bạn và sẽ liên hệ ngay qua SĐT: ${_currentUser.value.phoneNumber}. Bạn còn cần hỗ trợ gì khác không?"
            }
        }

        // Delay mock message simulation
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            val adminMsg = MessageModel(
                senderId = "admin",
                senderName = "StayEase Support",
                isFromAdmin = true,
                content = aiMessage
            )
            val updated = _chatMessages.value.toMutableList()
            updated.add(adminMsg)
            _chatMessages.value = updated
        }, 1200)
    }

    // Bookings manager API
    fun createBooking(booking: BookingModel) {
        val list = _bookings.value.toMutableList()
        list.add(0, booking) // Insert at beginning
        _bookings.value = list
        saveBookings()
        rewardLoyaltyPoints(50) // Reward points
    }

    fun updateBookingStatus(bookingId: String, status: BookingStatus) {
        val list = _bookings.value.map {
            if (it.id == bookingId) it.copy(status = status) else it
        }
        _bookings.value = list
        saveBookings()
    }

    // Reviews writer
    fun addReview(hotelId: String, rating: Float, comment: String) {
        val user = _currentUser.value
        val newReview = ReviewModel(
            hotelId = hotelId,
            userName = user.name,
            userAvatar = user.avatarUrl,
            rating = rating,
            comment = comment,
            date = "Hôm nay"
        )
        val list = _reviews.value.toMutableList()
        list.add(0, newReview)
        _reviews.value = list
        saveReviews()

        // Recalculate hotel's average rating dynamically!
        val hotelReviews = _reviews.value.filter { it.hotelId == hotelId }
        val avgRating = if (hotelReviews.isNotEmpty()) {
            hotelReviews.map { it.rating }.average()
        } else {
            4.5
        }
        val roundedRating = Math.round(avgRating * 10.0) / 10.0

        val updatedHotels = _hotels.value.map {
            if (it.id == hotelId) {
                it.copy(rating = roundedRating, reviewCount = hotelReviews.size + 15) // Keep old count weight
            } else {
                it
            }
        }
        _hotels.value = updatedHotels
        saveHotels()
    }

    // Voice search simulation
    fun searchByVoiceMock(voiceText: String): String {
        return when {
            voiceText.lowercase().contains("sapa") -> "Sapa"
            voiceText.lowercase().contains("hà nội") || voiceText.lowercase().contains("ha noi") -> "Hà Nội"
            voiceText.lowercase().contains("đà nẵng") || voiceText.lowercase().contains("da nang") -> "Đà Nẵng"
            voiceText.lowercase().contains("phú quốc") || voiceText.lowercase().contains("phu quoc") -> "Phú Quốc"
            voiceText.lowercase().contains("sài gòn") || voiceText.lowercase().contains("hồ chí minh") -> "Hồ Chí Minh"
            else -> voiceText
        }
    }

    // ADMIN CRUD
    fun addHotel(hotel: HotelModel) {
        val current = _hotels.value.toMutableList()
        current.add(0, hotel)
        _hotels.value = current
        saveHotels()
    }

    fun updateHotel(hotel: HotelModel) {
        val current = _hotels.value.map {
            if (it.id == hotel.id) hotel else it
        }
        _hotels.value = current
        saveHotels()
    }

    fun deleteHotel(hotelId: String) {
        val current = _hotels.value.filter { it.id != hotelId }
        _hotels.value = current
        saveHotels()
        // Also clean up rooms
        val rCurrent = _rooms.value.filter { it.hotelId != hotelId }
        _rooms.value = rCurrent
        saveRooms()
    }

    fun addRoom(room: RoomModel) {
        val current = _rooms.value.toMutableList()
        current.add(room)
        _rooms.value = current
        saveRooms()
    }

    fun updateRoom(room: RoomModel) {
        val current = _rooms.value.map {
            if (it.id == room.id) room else it
        }
        _rooms.value = current
        saveRooms()
    }

    fun deleteRoom(roomId: String) {
        val current = _rooms.value.filter { it.id != roomId }
        _rooms.value = current
        saveRooms()
    }
}
