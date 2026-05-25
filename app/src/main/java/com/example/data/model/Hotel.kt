package com.example.data.model

import java.util.UUID

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

data class ReviewModel(
    val id: String = UUID.randomUUID().toString(),
    val hotelId: String,
    val userName: String,
    val userAvatar: String,
    val rating: Float,
    val comment: String,
    val date: String
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
