import 'package:flutter/material.dart';
import 'package:munch_nearby/screens/bottom_screen_restaurant_owner/home_screen_restaurant.dart';
import 'package:munch_nearby/screens/bottom_screen_restaurant_owner/menu_screen.dart';
import 'package:munch_nearby/screens/bottom_screen_restaurant_owner/profile_screen_retaurant.dart';
import 'package:munch_nearby/screens/bottom_screen_restaurant_owner/review_screen.dart';

import '../widgets/app_bar_title.dart';

class BottomNavigationBarForRestaurant extends StatefulWidget {
  const BottomNavigationBarForRestaurant({super.key});

  @override
  State<BottomNavigationBarForRestaurant> createState() => _BottomNavigationBarForRestaurantState();
}

class _BottomNavigationBarForRestaurantState extends State<BottomNavigationBarForRestaurant> {
  int _selectedIndex = 0;

  List <Widget> lstBottomScreen = [
    const HomeScreenRestaurant(),
    const ReviewScreen(),
    const MenuScreen(),
    const ProfileScreenRetaurant(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const AppBarTitle(name: "Chiya Aada"),
      ),

      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.reviews_outlined), label: "Review"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: "Profile")
        ],

        selectedItemColor: Color(0xFFEE7C2B),
        unselectedItemColor: Color(0xFF64748B),
        currentIndex: _selectedIndex,
        onTap: (index){
          setState(() {
            _selectedIndex=index; 
          });
        },
      ),
    );
  }
}
