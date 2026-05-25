package com.example.data.model

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
