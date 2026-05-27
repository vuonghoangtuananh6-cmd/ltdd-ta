import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'utils/constants.dart';
import 'service/prefs_helper.dart';
import 'repositories/user_repository.dart';
import 'repositories/favorite_repository.dart';
import 'repositories/hotel_repository.dart';
import 'repositories/booking_repository.dart';

import 'controllers/auth_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/search_controller.dart';
import 'controllers/booking_controller.dart';
import 'controllers/favorite_controller.dart';
import 'controllers/admin_controller.dart';

import 'views/screens/onboarding_screen.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/auth/register_screen.dart';
import 'views/screens/auth/forgot_password_screen.dart';
import 'views/screens/auth/verify_email_screen.dart';
import 'views/screens/main_screen.dart';
import 'views/screens/search_screen.dart';
import 'views/screens/hotel_detail.dart';
import 'views/screens/checkout_screen.dart';
import 'views/screens/booking_success_screen.dart';
import 'views/screens/profile_screen.dart';
import 'views/screens/edit_profile_screen.dart';
import 'views/screens/wishlist_screen.dart';
import 'views/screens/change_password_screen.dart';
import 'views/screens/support_chat_screen.dart';
import 'views/screens/admin_screen.dart';
import 'views/screens/my_trips_screen.dart';

// Global variable for navigator key used in AuthGuard
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo SharedPreferences và các Repositories
  await PrefsHelper.init();
  UserRepository.init();
  FavoriteRepository.init();
  HotelRepository.init();
  BookingRepository.init();
  
  runApp(const StayEaseAppProvider());
}

class StayEaseAppProvider extends StatelessWidget {
  const StayEaseAppProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => BookingSearchController()),
        ChangeNotifierProvider(create: (_) => BookingController()),
        ChangeNotifierProvider(create: (_) => FavoriteController()),
        ChangeNotifierProvider(create: (_) => AdminController()),
      ],
      child: const StayEaseApp(),
    );
  }
}

class StayEaseApp extends StatelessWidget {
  const StayEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch home controller in order to rebuild when dark mode changes
    final homeController = context.watch<HomeController>();
    final isDarkMode = homeController.currentUser.isDarkMode;

    return MaterialApp(
      title: 'StayEase',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.primaryBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.orange,
          background: AppColors.primaryBackground,
          surface: AppColors.cardBackground,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.slate900,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.slate900,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: AppColors.slate800),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.slate200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.slate200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          labelStyle: const TextStyle(color: AppColors.slate500, fontSize: 14),
          hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.slate900,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.orange,
          background: AppColors.slate900,
          surface: AppColors.slate800,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.slate900,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.slate800,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.slate700),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.slate700),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          labelStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
          hintStyle: const TextStyle(color: AppColors.slate500, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      initialRoute: AppRoutes.splash,
      builder: (context, child) {
        return _AuthScope(
          navigatorKey: navigatorKey,
          child: child ?? const SizedBox(),
        );
      },
      routes: {
        AppRoutes.splash: (context) => const OnboardingScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.verifyEmail: (context) => const VerifyEmailScreen(),
        AppRoutes.main: (context) => const MainScreen(),
        '/home': (context) => const MainScreen(),
        AppRoutes.hotelDetail: (context) => const HotelDetailScreen(),
        AppRoutes.checkout: (context) => const CheckoutScreen(),
        '/booking_success': (context) => const BookingSuccessScreen(),
        AppRoutes.chat: (context) => const SupportChatScreen(),
        '/support_chat': (context) => const SupportChatScreen(),
        AppRoutes.admin: (context) => const AdminScreen(),
        AppRoutes.editProfile: (context) => const EditProfileScreen(),
        AppRoutes.changePassword: (context) => const ChangePasswordScreen(),
        AppRoutes.wishlist: (context) => const WishlistScreen(),
        '/search_destination': (context) => const SearchScreen(),
        '/my_trips': (context) => const MyTripsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class _AuthScope extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const _AuthScope({
    required this.navigatorKey,
    required this.child,
  });

  @override
  State<_AuthScope> createState() => _AuthScopeState();
}

class _AuthScopeState extends State<_AuthScope> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRoute();
    });
  }

  void _checkRoute() {
    final authController = Provider.of<AuthController>(context, listen: false);
    if (!authController.isLoggedIn()) {
      String? currentRoute;
      widget.navigatorKey.currentState?.popUntil((route) {
        currentRoute = route.settings.name;
        return true; // peek do not pop
      });

      if (currentRoute != null) {
        final isAuthRoute = currentRoute == AppRoutes.login ||
            currentRoute == AppRoutes.register ||
            currentRoute == AppRoutes.forgotPassword ||
            currentRoute == AppRoutes.verifyEmail ||
            currentRoute == AppRoutes.splash ||
            currentRoute == '/onboarding';

        if (!isAuthRoute) {
          widget.navigatorKey.currentState?.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, child) {
        if (!auth.isLoggedIn()) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkRoute();
          });
        }
        return widget.child;
      },
    );
  }
}
