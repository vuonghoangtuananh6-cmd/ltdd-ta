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
    val isEn = currentUser.language == "EN"

    var showEditProfileDialog by remember { mutableStateOf(false) }
    var editName by remember { mutableStateOf(currentUser.name) }
    var editEmail by remember { mutableStateOf(currentUser.email) }
    var editPhone by remember { mutableStateOf(currentUser.phoneNumber) }

    var showAvatarEditDialog by remember { mutableStateOf(false) }
    var editAvatarUrl by remember { mutableStateOf(currentUser.avatarUrl) }

    val bgColor = if (isDark) Color(0xFF0F172A) else MaterialTheme.colorScheme.background
    val cardColor = if (isDark) Color(0xFF1E293B) else MaterialTheme.colorScheme.surface
    val primaryTextColor = if (isDark) Color.White else MaterialTheme.colorScheme.onBackground
    val secondaryTextColor = if (isDark) Color.LightGray else MaterialTheme.colorScheme.onSurfaceVariant
    val inputColor = if (isDark) Color.White else MaterialTheme.colorScheme.onSurface

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(if (isEn) "Member Account" else "Tài Khoản Thành Viên", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color.White) },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = if (isDark) Color(0xFF0F172A) else Color(0xFF1E293B))
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(bgColor)
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp)
        ) {
            // Member Avatar Badge Info Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(containerColor = cardColor),
                elevation = CardDefaults.cardElevation(6.dp)
            ) {
                Column(
                    modifier = Modifier.padding(20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .clickable {
                                editAvatarUrl = currentUser.avatarUrl
                                showAvatarEditDialog = true
                            }
                            .testTag("avatar_container")
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
                        Box(
                            modifier = Modifier
                                .align(Alignment.BottomEnd)
                                .size(24.dp)
                                .background(Color(0xFFF97316), CircleShape)
                                .border(1.5.dp, if (isDark) Color(0xFF1E293B) else Color.White, CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.Edit,
                                contentDescription = "Edit Avatar",
                                tint = Color.White,
                                modifier = Modifier.size(12.dp)
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    Text(currentUser.name, color = primaryTextColor, fontWeight = FontWeight.Black, fontSize = 20.sp)
                    Text(currentUser.email, color = Color.Gray, fontSize = 13.sp)

                    Spacer(modifier = Modifier.height(16.dp))

                    // Progress indicator for Loyalty Silver/Gold state tier
                    Column(modifier = Modifier.fillMaxWidth()) {
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                            Text(if (isEn) "Gold Loyalty Tier" else "Hạng vàng hoàng kim (Gold Tier)", color = Color(0xFFEAB308), fontSize = 11.sp, fontWeight = FontWeight.Bold)
                            Text("${currentUser.loyaltyPoints}/1000 Pts", color = secondaryTextColor, fontSize = 11.sp)
                        }
                        Spacer(modifier = Modifier.height(6.dp))
                        LinearProgressIndicator(
                            progress = { currentUser.loyaltyPoints / 1000f },
                            color = Color(0xFFEAB308),
                            trackColor = if (isDark) Color(0xFF334155) else Color(0xFFE2E8F0),
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
            Text(if (isEn) "Application Settings" else "Thiết Lập Ứng Dụng", color = primaryTextColor, fontWeight = FontWeight.Bold, fontSize = 14.sp)
            Spacer(modifier = Modifier.height(10.dp))

            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = cardColor)
            ) {
                Column {
                    // Update profile row
                    ProfileClickableRow(
                        Icons.Default.ManageAccounts,
                        if (isEn) "Edit Personal Information" else "Chỉnh sửa thông tin cá nhân",
                        textColor = primaryTextColor,
                        onClick = {
                            editName = currentUser.name
                            editEmail = currentUser.email
                            editPhone = currentUser.phoneNumber
                            showEditProfileDialog = true
                        }
                    )
                    Divider(color = if (isDark) Color(0xFF334155) else Color(0xFFE2E8F0))

                    // Admin panel row - Locked to Admin Accounts only
                    if (currentUser.role == "ADMIN") {
                        ProfileClickableRow(
                            Icons.Default.SupervisorAccount,
                            if (isEn) "Hệ thống quản trị (Admin Dashboard)" else "Hệ thống quản trị (Admin Dashboard)",
                            tint = Color(0xFF60A5FA),
                            textColor = primaryTextColor,
                            onClick = onNavigateToAdmin
                        )
                        Divider(color = if (isDark) Color(0xFF334155) else Color(0xFFE2E8F0))
                    }

                    // Change Password row
                    ProfileClickableRow(
                        Icons.Default.Lock,
                        if (isEn) "Change Account Password" else "Đổi mật khẩu tài khoản",
                        textColor = primaryTextColor,
                        onClick = onNavigateToChangePassword
                    )
                    Divider(color = if (isDark) Color(0xFF334155) else Color(0xFFE2E8F0))

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
                            Text(if (isEn) "Preferred Language" else "Ngôn ngữ ưa thích", color = primaryTextColor, fontSize = 14.sp)
                        }
                        Text(if (currentUser.language == "VI") "Tiếng Việt \uD83C\uDDFB\uD83C\uDDF3" else "English \uD83C\uDDFA\uD83C\uDDF8", color = Color(0xFFF97316), fontSize = 13.sp, fontWeight = FontWeight.Bold)
                    }

                    Divider(color = if (isDark) Color(0xFF334155) else Color(0xFFE2E8F0))

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
                            Text(if (isEn) "Dark Mode" else "Chế độ tối (Dark Mode)", color = primaryTextColor, fontSize = 14.sp)
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
                colors = CardDefaults.cardColors(containerColor = cardColor)
            ) {
                Column {
                    ProfileClickableRow(Icons.Default.Policy, if (isEn) "Terms of Service & Privacy" else "Điều khoản phục vụ & Bảo mật", textColor = primaryTextColor, onClick = {})
                    Divider(color = if (isDark) Color(0xFF334155) else Color(0xFFE2E8F0))
                    ProfileClickableRow(Icons.Default.HelpOutline, if (isEn) "StayEase Help Center Q&A" else "Trung tâm trợ giúp hỏi đáp StayEase", textColor = primaryTextColor, onClick = {})
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
                Text(if (isEn) "LOGOUT" else "ĐĂNG XUẤT", fontWeight = FontWeight.Bold, color = Color.White)
            }
        }

        // Edit Profile Modal Info Dialog
        if (showEditProfileDialog) {
            AlertDialog(
                onDismissRequest = { showEditProfileDialog = false },
                title = { Text(if (isEn) "Edit Profile" else "Chỉnh Sửa Hồ Sơ") },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        OutlinedTextField(
                            value = editName,
                            onValueChange = { editName = it },
                            label = { Text(if (isEn) "Full Name" else "Họ & Tên đầy đủ") }
                        )
                        OutlinedTextField(
                            value = editEmail,
                            onValueChange = { editEmail = it },
                            label = { Text(if (isEn) "Contact Email" else "Email liên lạc") }
                        )
                        OutlinedTextField(
                            value = editPhone,
                            onValueChange = { editPhone = it },
                            label = { Text(if (isEn) "Phone Number" else "Số điện thoại") }
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
                        Text(if (isEn) "Update" else "Cập nhật", color = Color.White)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showEditProfileDialog = false }) { Text(if (isEn) "Cancel" else "Hủy") }
                }
            )
        }

        // Edit Avatar Preset & URL Dialog
        if (showAvatarEditDialog) {
            val avatarPresets = listOf(
                Pair("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80", if (isEn) "Mountain" else "Leo núi"),
                Pair("https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80", if (isEn) "Beach" else "Đi biển"),
                Pair("https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80", if (isEn) "Resort" else "Thư giãn"),
                Pair("https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=150&q=80", if (isEn) "Metropolis" else "Cảnh phố"),
                Pair("https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80", if (isEn) "Elite" else "Đại gia")
            )

            AlertDialog(
                onDismissRequest = { showAvatarEditDialog = false },
                title = { Text(if (isEn) "Select Beautiful Avatar" else "Đổi Ảnh Đại Diện") },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text(if (isEn) "Choose from beautiful travel presets:" else "Hãy chọn một ảnh phong cách du lịch:", fontSize = 13.sp)

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .horizontalScroll(rememberScrollState()),
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            avatarPresets.forEach { (url, label) ->
                                Column(
                                    horizontalAlignment = Alignment.CenterHorizontally,
                                    modifier = Modifier
                                        .clickable { editAvatarUrl = url }
                                        .padding(4.dp)
                                ) {
                                    Image(
                                        painter = coil.compose.rememberAsyncImagePainter(model = url),
                                        contentDescription = label,
                                        modifier = Modifier
                                            .size(54.dp)
                                            .clip(CircleShape)
                                            .border(
                                                width = if (editAvatarUrl == url) 3.dp else 1.dp,
                                                color = if (editAvatarUrl == url) Color(0xFFF97316) else Color.LightGray,
                                                shape = CircleShape
                                            ),
                                        contentScale = ContentScale.Crop
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(label, fontSize = 10.sp, color = if (editAvatarUrl == url) Color(0xFFF97316) else Color.Gray)
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(10.dp))
                        Text(if (isEn) "Or enter custom image URL link:" else "Hoặc dán địa chỉ đường dẫn link ảnh riêng:", fontSize = 13.sp)
                        OutlinedTextField(
                            value = editAvatarUrl,
                            onValueChange = { editAvatarUrl = it },
                            label = { Text(if (isEn) "Custom URL link" else "Link liên kết ảnh") },
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                },
                confirmButton = {
                    Button(
                        onClick = {
                            if (editAvatarUrl.isNotEmpty()) {
                                viewModel.updateAvatarUrl(editAvatarUrl)
                                showAvatarEditDialog = false
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316))
                    ) {
                        Text(if (isEn) "Apply" else "Áp dụng", color = Color.White)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showAvatarEditDialog = false }) { Text(if (isEn) "Cancel" else "Hủy") }
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
    textColor: Color = Color.White,
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
            Text(label, color = textColor, fontSize = 14.sp)
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
