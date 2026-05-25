package com.example.data.repository

import android.content.Context
import com.example.data.model.*
import com.example.data.service.ApiService
import com.example.data.service.PrefsHelper
import com.squareup.moshi.Types
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.*

interface HotelRepository {
    val hotels: StateFlow<List<HotelModel>>
    val rooms: StateFlow<List<RoomModel>>
    val reviews: StateFlow<List<ReviewModel>>
    val coupons: StateFlow<List<CouponModel>>
    val chatMessages: StateFlow<List<MessageModel>>
    val recentSearches: StateFlow<List<String>>
    val wishlist: StateFlow<Set<String>>

    fun fetchMockApiData()
    fun addReview(hotelId: String, rating: Float, comment: String)
    fun searchByVoiceMock(voiceText: String): String

    // Admin CRUD
    fun addHotel(hotel: HotelModel)
    fun updateHotel(hotel: HotelModel)
    fun deleteHotel(hotelId: String)
    fun addRoom(room: RoomModel)
    fun updateRoom(room: RoomModel)
    fun deleteRoom(roomId: String)
    fun addChatMessage(message: String)
}

fun HotelRepository(context: Context): HotelRepository = HotelRepositoryImpl(context)

class HotelRepositoryImpl(private val context: Context) : HotelRepository {
    private val prefsHelper = PrefsHelper(context)
    private val apiService = ApiService(prefsHelper.moshi)

    companion object {
        private val _hotels = MutableStateFlow<List<HotelModel>>(emptyList())
        val hotelsFlow = _hotels.asStateFlow()

        private val _rooms = MutableStateFlow<List<RoomModel>>(emptyList())
        val roomsFlow = _rooms.asStateFlow()

        private val _reviews = MutableStateFlow<List<ReviewModel>>(emptyList())
        val reviewsFlow = _reviews.asStateFlow()

        private val _chatMessages = MutableStateFlow<List<MessageModel>>(emptyList())
        val chatMessagesFlow = _chatMessages.asStateFlow()

        private val _coupons = MutableStateFlow<List<CouponModel>>(emptyList())
        val couponsFlow = _coupons.asStateFlow()

        private val _recentSearches = MutableStateFlow<List<String>>(emptyList())
        val recentSearchesFlow = _recentSearches.asStateFlow()

        private var isInitialized = false
    }

    override val hotels: StateFlow<List<HotelModel>> = hotelsFlow
    override val rooms: StateFlow<List<RoomModel>> = roomsFlow
    override val reviews: StateFlow<List<ReviewModel>> = reviewsFlow
    override val chatMessages: StateFlow<List<MessageModel>> = chatMessagesFlow
    override val coupons: StateFlow<List<CouponModel>> = couponsFlow
    override val recentSearches: StateFlow<List<String>> = recentSearchesFlow
    override val wishlist: StateFlow<Set<String>> = FavoriteRepositoryImpl.wishlistFlow

    init {
        synchronized(this) {
            if (!isInitialized) {
                // Initialize lists from prefs or defaults
                val hotelJson = prefsHelper.prefs.getString("saved_hotels", null)
                if (hotelJson != null) {
                    try {
                        val type = Types.newParameterizedType(List::class.java, HotelModel::class.java)
                        val list: List<HotelModel>? = prefsHelper.moshi.adapter<List<HotelModel>>(type).fromJson(hotelJson)
                        if (list != null) {
                            _hotels.value = list
                        } else {
                            loadDefaultHotels()
                        }
                    } catch (e: Exception) {
                        loadDefaultHotels()
                    }
                } else {
                    loadDefaultHotels()
                }

                val roomJson = prefsHelper.prefs.getString("saved_rooms", null)
                if (roomJson != null) {
                    try {
                        val type = Types.newParameterizedType(List::class.java, RoomModel::class.java)
                        val list: List<RoomModel>? = prefsHelper.moshi.adapter<List<RoomModel>>(type).fromJson(roomJson)
                        if (list != null) {
                            _rooms.value = list
                        } else {
                            loadDefaultRooms()
                        }
                    } catch (e: Exception) {
                        loadDefaultRooms()
                    }
                } else {
                    loadDefaultRooms()
                }

                val reviewJson = prefsHelper.prefs.getString("saved_reviews", null)
                if (reviewJson != null) {
                    try {
                        val type = Types.newParameterizedType(List::class.java, ReviewModel::class.java)
                        val list: List<ReviewModel>? = prefsHelper.moshi.adapter<List<ReviewModel>>(type).fromJson(reviewJson)
                        if (list != null) {
                            _reviews.value = list
                        } else {
                            loadDefaultReviews()
                        }
                    } catch (e: Exception) {
                        loadDefaultReviews()
                    }
                } else {
                    loadDefaultReviews()
                }

                val couponJson = prefsHelper.prefs.getString("saved_coupons", null)
                if (couponJson != null) {
                    try {
                        val type = Types.newParameterizedType(List::class.java, CouponModel::class.java)
                        val list: List<CouponModel>? = prefsHelper.moshi.adapter<List<CouponModel>>(type).fromJson(couponJson)
                        if (list != null) {
                            _coupons.value = list
                        } else {
                            _coupons.value = loadDefaultCoupons()
                        }
                    } catch (e: Exception) {
                        _coupons.value = loadDefaultCoupons()
                    }
                } else {
                    _coupons.value = loadDefaultCoupons()
                }

                _chatMessages.value = listOf(
                    MessageModel(senderId = "admin", senderName = "StayEase Support", isFromAdmin = true, content = "Xin chào! StayEase rất hân hạnh được hỗ trợ bạn. Bạn cần tìm phòng tại địa điểm nào ạ?"),
                )

                _recentSearches.value = listOf("Hà Nội", "Đà Nẵng", "Phú Quốc")

                isInitialized = true

                // Trigger live MockAPI load
                fetchMockApiData()
            }
        }
    }

    override fun fetchMockApiData() {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val listMaps = apiService.fetchHotelsFromApi()
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
            } catch (e: Exception) {
                e.printStackTrace()
            }
            
            try {
                val listMaps = apiService.fetchBookingsFromApi()
                if (listMaps != null) {
                    val newBookingsList = mutableListOf<BookingModel>()
                    for (item in listMaps) {
                        val id = item["id"]?.toString() ?: ""
                        val name = item["name"]?.toString() ?: ""
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
                        val bookingRepository = BookingRepositoryImpl(context)
                        // This updates booking repository flow safely!
                        val field = BookingRepositoryImpl.Companion::class.java.getDeclaredField("_bookings")
                        field.isAccessible = true
                        val mFlow = field.get(null) as MutableStateFlow<List<BookingModel>>
                        mFlow.value = newBookingsList
                        bookingRepository.saveBookings()
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun saveHotels() {
        val type = Types.newParameterizedType(List::class.java, HotelModel::class.java)
        prefsHelper.prefs.edit().putString("saved_hotels", prefsHelper.moshi.adapter<List<HotelModel>>(type).toJson(_hotels.value)).apply()
    }

    private fun saveRooms() {
        val type = Types.newParameterizedType(List::class.java, RoomModel::class.java)
        prefsHelper.prefs.edit().putString("saved_rooms", prefsHelper.moshi.adapter<List<RoomModel>>(type).toJson(_rooms.value)).apply()
    }

    private fun saveReviews() {
        val type = Types.newParameterizedType(List::class.java, ReviewModel::class.java)
        prefsHelper.prefs.edit().putString("saved_reviews", prefsHelper.moshi.adapter<List<ReviewModel>>(type).toJson(_reviews.value)).apply()
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
                "https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=800&q=80"
            ),
            amenities = listOf("Wifi", "Pool", "Breakfast", "Parking"),
            priceMin = 1800000.0,
            latitude = 22.3275,
            longitude = 103.8582,
            isFeatured = false
        )

        _hotels.value = listOf(h1, h2, h3, h4, h5, h6)
        saveHotels()
    }

    private fun loadDefaultRooms() {
        val rList = mutableListOf<RoomModel>()
        
        // Sofitel rooms
        rList.add(RoomModel("r1_1", "hotel_1", "Classic Luxury King Room", "Phòng cổ điển sang trọng mang đậm dấu ấn phong cách Đông Dương. Ban công rộng ngắm trọn vẹn khu vườn trung tâm yên tĩnh.", 4200000.0, "1 King Bed", 2, 32, listOf("https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Mini Bar", "Bathtub")))
        rList.add(RoomModel("r1_2", "hotel_1", "Opera Suite Deluxe", "Căn Suite lộng lẫy thiết kế theo phong cách nhà hát Opera cổ kính, dành riêng cho trải nghiệm hoàng gia cao cấp.", 7500000.0, "1 Premium King Bed", 3, 55, listOf("https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Butler Service", "Living Room", "Jacuzzi")))

        // InterContinental Danang rooms
        rList.add(RoomModel("r2_1", "hotel_2", "Resort Classic Oceanview", "Thức giấc cùng tiếng sóng vỗ rì rào và làn gió biển mát rượi tại ban công lộng gió ngắm trọn vịnh Sơn Trà tuyệt đẹp.", 6800000.0, "1 King Bed", 2, 48, listOf("https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Ocean View", "Balcony", "Coffee Maker")))
        rList.add(RoomModel("r2_2", "hotel_2", "Penthouse Seaside with Private Pool", "Trải nghiệm xa xỉ đỉnh cao tại căn biệt thự biển có sân hiên rộng, hồ bơi vô cực riêng tư dài 15m ngắm hoàng hôn rực rỡ.", 15200000.0, "1 Super King Bed", 4, 120, listOf("https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Private Pool", "Kitchen", "Wine Cellar", "Living Area")))

        // Hotel de la Coupole rooms
        rList.add(RoomModel("r3_1", "hotel_3", "Classic Indochine Room", "Căn phòng ngập tràn sắc màu thời trang Pháp quyến rũ kết hợp tinh tế cùng hoa văn thêu tay Sapa sặc sỡ.", 2400000.0, "1 King Bed", 2, 30, listOf("https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Heater", "Balcony")))
        rList.add(RoomModel("r3_2", "hotel_3", "Superior Double Twin Room", "Thiết kế giường đôi êm ái thích hợp cho các cặp bạn bè khám phá xứ sở sương mù Sapa thanh bình tuyệt diệu.", 2900000.0, "2 Single Beds", 2, 35, listOf("https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=600&q=80"), listOf("Wifi", "Breakfast", "Heater", "Mountain View")))

        _rooms.value = rList
        saveRooms()
    }

    private fun loadDefaultReviews() {
        _reviews.value = listOf(
            ReviewModel(UUID.randomUUID().toString(), "hotel_1", "Minh Hằng", "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=100&q=80", 5.0f, "Phòng vô cùng thượng hoàng, dịch vụ Metropole chưa bao giờ làm tôi thất vọng. Sẽ quay lại nhiều lần!", "2026-04-12"),
            ReviewModel(UUID.randomUUID().toString(), "hotel_1", "Alex Smith", "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=100&q=80", 4.5f, "Historic French elegance in the heart of Hanoi. Breakfast was unbelievable.", "2026-05-03"),
            ReviewModel(UUID.randomUUID().toString(), "hotel_2", "Tấn Dũng", "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80", 5.0f, "Thiên đường hạ giới! Cách bài trí từng lầu Sông - Đất - Sky cực mỹ lệ. Quán Citron ăn sáng ngon.", "2026-05-20")
        )
        saveReviews()
    }

    private fun loadDefaultCoupons(): List<CouponModel> {
        return listOf(
            CouponModel("STAYEASE200K", "Giảm ngày 200.000đ cho mọi phòng đặt", 10, 200000.0, 1000000.0),
            CouponModel("WELCOME500K", "Chào mừng hành khách mới giảm ngay 500.000đ từ StayEase Co.", 15, 500000.0, 3000000.0),
            CouponModel("SUPERDEAL800K", "Siêu khuyến mãi giảm trực tiếp 800.000đ thẳng hóa đơn", 20, 800000.0, 5000000.0)
        )
    }

    override fun addReview(hotelId: String, rating: Float, comment: String) {
        val userRepository = UserRepositoryImpl(context)
        val user = userRepository.currentUser.value
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

        val hotelReviews = _reviews.value.filter { it.hotelId == hotelId }
        val avgRating = if (hotelReviews.isNotEmpty()) {
            hotelReviews.map { it.rating }.average()
        } else {
            4.5
        }
        val roundedRating = Math.round(avgRating * 10.0) / 10.0

        val updatedHotels = _hotels.value.map {
            if (it.id == hotelId) {
                it.copy(rating = roundedRating, reviewCount = hotelReviews.size + 15)
            } else {
                it
            }
        }
        _hotels.value = updatedHotels
        saveHotels()
    }

    override fun searchByVoiceMock(voiceText: String): String {
        return when {
            voiceText.lowercase().contains("sapa") -> "Sapa"
            voiceText.lowercase().contains("hà nội") || voiceText.lowercase().contains("ha noi") -> "Hà Nội"
            voiceText.lowercase().contains("đà nẵng") || voiceText.lowercase().contains("da nang") -> "Đà Nẵng"
            voiceText.lowercase().contains("phú quốc") || voiceText.lowercase().contains("phu quoc") -> "Phú Quốc"
            voiceText.lowercase().contains("sài gòn") || voiceText.lowercase().contains("hồ chí minh") -> "Hồ Chí Minh"
            else -> voiceText
        }
    }

    override fun addChatMessage(message: String) {
        val userRepository = UserRepositoryImpl(context)
        val currentUser = userRepository.currentUser.value
        val userMsg = MessageModel(
            senderId = currentUser.id,
            senderName = currentUser.name,
            isFromAdmin = false,
            content = message
        )
        val list = _chatMessages.value.toMutableList()
        list.add(userMsg)
        _chatMessages.value = list

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
                "Cảm ơn câu hỏi từ quý khách. Đội ngũ StayEase đã nhận được thông tin yêu cầu tư vấn đặt phòng của bạn và sẽ liên hệ ngay qua SĐT: ${currentUser.phoneNumber}. Bạn còn cần hỗ trợ gì khác không?"
            }
        }

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

    override fun addHotel(hotel: HotelModel) {
        val current = _hotels.value.toMutableList()
        current.add(0, hotel)
        _hotels.value = current
        saveHotels()
    }

    override fun updateHotel(hotel: HotelModel) {
        val current = _hotels.value.map {
            if (it.id == hotel.id) hotel else it
        }
        _hotels.value = current
        saveHotels()
    }

    override fun deleteHotel(hotelId: String) {
        val current = _hotels.value.filter { it.id != hotelId }
        _hotels.value = current
        saveHotels()
        val rCurrent = _rooms.value.filter { it.hotelId != hotelId }
        _rooms.value = rCurrent
        saveRooms()
    }

    override fun addRoom(room: RoomModel) {
        val current = _rooms.value.toMutableList()
        current.add(room)
        _rooms.value = current
        saveRooms()
    }

    override fun updateRoom(room: RoomModel) {
        val current = _rooms.value.map {
            if (it.id == room.id) room else it
        }
        _rooms.value = current
        saveRooms()
    }

    override fun deleteRoom(roomId: String) {
        val current = _rooms.value.filter { it.id != roomId }
        _rooms.value = current
        saveRooms()
    }
}
