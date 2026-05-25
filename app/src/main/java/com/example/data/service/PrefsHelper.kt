package com.example.data.service

import android.content.Context
import android.content.SharedPreferences
import com.example.data.model.*
import com.squareup.moshi.Moshi
import com.squareup.moshi.Types
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory

class PrefsHelper(context: Context) {
    val prefs: SharedPreferences = context.getSharedPreferences("StayEase_Prefs", Context.MODE_PRIVATE)
    val moshi: Moshi = Moshi.Builder().addLast(KotlinJsonAdapterFactory()).build()

    fun <T> saveList(key: String, list: List<T>, clazz: Class<T>) {
        val type = Types.newParameterizedType(List::class.java, clazz)
        val json = moshi.adapter<List<T>>(type).toJson(list)
        prefs.edit().putString(key, json).apply()
    }

    fun <T> loadList(key: String, clazz: Class<T>): List<T>? {
        val json = prefs.getString(key, null) ?: return null
        return try {
            val type = Types.newParameterizedType(List::class.java, clazz)
            moshi.adapter<List<T>>(type).fromJson(json)
        } catch (e: Exception) {
            null
        }
    }

    fun saveUser(user: UserModel) {
        val json = moshi.adapter(UserModel::class.java).toJson(user)
        prefs.edit().putString("current_user", json).apply()
    }

    fun loadUser(): UserModel? {
        val json = prefs.getString("current_user", null) ?: return null
        return try {
            moshi.adapter(UserModel::class.java).fromJson(json)
        } catch (e: Exception) {
            null
        }
    }
}
