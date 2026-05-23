package com.example.presentation.screens

import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.HotelModel
import com.example.data.model.formatPrice
import com.example.presentation.viewmodel.HotelViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    viewModel: HotelViewModel,
    onNavigateToAdmin: () -> Unit,
    onNavigateToChangePassword: () -> Unit,
    onLogout: () -> Unit
) {
    val currentUser by viewModel.currentUser.collectAsState()
    val checkInDate by viewModel.checkInDate.collectAsState()
    val isDark = currentUser.isDarkMode

    var showEditProfileDialog by remember { mutableStateOf(false) }
    var editName by remember { mutableStateOf(currentUser.name) }
    var editEmail by remember { mutableStateOf(currentUser.email) }
    var editPhone by remember { mutableStateOf(currentUser.phoneNumber) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Tài Khoản Thành Viên", fontSize = 18.sp, fontWeight = FontWeight.Bold) },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color(0xFF0F172A))
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFF0F172A))
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp)
        ) {
            // Member Avatar Badge Info Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                elevation = CardDefaults.cardElevation(6.dp)
            ) {
                Column(
                    modifier = Modifier.padding(20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Image(
                        painter = coil.compose.rememberAsyncImagePainter(model = currentUser.avatarUrl),
                        contentDescription = "User avatar",
                        modifier = Modifier
                            .size(85.dp)
                            .clip(CircleShape)
                            .border(3.dp, Color(0xFFF97316), CircleShape),
                        contentScale = ContentScale.Crop
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    Text(currentUser.name, color = Color.White, fontWeight = FontWeight.Black, fontSize = 20.sp)
                    Text(currentUser.email, color = Color.Gray, fontSize = 13.sp)

                    Spacer(modifier = Modifier.height(16.dp))

                    // Progress indicator for Loyalty Silver/Gold state tier
                    Column(modifier = Modifier.fillMaxWidth()) {
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                            Text("Hạng vàng hoàng kim (Gold Tier)", color = Color(0xFFEAB308), fontSize = 11.sp, fontWeight = FontWeight.Bold)
                            Text("${currentUser.loyaltyPoints}/1000 Pts", color = Color.LightGray, fontSize = 11.sp)
                        }
                        Spacer(modifier = Modifier.height(6.dp))
                        LinearProgressIndicator(
                            progress = { currentUser.loyaltyPoints / 1000f },
                            color = Color(0xFFEAB308),
                            trackColor = Color(0xFF334155),
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(6.dp)
                                .clip(RoundedCornerShape(3.dp))
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Settings buttons lists
            Text("Thiết Lập Ứng Dụng", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
            Spacer(modifier = Modifier.height(10.dp))

            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B))
            ) {
                Column {
                    // Update profile row
                    ProfileClickableRow(Icons.Default.ManageAccounts, "Chỉnh sửa thông tin cá nhân", onClick = {
                        editName = currentUser.name
                        editEmail = currentUser.email
                        editPhone = currentUser.phoneNumber
                        showEditProfileDialog = true
                    })
                    Divider(color = Color(0xFF334155))

                    // Admin panel row
                    ProfileClickableRow(Icons.Default.SupervisorAccount, "Hệ thống quản trị (Admin Dashboard)", tint = Color(0xFF60A5FA), onClick = onNavigateToAdmin)
                    Divider(color = Color(0xFF334155))

                    // Change Password row
                    ProfileClickableRow(Icons.Default.Lock, "Đổi mật khẩu tài khoản", onClick = onNavigateToChangePassword)
                    Divider(color = Color(0xFF334155))

                    // Language toggle row
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable {
                                val current = currentUser.language
                                viewModel.setLanguage(if (current == "VI") "EN" else "VI")
                            }
                            .padding(16.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.Language, null, tint = Color(0xFFF97316), modifier = Modifier.size(22.dp))
                            Spacer(modifier = Modifier.width(16.dp))
                            Text("Ngôn ngữ ưa thích", color = Color.White, fontSize = 14.sp)
                        }
                        Text(if (currentUser.language == "VI") "Tiếng Việt \uD83C\uDDFB\uD83C\uDDF3" else "English \uD83C\uDDFA\uD83C\uDDF8", color = Color(0xFFF97316), fontSize = 13.sp, fontWeight = FontWeight.Bold)
                    }

                    Divider(color = Color(0xFF334155))

                    // Darkmode toggle row
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.DarkMode, null, tint = Color(0xFFF97316), modifier = Modifier.size(22.dp))
                            Spacer(modifier = Modifier.width(16.dp))
                            Text("Chế độ tối (Dark Mode)", color = Color.White, fontSize = 14.sp)
                        }
                        Switch(
                            checked = isDark,
                            onCheckedChange = { viewModel.toggleDarkMode(it) },
                            colors = SwitchDefaults.colors(checkedThumbColor = Color(0xFFF97316))
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Extra support options
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B))
            ) {
                Column {
                    ProfileClickableRow(Icons.Default.Policy, "Điều khoản phục vụ & Bảo mật", onClick = {})
                    Divider(color = Color(0xFF334155))
                    ProfileClickableRow(Icons.Default.HelpOutline, "Trung tâm trợ giúp hỏi đáp StayEase", onClick = {})
                }
            }

            Spacer(modifier = Modifier.height(30.dp))

            // Logout Button
            Button(
                onClick = onLogout,
                colors = ButtonDefaults.buttonColors(containerColor = Color.Red.copy(alpha = 0.85f)),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp)
                    .testTag("logout_profile_btn")
            ) {
                Icon(Icons.Default.Logout, null, tint = Color.White)
                Spacer(modifier = Modifier.width(8.dp))
                Text("ĐĂNG XUẤT", fontWeight = FontWeight.Bold, color = Color.White)
            }
        }

        // Edit Profile Modal Info Dialog
        if (showEditProfileDialog) {
            AlertDialog(
                onDismissRequest = { showEditProfileDialog = false },
                title = { Text("Chỉnh Sửa Hồ Sơ") },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        OutlinedTextField(
                            value = editName,
                            onValueChange = { editName = it },
                            label = { Text("Họ & Tên đầy đủ") }
                        )
                        OutlinedTextField(
                            value = editEmail,
                            onValueChange = { editEmail = it },
                            label = { Text("Email liên lạc") }
                        )
                        OutlinedTextField(
                            value = editPhone,
                            onValueChange = { editPhone = it },
                            label = { Text("Số điện thoại") }
                        )
                    }
                },
                confirmButton = {
                    Button(
                        onClick = {
                            if (editName.isNotEmpty() && editEmail.isNotEmpty()) {
                                viewModel.updateProfile(editName, editEmail, editPhone)
                                showEditProfileDialog = false
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316))
                    ) {
                        Text("Cập nhật", color = Color.White)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showEditProfileDialog = false }) { Text("Hủy") }
                }
            )
        }
    }
}

@Composable
fun ProfileClickableRow(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    label: String,
    tint: Color = Color(0xFFF97316),
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(16.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(icon, null, tint = tint, modifier = Modifier.size(22.dp))
            Spacer(modifier = Modifier.width(16.dp))
            Text(label, color = Color.White, fontSize = 14.sp)
        }
        Icon(Icons.Default.KeyboardArrowRight, null, tint = Color.Gray)
    }
}

// -------------------------------------------------------------
// WISHLIST INTERACTIVE SAVED SCREEN
// -------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WishlistScreen(
    viewModel: HotelViewModel,
    onNavigateToDetail: (String) -> Unit
) {
    val list by viewModel.wishlistHotels.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Bộ Sưu Tập Yêu Thích", fontSize = 18.sp, fontWeight = FontWeight.Bold) },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color(0xFF0F172A))
            )
        }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFF0F172A))
                .padding(innerPadding)
        ) {
            if (list.isEmpty()) {
                Column(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Icon(Icons.Default.FavoriteBorder, null, tint = Color.Gray, modifier = Modifier.size(50.dp))
                    Spacer(modifier = Modifier.height(12.dp))
                    Text("Chưa có khách sạn nào được lưu", color = Color.White)
                    Text("Bấm trái tim thả thương nhớ khi tìm phòng nhé!", color = Color.Gray, fontSize = 12.sp)
                }
            } else {
                LazyColumn(
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                    modifier = Modifier.fillMaxSize()
                ) {
                    items(list) { hotel ->
                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { onNavigateToDetail(hotel.id) },
                            shape = RoundedCornerShape(16.dp),
                            colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B))
                        ) {
                            Row {
                                Image(
                                    painter = coil.compose.rememberAsyncImagePainter(model = hotel.imageUrls.firstOrNull()),
                                    contentDescription = hotel.name,
                                    modifier = Modifier
                                        .size(110.dp)
                                        .clip(RoundedCornerShape(topStart = 16.dp, bottomStart = 16.dp, topEnd = 0.dp, bottomEnd = 0.dp)),
                                    contentScale = ContentScale.Crop
                                )

                                Column(modifier = Modifier.padding(12.dp)) {
                                    Text(hotel.name, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                                    Text(hotel.city, color = Color.LightGray, fontSize = 11.sp, modifier = Modifier.padding(vertical = 2.dp))

                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Icon(Icons.Default.Star, null, tint = Color(0xFFEAB308), modifier = Modifier.size(12.dp))
                                        Text(" ${hotel.rating}", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                    }

                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.Bottom
                                    ) {
                                        Text("${hotel.priceMin.formatPrice()}/đêm", color = Color(0xFFFF7E40), fontSize = 14.sp, fontWeight = FontWeight.Bold)
                                        Icon(
                                            Icons.Default.Favorite,
                                            contentDescription = "Unfavorite",
                                            tint = Color.Red,
                                            modifier = Modifier
                                                .clickable { viewModel.toggleWishlist(hotel.id) }
                                                .size(22.dp)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// -------------------------------------------------------------
// NOTIFICATION PREVIEW SCREEN
// -------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NotificationsScreen(
    onBack: () -> Unit
) {
    val items = listOf(
        Pair("Chào mừng đến với StayEase Resort!", "Cảm ơn quý khách đã đăng ký thành viên. Đã cộng 450 điểm Gold Loyalty dành riêng cho bạn trải nghiệm!"),
        Pair("Ưu đãi đặt sớm hè 2026", "Giảm sốc 20% khi chọn điểm đầu cầu Đà Nẵng, Phú Quốc. Bấm xem rinh ngay phòng Resort biển mát lịm."),
        Pair("Cập nhật vé máy bay & Phòng", "Chỉ còn lại 2 phòng Classic Luxury tại Sofitel Legend Metropole Hanoi trong hè này!")
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Hộp Thư Thông Báo", fontSize = 18.sp, fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back", tint = Color.White) }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color(0xFF0F172A))
            )
        }
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFF0F172A))
                .padding(innerPadding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(items) { (title, content) ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                    border = BorderStroke(1.dp, Color(0xFF334155))
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(
                                modifier = Modifier
                                    .size(36.dp)
                                    .clip(CircleShape)
                                    .background(Color(0xFFFF7E40).copy(alpha = 0.2f)),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(Icons.Default.Campaign, null, tint = Color(0xFFFF7E40), modifier = Modifier.size(20.dp))
                            }
                            Spacer(modifier = Modifier.width(12.dp))
                            Text(title, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        }
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(content, color = Color.LightGray, fontSize = 13.sp, lineHeight = 18.sp)
                    }
                }
            }
        }
    }
}
