package com.example.data.model

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
