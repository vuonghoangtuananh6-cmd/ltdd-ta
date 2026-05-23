package com.example.presentation.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.model.*
import com.example.data.repository.HotelRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

sealed class AuthResult {
    object Success : AuthResult()
    data class Error(val message: String) : AuthResult()
    object VerificationRequired : AuthResult()
}

class HotelViewModel(application: Application) : AndroidViewModel(application) {
    val repository = HotelRepository(application)

    // User authentication state simulation
    private val _isLoggedIn = MutableStateFlow(false)
    val isLoggedIn: StateFlow<Boolean> = _isLoggedIn.asStateFlow()

    init {
        val prefs = application.getSharedPreferences("StayEase_Prefs", android.content.Context.MODE_PRIVATE)
        val savedLoggedIn = prefs.getBoolean("remember_me_login", false)
        if (savedLoggedIn) {
            _isLoggedIn.value = true
        }
    }

    // Advanced Auth Flow Functions
    fun registerWithDetails(name: String, email: String, phone: String, pass: String): AuthResult {
        repository.registerUserAccount(name, email, phone, pass)
        return AuthResult.VerificationRequired
    }

    fun loginWithDetails(email: String, pass: String, rememberMe: Boolean): AuthResult {
        val success = repository.loginUserAccount(email, pass)
        if (success) {
            val isVerified = repository.isEmailVerified(email)
            if (isVerified) {
                _isLoggedIn.value = true
                val prefs = getApplication<Application>().getSharedPreferences("StayEase_Prefs", android.content.Context.MODE_PRIVATE)
                prefs.edit().putBoolean("remember_me_login", rememberMe).apply()
                return AuthResult.Success
            } else {
                return AuthResult.VerificationRequired
            }
        }
        return AuthResult.Error("Tài khoản hoặc mật khẩu không chính xác")
    }

    fun googleSignIn(email: String, name: String, avatarUrl: String, rememberMe: Boolean = true) {
        repository.googleSignInAccount(email, name, avatarUrl)
        _isLoggedIn.value = true
        val prefs = getApplication<Application>().getSharedPreferences("StayEase_Prefs", android.content.Context.MODE_PRIVATE)
        prefs.edit().putBoolean("remember_me_login", rememberMe).apply()
    }

    fun verifyEmailCode(email: String): Boolean {
        repository.markEmailVerified(email)
        return true
    }

    // Current search and dates state
    val searchCity = MutableStateFlow("Hà Nội")
    val checkInDate = MutableStateFlow("2026-06-15")
    val checkOutDate = MutableStateFlow("2026-06-17")
    val nightsCount = MutableStateFlow(2)
    val guestsCount = MutableStateFlow(2)
    val roomsCount = MutableStateFlow(1)

    // Advanced search criteria
    val filterPriceMin = MutableStateFlow(0f)
    val filterPriceMax = MutableStateFlow(30000000f)
    val filterStars = MutableStateFlow<Set<Int>>(emptySet())
    val filterAmenities = MutableStateFlow<Set<String>>(emptySet())
    val searchSortOrder = MutableStateFlow("POPULAR") // "LOW_TO_HIGH", "RATING", "POPULAR"

    // Search query state
    val searchQuery = MutableStateFlow("")

    // Selected items for booking checkout
    val selectedHotelForBooking = MutableStateFlow<HotelModel?>(null)
    val selectedRoomForBooking = MutableStateFlow<RoomModel?>(null)

    // Intermediate states for combining filters safely
    data class SearchState(val query: String, val city: String, val sort: String)
    data class FilterState(val priceMin: Float, val priceMax: Float, val stars: Set<Int>, val amenities: Set<String>)

    private val searchStateFlow = combine(searchQuery, searchCity, searchSortOrder) { q, c, s ->
        SearchState(q, c, s)
    }

    private val filterStateFlow = combine(filterPriceMin, filterPriceMax, filterStars, filterAmenities) { pMin, pMax, stars, ams ->
        FilterState(pMin, pMax, stars, ams)
    }

    // Reactive filter result
    val filteredHotels: StateFlow<List<HotelModel>> = combine(
        repository.hotels,
        searchStateFlow,
        filterStateFlow
    ) { hotels, search, filter ->
        var list = hotels.filter { h ->
            val matchesQuery = h.name.contains(search.query, ignoreCase = true) || h.city.contains(search.query, ignoreCase = true)
            val matchesCity = search.city.isEmpty() || h.city.lowercase(Locale.ROOT) == search.city.lowercase(Locale.ROOT)
            val inPriceRange = h.priceMin >= filter.priceMin && h.priceMin <= filter.priceMax
            val matchesStars = filter.stars.isEmpty() || filter.stars.contains(h.stars)
            val matchesAmenities = filter.amenities.isEmpty() || h.amenities.containsAll(filter.amenities)

            matchesQuery && matchesCity && inPriceRange && matchesStars && matchesAmenities
        }

        // Apply sort
        list = when (search.sort) {
            "LOW_TO_HIGH" -> list.sortedBy { it.priceMin }
            "RATING" -> list.sortedByDescending { it.rating }
            else -> list.sortedByDescending { it.isFeatured } // Popular / Featured
        }
        list
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // Wishlist selector state
    val wishlistHotels: StateFlow<List<HotelModel>> = combine(
        repository.hotels,
        repository.wishlist
    ) { hotels, wishlist ->
        hotels.filter { wishlist.contains(it.id) }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // Language in Vietnamese/English
    val currentLang: StateFlow<String> = repository.currentUser.map { it.language }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), "VI")

    // Active User
    val currentUser: StateFlow<UserModel> = repository.currentUser

    // Available coupons
    val coupons: StateFlow<List<CouponModel>> = repository.coupons

    // Bookings history
    val bookings: StateFlow<List<BookingModel>> = repository.bookings

    // Chat support messages
    val chatMessages: StateFlow<List<MessageModel>> = repository.chatMessages

    // Recent Searches management
    val recentSearches: StateFlow<List<String>> = repository.recentSearches

    fun setCity(city: String) {
        searchCity.value = city
    }

    fun addRecentSearch(search: String) {
        // Mock add
    }

    fun submitBookingSearch(city: String, checkIn: String, checkOut: String, guests: Int, rooms: Int) {
        searchCity.value = city
        checkInDate.value = checkIn
        checkOutDate.value = checkOut
        guestsCount.value = guests
        roomsCount.value = rooms

        // Compute nights dynamically
        try {
            val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.US)
            val d1 = sdf.parse(checkIn)
            val d2 = sdf.parse(checkOut)
            if (d1 != null && d2 != null) {
                val diff = d2.time - d1.time
                val nights = (diff / (1000 * 60 * 60 * 24)).toInt()
                nightsCount.value = if (nights > 0) nights else 1
            }
        } catch (e: Exception) {
            nightsCount.value = 1
        }
    }

    fun toggleWishlist(hotelId: String) {
        repository.toggleWishlist(hotelId)
    }

    fun updateProfile(name: String, email: String, phone: String) {
        repository.updateProfile(name, email, phone)
    }

    fun setLanguage(lang: String) {
        repository.setLanguage(lang)
    }

    fun toggleDarkMode(enabled: Boolean) {
        repository.setDarkMode(enabled)
    }

    fun addReview(hotelId: String, rating: Float, comment: String) {
        repository.addReview(hotelId, rating, comment)
    }

    fun getReviewsForHotel(hotelId: String): Flow<List<ReviewModel>> {
        return repository.reviews.map { list -> list.filter { it.hotelId == hotelId } }
    }

    fun getRoomsForHotel(hotelId: String): Flow<List<RoomModel>> {
        return repository.rooms.map { list -> list.filter { it.hotelId == hotelId } }
    }

    fun getHotelById(hotelId: String): HotelModel? {
        return repository.hotels.value.firstOrNull { it.id == hotelId }
    }

    fun getRoomById(roomId: String): RoomModel? {
        return repository.rooms.value.firstOrNull { it.id == roomId }
    }

    fun applyCoupon(code: String, subtotal: Double): Double {
        val coupon = repository.coupons.value.firstOrNull { it.code.equals(code, ignoreCase = true) }
        if (coupon != null && subtotal >= coupon.minSpend) {
            val maxDiscount = coupon.maxDiscount
            val calculated = subtotal * (coupon.discountPercent / 100.0)
            return if (calculated > maxDiscount) maxDiscount else calculated
        }
        return 0.0
    }

    fun createBooking(
        hotel: HotelModel,
        room: RoomModel,
        guestName: String,
        guestEmail: String,
        guestPhone: String,
        paymentMethod: String,
        couponCode: String?
    ): BookingModel {
        val sub = room.price * nightsCount.value
        val discount = if (couponCode != null) applyCoupon(couponCode, sub) else 0.0
        val tax = sub * 0.10 // 10%
        val service = sub * 0.05 // 5%
        val total = sub + tax + service - discount

        val b = BookingModel(
            userId = currentUser.value.id,
            hotelId = hotel.id,
            roomId = room.id,
            hotelName = hotel.name,
            roomName = room.name,
            hotelImage = hotel.imageUrls.firstOrNull() ?: "",
            checkInDate = checkInDate.value,
            checkOutDate = checkOutDate.value,
            nights = nightsCount.value,
            guestsCount = guestsCount.value,
            pricePerNight = room.price,
            subtotal = sub,
            taxFee = tax,
            serviceFee = service,
            discountAmount = discount,
            totalAmount = total,
            appliedCoupon = couponCode,
            guestName = guestName,
            guestEmail = guestEmail,
            guestPhone = guestPhone,
            paymentMethod = paymentMethod
        )

        repository.createBooking(b)
        return b
    }

    fun cancelBooking(bookingId: String) {
        repository.updateBookingStatus(bookingId, BookingStatus.CANCELLED)
    }

    fun sendSupportChat(message: String) {
        repository.addChatMessage(message)
    }

    // AUTH SIMULATION
    fun register(name: String, email: String, phone: String, pass: String) {
        repository.registerUserAccount(name, email, phone, pass)
        _isLoggedIn.value = true
    }

    fun login(email: String, pass: String): Boolean {
        val success = repository.loginUserAccount(email, pass)
        if (success) {
            _isLoggedIn.value = true
        }
        return success
    }

    fun logout() {
        _isLoggedIn.value = false
        val prefs = getApplication<Application>().getSharedPreferences("StayEase_Prefs", android.content.Context.MODE_PRIVATE)
        prefs.edit().putBoolean("remember_me_login", false).apply()
    }

    fun forgotPassword(email: String, newPass: String): Boolean {
        repository.savePassword(email, newPass)
        return true
    }

    fun changePassword(oldPass: String, newPass: String): Boolean {
        val currentEmail = currentUser.value.email
        val currentSavedPass = repository.getPassword(currentEmail)
        if (currentSavedPass == oldPass) {
            repository.savePassword(currentEmail, newPass)
            return true
        }
        return false
    }

    // Admin Panel Analytics
    val adminStats: Flow<Map<String, Any>> = repository.bookings.map { list ->
        val completed = list.filter { it.status == BookingStatus.COMPLETED || it.status == BookingStatus.CONFIRMED }
        val revenue = completed.sumOf { it.totalAmount }
        val bookingsCount = list.size
        val activeCount = list.count { it.status == BookingStatus.CONFIRMED }
        val cancelledCount = list.count { it.status == BookingStatus.CANCELLED }

        mapOf(
            "totalRevenue" to revenue,
            "bookingsCount" to bookingsCount,
            "activeBookings" to activeCount,
            "cancelledBookings" to cancelledCount,
            "hotelsCount" to repository.hotels.value.size,
            "roomsCount" to repository.rooms.value.size
        )
    }

    // Voice search simulated feedback
    fun handleVoiceInput(word: String): String {
        val detected = repository.searchByVoiceMock(word)
        searchCity.value = detected
        return detected
    }

    // ADMIN CRUD WRAPPERS
    fun createAdminHotel(name: String, city: String, address: String, stars: Int, priceMin: Double, description: String) {
        val nh = HotelModel(
            id = "hotel_" + UUID.randomUUID().toString().substring(0, 5),
            name = name,
            description = description,
            address = address,
            city = city,
            stars = stars,
            rating = 4.5,
            reviewCount = 0,
            imageUrls = listOf("https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=800&q=80"),
            amenities = listOf("Wifi", "Pool", "Breakfast", "Parking"),
            priceMin = priceMin,
            latitude = 21.0,
            longitude = 105.0
        )
        repository.addHotel(nh)
    }

    fun updateAdminHotel(hotel: HotelModel) {
        repository.updateHotel(hotel)
    }

    fun deleteAdminHotel(hotelId: String) {
        repository.deleteHotel(hotelId)
    }

    fun createAdminRoom(hotelId: String, name: String, price: Double, maxGuests: Int, sizeSqm: Int, description: String) {
        val nr = RoomModel(
            id = "room_" + UUID.randomUUID().toString().substring(0, 5),
            hotelId = hotelId,
            name = name,
            description = description,
            price = price,
            bedType = "1 Deluxe King Bed",
            maxGuests = maxGuests,
            sizeSqm = sizeSqm,
            imageUrls = listOf("https://images.unsplash.com/photo-1611891405112-700df06ad678?auto=format&fit=crop&w=600&q=80"),
            amenities = listOf("Wifi", "Minibar", "Air Conditioning")
        )
        repository.addRoom(nr)
    }

    fun deleteAdminRoom(roomId: String) {
        repository.deleteRoom(roomId)
    }
}
