package com.example.data.repository

import android.content.Context
import com.example.data.model.UserModel
import com.example.data.service.PrefsHelper
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.text.SimpleDateFormat
import java.util.*

interface UserRepository {
    val currentUser: StateFlow<UserModel>
    fun getPassword(email: String): String
    fun savePassword(email: String, pass: String)
    fun registerUserAccount(name: String, email: String, phone: String, pass: String): UserModel
    fun isEmailVerified(email: String): Boolean
    fun markEmailVerified(email: String)
    fun loginUserAccount(email: String, pass: String): Boolean
    fun googleSignInAccount(email: String, name: String, avatarUrl: String)
    fun updateProfile(name: String, email: String, phone: String)
    fun updateAvatarUrl(url: String)
    fun setLanguage(lang: String)
    fun setDarkMode(enabled: Boolean)
    fun rewardLoyaltyPoints(pts: Int)
}

class UserRepositoryImpl(context: Context) : UserRepository {
    private val prefsHelper = PrefsHelper(context)

    companion object {
        private val _currentUser = MutableStateFlow<UserModel>(UserModel())
        val currentUserFlow = _currentUser.asStateFlow()
        private var isInitialized = false
    }

    override val currentUser: StateFlow<UserModel> = currentUserFlow

    init {
        synchronized(this) {
            if (!isInitialized) {
                val savedUser = prefsHelper.loadUser()
                if (savedUser != null) {
                    val finalUser = if (savedUser.email.trim().lowercase() == "vuonghoangtuananh6@gmail.com") {
                        savedUser.copy(role = "ADMIN")
                    } else {
                        savedUser
                    }
                    _currentUser.value = finalUser
                } else {
                    _currentUser.value = UserModel()
                }
                isInitialized = true
            }
        }
    }

    private fun saveUser() {
        prefsHelper.saveUser(_currentUser.value)
    }

    override fun getPassword(email: String): String {
        return prefsHelper.prefs.getString("password_$email", "123456") ?: "123456"
    }

    override fun savePassword(email: String, pass: String) {
        prefsHelper.prefs.edit().putString("password_$email", pass).apply()
    }

    override fun registerUserAccount(name: String, email: String, phone: String, pass: String): UserModel {
        val emailClean = email.trim().lowercase()
        val isKeyAdmin = emailClean == "vuonghoangtuananh6@gmail.com"
        val newUser = UserModel(
            id = "user_" + UUID.randomUUID().toString().substring(0, 5),
            email = email,
            name = name,
            phoneNumber = phone,
            loyaltyPoints = 500,
            isVerified = isKeyAdmin,
            createdAt = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date()),
            role = if (isKeyAdmin) "ADMIN" else "USER"
        )
        _currentUser.value = newUser
        saveUser()
        savePassword(emailClean, pass)
        prefsHelper.prefs.edit().putString("profile_name_$emailClean", name).apply()
        prefsHelper.prefs.edit().putString("profile_phone_$emailClean", phone).apply()
        prefsHelper.prefs.edit().putBoolean("verified_$emailClean", isKeyAdmin).apply()
        return newUser
    }

    override fun isEmailVerified(email: String): Boolean {
        val emailClean = email.trim().lowercase()
        if (emailClean == "vuonghoangtuananh6@gmail.com") return true
        return prefsHelper.prefs.getBoolean("verified_$emailClean", false)
    }

    override fun markEmailVerified(email: String) {
        val emailClean = email.trim().lowercase()
        prefsHelper.prefs.edit().putBoolean("verified_$emailClean", true).apply()
        if (_currentUser.value.email.trim().lowercase() == emailClean) {
            _currentUser.value = _currentUser.value.copy(isVerified = true)
            saveUser()
        }
    }

    override fun loginUserAccount(email: String, pass: String): Boolean {
        val emailClean = email.trim().lowercase()
        val savedPass = getPassword(emailClean)
        if (savedPass == pass) {
            val name = prefsHelper.prefs.getString("profile_name_$emailClean", "Vương Hoàng Tuấn Anh") ?: "Vương Hoàng Tuấn Anh"
            val phone = prefsHelper.prefs.getString("profile_phone_$emailClean", "0987654321") ?: "0987654321"
            val isVerifiedStatus = isEmailVerified(emailClean)
            val isKeyAdmin = emailClean == "vuonghoangtuananh6@gmail.com"
            val loadedUser = UserModel(
                id = "user_" + emailClean.hashCode().toString().take(5),
                email = emailClean,
                name = name,
                phoneNumber = phone,
                loyaltyPoints = 450,
                isVerified = isVerifiedStatus,
                createdAt = "2026-05-23",
                role = if (isKeyAdmin) "ADMIN" else "USER"
            )
            _currentUser.value = loadedUser
            saveUser()
            return true
        }
        return false
    }

    override fun googleSignInAccount(email: String, name: String, avatarUrl: String) {
        val emailClean = email.trim().lowercase()
        val isKeyAdmin = emailClean == "vuonghoangtuananh6@gmail.com"
        val newUser = UserModel(
            id = "google_" + UUID.randomUUID().toString().substring(0, 5),
            email = emailClean,
            name = name,
            avatarUrl = avatarUrl,
            loyaltyPoints = 500,
            isVerified = true,
            createdAt = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date()),
            role = if (isKeyAdmin) "ADMIN" else "USER"
        )
        _currentUser.value = newUser
        saveUser()
        prefsHelper.prefs.edit().putString("profile_name_$emailClean", name).apply()
        prefsHelper.prefs.edit().putString("profile_phone_$emailClean", "0987654321").apply()
        prefsHelper.prefs.edit().putBoolean("verified_$emailClean", true).apply()
    }

    override fun updateProfile(name: String, email: String, phone: String) {
        val updatedUser = _currentUser.value.copy(name = name, email = email, phoneNumber = phone)
        _currentUser.value = updatedUser
        saveUser()
    }

    override fun updateAvatarUrl(url: String) {
        val updatedUser = _currentUser.value.copy(avatarUrl = url)
        _currentUser.value = updatedUser
        saveUser()
    }

    override fun setLanguage(lang: String) {
        val updatedUser = _currentUser.value.copy(language = lang)
        _currentUser.value = updatedUser
        saveUser()
    }

    override fun setDarkMode(enabled: Boolean) {
        val updatedUser = _currentUser.value.copy(isDarkMode = enabled)
        _currentUser.value = updatedUser
        saveUser()
    }

    override fun rewardLoyaltyPoints(pts: Int) {
        val updatedUser = _currentUser.value.copy(loyaltyPoints = _currentUser.value.loyaltyPoints + pts)
        _currentUser.value = updatedUser
        saveUser()
    }
}
