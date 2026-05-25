package com.example.presentation.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.model.HotelModel
import com.example.data.repository.HotelRepositoryImpl
import kotlinx.coroutines.flow.*
import java.text.SimpleDateFormat
import java.util.*

class SearchViewModel(application: Application) : AndroidViewModel(application) {
    val repository = HotelRepositoryImpl(application)

    val searchCity = MutableStateFlow("Hà Nội")
    val checkInDate = MutableStateFlow("2026-06-15")
    val checkOutDate = MutableStateFlow("2026-06-17")
    val nightsCount = MutableStateFlow(2)
    val guestsCount = MutableStateFlow(2)
    val roomsCount = MutableStateFlow(1)

    val filterPriceMin = MutableStateFlow(0f)
    val filterPriceMax = MutableStateFlow(30000000f)
    val filterStars = MutableStateFlow<Set<Int>>(emptySet())
    val filterAmenities = MutableStateFlow<Set<String>>(emptySet())
    val searchSortOrder = MutableStateFlow("POPULAR") // "LOW_TO_HIGH", "RATING", "POPULAR"

    val searchQuery = MutableStateFlow("")

    data class SearchState(val query: String, val city: String, val sort: String)
    data class FilterState(val priceMin: Float, val priceMax: Float, val stars: Set<Int>, val amenities: Set<String>)

    private val searchStateFlow = combine(searchQuery, searchCity, searchSortOrder) { q, c, s ->
        SearchState(q, c, s)
    }

    private val filterStateFlow = combine(filterPriceMin, filterPriceMax, filterStars, filterAmenities) { pMin, pMax, stars, ams ->
        FilterState(pMin, pMax, stars, ams)
    }

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

        list = when (search.sort) {
            "LOW_TO_HIGH" -> list.sortedBy { it.priceMin }
            "RATING" -> list.sortedByDescending { it.rating }
            else -> list.sortedByDescending { it.isFeatured }
        }
        list
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun setCity(city: String) {
        searchCity.value = city
    }

    fun submitBookingSearch(city: String, checkIn: String, checkOut: String, guests: Int, rooms: Int) {
        searchCity.value = city
        checkInDate.value = checkIn
        checkOutDate.value = checkOut
        guestsCount.value = guests
        roomsCount.value = rooms

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
}
