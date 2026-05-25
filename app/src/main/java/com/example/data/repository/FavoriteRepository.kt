package com.example.data.repository

import android.content.Context
import com.example.data.service.PrefsHelper
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

interface FavoriteRepository {
    val wishlist: StateFlow<Set<String>>
    fun toggleWishlist(hotelId: String)
}

class FavoriteRepositoryImpl(context: Context) : FavoriteRepository {
    private val prefsHelper = PrefsHelper(context)

    companion object {
        private val _wishlist = MutableStateFlow<Set<String>>(emptySet())
        val wishlistFlow = _wishlist.asStateFlow()
        private var isInitialized = false
    }

    override val wishlist: StateFlow<Set<String>> = wishlistFlow

    init {
        synchronized(this) {
            if (!isInitialized) {
                val wishlistSet = prefsHelper.prefs.getStringSet("wishlist_hotel_ids", emptySet()) ?: emptySet()
                _wishlist.value = wishlistSet
                isInitialized = true
            }
        }
    }

    override fun toggleWishlist(hotelId: String) {
        val updated = _wishlist.value.toMutableSet()
        if (updated.contains(hotelId)) {
            updated.remove(hotelId)
        } else {
            updated.add(hotelId)
        }
        _wishlist.value = updated
        prefsHelper.prefs.edit().putStringSet("wishlist_hotel_ids", updated).apply()
    }
}
