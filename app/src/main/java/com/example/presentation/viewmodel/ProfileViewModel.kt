package com.example.presentation.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.model.UserModel
import com.example.data.repository.UserRepositoryImpl
import kotlinx.coroutines.flow.*

class ProfileViewModel(application: Application) : AndroidViewModel(application) {
    private val userRepository = UserRepositoryImpl(application)

    val currentUser: StateFlow<UserModel> = userRepository.currentUser

    val currentLang: StateFlow<String> = userRepository.currentUser.map { it.language }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), "VI")

    fun updateProfile(name: String, email: String, phone: String) {
        userRepository.updateProfile(name, email, phone)
    }

    fun updateAvatarUrl(url: String) {
        userRepository.updateAvatarUrl(url)
    }

    fun setLanguage(lang: String) {
        userRepository.setLanguage(lang)
    }

    fun toggleDarkMode(enabled: Boolean) {
        userRepository.setDarkMode(enabled)
    }

    fun rewardLoyaltyPoints(pts: Int) {
        userRepository.rewardLoyaltyPoints(pts)
    }
}
