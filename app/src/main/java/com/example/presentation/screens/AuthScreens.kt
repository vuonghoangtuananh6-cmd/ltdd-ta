package com.example.presentation.screens

import androidx.compose.animation.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.presentation.viewmodel.HotelViewModel
import com.example.presentation.viewmodel.AuthResult
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LoginScreen(
    viewModel: HotelViewModel,
    onLoginSuccess: () -> Unit,
    onNavigateToRegister: () -> Unit,
    onNavigateToForgotPassword: () -> Unit,
    onVerifyEmailNeeded: (String) -> Unit
) {
    var email by rememberSaveable { mutableStateOf("vuonghoangtuananh6@gmail.com") }
    var password by rememberSaveable { mutableStateOf("123456") }
    var passwordVisible by rememberSaveable { mutableStateOf(false) }
    var rememberMe by rememberSaveable { mutableStateOf(true) }
    
    var errorMessage by remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }
    var showGoogleBottomSheet by remember { mutableStateOf(false) }
    
    val scrollState = rememberScrollState()
    val scope = rememberCoroutineScope()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0F172A))
    ) {
        // Upper aesthetic banner image
        Image(
            painter = coil.compose.rememberAsyncImagePainter(
                model = "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80"
            ),
            contentDescription = "Background",
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.38f),
            contentScale = ContentScale.Crop,
            alpha = 0.45f
        )

        // Gradient overlay
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color(0xFF0F172A).copy(alpha = 0.3f),
                            Color(0xFF0F172A).copy(alpha = 0.92f),
                            Color(0xFF0F172A)
                        ),
                        startY = 0.0f,
                        endY = 750.0f
                    )
                )
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
                .padding(24.dp)
                .verticalScroll(scrollState),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Spacer(modifier = Modifier.height(28.dp))

            // StayEase Header Brand
            Text(
                text = "StayEase",
                fontSize = 36.sp,
                fontWeight = FontWeight.Black,
                color = Color.White,
                letterSpacing = 1.sp
            )

            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(6.dp)
                        .background(Color(0xFFF97316), CircleShape)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = "Agoda Premium Partner System",
                    fontSize = 13.sp,
                    color = Color(0xFF94A3B8),
                    fontWeight = FontWeight.Medium
                )
                Spacer(modifier = Modifier.width(6.dp))
                Box(
                    modifier = Modifier
                        .size(6.dp)
                        .background(Color(0xFFF97316), CircleShape)
                )
            }

            Spacer(modifier = Modifier.height(32.dp))

            // Main Glassmorphism Form Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                border = BorderStroke(1.dp, Color(0xFF334155)),
                elevation = CardDefaults.cardElevation(defaultElevation = 10.dp)
            ) {
                Column(
                    modifier = Modifier.padding(24.dp)
                ) {
                    Text(
                        text = "ĐĂNG NHẬP",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.ExtraBold,
                        color = Color.White,
                        modifier = Modifier.padding(bottom = 20.dp)
                    )

                    // Error Box
                    AnimatedVisibility(
                        visible = errorMessage.isNotEmpty(),
                        enter = fadeIn() + expandVertically(),
                        exit = fadeOut() + shrinkVertically()
                    ) {
                        Card(
                            colors = CardDefaults.cardColors(containerColor = Color(0xFF7F1D1D)),
                            border = BorderStroke(1.dp, Color(0xFFF87171)),
                            shape = RoundedCornerShape(12.dp),
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(bottom = 16.dp)
                        ) {
                            Row(
                                modifier = Modifier.padding(12.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Warning,
                                    contentDescription = "Error",
                                    tint = Color(0xFFF87171),
                                    modifier = Modifier.size(20.dp)
                                )
                                Spacer(modifier = Modifier.width(10.dp))
                                Text(
                                    text = errorMessage,
                                    color = Color(0xFFFECACA),
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.Medium
                                )
                            }
                        }
                    }

                    // Email Inputs
                    OutlinedTextField(
                        value = email,
                        onValueChange = { email = it; errorMessage = "" },
                        label = { Text("Địa chỉ Email", color = Color(0xFF94A3B8)) },
                        placeholder = { Text("email@stayease.com", color = Color(0xFF475569)) },
                        leadingIcon = { Icon(Icons.Default.Email, contentDescription = "Email", tint = Color(0xFFF97316)) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = Color(0xFFF97316),
                            unfocusedBorderColor = Color(0xFF475569),
                            focusedLabelColor = Color(0xFFF97316),
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("login_email_input"),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                        shape = RoundedCornerShape(12.dp)
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    // Password Inputs
                    OutlinedTextField(
                        value = password,
                        onValueChange = { password = it; errorMessage = "" },
                        label = { Text("Mật khẩu", color = Color(0xFF94A3B8)) },
                        leadingIcon = { Icon(Icons.Default.Lock, contentDescription = "Password", tint = Color(0xFFF97316)) },
                        trailingIcon = {
                            IconButton(onClick = { passwordVisible = !passwordVisible }) {
                                Icon(
                                    imageVector = if (passwordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                    contentDescription = "Show/hide password",
                                    tint = Color(0xFF64748B)
                                )
                            }
                        },
                        visualTransformation = if (passwordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = Color(0xFFF97316),
                            unfocusedBorderColor = Color(0xFF475569),
                            focusedLabelColor = Color(0xFFF97316),
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("login_password_input"),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                        shape = RoundedCornerShape(12.dp)
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    // Row showing Forgot Password & Remember Me check
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.clickable { rememberMe = !rememberMe }
                        ) {
                            Checkbox(
                                checked = rememberMe,
                                onCheckedChange = { rememberMe = it },
                                colors = CheckboxDefaults.colors(
                                    checkedColor = Color(0xFFF97316),
                                    uncheckedColor = Color(0xFF475569),
                                    checkmarkColor = Color.White
                                )
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = "Ghi nhớ tôi",
                                color = Color(0xFF94A3B8),
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Medium
                            )
                        }

                        Text(
                            text = "Quên mật khẩu?",
                            color = Color(0xFFF97316),
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.clickable { onNavigateToForgotPassword() }
                        )
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    // Submit Button
                    Button(
                        onClick = {
                            if (email.trim().isEmpty() || !email.contains("@")) {
                                errorMessage = "Vui lòng nhập email hợp lệ"
                                return@Button
                            }
                            if (password.isEmpty()) {
                                errorMessage = "Mật khẩu không được để trống"
                                return@Button
                            }
                            
                            scope.launch {
                                isLoading = true
                                delay(1000) // Aesthetic delay simulating network requests
                                val result = viewModel.loginWithDetails(email.trim(), password, rememberMe)
                                isLoading = false
                                when (result) {
                                    is AuthResult.Success -> {
                                        onLoginSuccess()
                                    }
                                    is AuthResult.VerificationRequired -> {
                                        onVerifyEmailNeeded(email.trim())
                                    }
                                    is AuthResult.Error -> {
                                        errorMessage = result.message
                                    }
                                }
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316)),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(52.dp)
                            .testTag("login_button"),
                        enabled = !isLoading
                    ) {
                        if (isLoading) {
                            CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                        } else {
                            Text("ĐĂNG NHẬP", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Or separator
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(modifier = Modifier.weight(1f).height(1.dp).background(Color(0xFF334155)))
                Text(
                    text = "Hoặc tiếp tục với",
                    color = Color(0xFF64748B),
                    fontSize = 13.sp,
                    modifier = Modifier.padding(horizontal = 12.dp)
                )
                Box(modifier = Modifier.weight(1f).height(1.dp).background(Color(0xFF334155)))
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Google sign in button
            OutlinedButton(
                onClick = { showGoogleBottomSheet = true },
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.LightGray),
                border = BorderStroke(1.dp, Color(0xFF475569)),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    Text(
                        text = "☘ Đăng nhập bằng Google",
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                        fontSize = 15.sp
                    )
                }
            }

            Spacer(modifier = Modifier.height(28.dp))

            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center,
                modifier = Modifier.clickable { onNavigateToRegister() }
            ) {
                Text("Chưa có tài khoản? ", color = Color(0xFF64748B), fontSize = 15.sp)
                Text("Đăng ký ngay", color = Color(0xFFF97316), fontSize = 15.sp, fontWeight = FontWeight.Bold)
            }
            
            Spacer(modifier = Modifier.height(24.dp))
        }

        // Beautiful Interactive Interactive Google Auth simulation bottom sheet
        if (showGoogleBottomSheet) {
            ModalBottomSheet(
                onDismissRequest = { showGoogleBottomSheet = false },
                containerColor = Color(0xFF1E293B),
                dragHandle = {
                    Box(
                        modifier = Modifier
                            .padding(vertical = 12.dp)
                            .size(width = 40.dp, height = 4.dp)
                            .background(Color(0xFF475569), RoundedCornerShape(2.dp))
                    )
                }
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 24.dp, vertical = 16.dp)
                ) {
                    Text(
                        text = "Chọn tài khoản Google",
                        color = Color.White,
                        fontWeight = FontWeight.Bold,
                        fontSize = 18.sp
                    )
                    Text(
                        text = "đến ứng dụng StayEase & Agoda booking",
                        color = Color(0xFF94A3B8),
                        fontSize = 13.sp,
                        modifier = Modifier.padding(bottom = 20.dp)
                    )

                    val googleAccounts = listOf(
                        Triple("Vương Hoàng Tuấn Anh", "vuonghoangtuananh6@gmail.com", "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80"),
                        Triple("Tuan Anh Dev", "tuananh.dev.vn@gmail.com", "https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=150&q=80"),
                        Triple("Nguyen Quoc Anh", "quocanhnguyen@gmail.com", "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=150&q=80")
                    )

                    googleAccounts.forEach { (name, googleEmail, avatar) ->
                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 8.dp)
                                .clickable {
                                    scope.launch {
                                        showGoogleBottomSheet = false
                                        isLoading = true
                                        delay(1200) // mock network animation
                                        viewModel.googleSignIn(googleEmail, name, avatar, rememberMe)
                                        isLoading = false
                                        onLoginSuccess()
                                    }
                                },
                            colors = CardDefaults.cardColors(containerColor = Color(0xFF334155).copy(alpha = 0.5f)),
                            border = BorderStroke(1.dp, Color(0xFF475569))
                        ) {
                            Row(
                                modifier = Modifier.padding(16.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Image(
                                    painter = coil.compose.rememberAsyncImagePainter(model = avatar),
                                    contentDescription = "Avatar",
                                    modifier = Modifier
                                        .size(40.dp)
                                        .clip(CircleShape),
                                    contentScale = ContentScale.Crop
                                )
                                Spacer(modifier = Modifier.width(16.dp))
                                Column {
                                    Text(text = name, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 15.sp)
                                    Text(text = googleEmail, color = Color(0xFF94A3B8), fontSize = 13.sp)
                                }
                                Spacer(modifier = Modifier.weight(1f))
                                Icon(
                                    imageVector = Icons.Default.Login,
                                    contentDescription = "Sign In",
                                    tint = Color(0xFFF97316)
                                )
                            }
                        }
                    }
                    Spacer(modifier = Modifier.height(32.dp))
                }
            }
        }
    }
}

@Composable
fun RegisterScreen(
    viewModel: HotelViewModel,
    onRegisterSuccess: (String) -> Unit,
    onNavigateToLogin: () -> Unit
) {
    var name by rememberSaveable { mutableStateOf("") }
    var email by rememberSaveable { mutableStateOf("") }
    var phone by rememberSaveable { mutableStateOf("") }
    var password by rememberSaveable { mutableStateOf("") }
    var confirmPassword by rememberSaveable { mutableStateOf("") }
    
    var passwordVisible by rememberSaveable { mutableStateOf(false) }
    var confirmPasswordVisible by rememberSaveable { mutableStateOf(false) }
    
    var errorMessage by remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }
    
    val scrollState = rememberScrollState()
    val scope = rememberCoroutineScope()

    // Real-time validations variables
    val hasMinLength = password.length >= 8
    val hasUpper = password.any { it.isUpperCase() }
    val hasNumber = password.any { it.isDigit() }
    val hasSpecial = password.any { !it.isLetterOrDigit() }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0F172A))
    ) {
        Image(
            painter = coil.compose.rememberAsyncImagePainter(
                model = "https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=800&q=80"
            ),
            contentDescription = "Background",
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.38f),
            contentScale = ContentScale.Crop,
            alpha = 0.4f
        )

        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color(0xFF0F172A).copy(alpha = 0.3f),
                            Color(0xFF0F172A).copy(alpha = 0.95f),
                            Color(0xFF0F172A)
                        )
                    )
                )
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
                .padding(24.dp)
                .verticalScroll(scrollState),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Spacer(modifier = Modifier.height(28.dp))

            Text(
                text = "Tạo tài khoản",
                fontSize = 28.sp,
                fontWeight = FontWeight.Black,
                color = Color.White
            )

            Text(
                text = "Gia nhập hệ thống VIP của StayEase & Agoda Partner",
                fontSize = 13.sp,
                color = Color(0xFF94A3B8),
                modifier = Modifier.padding(top = 4.dp, bottom = 24.dp),
                textAlign = TextAlign.Center
            )

            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                border = BorderStroke(1.dp, Color(0xFF334155)),
                elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
            ) {
                Column(
                    modifier = Modifier.padding(24.dp)
                ) {
                    // Validations Banner Card
                    AnimatedVisibility(
                        visible = errorMessage.isNotEmpty(),
                        enter = fadeIn() + expandVertically(),
                        exit = fadeOut() + shrinkVertically()
                    ) {
                        Card(
                            colors = CardDefaults.cardColors(containerColor = Color(0xFF7F1D1D)),
                            border = BorderStroke(1.dp, Color(0xFFF87171)),
                            shape = RoundedCornerShape(12.dp),
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(bottom = 16.dp)
                        ) {
                            Row(
                                modifier = Modifier.padding(12.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Warning,
                                    contentDescription = "Warning",
                                    tint = Color(0xFFF87171),
                                    modifier = Modifier.size(18.dp)
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    text = errorMessage,
                                    color = Color(0xFFFECACA),
                                    fontSize = 13.sp
                                )
                            }
                        }
                    }

                    // Field: Họ Tên
                    OutlinedTextField(
                        value = name,
                        onValueChange = { name = it; errorMessage = "" },
                        label = { Text("Họ & Tên", color = Color(0xFF94A3B8)) },
                        leadingIcon = { Icon(Icons.Default.Person, contentDescription = "Name", tint = Color(0xFFF97316)) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = Color(0xFFF97316),
                            unfocusedBorderColor = Color(0xFF475569),
                            focusedLabelColor = Color(0xFFF97316),
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("reg_name_input"),
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp)
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Field: Email
                    OutlinedTextField(
                        value = email,
                        onValueChange = { email = it; errorMessage = "" },
                        label = { Text("Địa chỉ Email", color = Color(0xFF94A3B8)) },
                        leadingIcon = { Icon(Icons.Default.Email, contentDescription = "Email", tint = Color(0xFFF97316)) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = Color(0xFFF97316),
                            unfocusedBorderColor = Color(0xFF475569),
                            focusedLabelColor = Color(0xFFF97316),
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("reg_email_input"),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                        shape = RoundedCornerShape(12.dp)
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Field: Điện Thoại
                    OutlinedTextField(
                        value = phone,
                        onValueChange = { phone = it; errorMessage = "" },
                        label = { Text("Số điện thoại", color = Color(0xFF94A3B8)) },
                        leadingIcon = { Icon(Icons.Default.Phone, contentDescription = "Phone", tint = Color(0xFFF97316)) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = Color(0xFFF97316),
                            unfocusedBorderColor = Color(0xFF475569),
                            focusedLabelColor = Color(0xFFF97316),
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("reg_phone_input"),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                        shape = RoundedCornerShape(12.dp)
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Field: Mật Khẩu
                    OutlinedTextField(
                        value = password,
                        onValueChange = { password = it; errorMessage = "" },
                        label = { Text("Mật khẩu", color = Color(0xFF94A3B8)) },
                        leadingIcon = { Icon(Icons.Default.Lock, contentDescription = "Password", tint = Color(0xFFF97316)) },
                        trailingIcon = {
                            IconButton(onClick = { passwordVisible = !passwordVisible }) {
                                Icon(
                                    imageVector = if (passwordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                    contentDescription = "Show/hide password",
                                    tint = Color(0xFF64748B)
                                )
                            }
                        },
                        visualTransformation = if (passwordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = Color(0xFFF97316),
                            unfocusedBorderColor = Color(0xFF475569),
                            focusedLabelColor = Color(0xFFF97316),
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("reg_password_input"),
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp)
                    )

                    // REAL-TIME PASSWORD STRENGTH INDICATOR
                    if (password.isNotEmpty()) {
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "Độ mạnh mật khẩu:",
                            color = Color(0xFF94A3B8),
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        
                        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                            PasswordCriteriaRow(text = "Tối thiểu 8 ký tự", satisfied = hasMinLength)
                            PasswordCriteriaRow(text = "Chứa ít nhất 1 chữ hoa", satisfied = hasUpper)
                            PasswordCriteriaRow(text = "Chứa ít nhất 1 chữ số", satisfied = hasNumber)
                            PasswordCriteriaRow(text = "Chứa ít nhất 1 ký tự đặc biệt", satisfied = hasSpecial)
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    // Field: Confirm Password
                    OutlinedTextField(
                        value = confirmPassword,
                        onValueChange = { confirmPassword = it; errorMessage = "" },
                        label = { Text("Xác nhận mật khẩu", color = Color(0xFF94A3B8)) },
                        leadingIcon = { Icon(Icons.Default.Lock, contentDescription = "Confirm password", tint = Color(0xFFF97316)) },
                        trailingIcon = {
                            IconButton(onClick = { confirmPasswordVisible = !confirmPasswordVisible }) {
                                Icon(
                                    imageVector = if (confirmPasswordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                    contentDescription = "Show/hide password",
                                    tint = Color(0xFF64748B)
                                )
                            }
                        },
                        visualTransformation = if (confirmPasswordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = Color(0xFFF97316),
                            unfocusedBorderColor = Color(0xFF475569),
                            focusedLabelColor = Color(0xFFF97316),
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        ),
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp)
                    )

                    Spacer(modifier = Modifier.height(24.dp))

                    // Register Button with validation checks
                    Button(
                        onClick = {
                            if (name.trim().isEmpty() || email.trim().isEmpty() || phone.trim().isEmpty()) {
                                errorMessage = "Vui lòng nhập đầy đủ thông tin"
                                return@Button
                            }
                            if (!email.contains("@")) {
                                errorMessage = "Địa chỉ email không hợp lệ"
                                return@Button
                            }
                            if (phone.trim().length < 9) {
                                errorMessage = "Số điện thoại không hợp lệ"
                                return@Button
                            }
                            if (!hasMinLength || !hasUpper || !hasNumber || !hasSpecial) {
                                errorMessage = "Mật khẩu chưa đạt yêu cầu bảo mật!"
                                return@Button
                            }
                            if (password != confirmPassword) {
                                errorMessage = "Mật khẩu xác nhận không trùng khớp!"
                                return@Button
                            }

                            scope.launch {
                                isLoading = true
                                delay(1200) // mock latency
                                val result = viewModel.registerWithDetails(name, email.trim(), phone, password)
                                isLoading = false
                                if (result is AuthResult.VerificationRequired) {
                                    onRegisterSuccess(email.trim())
                                }
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316)),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(52.dp)
                            .testTag("register_button"),
                        enabled = !isLoading
                    ) {
                        if (isLoading) {
                            CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                        } else {
                            Text("ĐĂNG KÝ NGAY", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(28.dp))

            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center,
                modifier = Modifier.clickable { onNavigateToLogin() }
            ) {
                Text("Đã có tài khoản? ", color = Color(0xFF64748B), fontSize = 15.sp)
                Text("Đăng nhập ngay", color = Color(0xFFF97316), fontSize = 15.sp, fontWeight = FontWeight.Bold)
            }
            
            Spacer(modifier = Modifier.height(24.dp))
        }
    }
}

@Composable
fun PasswordCriteriaRow(text: String, satisfied: Boolean) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.padding(vertical = 1.dp)
    ) {
        Icon(
            imageVector = if (satisfied) Icons.Default.CheckCircle else Icons.Default.Cancel,
            contentDescription = null,
            tint = if (satisfied) Color(0xFF22C55E) else Color(0xFF64748B),
            modifier = Modifier.size(14.dp)
        )
        Spacer(modifier = Modifier.width(6.dp))
        Text(
            text = text,
            color = if (satisfied) Color(0xFF22C55E) else Color(0xFF94A3B8),
            fontSize = 12.sp
        )
    }
}

@Composable
fun VerifyEmailScreen(
    email: String,
    onVerificationSuccess: () -> Unit,
    onBackToLogin: () -> Unit,
    viewModel: HotelViewModel
) {
    var countdown by remember { mutableStateOf(60) }
    var isSendingVerification by remember { mutableStateOf(false) }
    var mockSuccessChecked by remember { mutableStateOf(false) }
    var resendSuccessMsg by remember { mutableStateOf("") }
    
    val scope = rememberCoroutineScope()

    LaunchedEffect(key1 = countdown) {
        if (countdown > 0) {
            delay(1000)
            countdown--
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0F172A)),
        contentAlignment = Alignment.Center
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Simulated Lottie / Animated checking ring
            Box(
                modifier = Modifier
                    .size(96.dp)
                    .background(Color(0xFF1E293B), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.MarkEmailRead,
                    contentDescription = "Mail",
                    tint = Color(0xFFF97316),
                    modifier = Modifier.size(48.dp)
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = "Xác thực tài khoản",
                fontSize = 26.sp,
                fontWeight = FontWeight.ExtraBold,
                color = Color.White
            )

            Spacer(modifier = Modifier.height(12.dp))

            Text(
                text = "StayEase đã gửi mã liên kết kích hoạt thật về hòm thư:",
                color = Color(0xFF94A3B8),
                fontSize = 14.sp,
                textAlign = TextAlign.Center
            )

            Text(
                text = email,
                color = Color(0xFFF97316),
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(vertical = 4.dp),
                textAlign = TextAlign.Center
            )

            Text(
                text = "Tìm kiếm trong hộp thư đến (Inbox) hoặc hộp thư lọc Spam. Vui lòng nhấn vào liên kết được đính kèm để kích hoạt vĩnh viễn tài khoản của bạn.",
                color = Color(0xFF64748B),
                fontSize = 13.sp,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 10.dp, bottom = 24.dp)
            )

            // Alert banner
            Card(
                colors = CardDefaults.cardColors(containerColor = Color(0xFF334155).copy(alpha = 0.4f)),
                border = BorderStroke(1.dp, Color(0xFF475569)),
                shape = RoundedCornerShape(16.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 24.dp)
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "☘ TRÌNH MÔ PHỎNG KIỂM TRA MÃ HỒM THƯ",
                        color = Color.White,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.ExtraBold,
                        letterSpacing = 0.5.sp
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = "Thư rác kiểm định được kết nối tự động. Bấm Đã xác thực hoặc nút giả lập liên kết Gmail để kích hoạt tài khoản ngay tức thì.",
                        color = Color(0xFF94A3B8),
                        fontSize = 11.sp,
                        textAlign = TextAlign.Center
                    )
                }
            }

            // Simulated interactive bypass button for instant verification
            Button(
                onClick = {
                    scope.launch {
                        mockSuccessChecked = true
                        viewModel.verifyEmailCode(email)
                        delay(1200) // loading state looks amazing
                        onVerificationSuccess()
                    }
                },
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF22C55E)),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                enabled = !mockSuccessChecked
            ) {
                if (mockSuccessChecked) {
                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                } else {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Verified, contentDescription = null, tint = Color.White)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Giả lập kích hoạt thành công (Bấm để Test)", fontWeight = FontWeight.Bold)
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Resend Email code countdown
            OutlinedButton(
                onClick = {
                    if (countdown == 0) {
                        isSendingVerification = true
                        scope.launch {
                            delay(1000)
                            isSendingVerification = false
                            resendSuccessMsg = "Đã gửi lại thư kích hoạt mới thành công!"
                            countdown = 60
                            delay(4000)
                            resendSuccessMsg = ""
                        }
                    }
                },
                shape = RoundedCornerShape(12.dp),
                border = BorderStroke(1.dp, if (countdown == 0) Color(0xFFF97316) else Color(0xFF334155)),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(50.dp),
                enabled = countdown == 0 && !isSendingVerification
            ) {
                if (isSendingVerification) {
                    CircularProgressIndicator(color = Color(0xFFF97316), modifier = Modifier.size(20.dp))
                } else {
                    Text(
                        text = if (countdown > 0) "Gửi lại kích hoạt sau (${countdown}s)" else "GỬI LẠI THƯ KÍCH HOẠT",
                        fontWeight = FontWeight.Bold,
                        color = if (countdown == 0) Color(0xFFF97316) else Color(0xFF64748B),
                        fontSize = 14.sp
                    )
                }
            }

            if (resendSuccessMsg.isNotEmpty()) {
                Spacer(modifier = Modifier.height(12.dp))
                Text(
                    text = "✓ $resendSuccessMsg",
                    color = Color(0xFF22C55E),
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(32.dp))

            Text(
                text = "Quay lại Đăng nhập",
                color = Color(0xFFF97316),
                fontSize = 15.sp,
                fontWeight = FontWeight.ExtraBold,
                modifier = Modifier.clickable { onBackToLogin() }
            )
        }
    }
}

@Composable
fun ForgotPasswordScreen(
    viewModel: HotelViewModel,
    onResetSuccess: () -> Unit,
    onBackToLogin: () -> Unit
) {
    var email by rememberSaveable { mutableStateOf("") }
    var otpSent by rememberSaveable { mutableStateOf(false) }
    var otpInput by rememberSaveable { mutableStateOf("") }
    var newPassword by rememberSaveable { mutableStateOf("") }
    var confirmPassword by rememberSaveable { mutableStateOf("") }
    
    var passwordVisible by rememberSaveable { mutableStateOf(false) }
    var confirmPasswordVisible by rememberSaveable { mutableStateOf(false) }
    
    var errorMessage by remember { mutableStateOf("") }
    var successMessage by remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }
    
    // Validations helper
    val hasMinLength = newPassword.length >= 8
    val hasUpper = newPassword.any { it.isUpperCase() }
    val hasNumber = newPassword.any { it.isDigit() }
    val hasSpecial = newPassword.any { !it.isLetterOrDigit() }

    val scrollState = rememberScrollState()
    val scope = rememberCoroutineScope()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0F172A))
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
                .padding(24.dp)
                .verticalScroll(scrollState),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "Quên Mật Khẩu",
                fontSize = 28.sp,
                fontWeight = FontWeight.Black,
                color = Color.White
            )

            Text(
                text = "Cung cấp email của bạn để lấy lại mật khẩu nhanh chóng qua OTP thật",
                fontSize = 14.sp,
                color = Color(0xFF94A3B8),
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 4.dp, bottom = 24.dp)
            )

            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                border = BorderStroke(1.dp, Color(0xFF334155)),
                elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
            ) {
                Column(
                    modifier = Modifier.padding(24.dp)
                ) {
                    if (!otpSent) {
                        OutlinedTextField(
                            value = email,
                            onValueChange = { email = it; errorMessage = "" },
                            label = { Text("Địa chỉ Email", color = Color(0xFF94A3B8)) },
                            leadingIcon = { Icon(Icons.Default.Email, contentDescription = "Email", tint = Color(0xFFF97316)) },
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = Color(0xFFF97316),
                                unfocusedBorderColor = Color(0xFF475569),
                                focusedTextColor = Color.White,
                                unfocusedTextColor = Color.White,
                                focusedLabelColor = Color(0xFFF97316)
                            ),
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true,
                            shape = RoundedCornerShape(12.dp)
                        )

                        if (errorMessage.isNotEmpty()) {
                            Text(errorMessage, color = Color.Red, fontSize = 13.sp, modifier = Modifier.padding(top = 8.dp))
                        }

                        Spacer(modifier = Modifier.height(24.dp))

                        Button(
                            onClick = {
                                if (email.trim().isEmpty() || !email.contains("@")) {
                                    errorMessage = "Hãy nhập địa chỉ email hợp lệ!"
                                    return@Button
                                }
                                scope.launch {
                                    isLoading = true
                                    delay(1200) // mock delay
                                    isLoading = false
                                    otpSent = true
                                    successMessage = "Mã OTP khôi phục 6 số đã được gửi tới ${email.trim()} (Mã mẫu: 123456)"
                                }
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316)),
                            shape = RoundedCornerShape(12.dp),
                            modifier = Modifier.fillMaxWidth().height(52.dp),
                            enabled = !isLoading
                        ) {
                            if (isLoading) {
                                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                            } else {
                                Text("GỬI MÃ KHÔI PHỤC", fontWeight = FontWeight.Bold, color = Color.White)
                            }
                        }
                    } else {
                        if (successMessage.isNotEmpty()) {
                            Card(
                                colors = CardDefaults.cardColors(containerColor = Color(0xFF14532D)),
                                border = BorderStroke(1.dp, Color(0xFF22C55E)),
                                modifier = Modifier.fillMaxWidth().padding(bottom = 16.dp)
                            ) {
                                Row(
                                    modifier = Modifier.padding(12.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Icon(Icons.Default.CheckCircle, contentDescription = null, tint = Color(0xFF22C55E))
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text(
                                        text = successMessage,
                                        color = Color(0xFFBBF7D0),
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.Medium
                                    )
                                }
                            }
                        }

                        // Code OTP focus value
                        OutlinedTextField(
                            value = otpInput,
                            onValueChange = { otpInput = it; errorMessage = "" },
                            label = { Text("Nhập mã OTP 6 số (123456)", color = Color(0xFF94A3B8)) },
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = Color(0xFFF97316),
                                unfocusedBorderColor = Color(0xFF475569),
                                focusedTextColor = Color.White,
                                unfocusedTextColor = Color.White,
                                focusedLabelColor = Color(0xFFF97316)
                            ),
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true,
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            shape = RoundedCornerShape(12.dp)
                        )

                        Spacer(modifier = Modifier.height(12.dp))

                        // New password
                        OutlinedTextField(
                            value = newPassword,
                            onValueChange = { newPassword = it; errorMessage = "" },
                            label = { Text("Mật khẩu mới", color = Color(0xFF94A3B8)) },
                            leadingIcon = { Icon(Icons.Default.Lock, contentDescription = "Password", tint = Color(0xFFF97316)) },
                            trailingIcon = {
                                IconButton(onClick = { passwordVisible = !passwordVisible }) {
                                    Icon(
                                        imageVector = if (passwordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                        contentDescription = "Show/hide password",
                                        tint = Color(0xFF64748B)
                                    )
                                }
                            },
                            visualTransformation = if (passwordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = Color(0xFFF97316),
                                unfocusedBorderColor = Color(0xFF475569),
                                focusedTextColor = Color.White,
                                unfocusedTextColor = Color.White,
                                focusedLabelColor = Color(0xFFF97316)
                            ),
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true,
                            shape = RoundedCornerShape(12.dp)
                        )

                        if (newPassword.isNotEmpty()) {
                            Spacer(modifier = Modifier.height(8.dp))
                            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                                PasswordCriteriaRow(text = "Tối thiểu 8 ký tự", satisfied = hasMinLength)
                                PasswordCriteriaRow(text = "Chứa ít nhất 1 chữ hoa", satisfied = hasUpper)
                                PasswordCriteriaRow(text = "Chứa ít nhất 1 chữ số", satisfied = hasNumber)
                                PasswordCriteriaRow(text = "Chứa ít nhất 1 ký tự đặc biệt", satisfied = hasSpecial)
                            }
                        }

                        Spacer(modifier = Modifier.height(12.dp))

                        // Match password Input
                        OutlinedTextField(
                            value = confirmPassword,
                            onValueChange = { confirmPassword = it; errorMessage = "" },
                            label = { Text("Xác nhận mật khẩu mới", color = Color(0xFF94A3B8)) },
                            leadingIcon = { Icon(Icons.Default.Lock, contentDescription = "Confirm password", tint = Color(0xFFF97316)) },
                            trailingIcon = {
                                IconButton(onClick = { confirmPasswordVisible = !confirmPasswordVisible }) {
                                    Icon(
                                        imageVector = if (confirmPasswordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                        contentDescription = "Show/hide password",
                                        tint = Color(0xFF64748B)
                                    )
                                }
                            },
                            visualTransformation = if (confirmPasswordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = Color(0xFFF97316),
                                unfocusedBorderColor = Color(0xFF475569),
                                focusedTextColor = Color.White,
                                unfocusedTextColor = Color.White,
                                focusedLabelColor = Color(0xFFF97316)
                            ),
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true,
                            shape = RoundedCornerShape(12.dp)
                        )

                        if (errorMessage.isNotEmpty()) {
                            Text(errorMessage, color = Color.Red, fontSize = 13.sp, modifier = Modifier.padding(top = 8.dp))
                        }

                        Spacer(modifier = Modifier.height(24.dp))

                        Button(
                            onClick = {
                                if (otpInput != "123456") {
                                    errorMessage = "Mã xác thực OTP chưa chính xác!"
                                    return@Button
                                }
                                if (!hasMinLength || !hasUpper || !hasNumber || !hasSpecial) {
                                    errorMessage = "Mật khẩu mới chưa đủ độ bảo mật!"
                                    return@Button
                                }
                                if (newPassword != confirmPassword) {
                                    errorMessage = "Mật khẩu xác nhận không chính xác!"
                                    return@Button
                                }

                                scope.launch {
                                    isLoading = true
                                    delay(1200) // mock logic
                                    isLoading = false
                                    viewModel.forgotPassword(email, newPassword)
                                    onResetSuccess()
                                }
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316)),
                            shape = RoundedCornerShape(12.dp),
                            modifier = Modifier.fillMaxWidth().height(52.dp),
                            enabled = !isLoading
                        ) {
                            if (isLoading) {
                                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                            } else {
                                Text("ĐẶT LẠI MẬT KHẨU", fontWeight = FontWeight.Bold, color = Color.White)
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(30.dp))

            Text(
                text = "Quay lại đăng nhập",
                color = Color(0xFFF97316),
                fontWeight = FontWeight.Bold,
                fontSize = 15.sp,
                modifier = Modifier.clickable { onBackToLogin() }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChangePasswordScreen(
    onChangePassword: (String, String) -> Boolean,
    onBack: () -> Unit
) {
    var oldPassword by rememberSaveable { mutableStateOf("") }
    var newPassword by rememberSaveable { mutableStateOf("") }
    var confirmPassword by rememberSaveable { mutableStateOf("") }
    
    var oldPasswordVisible by rememberSaveable { mutableStateOf(false) }
    var newPasswordVisible by rememberSaveable { mutableStateOf(false) }
    var confirmPasswordVisible by rememberSaveable { mutableStateOf(false) }
    
    var errorMessage by remember { mutableStateOf("") }
    var successMessage by remember { mutableStateOf("") }
    
    val hasMinLength = newPassword.length >= 8
    val hasUpper = newPassword.any { it.isUpperCase() }
    val hasNumber = newPassword.any { it.isDigit() }
    val hasSpecial = newPassword.any { !it.isLetterOrDigit() }

    val scrollState = rememberScrollState()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0F172A))
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
                .padding(24.dp)
                .verticalScroll(scrollState),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "Đổi Mật Khẩu",
                fontSize = 28.sp,
                fontWeight = FontWeight.Black,
                color = Color.White
            )

            Text(
                text = "Đổi mật khẩu định kỳ giúp tăng tính bảo mật tài khoản đáng kể",
                fontSize = 14.sp,
                color = Color(0xFF94A3B8),
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 4.dp, bottom = 24.dp)
            )

            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                border = BorderStroke(1.dp, Color(0xFF334155)),
                elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
            ) {
                Column(
                    modifier = Modifier.padding(24.dp)
                ) {
                    // Field Old
                    OutlinedTextField(
                        value = oldPassword,
                        onValueChange = { oldPassword = it; errorMessage = ""; successMessage = "" },
                        label = { Text("Mật khẩu cũ", color = Color(0xFF94A3B8)) },
                        trailingIcon = {
                            IconButton(onClick = { oldPasswordVisible = !oldPasswordVisible }) {
                                Icon(
                                    imageVector = if (oldPasswordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                    contentDescription = null,
                                    tint = Color(0xFF64748B)
                                )
                            }
                        },
                        visualTransformation = if (oldPasswordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = Color(0xFFF97316),
                            unfocusedBorderColor = Color(0xFF475569),
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedLabelColor = Color(0xFFF97316)
                        ),
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp)
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Field New
                    OutlinedTextField(
                        value = newPassword,
                        onValueChange = { newPassword = it; errorMessage = ""; successMessage = "" },
                        label = { Text("Mật khẩu mới", color = Color(0xFF94A3B8)) },
                        trailingIcon = {
                            IconButton(onClick = { newPasswordVisible = !newPasswordVisible }) {
                                Icon(
                                    imageVector = if (newPasswordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                    contentDescription = null,
                                    tint = Color(0xFF64748B)
                                )
                            }
                        },
                        visualTransformation = if (newPasswordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = Color(0xFFF97316),
                            unfocusedBorderColor = Color(0xFF475569),
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedLabelColor = Color(0xFFF97316)
                        ),
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp)
                    )

                    if (newPassword.isNotEmpty()) {
                        Spacer(modifier = Modifier.height(8.dp))
                        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                            PasswordCriteriaRow(text = "Tối thiểu 8 ký tự", satisfied = hasMinLength)
                            PasswordCriteriaRow(text = "Chứa ít nhất 1 chữ hoa", satisfied = hasUpper)
                            PasswordCriteriaRow(text = "Chứa ít nhất 1 chữ số", satisfied = hasNumber)
                            PasswordCriteriaRow(text = "Chứa ít nhất 1 ký tự đặc biệt", satisfied = hasSpecial)
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    // Field confirm
                    OutlinedTextField(
                        value = confirmPassword,
                        onValueChange = { confirmPassword = it; errorMessage = ""; successMessage = "" },
                        label = { Text("Xác nhận mật khẩu mới", color = Color(0xFF94A3B8)) },
                        trailingIcon = {
                            IconButton(onClick = { confirmPasswordVisible = !confirmPasswordVisible }) {
                                Icon(
                                    imageVector = if (confirmPasswordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                    contentDescription = null,
                                    tint = Color(0xFF64748B)
                                )
                            }
                        },
                        visualTransformation = if (confirmPasswordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = Color(0xFFF97316),
                            unfocusedBorderColor = Color(0xFF475569),
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedLabelColor = Color(0xFFF97316)
                        ),
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp)
                    )

                    if (errorMessage.isNotEmpty()) {
                        Text(errorMessage, color = Color.Red, fontSize = 13.sp, modifier = Modifier.padding(top = 8.dp))
                    }

                    if (successMessage.isNotEmpty()) {
                        Text(successMessage, color = Color(0xFF22C55E), fontSize = 13.sp, modifier = Modifier.padding(top = 8.dp))
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    Button(
                        onClick = {
                            if (oldPassword.isEmpty() || newPassword.isEmpty() || confirmPassword.isEmpty()) {
                                errorMessage = "Vui lòng điền đầy đủ tất cả các trường!"
                                return@Button
                            }
                            if (!hasMinLength || !hasUpper || !hasNumber || !hasSpecial) {
                                errorMessage = "Mật khẩu mới chưa đủ độ bảo mật!"
                                return@Button
                            }
                            if (newPassword != confirmPassword) {
                                errorMessage = "Mật khẩu xác nhận không trùng khớp!"
                                return@Button
                            }

                            val success = onChangePassword(oldPassword, newPassword)
                            if (success) {
                                successMessage = "Đổi mật khẩu thành công!"
                                oldPassword = ""
                                newPassword = ""
                                confirmPassword = ""
                            } else {
                                errorMessage = "Mật khẩu cũ không chính xác!"
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFF97316)),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.fillMaxWidth().height(52.dp)
                    ) {
                        Text("CẬP NHẬT MẬT KHẨU", fontWeight = FontWeight.Bold, color = Color.White)
                    }
                }
            }

            Spacer(modifier = Modifier.height(30.dp))

            Text(
                text = "Quay lại trang cá nhân",
                color = Color(0xFFF97316),
                fontWeight = FontWeight.Bold,
                fontSize = 15.sp,
                modifier = Modifier.clickable { onBack() }
            )
        }
    }
}
