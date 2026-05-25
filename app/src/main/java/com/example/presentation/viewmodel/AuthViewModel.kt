package com.example.presentation.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import com.example.data.repository.UserRepositoryImpl

sealed class AuthResult {
    object Success : AuthResult()
    data class Error(val message: String) : AuthResult()
    object VerificationRequired : AuthResult()
}

class AuthViewModel(application: Application) : AndroidViewModel(application) {
    private val userRepository = UserRepositoryImpl(application)

    companion object {
        val isLoggedInState = kotlinx.coroutines.flow.MutableStateFlow(false)
    }

    val isLoggedIn = isLoggedInState

    init {
        val prefs = application.getSharedPreferences("StayEase_Prefs", android.content.Context.MODE_PRIVATE)
        val savedLoggedIn = prefs.getBoolean("remember_me_login", false)
        if (savedLoggedIn) {
            isLoggedInState.value = true
        }
    }

    fun register(name: String, email: String, phone: String, pass: String) {
        userRepository.registerUserAccount(name, email, phone, pass)
        isLoggedInState.value = true
    }

    fun registerWithDetails(name: String, email: String, phone: String, pass: String): AuthResult {
        userRepository.registerUserAccount(name, email, phone, pass)
        return AuthResult.VerificationRequired
    }

    fun login(email: String, pass: String): Boolean {
        val success = userRepository.loginUserAccount(email, pass)
        if (success) {
            isLoggedInState.value = true
        }
        return success
    }

    fun loginWithDetails(email: String, pass: String, rememberMe: Boolean): AuthResult {
        val success = userRepository.loginUserAccount(email, pass)
        if (success) {
            val isVerified = userRepository.isEmailVerified(email)
            if (isVerified) {
                isLoggedInState.value = true
                val prefs = getApplication<Application>().getSharedPreferences("StayEase_Prefs", android.content.Context.MODE_PRIVATE)
                prefs.edit().putBoolean("remember_me_login", rememberMe).apply()
                return AuthResult.Success
            } else {
                return AuthResult.VerificationRequired
            }
        }
        return AuthResult.Error("Tài khoản hoặc mật khẩu không chính xác")
    }

    fun googleSignIn(email: String, name: String, avatarUrl: String, rememberMe: Boolean = true) {
        userRepository.googleSignInAccount(email, name, avatarUrl)
        isLoggedInState.value = true
        val prefs = getApplication<Application>().getSharedPreferences("StayEase_Prefs", android.content.Context.MODE_PRIVATE)
        prefs.edit().putBoolean("remember_me_login", rememberMe).apply()
    }

    fun verifyEmailCode(email: String): Boolean {
        userRepository.markEmailVerified(email)
        return true
    }

    fun logout() {
        isLoggedInState.value = false
        val prefs = getApplication<Application>().getSharedPreferences("StayEase_Prefs", android.content.Context.MODE_PRIVATE)
        prefs.edit().putBoolean("remember_me_login", false).apply()
    }

    fun forgotPassword(email: String, newPass: String): Boolean {
        userRepository.savePassword(email, newPass)
        return true
    }

    fun changePassword(oldPass: String, newPass: String): Boolean {
        val currentEmail = userRepository.currentUser.value.email
        val currentSavedPass = userRepository.getPassword(currentEmail)
        if (currentSavedPass == oldPass) {
            userRepository.savePassword(currentEmail, newPass)
            return true
        }
        return false
    }
}
