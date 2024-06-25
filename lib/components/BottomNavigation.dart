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

  bool _isLoading = false;

void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  // Optionally add a check to avoid unnecessary navigation
  if (ModalRoute.of(context)?.settings.name != _pages[index].toString()) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => _pages[index],
    ));
  }
}


  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      if (_isLoading)
        // If still loading, show CircularProgressIndicator covering the entire screen
        Container(
            color: const Color(0xff2b4260)
                .withOpacity(0.7), // Adjust opacity and color as needed
            child: const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white), // Adjust color
            ))),
      BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Shopping',
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
        selectedItemColor: Color(0xff2b4260),
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: const TextStyle(color: Color(0xff2b4260)),
        unselectedLabelStyle: const TextStyle(color: Colors.black),
        onTap: _onItemTapped,
      ),
    ]);
  }
}

