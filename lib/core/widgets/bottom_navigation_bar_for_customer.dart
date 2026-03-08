import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/services/storage/user_session_service.dart';

import 'app_bar_title.dart';
import '../../features/favourite/presentation/pages/favourite_screen.dart';
import '../../features/restaurant/presentation/pages/home_screen.dart';
import '../../features/map/presentation/pages/map_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';

class BottomNavigationBarForCustomer extends ConsumerStatefulWidget {
  const BottomNavigationBarForCustomer({super.key});

  @override
  ConsumerState<BottomNavigationBarForCustomer> createState() =>
      _BottomNavigationBarForCustomerState();
}

class _BottomNavigationBarForCustomerState
    extends ConsumerState<BottomNavigationBarForCustomer> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const MapScreen(),
    const FavouriteScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(userSessionServiceProvider);
    final currentUserName = session.getCurrentUserName()?.trim();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: AppBarTitle(name: currentUserName ?? 'User'),
      ),
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Favourite",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: "Profile",
          ),
        ],
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFEE7C2B),
        unselectedItemColor: Color(0xFF64748B),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
