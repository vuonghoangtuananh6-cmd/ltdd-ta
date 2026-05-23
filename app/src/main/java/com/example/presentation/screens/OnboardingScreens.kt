package com.example.presentation.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.Hotel
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(onTimeout: () -> Unit) {
    var startAnimation by remember { mutableStateOf(false) }
    val scale by animateFloatAsState(
        targetValue = if (startAnimation) 1.2f else 0.8f,
        animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy, stiffness = Spring.StiffnessLow),
        label = "LogoScale"
    )

    LaunchedEffect(key1 = true) {
        startAnimation = true
        delay(2200)
        onTimeout()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFF0F172A), // Deep Slate
                        Color(0xFF1E293B),
                        Color(0xFF334155)
                    )
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Box(
                modifier = Modifier
                    .size(100.dp)
                    .clip(CircleShape)
                    .background(Color(0xFFF97316).copy(alpha = 0.2f))
                    .scale(scale),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Hotel,
                    contentDescription = "StayEase Logo Icon",
                    tint = Color(0xFFF97316), // Bright Orange accent
                    modifier = Modifier.size(60.dp)
                )
            }
            Spacer(modifier = Modifier.height(20.dp))
            Text(
                text = "StayEase",
                color = Color.White,
                fontSize = 36.sp,
                fontWeight = FontWeight.ExtraBold,
                letterSpacing = 2.sp
            )
            Text(
                text = "Luxury & Easy Room Booking",
                color = Color.LightGray.copy(alpha = 0.8f),
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                letterSpacing = 1.sp
            )
        }

        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 50.dp),
            contentAlignment = Alignment.Center
        ) {
            CircularProgressIndicator(
                color = Color(0xFFF97316),
                strokeWidth = 3.dp,
                modifier = Modifier.size(36.dp)
            )
        }
    }
}

@Composable
fun OnboardingScreen(onFinish: () -> Unit) {
    var currentPage by remember { mutableIntStateOf(0) }
    val pages = listOf(
        OnboardingPageData(
            title = "Tìm Khách Sạn Ưng Ý",
            desc = "Khám phá bộ sưu tập hàng nghìn khách sạn 5 sao sang trọng nhất tại Việt Nam với mức giá ưu đãi tốt nhất.",
            imageUrl = "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80"
        ),
        OnboardingPageData(
            title = "Ưu Đãi Đặc Biệt Mỗi Ngày",
            desc = "Nhập các mã khuyến mãi khủng lên tới 20% mỗi ngày, tích điểm thành viên nhận nhiều phần quà hấp dẫn.",
            imageUrl = "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80"
        ),
        OnboardingPageData(
            title = "Hỗ Trợ Nhanh Chóng 24/7",
            desc = "Đặt phòng chỉ với 3 bước chạm, thanh toán đa nền tảng linh hoạt, trò chuyện hỏi đáp trực tiếp cùng trợ lý AI thông minh.",
            imageUrl = "https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=800&q=80"
        )
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0F172A))
    ) {
        // Background Image with darkness scrim
        Image(
            painter = coil.compose.rememberAsyncImagePainter(model = pages[currentPage].imageUrl),
            contentDescription = "Onboarding background",
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Crop
        )

        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color.Transparent,
                            Color(0xFF0F172A).copy(alpha = 0.5f),
                            Color(0xFF0F172A)
                        )
                    )
                )
        )

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .align(Alignment.BottomCenter)
                .navigationBarsPadding()
                .padding(24.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center
            ) {
                pages.forEachIndexed { index, _ ->
                    Box(
                        modifier = Modifier
                            .padding(horizontal = 4.dp)
                            .size(width = if (currentPage == index) 24.dp else 8.dp, height = 8.dp)
                            .clip(RoundedCornerShape(4.dp))
                            .background(if (currentPage == index) Color(0xFFF97316) else Color.Gray)
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = pages[currentPage].title,
                color = Color.White,
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.fillMaxWidth(),
                textAlign = TextAlign.Start
            )

            Spacer(modifier = Modifier.height(12.dp))

            Text(
                text = pages[currentPage].desc,
                color = Color.LightGray,
                fontSize = 16.sp,
                fontWeight = FontWeight.Normal,
                lineHeight = 22.sp,
                modifier = Modifier.fillMaxWidth(),
                textAlign = TextAlign.Start
            )

            Spacer(modifier = Modifier.height(36.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Bỏ qua",
                    color = Color.Gray,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium,
                    modifier = Modifier
                        .clickable { onFinish() }
                        .testTag("skip_onboarding_btn")
                )

                Button(
                    onClick = {
                        if (currentPage < pages.size - 1) {
                            currentPage++
                        } else {
                            onFinish()
                        }
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316)),
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier
                        .height(50.dp)
                        .testTag("next_onboarding_btn")
                ) {
                    Text(
                        text = if (currentPage == pages.size - 1) "Bắt đầu ngay" else "Tiếp tục",
                        color = Color.White,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Icon(
                        imageVector = Icons.Default.ArrowForward,
                        contentDescription = "Next icon",
                        tint = Color.White
                    )
                }
            }
        }
    }
}

data class OnboardingPageData(
    val title: String,
    val desc: String,
    val imageUrl: String
)
