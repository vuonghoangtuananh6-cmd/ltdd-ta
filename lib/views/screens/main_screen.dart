// lib/views/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'my_trips_screen.dart';
import 'profile_screen.dart';
import '../../utils/constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    SearchScreen(),
    MyTripsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.slate400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Tìm kiếm",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.luggage_outlined),
            activeIcon: Icon(Icons.luggage),
            label: "Chuyến đi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Cá nhân",
          ),
        ],
      ),
    );
  }
}
