package com.example.presentation.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.HotelModel
import com.example.data.model.formatPrice
import com.example.presentation.viewmodel.HotelViewModel
import com.example.ui.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    viewModel: HotelViewModel,
    onNavigateToDetail: (String) -> Unit,
    onNavigateToSearchResults: () -> Unit,
    onNavigateToChat: () -> Unit,
    onNavigateToNotifications: () -> Unit
) {
    val scrollState = rememberScrollState()
    val hotels by viewModel.filteredHotels.collectAsState()
    val allHotels by viewModel.repository.hotels.collectAsState()
    val currentUser by viewModel.currentUser.collectAsState()
    val recentList by viewModel.recentSearches.collectAsState()
    val focusManager = LocalFocusManager.current

    val datesList = remember {
        val list = mutableListOf<Pair<String, String>>()
        val dateFormat = java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale.US)
        val labelFormat = java.text.SimpleDateFormat("EEEE, dd 'Thg' MM", java.util.Locale("vi"))
        val cal = java.util.Calendar.getInstance()
        cal.set(2026, java.util.Calendar.MAY, 23)
        for (i in 0..45) {
            val dateStr = dateFormat.format(cal.time)
            val label = labelFormat.format(cal.time)
            list.add(Pair(dateStr, label))
            cal.add(java.util.Calendar.DATE, 1)
        }
        list
    }

    // Voice search simulator state
    var showVoiceDialog by remember { mutableStateOf(false) }
    var voiceMessageState by remember { mutableStateOf("Đang nghe...") }

    // Search Box state variables
    var locationInput by remember { mutableStateOf(viewModel.searchCity.value) }
    var showCheckInPicker by remember { mutableStateOf(false) }
    var showGuestsPicker by remember { mutableStateOf(false) }
    var showFlightDialog by remember { mutableStateOf(false) }
    var showDealsBottomSheet by remember { mutableStateOf(false) }

    // Date Strings selection
    var checkIn by remember { mutableStateOf(viewModel.checkInDate.value) }
    var checkOut by remember { mutableStateOf(viewModel.checkOutDate.value) }
    var guests by remember { mutableIntStateOf(viewModel.guestsCount.value) }
    var rooms by remember { mutableIntStateOf(viewModel.roomsCount.value) }

    val isEn = currentUser.language == "EN"

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(scrollState)
                .padding(bottom = 80.dp) // Leave space for bottom navigation bars
        ) {
            // Elegant Light Header like mockup
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .shadow(elevation = 2.dp, shape = RoundedCornerShape(bottomStart = 24.dp, bottomEnd = 24.dp)),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                shape = RoundedCornerShape(bottomStart = 24.dp, bottomEnd = 24.dp)
            ) {
                Column(
                    modifier = Modifier
                        .statusBarsPadding()
                        .padding(horizontal = 20.dp, vertical = 16.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // Brand Logo + Title
                        Row(
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(36.dp)
                                    .clip(RoundedCornerShape(10.dp))
                                    .background(StayHubBlue600),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = "ST",
                                    color = Color.White,
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "StayHub",
                                color = if (currentUser.isDarkMode) Color.White else StayHubBlue900,
                                fontSize = 22.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }

                        // Notifications & Chat Icons (StayHub light blue)
                        Row {
                            IconButton(
                                onClick = onNavigateToNotifications,
                                modifier = Modifier
                                    .size(38.dp)
                                    .clip(CircleShape)
                                    .background(if (currentUser.isDarkMode) Color(0xFF334155) else StayHubBlue50)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Notifications,
                                    contentDescription = "Notifications",
                                    tint = if (currentUser.isDarkMode) Color(0xFFF97316) else StayHubBlue700,
                                    modifier = Modifier.size(20.dp)
                                )
                            }
                            Spacer(modifier = Modifier.width(8.dp))
                            IconButton(
                                onClick = onNavigateToChat,
                                modifier = Modifier
                                    .size(38.dp)
                                    .clip(CircleShape)
                                    .background(if (currentUser.isDarkMode) Color(0xFF334155) else StayHubBlue50)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Chat,
                                    contentDescription = "Support Chat",
                                    tint = if (currentUser.isDarkMode) Color(0xFFF97316) else StayHubBlue700,
                                    modifier = Modifier.size(20.dp)
                                )
                            }
                        }
                    }
                }
            }

            // Welcoming User Banner (Light Premium)
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = if (isEn) "Hello, ${currentUser.name} \uD83D\uDC4B" else "Chào, ${currentUser.name} \uD83D\uDC4B",
                        color = MaterialTheme.colorScheme.onBackground,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.Stars,
                            contentDescription = "Loyalty points",
                            tint = AccentOrange,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = if (isEn) "Gold Points: ${currentUser.loyaltyPoints} | VIP Member" else "Điểm Gold: ${currentUser.loyaltyPoints} | VIP Member",
                            color = AccentOrange,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }

                // User Initials Avatar
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(Slate200)
                        .border(2.dp, Color.White, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = currentUser.name.split(" ").lastOrNull()?.take(2)?.uppercase() ?: "AD",
                        color = Slate600,
                        fontWeight = FontWeight.Bold,
                        fontSize = 13.sp
                    )
                }
            }

            // Quick Categories mockup representation
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Hotel Category
                Column(
                    modifier = Modifier.clickable {
                        viewModel.searchCity.value = ""
                        viewModel.searchQuery.value = ""
                        onNavigateToSearchResults()
                    },
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .size(56.dp)
                            .clip(RoundedCornerShape(16.dp))
                            .background(StayHubBlue50),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Apartment,
                            contentDescription = "Hotel",
                            tint = StayHubBlue700,
                            modifier = Modifier.size(26.dp)
                        )
                    }
                    Spacer(modifier = Modifier.height(6.dp))
                    Text("Hotel", color = Slate600, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }

                // Resort Category
                Column(
                    modifier = Modifier.clickable {
                        viewModel.searchCity.value = ""
                        viewModel.searchQuery.value = "Resort"
                        onNavigateToSearchResults()
                    },
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .size(56.dp)
                            .clip(RoundedCornerShape(16.dp))
                            .background(AccentOrange50),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.BeachAccess,
                            contentDescription = "Resort",
                            tint = AccentOrange,
                            modifier = Modifier.size(26.dp)
                        )
                    }
                    Spacer(modifier = Modifier.height(6.dp))
                    Text("Resort", color = Slate600, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }

                // Flights Category
                Column(
                    modifier = Modifier.clickable {
                        showFlightDialog = true
                    },
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .size(56.dp)
                            .clip(RoundedCornerShape(16.dp))
                            .background(AccentGreen50),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.FlightTakeoff,
                            contentDescription = "Flights",
                            tint = AccentGreen,
                            modifier = Modifier.size(26.dp)
                        )
                    }
                    Spacer(modifier = Modifier.height(6.dp))
                    Text("Flights", color = Slate600, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }

                // Deals Category
                Column(
                    modifier = Modifier.clickable {
                        showDealsBottomSheet = true
                    },
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .size(56.dp)
                            .clip(RoundedCornerShape(16.dp))
                            .background(AccentPurple50),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Loyalty,
                            contentDescription = "Deals",
                            tint = AccentPurple,
                            modifier = Modifier.size(24.dp)
                        )
                    }
                    Spacer(modifier = Modifier.height(6.dp))
                    Text("Deals", color = Slate600, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Carousel Banner Promotion
            PromotionCarouselWidget()

            Spacer(modifier = Modifier.height(16.dp))

            // Main Booking Search Form Container (Agoda style card)
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
                border = BorderStroke(1.dp, if (currentUser.isDarkMode) Color(0xFF334155) else Slate200)
            ) {
                Column(
                    modifier = Modifier.padding(16.dp)
                ) {
                    Text(
                        text = if (isEn) "Book Hotels & Resorts" else "Đặt Phòng Khách Sạn & Resort",
                        color = MaterialTheme.colorScheme.onSurface,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(bottom = 12.dp)
                    )

                    // Destination row with Voice input button
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        OutlinedTextField(
                            value = locationInput,
                            onValueChange = { locationInput = it },
                            label = { Text(if (isEn) "Destination / Hotel" else "Điểm đến / Tên khách sạn", color = Slate500) },
                            placeholder = { Text(if (isEn) "Enter location (e.g. Ha Noi)" else "Nhập địa điểm (ví dụ: Hà Nội)", color = Slate400) },
                            leadingIcon = { Icon(Icons.Default.LocationOn, contentDescription = "Location", tint = StayHubBlue600) },
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = StayHubBlue600,
                                unfocusedBorderColor = if (currentUser.isDarkMode) Color(0xFF475569) else Slate300,
                                focusedTextColor = MaterialTheme.colorScheme.onSurface,
                                unfocusedTextColor = MaterialTheme.colorScheme.onSurfaceVariant,
                                focusedContainerColor = if (currentUser.isDarkMode) Color(0xFF0F172A) else Slate100,
                                unfocusedContainerColor = if (currentUser.isDarkMode) Color(0xFF0F172A) else Slate100
                            ),
                            shape = RoundedCornerShape(12.dp),
                            modifier = Modifier
                                .weight(1f)
                                .testTag("home_location_input"),
                            singleLine = true
                        )

                        Spacer(modifier = Modifier.width(8.dp))

                        // Voice Search trigger button
                        Box(
                            modifier = Modifier
                                .size(50.dp)
                                .clip(RoundedCornerShape(12.dp))
                                .background(if (currentUser.isDarkMode) Color(0xFF334155) else StayHubBlue100)
                                .clickable {
                                    showVoiceDialog = true
                                    voiceMessageState = if (isEn) "Listening..." else "Đang nghe..."
                                },
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.Mic,
                                contentDescription = "Voice Search",
                                tint = StayHubBlue700
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    // Date Pickers Row
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Card(
                            onClick = { showCheckInPicker = true },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(12.dp),
                            colors = CardDefaults.cardColors(containerColor = if (currentUser.isDarkMode) Color(0xFF1E293B) else Slate100),
                            border = BorderStroke(1.dp, if (currentUser.isDarkMode) Color(0xFF334155) else Slate200)
                        ) {
                            Column(modifier = Modifier.padding(12.dp)) {
                                Text(if (isEn) "Check-in" else "Nhận phòng", color = Slate500, fontSize = 11.sp)
                                Spacer(modifier = Modifier.height(4.dp))
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(Icons.Default.DateRange, contentDescription = null, tint = StayHubBlue600, modifier = Modifier.size(16.dp))
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Text(checkIn, color = MaterialTheme.colorScheme.onSurface, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                                }
                            }
                        }

                        Card(
                            onClick = { showCheckInPicker = true },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(12.dp),
                            colors = CardDefaults.cardColors(containerColor = if (currentUser.isDarkMode) Color(0xFF1E293B) else Slate100),
                            border = BorderStroke(1.dp, if (currentUser.isDarkMode) Color(0xFF334155) else Slate200)
                        ) {
                            Column(modifier = Modifier.padding(12.dp)) {
                                Text(if (isEn) "Check-out" else "Trả phòng", color = Slate500, fontSize = 11.sp)
                                Spacer(modifier = Modifier.height(4.dp))
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(Icons.Default.DateRange, contentDescription = null, tint = StayHubBlue600, modifier = Modifier.size(16.dp))
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Text(checkOut, color = MaterialTheme.colorScheme.onSurface, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                                }
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    // Guest selector block
                    Card(
                        onClick = { showGuestsPicker = true },
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(12.dp),
                        colors = CardDefaults.cardColors(containerColor = if (currentUser.isDarkMode) Color(0xFF1E293B) else Slate100),
                        border = BorderStroke(1.dp, if (currentUser.isDarkMode) Color(0xFF334155) else Slate200)
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(12.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column {
                                Text(if (isEn) "Guests & Rooms" else "Khách & Phòng", color = Slate500, fontSize = 11.sp)
                                Spacer(modifier = Modifier.height(4.dp))
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(Icons.Default.People, contentDescription = null, tint = StayHubBlue600, modifier = Modifier.size(16.dp))
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(
                                        text = if (isEn) "$guests guests, $rooms rooms" else "$guests khách, $rooms phòng",
                                        color = MaterialTheme.colorScheme.onSurface,
                                        fontSize = 14.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                }
                            }
                            Icon(Icons.Default.KeyboardArrowDown, contentDescription = null, tint = Slate500)
                        }
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Submit Search Button
                    Button(
                        onClick = {
                            focusManager.clearFocus()
                            viewModel.submitBookingSearch(
                                city = locationInput,
                                checkIn = checkIn,
                                checkOut = checkOut,
                                guests = guests,
                                rooms = rooms
                            )
                            onNavigateToSearchResults()
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = StayHubBlue600),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(48.dp)
                            .testTag("home_search_submit_btn")
                    ) {
                        Icon(imageVector = Icons.Default.Search, contentDescription = "Search", tint = Color.White)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(if (isEn) "FIND ROOMS NOW" else "TÌM PHÒNG NGAY", fontSize = 15.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // AI Smart Recommendation Banner
            AISmartTravelWidget(onLocationSelected = { locationInput = it })

            Spacer(modifier = Modifier.height(20.dp))

            // Featured/Popular list of Hotels (Khách sạn nổi bật)
            RowHeaderWidget(if (isEn) "Featured Hotels \uD83D\uDD25" else "Khách sạn nổi bật \uD83D\uDD25", isEn = isEn, onViewAll = {
                locationInput = ""
                viewModel.setCity("")
                onNavigateToSearchResults()
            })

            LazyRow(
                contentPadding = PaddingValues(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                items(hotels.filter { it.isFeatured }) { hotel ->
                    HotelFeaturedCard(hotel, onHotelClick = { onNavigateToDetail(hotel.id) })
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Suggested destination category grid
            RowHeaderWidget(if (isEn) "Popular Destinations" else "Gợi ý điểm đến phổ biến", isEn = isEn, onViewAll = {})
            LazyRow(
                contentPadding = PaddingValues(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(90.dp)
            ) {
                val destinations = listOf(
                    Pair("Hà Nội", "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=150&q=80"),
                    Pair("Đà Nẵng", "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=150&q=80"),
                    Pair("Sapa", "https://images.unsplash.com/photo-1495365200479-c4ed1d35e1aa?auto=format&fit=crop&w=150&q=80"),
                    Pair("Phú Quốc", "https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=150&q=80"),
                    Pair("Nha Trang", "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=150&q=80"),
                    Pair("Đà Lạt", "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=150&q=80"),
                    Pair("Hạ Long", "https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=150&q=80"),
                    Pair("Huế", "https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=150&q=80"),
                    Pair("Vũng Tàu", "https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=150&q=80"),
                    Pair("Ninh Bình", "https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=150&q=80"),
                    Pair("Quy Nhơn", "https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=150&q=80")
                )
                items(destinations) { (destName, destImg) ->
                    Box(
                        modifier = Modifier
                            .width(130.dp)
                            .fillMaxHeight()
                            .clip(RoundedCornerShape(12.dp))
                            .clickable {
                                locationInput = destName
                                viewModel.setCity(destName)
                                onNavigateToSearchResults()
                            }
                    ) {
                        Image(
                            painter = coil.compose.rememberAsyncImagePainter(model = destImg),
                            contentDescription = destName,
                            modifier = Modifier.fillMaxSize(),
                            contentScale = ContentScale.Crop
                        )
                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .background(Color.Black.copy(alpha = 0.4f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = destName,
                                color = Color.White,
                                fontWeight = FontWeight.Bold,
                                fontSize = 14.sp
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Regular hotels block
            RowHeaderWidget(if (isEn) "Recommended for You" else "Dành cho bạn gần đây", isEn = isEn, onViewAll = {
                locationInput = ""
                viewModel.setCity("")
                onNavigateToSearchResults()
            })

            LazyRow(
                contentPadding = PaddingValues(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 16.dp)
            ) {
                items(hotels.filter { !it.isFeatured }) { hotel ->
                    HotelMiniCard(hotel, onHotelClick = { onNavigateToDetail(hotel.id) })
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // All Hotels list block
            RowHeaderWidget(if (isEn) "All Hotels \uD83C\uDFE8" else "Tất cả khách sạn \uD83C\uDFE8", isEn = isEn, onViewAll = {
                locationInput = ""
                viewModel.setCity("")
                onNavigateToSearchResults()
            })

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                allHotels.forEach { hotel ->
                    HotelRowCard(hotel, onHotelClick = { onNavigateToDetail(hotel.id) })
                }
            }
        }

        // --- Simulated Voice Search Overlay Dialog ---
        if (showVoiceDialog) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.75f))
                    .clickable { showVoiceDialog = false },
                contentAlignment = Alignment.Center
            ) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth(0.85f)
                        .clickable(enabled = false) {},
                    colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                    shape = RoundedCornerShape(24.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "Tìm kiếm giọng nói AI",
                            color = Color.White,
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(16.dp))

                        // Mic bouncing animate animation mock
                        Box(
                            modifier = Modifier
                                .size(70.dp)
                                .clip(CircleShape)
                                .background(Color(0xFFF97316).copy(alpha = 0.2f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.Mic,
                                contentDescription = "Active mic",
                                tint = Color(0xFFF97316),
                                modifier = Modifier.size(40.dp)
                            )
                        }

                        Spacer(modifier = Modifier.height(16.dp))
                        Text(voiceMessageState, color = Color.LightGray, fontSize = 15.sp, textAlign = TextAlign.Center)

                        LaunchedEffect(key1 = true) {
                            delay(1200)
                            voiceMessageState = "Hành khách đang muốn tìm phòng ở..."
                            delay(1000)
                            voiceMessageState = "\"Sapa\" \uD83C\uDF2B️"
                            delay(1200)
                            locationInput = viewModel.handleVoiceInput("Sapa")
                            showVoiceDialog = false
                        }
                    }
                }
            }
        }

        // --- Custom Pickers ---
        if (showCheckInPicker) {
            var selectedTab by remember { mutableStateOf(0) } // 0: Check-In, 1: Check-Out
            
            AlertDialog(
                onDismissRequest = { showCheckInPicker = false },
                title = { Text(if (selectedTab == 0) "Chọn Ngày Nhận Phòng" else "Chọn Ngày Trả Phòng", color = Slate900) },
                text = {
                    Column(modifier = Modifier.height(350.dp)) {
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(if (selectedTab == 0) StayHubBlue100 else Color.Transparent)
                                    .clickable { selectedTab = 0 }
                                    .padding(8.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text("Nhận phòng", fontSize = 11.sp, color = Slate600)
                                    Text(checkIn, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = StayHubBlue700)
                                }
                            }
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(if (selectedTab == 1) StayHubBlue100 else Color.Transparent)
                                    .clickable { selectedTab = 1 }
                                    .padding(8.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text("Trả phòng", fontSize = 11.sp, color = Slate600)
                                    Text(checkOut, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = StayHubBlue700)
                                }
                            }
                        }
                        
                        Spacer(modifier = Modifier.height(12.dp))
                        Divider(color = Slate200)
                        Spacer(modifier = Modifier.height(12.dp))
                        
                        LazyColumn(modifier = Modifier.weight(1f)) {
                            items(datesList) { (dateStr, dateLabel) ->
                                val sdf = java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale.US)
                                val isPastCheckInInCheckOut = selectedTab == 1 && dateStr <= checkIn
                                val isSelected = if (selectedTab == 0) checkIn == dateStr else checkOut == dateStr
                                
                                val textColor = if (isPastCheckInInCheckOut) Color.Gray else if (isSelected) Color.White else Slate800
                                val bg = if (isSelected) StayHubBlue600 else if (isPastCheckInInCheckOut) Color.Transparent else Slate100
                                
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(vertical = 4.dp)
                                        .clip(RoundedCornerShape(10.dp))
                                        .background(bg)
                                        .clickable(enabled = !isPastCheckInInCheckOut) {
                                            if (selectedTab == 0) {
                                                checkIn = dateStr
                                                // auto advance to check-out and ensure check-out is after check-in
                                                if (checkOut <= dateStr) {
                                                    val parts = dateStr.split("-")
                                                    val cal = java.util.Calendar.getInstance()
                                                    cal.set(parts[0].toInt(), parts[1].toInt() - 1, parts[2].toInt())
                                                    cal.add(java.util.Calendar.DATE, 1)
                                                    checkOut = sdf.format(cal.time)
                                                }
                                                selectedTab = 1
                                            } else {
                                                checkOut = dateStr
                                            }
                                        }
                                        .padding(horizontal = 16.dp, vertical = 12.dp),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text(dateLabel, color = textColor, fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal)
                                    if (isSelected) {
                                        Icon(Icons.Default.Check, contentDescription = "Selected", tint = Color.White, modifier = Modifier.size(16.dp))
                                    }
                                }
                            }
                        }
                    }
                },
                confirmButton = {
                    Button(
                        onClick = { showCheckInPicker = false },
                        colors = ButtonDefaults.buttonColors(containerColor = StayHubBlue600)
                    ) {
                        Text("Xác nhận", color = Color.White)
                    }
                }
            )
        }

        if (showFlightDialog) {
            var originCity by remember { mutableStateOf("Hải Phòng") }
            val destCity = locationInput.ifEmpty { "Nha Trang" }
            var selectedAirline by remember { mutableStateOf("Vietnam Airlines") }
            var bookingSuccess by remember { mutableStateOf(false) }

            AlertDialog(
                onDismissRequest = { showFlightDialog = false },
                title = { 
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.FlightTakeoff, "Flight Info", tint = AccentGreen, modifier = Modifier.size(24.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Combo Bay + Ở StayEase", color = Slate900, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    }
                },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        Text("Đồng hành cùng đối tác hàng không để nhận ưu đãi giảm 15% gói combo thẳng vào dịch vụ nghỉ dưỡng.", fontSize = 12.sp, color = Slate600)
                        
                        if (bookingSuccess) {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(Color(0xFFDCFCE7))
                                    .border(1.dp, Color(0xFF22C55E), RoundedCornerShape(12.dp))
                                    .padding(16.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Icon(Icons.Default.CheckCircle, "Success", tint = Color(0xFF22C55E), modifier = Modifier.size(36.dp))
                                    Spacer(modifier = Modifier.height(8.dp))
                                    Text("Đã giữ chỗ Combo Bay!", fontWeight = FontWeight.Bold, color = Color(0xFF15803D), fontSize = 14.sp)
                                    Text("Đã đăng ký giảm thêm 15% vào hóa đơn phòng khách sạn của bạn khi checkout.", fontSize = 11.sp, color = Color(0xFF166534), textAlign = TextAlign.Center)
                                }
                            }
                        } else {
                            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text("Khởi hành", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Slate700)
                                    Box(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .clip(RoundedCornerShape(8.dp))
                                            .background(Slate100)
                                            .clickable { 
                                                originCity = if (originCity == "Hải Phòng") "TP. Hồ Chí Minh" else if (originCity == "TP. Hồ Chí Minh") "Hà Nội" else "Hải Phòng"
                                            }
                                            .padding(10.dp)
                                    ) {
                                        Text(originCity, fontSize = 13.sp, color = Slate900)
                                    }
                                }
                                Column(modifier = Modifier.weight(1f)) {
                                    Text("Điểm đến hợp tác", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Slate700)
                                    Box(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .clip(RoundedCornerShape(8.dp))
                                            .background(Slate100)
                                            .clickable { }
                                            .padding(10.dp)
                                    ) {
                                        Text(destCity, fontSize = 13.sp, color = Slate900)
                                    }
                                }
                            }

                            Text("Hãng bay đối tác", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Slate700)
                            Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                                listOf("Vietnam Airlines", "VietJet Air", "Bamboo Airways").forEach { airline ->
                                    val isSel = selectedAirline == airline
                                    Box(
                                        modifier = Modifier
                                            .weight(1f)
                                            .clip(RoundedCornerShape(8.dp))
                                            .background(if (isSel) Color(0xFFDCFCE7) else Slate100)
                                            .border(1.dp, if (isSel) Color(0xFF22C55E) else Slate200, RoundedCornerShape(8.dp))
                                            .clickable { selectedAirline = airline }
                                            .padding(8.dp),
                                        contentAlignment = Alignment.Center
                                    ) {
                                        Text(airline, fontSize = 10.sp, fontWeight = FontWeight.Bold, color = if (isSel) Color(0xFF15803D) else Slate700)
                                    }
                                }
                            }
                        }
                    }
                },
                confirmButton = {
                    if (bookingSuccess) {
                        Button(
                            onClick = { 
                                showFlightDialog = false
                                bookingSuccess = false
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = AccentGreen)
                        ) {
                            Text("Đóng", color = Color.White)
                        }
                    } else {
                        Button(
                            onClick = { bookingSuccess = true },
                            colors = ButtonDefaults.buttonColors(containerColor = AccentGreen)
                        ) {
                            Text("Giữ vé & Áp Combo", color = Color.White)
                        }
                    }
                }
            )
        }

        if (showDealsBottomSheet) {
            val couponsList by viewModel.coupons.collectAsState()
            
            AlertDialog(
                onDismissRequest = { showDealsBottomSheet = false },
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.CardGiftcard, "Gift", tint = AccentPurple, modifier = Modifier.size(24.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Ưu Đãi Đặc Biệt & Coupons", color = Slate900, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    }
                },
                text = {
                    Column(
                        modifier = Modifier.height(300.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Text("Nhấn vào sảo chép coupon để áp thẳng giảm giá VND vào hóa đơn phòng khách sạn của bạn:", fontSize = 12.sp, color = Slate600)
                        
                        LazyColumn(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                            items(couponsList) { coupon ->
                                Card(
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = CardDefaults.cardColors(containerColor = Color.White),
                                    border = BorderStroke(1.dp, AccentPurple.copy(alpha = 0.3f)),
                                    shape = RoundedCornerShape(12.dp)
                                ) {
                                    Column(modifier = Modifier.padding(12.dp)) {
                                        Row(
                                            modifier = Modifier.fillMaxWidth(),
                                            horizontalArrangement = Arrangement.SpaceBetween,
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Text(coupon.code, fontWeight = FontWeight.Bold, color = AccentPurple, fontSize = 14.sp)
                                            Box(
                                                modifier = Modifier
                                                    .clip(RoundedCornerShape(8.dp))
                                                    .background(AccentPurple.copy(alpha = 0.1f))
                                                    .clickable {
                                                        // Instantly apply coupon or notify user
                                                    }
                                                    .padding(horizontal = 10.dp, vertical = 4.dp)
                                            ) {
                                                Text("Sao chép", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = AccentPurple)
                                            }
                                        }
                                        Spacer(modifier = Modifier.height(4.dp))
                                        Text(coupon.description, fontSize = 11.sp, color = Slate700)
                                        Spacer(modifier = Modifier.height(4.dp))
                                        Text(
                                            "Tối đa giảm: ${coupon.maxDiscount.formatPrice()} | Đơn tối thiểu: ${coupon.minSpend.formatPrice()}",
                                            fontSize = 10.sp,
                                            color = Slate500,
                                            fontWeight = FontWeight.Bold
                                        )
                                    }
                                }
                            }
                        }
                    }
                },
                confirmButton = {
                    Button(
                        onClick = { showDealsBottomSheet = false },
                        colors = ButtonDefaults.buttonColors(containerColor = AccentPurple)
                    ) {
                        Text("Đóng", color = Color.White)
                    }
                }
            )
        }

        if (showGuestsPicker) {
            AlertDialog(
                onDismissRequest = { showGuestsPicker = false },
                title = { Text("Lọc Khách & Phòng") },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                            Text("Số khách")
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                IconButton(onClick = { if (guests > 1) guests-- }) { Icon(Icons.Default.Remove, "Less") }
                                Text("$guests", fontWeight = FontWeight.Bold)
                                IconButton(onClick = { guests++ }) { Icon(Icons.Default.Add, "More") }
                            }
                        }
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                            Text("Số phòng")
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                IconButton(onClick = { if (rooms > 1) rooms-- }) { Icon(Icons.Default.Remove, "Less") }
                                Text("$rooms", fontWeight = FontWeight.Bold)
                                IconButton(onClick = { rooms++ }) { Icon(Icons.Default.Add, "More") }
                            }
                        }
                    }
                },
                confirmButton = {
                    Button(onClick = { showGuestsPicker = false }, colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316))) {
                        Text("Xác nhận", color = Color.White)
                    }
                }
            )
        }
    }
}

@Composable
fun PromotionCarouselWidget() {
    val banners = listOf(
        Pair("Ưu đãi khai hè: Giảm 20% đặt phòng", "Nhập mã: STAYHUBSALE"),
        Pair("Tích Gold Point gấp 3 ngày vàng", "Hot deal đặt phòng nghỉ mát"),
        Pair("Săn Voucher Chào mừng $100", "Thời hạn áp dụng hữu hạn")
    )
    var currentSlide by remember { mutableIntStateOf(0) }

    LaunchedEffect(key1 = true) {
        while (true) {
            delay(4000)
            currentSlide = (currentSlide + 1) % banners.size
        }
    }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .height(130.dp),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.Transparent)
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.horizontalGradient(
                        colors = listOf(StayHubBlue900, StayHubBlue600) // StayHub style grand blue gradient
                    )
                )
                .padding(20.dp),
            contentAlignment = Alignment.CenterStart
        ) {
            Column(modifier = Modifier.fillMaxHeight(), verticalArrangement = Arrangement.Center) {
                Text(
                    text = banners[currentSlide].first,
                    color = Color.White,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Black
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = banners[currentSlide].second,
                    color = Color.White.copy(alpha = 0.9f),
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium
                )
                Spacer(modifier = Modifier.height(8.dp))
                // Visual indicators dots
                Row {
                    banners.forEachIndexed { i, _ ->
                        Box(
                            modifier = Modifier
                                .padding(horizontal = 2.dp)
                                .size(if (currentSlide == i) 14.dp else 6.dp, 6.dp)
                                .clip(RoundedCornerShape(3.dp))
                                .background(if (currentSlide == i) Color.White else Color.White.copy(alpha = 0.4f))
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun AISmartTravelWidget(onLocationSelected: (String) -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = StayHubBlue50),
        border = BorderStroke(1.dp, StayHubBlue100)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(StayHubBlue100),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.AutoAwesome,
                    contentDescription = "AI Recommender",
                    tint = StayHubBlue700,
                    modifier = Modifier.size(24.dp)
                )
            }
            Spacer(modifier = Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = "Gợi ý AI StayEase",
                    color = StayHubBlue900,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp
                )
                Text(
                    text = "Hôm nay mát mẻ, Sa Pa đang có tuyết rơi mây phủ rất săn ảnh đẹp đó nhé!",
                    color = Slate600,
                    fontSize = 12.sp,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
            }
            Spacer(modifier = Modifier.width(8.dp))
            Button(
                onClick = { onLocationSelected("Sapa") },
                colors = ButtonDefaults.buttonColors(containerColor = StayHubBlue600),
                shape = RoundedCornerShape(8.dp),
                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp),
                modifier = Modifier.height(32.dp)
            ) {
                Text("Chọn", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
fun RowHeaderWidget(title: String, isEn: Boolean = false, onViewAll: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(title, color = MaterialTheme.colorScheme.onBackground, fontWeight = FontWeight.Bold, fontSize = 16.sp)
        Text(
            if (isEn) "See all" else "Xem tất cả",
            color = StayHubBlue700,
            fontSize = 13.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.clickable { onViewAll() }
        )
    }
}

@Composable
fun HotelFeaturedCard(hotel: HotelModel, onHotelClick: () -> Unit) {
    Card(
        modifier = Modifier
            .width(240.dp)
            .clickable { onHotelClick() }
            .shadow(elevation = 3.dp, shape = RoundedCornerShape(16.dp)),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = CardBackground),
        border = BorderStroke(1.dp, Slate200)
    ) {
        Column {
            Box(modifier = Modifier.height(130.dp)) {
                Image(
                    painter = coil.compose.rememberAsyncImagePainter(model = hotel.imageUrls.firstOrNull()),
                    contentDescription = hotel.name,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
                // Rating overlay sticker (Accent Green)
                Box(
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(8.dp)
                        .clip(RoundedCornerShape(6.dp))
                        .background(AccentGreen)
                        .padding(horizontal = 6.dp, vertical = 3.dp)
                ) {
                    Text("${hotel.rating}", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }
            }

            Column(modifier = Modifier.padding(12.dp)) {
                Text(
                    text = hotel.name,
                    color = Slate900,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = hotel.address,
                    color = Slate500,
                    fontSize = 11.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.padding(top = 2.dp)
                )

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(top = 4.dp)
                ) {
                    repeat(hotel.stars) {
                        Icon(Icons.Default.Star, contentDescription = null, tint = AccentOrange, modifier = Modifier.size(12.dp))
                    }
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("${hotel.reviewCount} đánh giá", color = Slate500, fontSize = 10.sp)
                }

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 8.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Giá bình quân", color = Slate500, fontSize = 11.sp)
                    Text("${hotel.priceMin.formatPrice()}/đêm", color = StayHubBlue700, fontSize = 15.sp, fontWeight = FontWeight.ExtraBold)
                }
            }
        }
    }
}

@Composable
fun HotelMiniCard(hotel: HotelModel, onHotelClick: () -> Unit) {
    Card(
        modifier = Modifier
            .width(180.dp)
            .clickable { onHotelClick() }
            .shadow(elevation = 2.dp, shape = RoundedCornerShape(12.dp)),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = CardBackground),
        border = BorderStroke(1.dp, Slate200)
    ) {
        Column {
            Image(
                painter = coil.compose.rememberAsyncImagePainter(model = hotel.imageUrls.firstOrNull()),
                contentDescription = hotel.name,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(95.dp),
                contentScale = ContentScale.Crop
            )
            Column(modifier = Modifier.padding(8.dp)) {
                Text(
                    text = hotel.name,
                    color = Slate900,
                    fontWeight = FontWeight.Bold,
                    fontSize = 12.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(vertical = 2.dp)) {
                    Icon(Icons.Default.Star, contentDescription = null, tint = AccentOrange, modifier = Modifier.size(10.dp))
                    Spacer(modifier = Modifier.width(2.dp))
                    Text("${hotel.rating} (${hotel.reviewCount})", color = Slate500, fontSize = 10.sp)
                }
                Text("${hotel.priceMin.formatPrice()}/đêm", color = StayHubBlue700, fontSize = 13.sp, fontWeight = FontWeight.Bold)
            }
        }
    }
}

// -------------------------------------------------------------
// SEARCH RESULTS AND ADVANCED FILTER SCREEN LISTINGS
// -------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SearchResultsScreen(
    viewModel: HotelViewModel,
    onNavigateToDetail: (String) -> Unit,
    onBack: () -> Unit
) {
    val listHotels by viewModel.filteredHotels.collectAsState()
    val searchCity by viewModel.searchCity.collectAsState()
    val checkIn by viewModel.checkInDate.collectAsState()
    val checkOut by viewModel.checkOutDate.collectAsState()
    val nights by viewModel.nightsCount.collectAsState()

    var showFilterSheet by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = if (searchCity.isEmpty()) "Kết quả tìm kiếm" else searchCity,
                            color = Color.White,
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = "$checkIn ~ $checkOut ($nights đêm)",
                            color = StayHubBlue100,
                            fontSize = 11.sp
                        )
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, "Back", tint = Color.White)
                    }
                },
                actions = {
                    IconButton(onClick = { showFilterSheet = true }) {
                        Icon(Icons.Default.FilterList, "Filter Drawer", tint = Color.White)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = StayHubBlue900)
            )
        }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(AppBackground)
                .padding(innerPadding)
        ) {
            if (listHotels.isEmpty()) {
                // Empty state
                Column(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Icon(Icons.Default.SentimentVeryDissatisfied, null, tint = Slate400, modifier = Modifier.size(60.dp))
                    Spacer(modifier = Modifier.height(12.dp))
                    Text("Không tìm thấy kết quả phù hợp", color = Slate900, fontWeight = FontWeight.Bold)
                    Text("Vui lòng thử điều chỉnh lại bộ lọc tìm kiếm", color = Slate500, fontSize = 13.sp)
                }
            } else {
                LazyColumn(
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                    modifier = Modifier.fillMaxSize()
                ) {
                    items(listHotels) { hotel ->
                        HotelRowCard(hotel, onHotelClick = { onNavigateToDetail(hotel.id) })
                    }
                }
            }

            // Advanced filter sheet custom modal trigger
            if (showFilterSheet) {
                AdvancedFilterModalSheet(
                    viewModel = viewModel,
                    onDismiss = { showFilterSheet = false }
                )
            }
        }
    }
}

@Composable
fun HotelRowCard(hotel: HotelModel, onHotelClick: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onHotelClick() }
            .shadow(elevation = 2.dp, shape = RoundedCornerShape(16.dp)),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = CardBackground),
        border = BorderStroke(1.dp, Slate200)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(130.dp)
        ) {
            Image(
                painter = coil.compose.rememberAsyncImagePainter(model = hotel.imageUrls.firstOrNull()),
                contentDescription = hotel.name,
                modifier = Modifier
                    .width(120.dp)
                    .fillMaxHeight(),
                contentScale = ContentScale.Crop
            )

            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(12.dp)
                    .fillMaxHeight(),
                verticalArrangement = Arrangement.SpaceBetween
            ) {
                Column {
                    Text(
                        text = hotel.name,
                        color = Slate900,
                        fontWeight = FontWeight.Bold,
                        fontSize = 14.sp,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        text = hotel.address,
                        color = Slate500,
                        fontSize = 11.sp,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.padding(top = 2.dp)
                    )
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.padding(top = 4.dp)
                    ) {
                        Icon(Icons.Default.Star, "Ratings", tint = AccentOrange, modifier = Modifier.size(11.dp))
                        Text(
                            " ${hotel.rating} ",
                            color = Slate900,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Text("(${hotel.reviewCount} đánh giá)", color = Slate500, fontSize = 10.sp)
                    }
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.Bottom
                ) {
                    // Amenities quick preview
                    Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        if (hotel.amenities.contains("Wifi")) {
                            Icon(Icons.Default.Wifi, null, tint = StayHubBlue600, modifier = Modifier.size(14.dp))
                        }
                        if (hotel.amenities.contains("Pool")) {
                            Icon(Icons.Default.Pool, null, tint = AccentGreen, modifier = Modifier.size(14.dp))
                        }
                        if (hotel.amenities.contains("Breakfast")) {
                            Icon(Icons.Default.FreeBreakfast, null, tint = AccentOrange, modifier = Modifier.size(14.dp))
                        }
                    }

                    Column(horizontalAlignment = Alignment.End) {
                        Text("Bắt đầu từ", color = Slate500, fontSize = 10.sp)
                        Text(hotel.priceMin.formatPrice(), color = StayHubBlue700, fontSize = 18.sp, fontWeight = FontWeight.Black)
                    }
                }
            }
        }
    }
}

// -------------------------------------------------------------
// FILTER SHEET MODAL SCREEN
// -------------------------------------------------------------

@Composable
fun AdvancedFilterModalSheet(
    viewModel: HotelViewModel,
    onDismiss: () -> Unit
) {
    // Collect local filter state
    val pMin by viewModel.filterPriceMin.collectAsState()
    val pMax by viewModel.filterPriceMax.collectAsState()
    val selectedStars by viewModel.filterStars.collectAsState()
    val selectedAmenities by viewModel.filterAmenities.collectAsState()
    val selectedSortOrder by viewModel.searchSortOrder.collectAsState()

    var tempMinPrice by remember { mutableFloatStateOf(pMin) }
    var tempMaxPrice by remember { mutableFloatStateOf(pMax) }
    var tempStars by remember { mutableStateOf(selectedStars) }
    var tempAmenities by remember { mutableStateOf(selectedAmenities) }
    var tempSort by remember { mutableStateOf(selectedSortOrder) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.5f))
            .clickable { onDismiss() },
        contentAlignment = Alignment.BottomCenter
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.78f)
                .clickable(enabled = false) {},
            colors = CardDefaults.cardColors(containerColor = CardBackground),
            shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp),
            elevation = CardDefaults.cardElevation(defaultElevation = 16.dp),
            border = BorderStroke(1.dp, Slate200)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(20.dp)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.SpaceBetween
            ) {
                Column {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("Bộ Lọc Tìm Kiếm", color = Slate900, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                        Text(
                            "Đặt lại",
                            color = StayHubBlue700,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.clickable {
                                tempMinPrice = 0f
                                tempMaxPrice = 30000000f
                                tempStars = emptySet()
                                tempAmenities = emptySet()
                                tempSort = "POPULAR"
                            }
                        )
                    }

                    Spacer(modifier = Modifier.height(20.dp))

                    // Sort Order radio blocks
                    Text("Sắp xếp theo", color = Slate900, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 8.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        listOf(
                            Pair("Phục vụ", "POPULAR"),
                            Pair("Giá thấp-cao", "LOW_TO_HIGH"),
                            Pair("Đánh giá cao", "RATING")
                        ).forEach { (label, mode) ->
                            val isSelected = tempSort == mode
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(if (isSelected) StayHubBlue600 else Slate100)
                                    .border(1.dp, if (isSelected) StayHubBlue600 else Slate200, RoundedCornerShape(8.dp))
                                    .clickable { tempSort = mode }
                                    .padding(vertical = 10.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(label, color = if (isSelected) Color.White else Slate700, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Slider Range
                    Text("Khoảng giá (mỗi đêm): ${tempMinPrice.toDouble().formatPrice()} - ${tempMaxPrice.toDouble().formatPrice()}", color = Slate900, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    RangeSlider(
                        value = tempMinPrice..tempMaxPrice,
                        onValueChange = { range ->
                            tempMinPrice = range.start
                            tempMaxPrice = range.endInclusive
                        },
                        valueRange = 0f..30000000f,
                        colors = SliderDefaults.colors(
                            activeTrackColor = StayHubBlue600,
                            inactiveTrackColor = Slate200,
                            thumbColor = StayHubBlue600
                        ),
                        modifier = Modifier.padding(horizontal = 8.dp)
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    // Star Selection Row
                    Text("Hạng sao khách sạn", color = Slate900, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 8.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        listOf(3, 4, 5).forEach { star ->
                            val isSelected = tempStars.contains(star)
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(if (isSelected) StayHubBlue50 else Slate100)
                                    .border(2.dp, if (isSelected) StayHubBlue600 else Slate200, RoundedCornerShape(8.dp))
                                    .clickable {
                                        val next = tempStars.toMutableSet()
                                        if (next.contains(star)) next.remove(star) else next.add(star)
                                        tempStars = next
                                    }
                                    .padding(vertical = 8.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Text("$star", color = if (isSelected) StayHubBlue900 else Slate700, fontWeight = FontWeight.Bold)
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Icon(Icons.Default.Star, null, tint = AccentOrange, modifier = Modifier.size(16.dp))
                                }
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Amenities selection chips grid
                    Text("Đặc tính ưu đãi / Tiện nghi", color = Slate900, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    FlowRowWidget(
                        items = listOf("Wifi", "Pool", "Gym", "Breakfast", "Parking", "Spa"),
                        selected = tempAmenities,
                        onToggle = { amenity ->
                            val next = tempAmenities.toMutableSet()
                            if (next.contains(amenity)) next.remove(amenity) else next.add(amenity)
                            tempAmenities = next
                        }
                    )
                }

                Button(
                    onClick = {
                        viewModel.filterPriceMin.value = tempMinPrice
                        viewModel.filterPriceMax.value = tempMaxPrice
                        viewModel.filterStars.value = tempStars
                        viewModel.filterAmenities.value = tempAmenities
                        viewModel.searchSortOrder.value = tempSort
                        onDismiss()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = StayHubBlue600),
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(50.dp)
                ) {
                    Text("ÁP DỤNG BỘ LỌC", fontWeight = FontWeight.Bold, color = Color.White)
                }
            }
        }
    }
}

@Composable
fun FlowRowWidget(
    items: List<String>,
    selected: Set<String>,
    onToggle: (String) -> Unit
) {
    // Flow row using basic Row + scrolling or layout wraps.
    // For simplicity, we make horizontal scroll row
    LazyRow(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(items) { term ->
            val isSelected = selected.contains(term)
            FilterChip(
                selected = isSelected,
                onClick = { onToggle(term) },
                label = { Text(term) },
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = StayHubBlue600,
                    selectedLabelColor = Color.White,
                    containerColor = Slate100,
                    labelColor = Slate600
                )
            )
        }
    }
}
