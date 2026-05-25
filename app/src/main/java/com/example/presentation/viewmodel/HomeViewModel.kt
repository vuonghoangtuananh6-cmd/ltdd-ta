package com.example.presentation.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import com.example.data.model.*
import com.example.data.repository.*
import kotlinx.coroutines.flow.*
import java.util.*

class HomeViewModel(application: Application) : AndroidViewModel(application) {
    val repository = HotelRepositoryImpl(application)

    val hotels: StateFlow<List<HotelModel>> = repository.hotels
    val rooms: StateFlow<List<RoomModel>> = repository.rooms
    val chatMessages: StateFlow<List<MessageModel>> = repository.chatMessages
    val recentSearches: StateFlow<List<String>> = repository.recentSearches

    fun sendSupportChat(message: String) {
        repository.addChatMessage(message)
    }

    fun handleVoiceInput(word: String): String {
        return repository.searchByVoiceMock(word)
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
