package com.example.presentation.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.model.HotelModel
import com.example.data.repository.FavoriteRepositoryImpl
import com.example.data.repository.HotelRepositoryImpl
import kotlinx.coroutines.flow.*

class FavoriteViewModel(application: Application) : AndroidViewModel(application) {
    private val favoriteRepository = FavoriteRepositoryImpl(application)
    private val hotelRepository = HotelRepositoryImpl(application)

    val wishlist: StateFlow<Set<String>> = favoriteRepository.wishlist

    val wishlistHotels: StateFlow<List<HotelModel>> = combine(
        hotelRepository.hotels,
        favoriteRepository.wishlist
    ) { hotels, wishlist ->
        hotels.filter { wishlist.contains(it.id) }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun toggleWishlist(hotelId: String) {
        favoriteRepository.toggleWishlist(hotelId)
    }
}
