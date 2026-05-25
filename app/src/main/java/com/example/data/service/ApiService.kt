package com.example.data.service

import com.squareup.moshi.Moshi
import com.squareup.moshi.Types
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.HttpURLConnection
import java.net.URL

class ApiService(private val moshi: Moshi) {
    suspend fun fetchHotelsFromApi(): List<Map<String, Any>>? = withContext(Dispatchers.IO) {
        try {
            val urlHotels = URL("https://6a0c97985aa893e1015c1b6e.mockapi.io/hotels")
            val connectionHotels = urlHotels.openConnection() as HttpURLConnection
            connectionHotels.requestMethod = "GET"
            connectionHotels.connectTimeout = 10000
            connectionHotels.readTimeout = 10000
            
            if (connectionHotels.responseCode == 200) {
                val rawJson = connectionHotels.inputStream.bufferedReader().use { it.readText() }
                val type = Types.newParameterizedType(List::class.java, Map::class.java)
                return@withContext moshi.adapter<List<Map<String, Any>>>(type).fromJson(rawJson)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        null
    }

    suspend fun fetchBookingsFromApi(): List<Map<String, Any>>? = withContext(Dispatchers.IO) {
        try {
            val urlBookings = URL("https://6a0c97985aa893e1015c1b6e.mockapi.io/booking")
            val connectionBookings = urlBookings.openConnection() as HttpURLConnection
            connectionBookings.requestMethod = "GET"
            connectionBookings.connectTimeout = 10000
            connectionBookings.readTimeout = 10000
            
            if (connectionBookings.responseCode == 200) {
                val rawJson = connectionBookings.inputStream.bufferedReader().use { it.readText() }
                val type = Types.newParameterizedType(List::class.java, Map::class.java)
                return@withContext moshi.adapter<List<Map<String, Any>>>(type).fromJson(rawJson)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        null
    }
}
