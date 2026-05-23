package com.example.presentation.screens

import androidx.compose.animation.*
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
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
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
import kotlinx.coroutines.flow.collect

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HotelDetailScreen(
    hotelId: String,
    viewModel: HotelViewModel,
    onNavigateToCheckout: () -> Unit,
    onBack: () -> Unit
) {
    val hotel = viewModel.getHotelById(hotelId)
    if (hotel == null) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("Không tìm thấy thông tin khách sạn", color = Color.White)
        }
        return
    }

    val rooms by viewModel.getRoomsForHotel(hotelId).collectAsState(initial = emptyList())
    val reviews by viewModel.getReviewsForHotel(hotelId).collectAsState(initial = emptyList())
    val wishlistSet by viewModel.repository.wishlist.collectAsState()
    val isFavorited = wishlistSet.contains(hotelId)

    val scrollState = rememberScrollState()

    // Add review states
    var isWritingReview by remember { mutableStateOf(false) }
    var reviewRating by remember { mutableFloatStateOf(5f) }
    var reviewComment by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(hotel.name, fontSize = 16.sp, fontWeight = FontWeight.Bold, maxLines = 1, overflow = TextOverflow.Ellipsis) },
                navigationIcon = {
                    IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, "Back", tint = Color.White) }
                },
                actions = {
                    IconButton(onClick = { viewModel.toggleWishlist(hotelId) }) {
                        Icon(
                            imageVector = if (isFavorited) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                            contentDescription = "Favorite",
                            tint = if (isFavorited) Color.Red else Color.White
                        )
                    }
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
                .verticalScroll(scrollState)
        ) {
            // Immersive Photo Carousel Slider
            LazyRow(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(220.dp),
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                items(hotel.imageUrls) { url ->
                    Image(
                        painter = coil.compose.rememberAsyncImagePainter(model = url),
                        contentDescription = hotel.name,
                        modifier = Modifier
                            .fillParentMaxWidth()
                            .fillMaxHeight(),
                        contentScale = ContentScale.Crop
                    )
                }
            }

            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                // Stars & Name Block
                Row(verticalAlignment = Alignment.CenterVertically) {
                    repeat(hotel.stars) {
                        Icon(Icons.Default.Star, null, tint = Color(0xFFEAB308), modifier = Modifier.size(16.dp))
                    }
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        "${hotel.stars} Sao Luxury",
                        color = Color(0xFFEAB308),
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = hotel.name,
                    color = Color.White,
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold
                )

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(top = 4.dp)
                ) {
                    Icon(Icons.Default.LocationOn, null, tint = Color.Gray, modifier = Modifier.size(14.dp))
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(hotel.address, color = Color.LightGray, fontSize = 12.sp)
                }

                Divider(color = Color(0xFF334155), modifier = Modifier.padding(vertical = 16.dp))

                // Score overview bar
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color(0xFF1E293B))
                        .padding(12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(40.dp)
                                .clip(RoundedCornerShape(8.dp))
                                .background(Color(0xFF22C55E)),
                            contentAlignment = Alignment.Center
                        ) {
                            Text("${hotel.rating}", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                        }
                        Spacer(modifier = Modifier.width(12.dp))
                        Column {
                            Text(
                                text = if (hotel.rating >= 9.0) "Tuyệt hảo" else "Rất tốt",
                                color = Color.White,
                                fontWeight = FontWeight.Bold,
                                fontSize = 14.sp
                            )
                            Text("${reviews.size + 15} đánh giá từ hành khách", color = Color.Gray, fontSize = 11.sp)
                        }
                    }

                    Row {
                        Icon(Icons.Default.ArrowForward, null, tint = Color.Gray)
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Description Block
                Text("Về khách sạn này", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = hotel.description,
                    color = Color.LightGray,
                    fontSize = 14.sp,
                    lineHeight = 20.sp
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Amenities Flow
                Text("Tiện nghi nổi bật", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Spacer(modifier = Modifier.height(8.dp))
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    items(hotel.amenities) { amenity ->
                        val icon = when (amenity) {
                            "Wifi" -> Icons.Default.Wifi
                            "Pool" -> Icons.Default.Pool
                            "Gym" -> Icons.Default.FitnessCenter
                            "Breakfast" -> Icons.Default.FreeBreakfast
                            "Parking" -> Icons.Default.LocalParking
                            "Spa" -> Icons.Default.Spa
                            else -> Icons.Default.Hotel
                        }
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(8.dp))
                                .background(Color(0xFF1E293B))
                                .padding(horizontal = 12.dp, vertical = 6.dp)
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(icon, null, tint = Color(0xFFF97316), modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(amenity, color = Color.White, fontSize = 12.sp)
                            }
                        }
                    }
                }

                Divider(color = Color(0xFF334155), modifier = Modifier.padding(vertical = 16.dp))

                // --- Google Maps Custom Canvas Vector Block ---
                Text("Bản đồ / Vị trí địa lý", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Spacer(modifier = Modifier.height(8.dp))
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(150.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .background(Color(0xFF243B55))
                ) {
                    // Custom Draw beautiful native Canvas stylized streets map mockup!
                    Canvas(modifier = Modifier.fillMaxSize()) {
                        val canvasW = size.width
                        val canvasH = size.height

                        // Draw background beige grass streets
                        val paintBg = Color(0xFF1E293B)
                        val paintStreet = Color(0xFF334155)

                        // Draw Grid streets lines
                        drawLine(color = paintStreet, start = androidx.compose.ui.geometry.Offset(0f, canvasH * 0.3f), end = androidx.compose.ui.geometry.Offset(canvasW, canvasH * 0.3f), strokeWidth = 12f)
                        drawLine(color = paintStreet, start = androidx.compose.ui.geometry.Offset(0f, canvasH * 0.7f), end = androidx.compose.ui.geometry.Offset(canvasW, canvasH * 0.7f), strokeWidth = 14f)
                        drawLine(color = paintStreet, start = androidx.compose.ui.geometry.Offset(canvasW * 0.4f, 0f), end = androidx.compose.ui.geometry.Offset(canvasW * 0.4f, canvasH), strokeWidth = 16f)

                        // Draw diagonal trail rivers paths
                        val riverPath = Path().apply {
                            moveTo(0f, canvasH)
                            cubicTo(canvasW * 0.2f, canvasH * 0.8f, canvasW * 0.6f, canvasH * 0.2f, canvasW, 0f)
                        }
                        drawPath(riverPath, color = Color(0xFF2563EB).copy(alpha = 0.3f), style = Stroke(width = 20f))

                        // Draw center pin radar ripple
                        drawCircle(color = Color(0xFFF97316).copy(alpha = 0.25f), radius = 40f, center = androidx.compose.ui.geometry.Offset(canvasW * 0.4f, canvasH * 0.3f))
                        drawCircle(color = Color(0xFFF97316), radius = 10f, center = androidx.compose.ui.geometry.Offset(canvasW * 0.4f, canvasH * 0.3f))
                    }

                    // Floating description indicator on map
                    Box(
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .padding(8.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .background(Color.Black.copy(alpha = 0.7f))
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text(
                            "Vị độ: ${hotel.latitude} | Kinh độ: ${hotel.longitude}",
                            color = Color.LightGray,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }

                Divider(color = Color(0xFF334155), modifier = Modifier.padding(vertical = 16.dp))

                // --- Room List Selections ---
                Text("Chọn Loại Phòng", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                Spacer(modifier = Modifier.height(12.dp))

                rooms.forEach { room ->
                    RoomItemCard(room, onRoomSelect = {
                        viewModel.selectedHotelForBooking.value = hotel
                        viewModel.selectedRoomForBooking.value = room
                        onNavigateToCheckout()
                    })
                }

                Divider(color = Color(0xFF334155), modifier = Modifier.padding(vertical = 16.dp))

                // --- Ratings & Reviews Block ---
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Đánh giá từ du khách", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    TextButton(onClick = { isWritingReview = !isWritingReview }) {
                        Text(if (isWritingReview) "Hủy bỏ" else "Viết đánh giá \u270D", color = Color(0xFFF97316))
                    }
                }

                // Interactive Review Composer
                AnimatedVisibility(visible = isWritingReview) {
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 8.dp),
                        shape = RoundedCornerShape(12.dp),
                        colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                        border = BorderStroke(1.dp, Color(0xFF475569))
                    ) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Text("Viết trải nghiệm của bạn", color = Color.White, fontWeight = FontWeight.Bold)
                            Spacer(modifier = Modifier.height(8.dp))

                            // Interactive Star selection
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text("Số sao: ", color = Color.LightGray, fontSize = 13.sp)
                                repeat(5) { i ->
                                    val checked = i < reviewRating.toInt()
                                    Icon(
                                        imageVector = if (checked) Icons.Default.Star else Icons.Default.StarBorder,
                                        contentDescription = null,
                                        tint = Color(0xFFEAB308),
                                        modifier = Modifier
                                            .size(24.dp)
                                            .clickable { reviewRating = (i + 1).toFloat() }
                                    )
                                }
                            }

                            Spacer(modifier = Modifier.height(12.dp))

                            OutlinedTextField(
                                value = reviewComment,
                                onValueChange = { reviewComment = it },
                                placeholder = { Text("Mô tả dịch vụ nhà hàng, giường ngủ, hồ bơi...") },
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedBorderColor = Color(0xFFF97316),
                                    unfocusedBorderColor = Color(0xFF475569),
                                    focusedTextColor = Color.White,
                                    unfocusedTextColor = Color.White
                                ),
                                modifier = Modifier.fillMaxWidth()
                            )

                            Spacer(modifier = Modifier.height(12.dp))

                            Button(
                                onClick = {
                                    if (reviewComment.isNotEmpty()) {
                                        viewModel.addReview(hotelId, reviewRating, reviewComment)
                                        reviewComment = ""
                                        isWritingReview = false
                                    }
                                },
                                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316)),
                                modifier = Modifier.align(Alignment.End)
                            ) {
                                Text("Gửi đánh giá", color = Color.White)
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))

                // Reviews List
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    reviews.forEach { review ->
                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(12.dp),
                            colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B).copy(alpha = 0.6f))
                        ) {
                            Column(modifier = Modifier.padding(12.dp)) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Image(
                                            painter = coil.compose.rememberAsyncImagePainter(model = review.userAvatar),
                                            contentDescription = review.userName,
                                            modifier = Modifier
                                                .size(32.dp)
                                                .clip(CircleShape),
                                            contentScale = ContentScale.Crop
                                        )
                                        Spacer(modifier = Modifier.width(8.dp))
                                        Column {
                                            Text(review.userName, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                            Text(review.date, color = Color.Gray, fontSize = 10.sp)
                                        }
                                    }

                                    Row {
                                        repeat(review.rating.toInt()) {
                                            Icon(Icons.Default.Star, null, tint = Color(0xFFEAB308), modifier = Modifier.size(11.dp))
                                        }
                                    }
                                }

                                Spacer(modifier = Modifier.height(8.dp))
                                Text(review.comment, color = Color.LightGray, fontSize = 13.sp, lineHeight = 18.sp)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun RoomItemCard(room: RoomModel, onRoomSelect: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp)
            .shadow(4.dp, RoundedCornerShape(16.dp)),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
        border = BorderStroke(1.dp, Color(0xFF334155))
    ) {
        Column {
            Image(
                painter = coil.compose.rememberAsyncImagePainter(model = room.imageUrls.firstOrNull()),
                contentDescription = room.name,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(120.dp),
                contentScale = ContentScale.Crop
            )

            Column(modifier = Modifier.padding(16.dp)) {
                Text(room.name, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Spacer(modifier = Modifier.height(4.dp))
                Text(room.description, color = Color.LightGray, fontSize = 12.sp, maxLines = 2, overflow = TextOverflow.Ellipsis)

                Spacer(modifier = Modifier.height(12.dp))

                // Specifications
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.KingBed, null, tint = Color.Gray, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(room.bedType, color = Color.Gray, fontSize = 11.sp)
                    }

                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.SquareFoot, null, tint = Color.Gray, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("${room.sizeSqm} m²", color = Color.Gray, fontSize = 11.sp)
                    }

                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Group, null, tint = Color.Gray, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("${room.maxGuests} Khách tối đa", color = Color.Gray, fontSize = 11.sp)
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))

                Divider(color = Color(0xFF334155))

                Spacer(modifier = Modifier.height(12.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text("Còn lại ${room.totalAvailable} phòng!", color = Color(0xFF22C55E), fontSize = 11.sp, fontWeight = FontWeight.Bold)
                        Row(verticalAlignment = Alignment.Bottom) {
                            Text(room.price.formatPrice(), color = Color(0xFFFF7E40), fontSize = 22.sp, fontWeight = FontWeight.Black)
                            Text("/đêm", color = Color.Gray, fontSize = 12.sp, modifier = Modifier.padding(bottom = 2.dp))
                        }
                    }

                    Button(
                        onClick = onRoomSelect,
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316)),
                        shape = RoundedCornerShape(10.dp),
                        modifier = Modifier
                            .height(42.dp)
                            .testTag("book_room_button_${room.id}")
                    ) {
                        Text("ĐẶT PHÒNG", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    }
                }
            }
        }
    }
}
