package com.example.data.repository

import android.content.Context
import com.example.data.model.BookingModel
import com.example.data.model.BookingStatus
import com.example.data.service.PrefsHelper
import com.squareup.moshi.Types
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.util.*

interface BookingRepository {
    val bookings: StateFlow<List<BookingModel>>
    fun createBooking(booking: BookingModel)
    fun updateBookingStatus(bookingId: String, status: BookingStatus)
    fun saveBookings()
}

class BookingRepositoryImpl(private val context: Context) : BookingRepository {
    private val prefsHelper = PrefsHelper(context)

    companion object {
        private val _bookings = MutableStateFlow<List<BookingModel>>(emptyList())
        val bookingsFlow = _bookings.asStateFlow()
        private var isInitialized = false
    }

    override val bookings: StateFlow<List<BookingModel>> = bookingsFlow

    init {
        synchronized(this) {
            if (!isInitialized) {
                val bookingJson = prefsHelper.prefs.getString("saved_bookings", null)
                if (bookingJson != null) {
                    try {
                        val type = Types.newParameterizedType(List::class.java, BookingModel::class.java)
                        val list: List<BookingModel>? = prefsHelper.moshi.adapter<List<BookingModel>>(type).fromJson(bookingJson)
                        if (list != null) {
                            _bookings.value = list
                        } else {
                            _bookings.value = loadDefaultBookings()
                        }
                    } catch (e: Exception) {
                        _bookings.value = loadDefaultBookings()
                    }
                } else {
                    _bookings.value = loadDefaultBookings()
                }
                isInitialized = true
            }
        }
    }

    override fun saveBookings() {
        val type = Types.newParameterizedType(List::class.java, BookingModel::class.java)
        prefsHelper.prefs.edit().putString("saved_bookings", prefsHelper.moshi.adapter<List<BookingModel>>(type).toJson(_bookings.value)).apply()
    }

    override fun createBooking(booking: BookingModel) {
        val list = _bookings.value.toMutableList()
        list.add(0, booking) // Insert at beginning
        _bookings.value = list
        saveBookings()

        // Reward points to active user
        val userRepository = UserRepositoryImpl(context)
        userRepository.rewardLoyaltyPoints(50)
    }

    override fun updateBookingStatus(bookingId: String, status: BookingStatus) {
        val list = _bookings.value.map {
            if (it.id == bookingId) it.copy(status = status) else it
        }
        _bookings.value = list
        saveBookings()
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
}
