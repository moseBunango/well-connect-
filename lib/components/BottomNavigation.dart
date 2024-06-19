import 'package:flutter/material.dart';
import 'package:well_connect_app/pages/HomePage.dart';
import 'package:well_connect_app/pages/OrderPage.dart';
import 'package:well_connect_app/pages/ProfileDetailsPage.dart';
import 'package:well_connect_app/pages/ProfilePage.dart';
import 'package:well_connect_app/pages/SearchPage.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    OrderPage(),
    ProfileDetailsPage(),
    ProfilePage(),
  ];

  

  void _onItemTapped(int index) async {
    
    await Future.delayed(
        Duration(seconds: 0)); // Simulate loading for 2 seconds
// Navigate to the corresponding page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) {
            // Otherwise, navigate to the selected page
            return _pages[index];
          
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Color(0xff2b4260),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.teal,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
    );
  }
}
