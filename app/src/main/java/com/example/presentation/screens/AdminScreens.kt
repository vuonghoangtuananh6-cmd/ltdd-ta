package com.example.presentation.screens

import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.HotelModel
import com.example.data.model.RoomModel
import com.example.data.model.formatPrice
import com.example.presentation.viewmodel.HotelViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminDashboardScreen(
    viewModel: HotelViewModel,
    onBack: () -> Unit
) {
    val stats by viewModel.adminStats.collectAsState(initial = emptyMap())
    val hotelsList by viewModel.repository.hotels.collectAsState()
    val roomsList by viewModel.repository.rooms.collectAsState()

    var activeTab by remember { mutableStateOf("DASHBOARD") } // "DASHBOARD", "HOTELS", "ROOMS"

    // Form overlays add states
    var showAddHotelDialog by remember { mutableStateOf(false) }
    var addHotelName by remember { mutableStateOf("") }
    var addHotelCity by remember { mutableStateOf("Hà Nội") }
    var addHotelAddress by remember { mutableStateOf("") }
    var addHotelStars by remember { mutableIntStateOf(5) }
    var addHotelPrice by remember { mutableStateOf("150") }
    var addHotelDesc by remember { mutableStateOf("") }

    var showAddRoomDialog by remember { mutableStateOf(false) }
    var addRoomHotelId by remember { mutableStateOf("") }
    var addRoomName by remember { mutableStateOf("") }
    var addRoomPrice by remember { mutableStateOf("100") }
    var addRoomGuests by remember { mutableIntStateOf(2) }
    var addRoomSize by remember { mutableIntStateOf(40) }
    var addRoomDesc by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Trang Quản Trị KPI & CRUD", fontSize = 16.sp, fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back", tint = Color.White) }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color(0xFF0F172A))
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFF0F172A))
                .padding(innerPadding)
        ) {
            // Tab control bar buttons row
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color(0xFF1E293B))
                    .padding(vertical = 4.dp),
                horizontalArrangement = Arrangement.SpaceAround
            ) {
                listOf(
                    Pair("Tổng Quan", "DASHBOARD"),
                    Pair("Khách Sạn", "HOTELS"),
                    Pair("Phòng Trống", "ROOMS")
                ).forEach { (label, tab) ->
                    val selected = activeTab == tab
                    TextButton(
                        onClick = { activeTab = tab },
                        colors = ButtonDefaults.textButtonColors(
                            contentColor = if (selected) Color(0xFFF97316) else Color.LightGray
                        )
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(label, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                            if (selected) {
                                Box(
                                    modifier = Modifier
                                        .padding(top = 4.dp)
                                        .size(16.dp, 3.dp)
                                        .clip(RoundedCornerShape(1.dp))
                                        .background(Color(0xFFF97316))
                                )
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            when (activeTab) {
                "DASHBOARD" -> {
                    // --- TAB DASHBOARD ---
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .verticalScroll(rememberScrollState())
                            .padding(horizontal = 16.dp)
                    ) {
                        Text("KPI Doanh Nghiệp Thống Kê", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Spacer(modifier = Modifier.height(8.dp))

                        // Grid stats indicators
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            StatsWidget(
                                modifier = Modifier.weight(1f),
                                label = "DOANH THU",
                                value = ((stats["totalRevenue"] as? Double) ?: 0.0).formatPrice(),
                                icon = Icons.Default.MonetizationOn,
                                color = Color(0xFF22C55E)
                            )
                            StatsWidget(
                                modifier = Modifier.weight(1f),
                                label = "BOOKING MỚI",
                                value = "${stats["bookingsCount"] ?: 0}",
                                icon = Icons.Default.BookmarkAdded,
                                color = Color(0xFF3B82F6)
                            )
                        }

                        Spacer(modifier = Modifier.height(12.dp))

                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            StatsWidget(
                                modifier = Modifier.weight(1f),
                                label = "ĐANG KHẢO SÁT",
                                value = "${stats["activeBookings"] ?: 0}",
                                icon = Icons.Default.Timelapse,
                                color = Color(0xFFEAB308)
                            )
                            StatsWidget(
                                modifier = Modifier.weight(1f),
                                label = "TỈ LỆ HỦY",
                                value = "${stats["cancelledBookings"] ?: 0} phòng",
                                icon = Icons.Default.Cancel,
                                color = Color.Red
                            )
                        }

                        Spacer(modifier = Modifier.height(20.dp))

                        // --- Beautiful Canvas-driven Revenue Chart (Line & Bar charts) ---
                        Text("Sự tăng trưởng Doanh thu ($)", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Spacer(modifier = Modifier.height(8.dp))

                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(180.dp),
                            shape = RoundedCornerShape(16.dp),
                            colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                            border = BorderStroke(1.dp, Color(0xFF334155))
                        ) {
                            // Custom drawings Line chart mimicking professional analytics
                            Canvas(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .padding(16.dp)
                            ) {
                                val w = size.width
                                val h = size.height

                                // Draw analytical outline grid lines
                                drawLine(Color.Gray.copy(alpha = 0.3f), Offset(0f, h * 0.25f), Offset(w, h * 0.25f), strokeWidth = 2f)
                                drawLine(Color.Gray.copy(alpha = 0.3f), Offset(0f, h * 0.5f), Offset(w, h * 0.5f), strokeWidth = 2f)
                                drawLine(Color.Gray.copy(alpha = 0.3f), Offset(0f, h * 0.75f), Offset(w, h * 0.75f), strokeWidth = 2f)
                                drawLine(Color.Gray.copy(alpha = 0.6f), Offset(0f, h), Offset(w, h), strokeWidth = 4f)

                                // Plot data points representing Jan-Jun
                                val points = listOf(
                                    Offset(0f, h * 0.8f),
                                    Offset(w * 0.2f, h * 0.55f),
                                    Offset(w * 0.4f, h * 0.68f),
                                    Offset(w * 0.6f, h * 0.3f),
                                    Offset(w * 0.8f, h * 0.45f),
                                    Offset(w * 1.0f, h * 0.15f)
                                )

                                // Draw lines connecting points
                                for (i in 0 until points.size - 1) {
                                    drawLine(
                                        color = Color(0xFFF97316),
                                        start = points[i],
                                        end = points[i + 1],
                                        strokeWidth = 6f
                                    )
                                }

                                // Circles highlights
                                points.forEach { pt ->
                                    drawCircle(Color.White, radius = 6f, center = pt)
                                    drawCircle(Color(0xFFF97316), radius = 4f, center = pt)
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(16.dp))

                        // Custom Bar Graph representing booking distributions
                        Text("Phân bổ cơ sở lưu trú miền", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Spacer(modifier = Modifier.height(8.dp))

                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(120.dp)
                                .padding(bottom = 16.dp),
                            shape = RoundedCornerShape(16.dp),
                            colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B))
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .padding(16.dp),
                                horizontalArrangement = Arrangement.SpaceAround,
                                verticalAlignment = Alignment.Bottom
                            ) {
                                val bars = listOf(
                                    Pair("Hà Nội", 0.85f),
                                    Pair("Đà Nẵng", 0.65f),
                                    Pair("Sapa", 0.45f),
                                    Pair("Phú Quốc", 0.75f)
                                )

                                bars.forEach { (city, percent) ->
                                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                        Box(
                                            modifier = Modifier
                                                .width(28.dp)
                                                .fillMaxHeight(percent)
                                                .clip(RoundedCornerShape(topStart = 4.dp, topEnd = 4.dp))
                                                .background(
                                                    Brush.verticalGradient(
                                                        colors = listOf(Color(0xFF60A5FA), Color(0xFF2563EB))
                                                    )
                                                )
                                        )
                                        Spacer(modifier = Modifier.height(4.dp))
                                        Text(city, color = Color.LightGray, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                        }
                    }
                }

                "HOTELS" -> {
                    // --- TAB CRUD HOTELS ---
                    Column(modifier = Modifier.fillMaxSize()) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 16.dp, vertical = 8.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text("Tổng số: ${hotelsList.size} khách sạn", color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                            Button(
                                onClick = { showAddHotelDialog = true },
                                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316)),
                                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp),
                                shape = RoundedCornerShape(8.dp),
                                modifier = Modifier.height(32.dp)
                            ) {
                                Icon(Icons.Default.Add, null, tint = Color.White, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(4.dp))
                                Text("Thêm mới", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                            }
                        }

                        LazyColumn(
                            contentPadding = PaddingValues(16.dp),
                            verticalArrangement = Arrangement.spacedBy(12.dp),
                            modifier = Modifier.fillMaxSize()
                        ) {
                            items(hotelsList) { hotel ->
                                AdminHotelItem(hotel, onDelete = {
                                    viewModel.deleteAdminHotel(hotel.id)
                                })
                            }
                        }
                    }
                }

                "ROOMS" -> {
                    // --- TAB CRUD ROOMS ---
                    Column(modifier = Modifier.fillMaxSize()) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 16.dp, vertical = 8.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text("Tổng số: ${roomsList.size} loại cấu hình phòng", color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                            Button(
                                onClick = {
                                    if (hotelsList.isNotEmpty()) {
                                        addRoomHotelId = hotelsList.first().id
                                        showAddRoomDialog = true
                                    }
                                },
                                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316)),
                                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp),
                                shape = RoundedCornerShape(8.dp),
                                modifier = Modifier.height(32.dp)
                            ) {
                                Icon(Icons.Default.Add, null, tint = Color.White, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(4.dp))
                                Text("Thêm phòng", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                            }
                        }

                        LazyColumn(
                            contentPadding = PaddingValues(16.dp),
                            verticalArrangement = Arrangement.spacedBy(12.dp),
                            modifier = Modifier.fillMaxSize()
                        ) {
                            items(roomsList) { room ->
                                val matchedHotel = hotelsList.firstOrNull { it.id == room.hotelId }
                                val hotelLabel = matchedHotel?.name ?: "Khách sạn bí ẩn"

                                AdminRoomItem(room, hotelName = hotelLabel, onDelete = {
                                    viewModel.deleteAdminRoom(room.id)
                                })
                            }
                        }
                    }
                }
            }
        }

        // --- Dialog Add Hotel Overlay ---
        if (showAddHotelDialog) {
            AlertDialog(
                onDismissRequest = { showAddHotelDialog = false },
                title = { Text("Thêm Khách Sạn Mới") },
                text = {
                    Column(
                        verticalArrangement = Arrangement.spacedBy(10.dp),
                        modifier = Modifier.verticalScroll(rememberScrollState())
                    ) {
                        OutlinedTextField(value = addHotelName, onValueChange = { addHotelName = it }, label = { Text("Tên khách sạn") })
                        OutlinedTextField(value = addHotelCity, onValueChange = { addHotelCity = it }, label = { Text("Thành phố (ví dụ: Hà Nội)") })
                        OutlinedTextField(value = addHotelAddress, onValueChange = { addHotelAddress = it }, label = { Text("Địa chỉ") })
                        OutlinedTextField(value = addHotelPrice, onValueChange = { addHotelPrice = it }, label = { Text("Bắt đầu giá từ ($)") })
                        OutlinedTextField(value = addHotelDesc, onValueChange = { addHotelDesc = it }, label = { Text("Mô tả chi tiết") })
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text("Số sao: ")
                            Spacer(modifier = Modifier.width(8.dp))
                            listOf(3, 4, 5).forEach { stars ->
                                FilterChip(
                                    selected = addHotelStars == stars,
                                    onClick = { addHotelStars = stars },
                                    label = { Text("$stars ⭐") },
                                    modifier = Modifier.padding(horizontal = 4.dp)
                                )
                            }
                        }
                    }
                },
                confirmButton = {
                    Button(
                        onClick = {
                            if (addHotelName.isNotEmpty() && addHotelAddress.isNotEmpty()) {
                                val priceDouble = addHotelPrice.toDoubleOrNull() ?: 150.0
                                viewModel.createAdminHotel(
                                    name = addHotelName,
                                    city = addHotelCity,
                                    address = addHotelAddress,
                                    stars = addHotelStars,
                                    priceMin = priceDouble,
                                    description = addHotelDesc
                                )
                                // Clear
                                addHotelName = ""
                                addHotelAddress = ""
                                addHotelDesc = ""
                                showAddHotelDialog = false
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316))
                    ) {
                        Text("Xác nhận tạo", color = Color.White)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showAddHotelDialog = false }) { Text("Đóng") }
                }
            )
        }

        // --- Dialog Add Room Overlay ---
        if (showAddRoomDialog) {
            AlertDialog(
                onDismissRequest = { showAddRoomDialog = false },
                title = { Text("Thêm Phòng Trống") },
                text = {
                    Column(
                        verticalArrangement = Arrangement.spacedBy(10.dp),
                        modifier = Modifier.verticalScroll(rememberScrollState())
                    ) {
                        Text("Chọn khách sạn chủ:")
                        // Quick linear rows selector helper
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(60.dp)
                                .horizontalScroll(rememberScrollState())
                        ) {
                            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                hotelsList.forEach { hotel ->
                                    FilterChip(
                                        selected = addRoomHotelId == hotel.id,
                                        onClick = { addRoomHotelId = hotel.id },
                                        label = { Text(hotel.name, maxLines = 1, overflow = TextOverflow.Ellipsis) }
                                    )
                                }
                            }
                        }

                        OutlinedTextField(value = addRoomName, onValueChange = { addRoomName = it }, label = { Text("Tên loại phòng") })
                        OutlinedTextField(value = addRoomPrice, onValueChange = { addRoomPrice = it }, label = { Text("Giá một đêm ($)") })
                        OutlinedTextField(value = addRoomDesc, onValueChange = { addRoomDesc = it }, label = { Text("Mô tả phòng") })
                    }
                },
                confirmButton = {
                    Button(
                        onClick = {
                            if (addRoomName.isNotEmpty() && addRoomHotelId.isNotEmpty()) {
                                val priceDVal = addRoomPrice.toDoubleOrNull() ?: 100.0
                                viewModel.createAdminRoom(
                                    hotelId = addRoomHotelId,
                                    name = addRoomName,
                                    price = priceDVal,
                                    maxGuests = addRoomGuests,
                                    sizeSqm = addRoomSize,
                                    description = addRoomDesc
                                )
                                addRoomName = ""
                                addRoomDesc = ""
                                showAddRoomDialog = false
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316))
                    ) {
                        Text("Xác nhận tạo", color = Color.White)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showAddRoomDialog = false }) { Text("Đóng") }
                }
            )
        }
    }
}

@Composable
fun StatsWidget(
    modifier: Modifier = Modifier,
    label: String,
    value: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    color: Color
) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
        border = BorderStroke(1.dp, Color(0xFF334155))
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(color.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(icon, null, tint = color, modifier = Modifier.size(20.dp))
            }
            Spacer(modifier = Modifier.width(12.dp))
            Column {
                Text(label, color = Color.Gray, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                Text(value, color = Color.White, fontSize = 15.sp, fontWeight = FontWeight.Black)
            }
        }
    }
}

@Composable
fun AdminHotelItem(hotel: HotelModel, onDelete: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B))
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(modifier = Modifier.weight(1f), verticalAlignment = Alignment.CenterVertically) {
                Image(
                    painter = coil.compose.rememberAsyncImagePainter(model = hotel.imageUrls.firstOrNull()),
                    contentDescription = hotel.name,
                    modifier = Modifier
                        .size(50.dp)
                        .clip(RoundedCornerShape(6.dp)),
                    contentScale = ContentScale.Crop
                )
                Spacer(modifier = Modifier.width(12.dp))
                Column {
                    Text(hotel.name, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    Text("${hotel.city} | ${hotel.priceMin.formatPrice()}/đêm", color = Color.LightGray, fontSize = 11.sp)
                }
            }

            IconButton(onClick = onDelete) {
                Icon(Icons.Default.Delete, "Delete", tint = Color.Red.copy(alpha = 0.85f))
            }
        }
    }
}

@Composable
fun AdminRoomItem(room: RoomModel, hotelName: String, onDelete: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B))
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(room.name, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                Text("Chủ: $hotelName", color = Color.LightGray, fontSize = 11.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
                Text(room.price.formatPrice() + "/đêm", color = Color(0xFFFF7E40), fontSize = 12.sp, fontWeight = FontWeight.Bold)
            }

            IconButton(onClick = onDelete) {
                Icon(Icons.Default.Delete, "Delete", tint = Color.Red.copy(alpha = 0.85f))
            }
        }
    }
}
