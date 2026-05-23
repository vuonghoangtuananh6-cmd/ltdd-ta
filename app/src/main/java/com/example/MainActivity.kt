package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.*
import androidx.navigation.navArgument
import com.example.presentation.screens.*
import com.example.presentation.viewmodel.HotelViewModel
import com.example.ui.theme.*

class MainActivity : ComponentActivity() {
    private val viewModel: HotelViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                MainAppHost(viewModel = viewModel)
            }
        }
    }
}

@Composable
fun MainAppHost(viewModel: HotelViewModel) {
    val navController = rememberNavController()
    val isLoggedIn by viewModel.isLoggedIn.collectAsState()

    // Monitor current backstack entry to control whether to show Bottom Navigation standard bar
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    // Hide bottom navigation on auth, splash, checkout, success, chat, notifications, details, and onboarding
    val showBottomBar = currentRoute in listOf("home", "booking_history", "wishlist", "profile")

    Scaffold(
        modifier = Modifier
            .fillMaxSize()
            .background(AppBackground),
        bottomBar = {
            if (showBottomBar) {
                NavigationBar(
                    containerColor = CardBackground,
                    tonalElevation = 6.dp,
                    modifier = Modifier
                        .navigationBarsPadding()
                        .clip(RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp))
                ) {
                    NavigationBarItem(
                        selected = currentRoute == "home",
                        onClick = {
                            if (currentRoute != "home") {
                                navController.navigate("home") {
                                    popUpTo("home") { inclusive = true }
                                }
                            }
                        },
                        icon = { Icon(Icons.Default.Home, contentDescription = "Trang chủ") },
                        label = { Text("Trang chủ", fontSize = 11.sp, fontWeight = FontWeight.Bold) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = StayHubBlue700,
                            selectedTextColor = StayHubBlue700,
                            indicatorColor = StayHubBlue100,
                            unselectedIconColor = Slate400,
                            unselectedTextColor = Slate500
                        ),
                        modifier = Modifier.testTag("nav_item_home")
                    )

                    NavigationBarItem(
                        selected = currentRoute == "booking_history",
                        onClick = {
                            if (currentRoute != "booking_history") {
                                navController.navigate("booking_history") {
                                    popUpTo("home")
                                }
                            }
                        },
                        icon = { Icon(Icons.Default.ReceiptLong, contentDescription = "Sổ đặt phòng") },
                        label = { Text("Đặt phòng", fontSize = 11.sp, fontWeight = FontWeight.Bold) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = StayHubBlue700,
                            selectedTextColor = StayHubBlue700,
                            indicatorColor = StayHubBlue100,
                            unselectedIconColor = Slate400,
                            unselectedTextColor = Slate500
                        ),
                        modifier = Modifier.testTag("nav_item_history")
                    )

                    NavigationBarItem(
                        selected = currentRoute == "wishlist",
                        onClick = {
                            if (currentRoute != "wishlist") {
                                navController.navigate("wishlist") {
                                    popUpTo("home")
                                }
                            }
                        },
                        icon = { Icon(Icons.Default.Favorite, contentDescription = "Yêu thích") },
                        label = { Text("Yêu thích", fontSize = 11.sp, fontWeight = FontWeight.Bold) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = StayHubBlue700,
                            selectedTextColor = StayHubBlue700,
                            indicatorColor = StayHubBlue100,
                            unselectedIconColor = Slate400,
                            unselectedTextColor = Slate500
                        ),
                        modifier = Modifier.testTag("nav_item_wishlist")
                    )

                    NavigationBarItem(
                        selected = currentRoute == "profile",
                        onClick = {
                            if (currentRoute != "profile") {
                                navController.navigate("profile") {
                                    popUpTo("home")
                                }
                            }
                        },
                        icon = { Icon(Icons.Default.Person, contentDescription = "Cá nhân") },
                        label = { Text("Cá nhân", fontSize = 11.sp, fontWeight = FontWeight.Bold) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = StayHubBlue700,
                            selectedTextColor = StayHubBlue700,
                            indicatorColor = StayHubBlue100,
                            unselectedIconColor = Slate400,
                            unselectedTextColor = Slate500
                        ),
                        modifier = Modifier.testTag("nav_item_profile")
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = "splash",
            modifier = Modifier.padding(
                bottom = if (showBottomBar) innerPadding.calculateBottomPadding() else 0.dp
            )
        ) {
            // Splash Screen Route
            composable("splash") {
                SplashScreen(onTimeout = {
                    navController.navigate("onboarding") {
                        popUpTo("splash") { inclusive = true }
                    }
                })
            }

            // Onboarding Screen Route
            composable("onboarding") {
                OnboardingScreen(onFinish = {
                    val nextDest = if (isLoggedIn) "home" else "login"
                    navController.navigate(nextDest) {
                        popUpTo("onboarding") { inclusive = true }
                    }
                })
            }

            // Auth Screen Routes
            composable("login") {
                LoginScreen(
                    viewModel = viewModel,
                    onLoginSuccess = {
                        navController.navigate("home") {
                            popUpTo("login") { inclusive = true }
                        }
                    },
                    onNavigateToRegister = {
                        navController.navigate("register")
                    },
                    onNavigateToForgotPassword = {
                        navController.navigate("forgot_password")
                    },
                    onVerifyEmailNeeded = { email ->
                        navController.navigate("verify_email/$email")
                    }
                )
            }

            composable("register") {
                RegisterScreen(
                    viewModel = viewModel,
                    onRegisterSuccess = { email ->
                        navController.navigate("verify_email/$email") {
                            popUpTo("register") { inclusive = true }
                        }
                    },
                    onNavigateToLogin = {
                        navController.navigate("login") {
                            popUpTo("register") { inclusive = true }
                        }
                    }
                )
            }

            composable(
                route = "verify_email/{email}",
                arguments = listOf(navArgument("email") { type = NavType.StringType })
            ) { backStackEntry ->
                val email = backStackEntry.arguments?.getString("email") ?: ""
                VerifyEmailScreen(
                    email = email,
                    onVerificationSuccess = {
                        navController.navigate("home") {
                            popUpTo("verify_email/{email}") { inclusive = true }
                        }
                    },
                    onBackToLogin = {
                        navController.navigate("login") {
                            popUpTo("verify_email/{email}") { inclusive = true }
                        }
                    },
                    viewModel = viewModel
                )
            }

            composable("forgot_password") {
                ForgotPasswordScreen(
                    viewModel = viewModel,
                    onResetSuccess = {
                        navController.navigate("login") {
                            popUpTo("forgot_password") { inclusive = true }
                        }
                    },
                    onBackToLogin = {
                        navController.popBackStack()
                    }
                )
            }

            composable("change_password") {
                ChangePasswordScreen(
                    onChangePassword = { oldPass, newPass ->
                        viewModel.changePassword(oldPass, newPass)
                    },
                    onBack = {
                        navController.popBackStack()
                    }
                )
            }

            // Core App Shell Screens (Main Navigation)
            composable("home") {
                HomeScreen(
                    viewModel = viewModel,
                    onNavigateToDetail = { hotelId ->
                        navController.navigate("hotel_detail/$hotelId")
                    },
                    onNavigateToSearchResults = {
                        navController.navigate("search_results")
                    },
                    onNavigateToChat = {
                        navController.navigate("messenger_chat")
                    },
                    onNavigateToNotifications = {
                        navController.navigate("notifications")
                    }
                )
            }

            composable("booking_history") {
                BookingHistoryScreen(
                    viewModel = viewModel,
                    onNavigateToDetail = { hotelId ->
                        navController.navigate("hotel_detail/$hotelId")
                    }
                )
            }

            composable("wishlist") {
                WishlistScreen(
                    viewModel = viewModel,
                    onNavigateToDetail = { hotelId ->
                        navController.navigate("hotel_detail/$hotelId")
                    }
                )
            }

            composable("profile") {
                ProfileScreen(
                    viewModel = viewModel,
                    onNavigateToAdmin = {
                        navController.navigate("admin_dashboard")
                    },
                    onNavigateToChangePassword = {
                        navController.navigate("change_password")
                    },
                    onLogout = {
                        viewModel.logout()
                        navController.navigate("login") {
                            popUpTo("home") { inclusive = true }
                        }
                    }
                )
            }

            // Search Results Route
            composable("search_results") {
                SearchResultsScreen(
                    viewModel = viewModel,
                    onNavigateToDetail = { hotelId ->
                        navController.navigate("hotel_detail/$hotelId")
                    },
                    onBack = {
                        navController.popBackStack()
                    }
                )
            }

            // Hotel Detail Route
            composable(
                route = "hotel_detail/{hotelId}",
                arguments = listOf(navArgument("hotelId") { type = NavType.StringType })
            ) { backStackEntry ->
                val hotelId = backStackEntry.arguments?.getString("hotelId") ?: ""
                HotelDetailScreen(
                    hotelId = hotelId,
                    viewModel = viewModel,
                    onNavigateToCheckout = {
                        navController.navigate("checkout")
                    },
                    onBack = {
                        navController.popBackStack()
                    }
                )
            }

            // Booking checkout workflow route
            composable("checkout") {
                CheckoutScreen(
                    viewModel = viewModel,
                    onNavigateToSuccess = { bookingId ->
                        navController.navigate("success/$bookingId") {
                            popUpTo("checkout") { inclusive = true }
                        }
                    },
                    onBack = {
                        navController.popBackStack()
                    }
                )
            }

            // Booking Success billing ticket route
            composable(
                route = "success/{bookingId}",
                arguments = listOf(navArgument("bookingId") { type = NavType.StringType })
            ) { backStackEntry ->
                val bookingId = backStackEntry.arguments?.getString("bookingId") ?: ""
                BookingSuccessScreen(
                    bookingId = bookingId,
                    viewModel = viewModel,
                    onNavigateBackHome = {
                        navController.navigate("home") {
                            popUpTo("home") { inclusive = true }
                        }
                    }
                )
            }

            // Messenger Support agent live Chat
            composable("messenger_chat") {
                SupportChatScreen(
                    viewModel = viewModel,
                    onBack = {
                        navController.popBackStack()
                    }
                )
            }

            // Notifications alerts inbox mail
            composable("notifications") {
                NotificationsScreen(
                    onBack = {
                        navController.popBackStack()
                    }
                )
            }

            // Admin Dashboard KPIs & CRUD system
            composable("admin_dashboard") {
                AdminDashboardScreen(
                    viewModel = viewModel,
                    onBack = {
                        navController.popBackStack()
                    }
                )
            }
        }
    }
}
