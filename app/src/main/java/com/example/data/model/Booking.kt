package com.example.data.model

import java.util.UUID

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

data class PaymentModel(
    val id: String = UUID.randomUUID().toString().substring(0, 10).uppercase(),
    val bookingId: String,
    val paymentMethod: String, // "Momo" | "ZaloPay" | "VNPay" | "Credit Card" | "COD"
    val amount: Double,
    val status: String = "SUCCESS",
    val timestamp: Long = System.currentTimeMillis()
)
