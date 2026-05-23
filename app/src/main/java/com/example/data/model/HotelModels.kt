package com.example.data.model

import java.util.UUID

data class UserModel(
    val id: String = "user_123",
    val email: String = "vuonghoangtuananh6@gmail.com",
    val name: String = "Vương Hoàng Tuấn Anh",
    val avatarUrl: String = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80",
    val loyaltyPoints: Int = 450,
    val phoneNumber: String = "0987654321",
    val coupons: List<String> = listOf("STAYEASE50", "AGODASALE", "WELCOME100"),
    val language: String = "VI", // "VI" or "EN"
    val isDarkMode: Boolean = false,
    val isVerified: Boolean = false,
    val createdAt: String = "2026-05-23",
    val role: String = "USER"
)

data class HotelModel(
    val id: String,
    val name: String,
    val description: String,
    val address: String,
    val city: String,
    val stars: Int,
    val rating: Double,
    val reviewCount: Int,
    val imageUrls: List<String>,
    val amenities: List<String>, // "Wifi", "Pool", "Gym", "Breakfast", "Parking", "Spa"
    val priceMin: Double,
    val latitude: Double = 0.0,
    val longitude: Double = 0.0,
    val isFeatured: Boolean = false
)

data class RoomModel(
    val id: String,
    val hotelId: String,
    val name: String,
    val description: String,
    val price: Double,
    val bedType: String,
    val maxGuests: Int,
    val sizeSqm: Int,
    val imageUrls: List<String>,
    val amenities: List<String>,
    val totalAvailable: Int = 5
)

enum class BookingStatus {
    PENDING, CONFIRMED, CANCELLED, COMPLETED
}

data class BookingModel(
    val id: String = UUID.randomUUID().toString().substring(0, 8).uppercase(),
    val userId: String,
    val hotelId: String,
    val roomId: String,
    val hotelName: String,
    val roomName: String,
    val hotelImage: String,
    val checkInDate: String, // "YYYY-MM-DD"
    val checkOutDate: String, // "YYYY-MM-DD"
    val nights: Int,
    val guestsCount: Int,
    val pricePerNight: Double,
    val subtotal: Double,
    val taxFee: Double,
    val serviceFee: Double,
    val discountAmount: Double,
    val totalAmount: Double,
    val appliedCoupon: String?,
    val status: BookingStatus = BookingStatus.CONFIRMED,
    val qrCode: String = "STAYEASE-$id",
    val guestName: String,
    val guestEmail: String,
    val guestPhone: String,
    val paymentMethod: String,
    val timestamp: Long = System.currentTimeMillis()
)

data class ReviewModel(
    val id: String = UUID.randomUUID().toString(),
    val hotelId: String,
    val userName: String,
    val userAvatar: String,
    val rating: Float,
    val comment: String,
    val date: String
)

data class PaymentModel(
    val id: String = UUID.randomUUID().toString().substring(0, 10).uppercase(),
    val bookingId: String,
    val paymentMethod: String, // "Momo" | "ZaloPay" | "VNPay" | "Credit Card" | "COD"
    val amount: Double,
    val status: String = "SUCCESS",
    val timestamp: Long = System.currentTimeMillis()
)

data class MessageModel(
    val id: String = UUID.randomUUID().toString(),
    val senderId: String,
    val senderName: String,
    val isFromAdmin: Boolean,
    val content: String,
    val timestamp: Long = System.currentTimeMillis()
)

data class CouponModel(
    val code: String,
    val description: String,
    val discountPercent: Int,
    val maxDiscount: Double,
    val minSpend: Double
)

fun Double.formatPrice(): String {
    return if (this >= 10000) {
        val symbols = java.text.DecimalFormatSymbols(java.util.Locale.US).apply {
            groupingSeparator = '.'
        }
        val formatter = java.text.DecimalFormat("#,###", symbols)
        formatter.format(this) + "đ"
    } else {
        "$" + String.format(java.util.Locale.US, "%.0f", this)
    }
}
