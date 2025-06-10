import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/login-screen.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/components/admin/users-list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0; // Tracks selected tab

  final List<Widget> _screens = [
    UsersScreen(),
    Center(child: Text("Trigger Section (Coming Soon)", style: TextStyle(color: Colors.white))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data

    // Navigate to login screen and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false, // This removes all previous routes
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        
        title: Text(
          "Ecosoul Admin",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: Icon(Icons.account_circle, color: Colors.white, size: 28),
          //   onPressed: () {}, // Add profile navigation later
          // ),
          IconButton(
                        icon: Icon(Icons.logout, color: Colors.white),
                        onPressed: () => logout(context)),
        ],
      ),
      body: _screens[_selectedIndex], // Load respective screen
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.gold,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt),
            label: "Trigger",
          ),
        ],
      ),
    );
  }
}
