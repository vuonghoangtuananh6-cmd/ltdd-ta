package com.example.presentation.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import com.example.data.model.*
import com.example.data.repository.*
import kotlinx.coroutines.flow.*

class BookingViewModel(application: Application) : AndroidViewModel(application) {
    private val bookingRepository = BookingRepositoryImpl(application)
    private val userRepository = UserRepositoryImpl(application)
    private val hotelRepository = HotelRepositoryImpl(application)

    val bookings: StateFlow<List<BookingModel>> = bookingRepository.bookings
    val coupons: StateFlow<List<CouponModel>> = hotelRepository.coupons

    val selectedHotelForBooking = MutableStateFlow<HotelModel?>(null)
    val selectedRoomForBooking = MutableStateFlow<RoomModel?>(null)

    val checkInDate = MutableStateFlow("2026-06-15")
    val checkOutDate = MutableStateFlow("2026-06-17")
    val nightsCount = MutableStateFlow(2)
    val guestsCount = MutableStateFlow(2)
    val roomsCount = MutableStateFlow(1)

    val adminStats: Flow<Map<String, Any>> = bookingRepository.bookings.map { list ->
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
            "hotelsCount" to hotelRepository.hotels.value.size,
            "roomsCount" to hotelRepository.rooms.value.size
        )
    }

    fun applyCoupon(code: String, subtotal: Double): Double {
        val coupon = hotelRepository.coupons.value.firstOrNull { it.code.equals(code, ignoreCase = true) }
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
        val tax = sub * 0.10
        val service = sub * 0.05
        val total = sub + tax + service - discount

        val b = BookingModel(
            userId = userRepository.currentUser.value.id,
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

        bookingRepository.createBooking(b)
        return b
    }

    fun cancelBooking(bookingId: String) {
        bookingRepository.updateBookingStatus(bookingId, BookingStatus.CANCELLED)
    }
}
