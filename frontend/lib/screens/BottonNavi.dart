import 'package:flutter/material.dart';
import 'package:frontend/screens/ChatgroupeScreen.dart';
import 'package:frontend/screens/HomeScreen.dart';
import 'package:frontend/screens/PostScreen.dart';
import 'package:frontend/screens/ProfileScreen.dart';
import 'package:iconsax/iconsax.dart';

class ButtonnavBar extends StatefulWidget {
  const ButtonnavBar({super.key});

  @override
  State<ButtonnavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<ButtonnavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    Homescreen(),
    Chatgroupescreen(),
    Postscreen(),
    Profilescreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color:Colors.white,
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          selectedItemColor: isDarkMode ? Colors.white : Colors.blue,
          unselectedItemColor: isDarkMode ? Colors.grey : Colors.black54,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.home),
              activeIcon: Icon(Iconsax.home_15),
              label: "Home",
            ),
                 BottomNavigationBarItem(
              icon: Icon(Iconsax.people),
              activeIcon: Icon(Iconsax.people),
              label: "groups",
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.add_square),
              activeIcon: Icon(Iconsax.add_square5),
              label: "Post",
              
            ),

            BottomNavigationBarItem(
              icon: Icon(Iconsax.user),
              activeIcon: Icon(Iconsax.user),
              label: "ProFile",
            ),
          
          ],
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}