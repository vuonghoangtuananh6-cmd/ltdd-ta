package com.example.presentation.screens

import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.QrCode
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.BookingModel
import com.example.data.model.BookingStatus
import com.example.data.model.formatPrice
import com.example.presentation.viewmodel.HotelViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CheckoutScreen(
    viewModel: HotelViewModel,
    onNavigateToSuccess: (String) -> Unit,
    onBack: () -> Unit
) {
    val hotel = viewModel.selectedHotelForBooking.collectAsState().value
    val room = viewModel.selectedRoomForBooking.collectAsState().value
    val currentUser by viewModel.currentUser.collectAsState()

    if (hotel == null || room == null) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("Không có thông tin giao dịch", color = Color.White)
        }
        return
    }

    val nights by viewModel.nightsCount.collectAsState()
    val guests by viewModel.guestsCount.collectAsState()
    val coupons by viewModel.coupons.collectAsState()

    // Form states
    var name by remember { mutableStateOf(currentUser.name) }
    var email by remember { mutableStateOf(currentUser.email) }
    var phone by remember { mutableStateOf(currentUser.phoneNumber) }
    var selectedPayment by remember { mutableStateOf("Momo") }
    var couponCode by remember { mutableStateOf("") }
    var appliedCouponResult by remember { mutableStateOf<String?>(null) }
    var messagePromoError by remember { mutableStateOf("") }

    val subtotal = room.price * nights
    val discount = if (appliedCouponResult != null) viewModel.applyCoupon(appliedCouponResult!!, subtotal) else 0.0
    val tax = subtotal * 0.10
    val service = subtotal * 0.05
    val total = subtotal + tax + service - discount

    var isBookingNow by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Xác nhận Đặt phòng", fontSize = 16.sp, fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, "Back", tint = Color.White) }
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
                .verticalScroll(rememberScrollState())
                .padding(16.dp)
        ) {
            // Selected Hotel Summary Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B))
            ) {
                Row(modifier = Modifier.padding(12.dp)) {
                    Image(
                        painter = coil.compose.rememberAsyncImagePainter(model = hotel.imageUrls.firstOrNull()),
                        contentDescription = hotel.name,
                        modifier = Modifier
                            .size(75.dp)
                            .clip(RoundedCornerShape(8.dp)),
                        contentScale = ContentScale.Crop
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text(hotel.name, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
                        Text(room.name, color = Color.LightGray, fontSize = 12.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
                        Text(
                            "$nights đêm | $guests khách | ${room.bedType}",
                            color = Color.Gray,
                            fontSize = 11.sp,
                            modifier = Modifier.padding(top = 2.dp)
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Guest Details Form Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                border = BorderStroke(1.dp, Color(0xFF334155))
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Thông Tin Khách Lưu Trú", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    Spacer(modifier = Modifier.height(12.dp))

                    OutlinedTextField(
                        value = name,
                        onValueChange = { name = it },
                        label = { Text("Họ & Tên liên hệ", color = Color.Gray) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedBorderColor = Color(0xFFF97316),
                            unfocusedBorderColor = Color(0xFF475569)
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("checkout_name"),
                        singleLine = true
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    OutlinedTextField(
                        value = email,
                        onValueChange = { email = it },
                        label = { Text("Email nhận hóa đơn", color = Color.Gray) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedBorderColor = Color(0xFFF97316),
                            unfocusedBorderColor = Color(0xFF475569)
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("checkout_email"),
                        singleLine = true
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    OutlinedTextField(
                        value = phone,
                        onValueChange = { phone = it },
                        label = { Text("Số điện thoại liên lạc", color = Color.Gray) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedBorderColor = Color(0xFFF97316),
                            unfocusedBorderColor = Color(0xFF475569)
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("checkout_phone"),
                        singleLine = true
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Coupons Promotion apply Coupon code
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B))
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Mã Giảm Giá Ưu Đãi (Coupon)", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    Spacer(modifier = Modifier.height(10.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        OutlinedTextField(
                            value = couponCode,
                            onValueChange = { couponCode = it; messagePromoError = "" },
                            placeholder = { Text("Nhập ví dụ: STAYEASE50") },
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedTextColor = Color.White,
                                unfocusedTextColor = Color.White,
                                focusedBorderColor = Color(0xFFF97316),
                                unfocusedBorderColor = Color(0xFF475569)
                            ),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier.weight(1f),
                            singleLine = true
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Button(
                            onClick = {
                                val match = coupons.firstOrNull { it.code.equals(couponCode, ignoreCase = true) }
                                if (match != null) {
                                    if (subtotal >= match.minSpend) {
                                        appliedCouponResult = match.code
                                        messagePromoError = "Áp dụng thành công! Đã giảm -${viewModel.applyCoupon(match.code, subtotal).formatPrice()}"
                                    } else {
                                        messagePromoError = "Đơn tủ tối thiểu phải đạt ${match.minSpend.formatPrice()}"
                                    }
                                } else {
                                    messagePromoError = "Mã giảm giá không hợp lệ"
                                }
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316)),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier.height(48.dp)
                        ) {
                            Text("Áp Dụng")
                        }
                    }

                    if (messagePromoError.isNotEmpty()) {
                        Text(
                            text = messagePromoError,
                            color = if (appliedCouponResult != null) Color(0xFF22C55E) else Color.Red,
                            fontSize = 12.sp,
                            modifier = Modifier.padding(top = 6.dp)
                        )
                    }

                    // Predefined popular coupons click helper to quickly test
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = 10.dp)
                    ) {
                        coupons.forEach { coupon ->
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(Color(0xFFF97316).copy(alpha = 0.15f))
                                    .border(1.dp, Color(0xFFF97316).copy(alpha = 0.4f), RoundedCornerShape(6.dp))
                                    .clickable { couponCode = coupon.code }
                                    .padding(horizontal = 6.dp, vertical = 3.dp)
                            ) {
                                Text(coupon.code, color = Color(0xFFF97316), fontSize = 10.sp, fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Payment Methods Selection Cards
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                border = BorderStroke(1.dp, Color(0xFF334155))
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Phương Thức Thanh Toán", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    Spacer(modifier = Modifier.height(12.dp))

                    listOf(
                        Pair("Momo", "Ví MoMo lướt thanh toán siêu rẻ"),
                        Pair("ZaloPay", "Khuyến mại hoàn tiền ZaloPay"),
                        Pair("VNPay", "Cổng VNPay quét mã QR Ngân Hàng"),
                        Pair("Credit Card", "Thẻ tín dụng Visa / MasterCard / JCB"),
                        Pair("COD", "Thanh toán trực tiếp tại quầy tiếp đón")
                    ).forEach { (method, desc) ->
                        val isSelected = selectedPayment == method
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp)
                                .clip(RoundedCornerShape(10.dp))
                                .background(if (isSelected) Color(0xFF0F172A) else Color.Transparent)
                                .border(1.dp, if (isSelected) Color(0xFFF97316) else Color.Transparent, RoundedCornerShape(10.dp))
                                .clickable { selectedPayment = method }
                                .padding(12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            RadioButton(
                                selected = isSelected,
                                onClick = { selectedPayment = method },
                                colors = RadioButtonDefaults.colors(selectedColor = Color(0xFFF97316))
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Column {
                                Text(method, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                Text(desc, color = Color.Gray, fontSize = 11.sp)
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Comprehensive Price Invoice breakdown card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B))
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Chi Tiết Hóa Đơn", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    Spacer(modifier = Modifier.height(12.dp))

                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Mức giá gốc $nights đêm", color = Color.LightGray, fontSize = 13.sp)
                        Text(subtotal.formatPrice(), color = Color.White, fontSize = 13.sp)
                    }
                    Spacer(modifier = Modifier.height(6.dp))
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Thuế VAT (10%)", color = Color.LightGray, fontSize = 13.sp)
                        Text(tax.formatPrice(), color = Color.White, fontSize = 13.sp)
                    }
                    Spacer(modifier = Modifier.height(6.dp))
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Phí phục vụ & bảo an (5%)", color = Color.LightGray, fontSize = 13.sp)
                        Text(service.formatPrice(), color = Color.White, fontSize = 13.sp)
                    }

                    if (discount > 0.0) {
                        Spacer(modifier = Modifier.height(6.dp))
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                            Text("Khuyến trừ ưu đãi", color = Color(0xFF22C55E), fontSize = 13.sp)
                            Text("-${discount.formatPrice()}", color = Color(0xFF22C55E), fontSize = 13.sp, fontWeight = FontWeight.Bold)
                        }
                    }

                    Divider(color = Color(0xFF334155), modifier = Modifier.padding(vertical = 12.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("TỔNG TIỀN THANH TOÁN", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Text(total.formatPrice(), color = Color(0xFFFF7E40), fontSize = 20.sp, fontWeight = FontWeight.Black)
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Action confirm button
            Button(
                onClick = {
                    if (name.isEmpty() || email.isEmpty() || phone.isEmpty()) {
                        messagePromoError = "Vui lòng hoàn thiện đúng thông tin khách liên lạc"
                    } else {
                        isBookingNow = true
                        val bResult = viewModel.createBooking(
                            hotel = hotel,
                            room = room,
                            guestName = name,
                            guestEmail = email,
                            guestPhone = phone,
                            paymentMethod = selectedPayment,
                            couponCode = appliedCouponResult
                        )
                        onNavigateToSuccess(bResult.id)
                    }
                },
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316)),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp)
                    .testTag("checkout_confirm_booking_btn")
            ) {
                if (isBookingNow) {
                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                } else {
                    Text("XÁC NHẬN ĐẶT PHÒNG", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
                }
            }
        }
    }
}

// -------------------------------------------------------------
// BOOKING SUCCESS TICKET WATERMARK SCREEN
// -------------------------------------------------------------

@Composable
fun BookingSuccessScreen(
    bookingId: String,
    viewModel: HotelViewModel,
    onNavigateBackHome: () -> Unit
) {
    val bList by viewModel.bookings.collectAsState()
    val booking = bList.firstOrNull { it.id == bookingId }

    if (booking == null) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("Không tìm thấy biên lai hóa đơn", color = Color.White)
        }
        return
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0F172A))
            .statusBarsPadding()
            .navigationBarsPadding(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth(0.9f)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Success animation visual representation icon
            Box(
                modifier = Modifier
                    .size(70.dp)
                    .clip(CircleShape)
                    .background(Color(0xFF22C55E).copy(alpha = 0.2f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.CheckCircle,
                    contentDescription = "Success tick",
                    tint = Color(0xFF22C55E),
                    modifier = Modifier.size(50.dp)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            Text("Thanh Toán & Đặt Phòng Thành Công!", color = Color.White, fontSize = 18.sp, fontWeight = FontWeight.Black, textAlign = TextAlign.Center)
            Text("StayEase đã gửi email xác minh và mã QR tới: ${booking.guestEmail}", color = Color.Gray, fontSize = 12.sp, textAlign = TextAlign.Center, modifier = Modifier.padding(top = 4.dp))

            Spacer(modifier = Modifier.height(24.dp))

            // Premium Visual Receipt Ticket Layout
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                elevation = CardDefaults.cardElevation(8.dp)
            ) {
                Column(modifier = Modifier.padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("VÉ SỬ DỤNG PHÒNG", color = Color.Gray, fontSize = 12.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(booking.hotelName, color = Color.White, fontWeight = FontWeight.ExtraBold, fontSize = 16.sp, textAlign = TextAlign.Center)
                    Text(booking.roomName, color = Color.LightGray, fontSize = 12.sp)

                    Divider(color = Color(0xFF334155), modifier = Modifier.padding(vertical = 12.dp))

                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Column {
                            Text("MÃ ĐẶT", color = Color.Gray, fontSize = 10.sp)
                            Text(booking.id, color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                        }
                        Column(horizontalAlignment = Alignment.End) {
                            Text("HÀNH KHÁCH", color = Color.Gray, fontSize = 10.sp)
                            Text(booking.guestName, color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Column {
                            Text("CHECK-IN / NHẬN", color = Color.Gray, fontSize = 10.sp)
                            Text(booking.checkInDate, color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                        }
                        Column(horizontalAlignment = Alignment.End) {
                            Text("CHECK-OUT / TRẢ", color = Color.Gray, fontSize = 10.sp)
                            Text(booking.checkOutDate, color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                        }
                    }

                    Divider(color = Color(0xFF334155), modifier = Modifier.padding(vertical = 12.dp))

                    // QR ticket code generator native vector rendering mock
                    Box(
                        modifier = Modifier
                            .size(140.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .background(Color.White)
                            .padding(8.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        // Drawing static mock QR paths representing scanner code
                        Canvas(modifier = Modifier.fillMaxSize()) {
                            val w = size.width
                            val h = size.height

                            // Draw 3 corner anchors squares
                            val anchorSize = w * 0.25f
                            val paintBlack = Color.Black

                            // Top Left
                            drawRect(paintBlack, topLeft = androidx.compose.ui.geometry.Offset(0f, 0f), size = androidx.compose.ui.geometry.Size(anchorSize, anchorSize))
                            drawRect(Color.White, topLeft = androidx.compose.ui.geometry.Offset(4f, 4f), size = androidx.compose.ui.geometry.Size(anchorSize - 8f, anchorSize - 8f))
                            drawRect(paintBlack, topLeft = androidx.compose.ui.geometry.Offset(8f, 8f), size = androidx.compose.ui.geometry.Size(anchorSize - 16f, anchorSize - 16f))

                            // Top Right
                            drawRect(paintBlack, topLeft = androidx.compose.ui.geometry.Offset(w - anchorSize, 0f), size = androidx.compose.ui.geometry.Size(anchorSize, anchorSize))
                            drawRect(Color.White, topLeft = androidx.compose.ui.geometry.Offset(w - anchorSize + 4f, 4f), size = androidx.compose.ui.geometry.Size(anchorSize - 8f, anchorSize - 8f))
                            drawRect(paintBlack, topLeft = androidx.compose.ui.geometry.Offset(w - anchorSize + 8f, 8f), size = androidx.compose.ui.geometry.Size(anchorSize - 16f, anchorSize - 16f))

                            // Bottom Left
                            drawRect(paintBlack, topLeft = androidx.compose.ui.geometry.Offset(0f, h - anchorSize), size = androidx.compose.ui.geometry.Size(anchorSize, anchorSize))
                            drawRect(Color.White, topLeft = androidx.compose.ui.geometry.Offset(4f, h - anchorSize + 4f), size = androidx.compose.ui.geometry.Size(anchorSize - 8f, anchorSize - 8f))
                            drawRect(paintBlack, topLeft = androidx.compose.ui.geometry.Offset(8f, h - anchorSize + 8f), size = androidx.compose.ui.geometry.Size(anchorSize - 16f, anchorSize - 16f))

                            // Random code lines simulated
                            val strokeQ = 6f
                            drawLine(paintBlack, androidx.compose.ui.geometry.Offset(w * 0.5f, h * 0.1f), androidx.compose.ui.geometry.Offset(w * 0.5f, h * 0.9f), strokeWidth = strokeQ)
                            drawLine(paintBlack, androidx.compose.ui.geometry.Offset(w * 0.4f, h * 0.5f), androidx.compose.ui.geometry.Offset(w * 0.8f, h * 0.5f), strokeWidth = strokeQ)
                            drawLine(paintBlack, androidx.compose.ui.geometry.Offset(w * 0.7f, h * 0.2f), androidx.compose.ui.geometry.Offset(w * 0.7f, h * 0.8f), strokeWidth = strokeQ)
                        }
                    }

                    Spacer(modifier = Modifier.height(10.dp))
                    Text(booking.qrCode, color = Color.Gray, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }
            }

            Spacer(modifier = Modifier.height(30.dp))

            Button(
                onClick = onNavigateBackHome,
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316)),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp)
            ) {
                Text("QUAY LẠI TRANG CHỦ", fontWeight = FontWeight.Bold, color = Color.White)
            }
        }
    }
}

// -------------------------------------------------------------
// HISTORIC BOOKING LISTINGS HISTORY SCREEN
// -------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookingHistoryScreen(
    viewModel: HotelViewModel,
    onNavigateToDetail: (String) -> Unit
) {
    val bList by viewModel.bookings.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Quản Lý Sổ Đặt Phòng", fontSize = 18.sp, fontWeight = FontWeight.Bold) },
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
            if (bList.isEmpty()) {
                Column(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Icon(Icons.Default.History, null, tint = Color.Gray, modifier = Modifier.size(50.dp))
                    Spacer(modifier = Modifier.height(12.dp))
                    Text("Sổ lịch sử trống trơn", color = Color.White)
                }
            } else {
                LazyColumn(
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                    modifier = Modifier.fillMaxSize()
                ) {
                    items(bList) { booking ->
                        BookingTicketItem(booking, onCancel = {
                            viewModel.cancelBooking(booking.id)
                        }, onReBook = {
                            onNavigateToDetail(booking.hotelId)
                        })
                    }
                }
            }
        }
    }
}

@Composable
fun BookingTicketItem(
    booking: BookingModel,
    onCancel: () -> Unit,
    onReBook: () -> Unit
) {
    val statusColor = when (booking.status) {
        BookingStatus.CONFIRMED -> Color(0xFF22C55E)
        BookingStatus.COMPLETED -> Color(0xFF3B82F6)
        BookingStatus.CANCELLED -> Color.Red
        BookingStatus.PENDING -> Color(0xFFEAB308)
    }

    val statusLabel = when (booking.status) {
        BookingStatus.CONFIRMED -> "ĐÃ XÁC NHẬN"
        BookingStatus.COMPLETED -> "ĐÃ HOÀN THÀNH"
        BookingStatus.CANCELLED -> "ĐÃ HỦY PHÒNG"
        BookingStatus.PENDING -> "ĐANG KHẢO SÁT"
    }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
        border = BorderStroke(1.dp, Color(0xFF334155))
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "MÃ: ${booking.id}",
                    color = Color.White,
                    fontWeight = FontWeight.ExtraBold,
                    fontSize = 13.sp
                )

                // High contrast status Pill
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .background(statusColor.copy(alpha = 0.2f))
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                ) {
                    Text(statusLabel, color = statusColor, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            Row {
                Image(
                    painter = coil.compose.rememberAsyncImagePainter(model = booking.hotelImage),
                    contentDescription = booking.hotelName,
                    modifier = Modifier
                        .size(60.dp)
                        .clip(RoundedCornerShape(8.dp)),
                    contentScale = ContentScale.Crop
                )

                Spacer(modifier = Modifier.width(12.dp))

                Column {
                    Text(booking.hotelName, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    Text(booking.roomName, color = Color.LightGray, fontSize = 12.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    Text(
                        "${booking.checkInDate} ~ ${booking.checkOutDate} (${booking.nights} đêm)",
                        color = Color.Gray,
                        fontSize = 11.sp,
                        modifier = Modifier.padding(top = 2.dp)
                    )
                }
            }

            Divider(color = Color(0xFF334155), modifier = Modifier.padding(vertical = 12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text("Tổng thanh toán", color = Color.Gray, fontSize = 11.sp)
                    Text(booking.totalAmount.formatPrice(), color = Color(0xFFFF7E40), fontSize = 16.sp, fontWeight = FontWeight.Bold)
                }

                Row {
                    if (booking.status == BookingStatus.CONFIRMED) {
                        OutlinedButton(
                            onClick = onCancel,
                            colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.Red),
                            border = BorderStroke(1.dp, Color.Red),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier.height(36.dp)
                        ) {
                            Text("Hủy Phòng", fontSize = 12.sp, fontWeight = FontWeight.Bold)
                        }
                    } else {
                        Button(
                            onClick = onReBook,
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF1E293B)),
                            border = BorderStroke(1.dp, Color(0xFFF97316)),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier.height(36.dp)
                        ) {
                            Text("Xem Lại", color = Color(0xFFF97316), fontSize = 12.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }
            }
        }
    }
}
