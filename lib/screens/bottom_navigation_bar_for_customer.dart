import 'package:flutter/material.dart';
import 'package:munch_nearby/screens/bottom_screen_customer/favourite_screen.dart';
import 'package:munch_nearby/screens/bottom_screen_customer/home_screen.dart';
import 'package:munch_nearby/screens/bottom_screen_customer/map_screen.dart';
import 'package:munch_nearby/screens/bottom_screen_customer/profile_screen.dart';

class BottomNavigationBarForCustomer extends StatefulWidget {
  const BottomNavigationBarForCustomer({super.key});

  @override
  State<BottomNavigationBarForCustomer> createState() => _BottomNavigationBarForCustomerState();
}

class _BottomNavigationBarForCustomerState extends State<BottomNavigationBarForCustomer> {
  int _selectedIndex = 0;

  List <Widget> lstBottomScreen = [
    const HomeScreen(),
    const MapScreen(),
    const FavouriteScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favourite"),
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
