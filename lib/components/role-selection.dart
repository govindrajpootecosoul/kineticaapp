import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/admin/admin-home.dart';
import 'package:flutter_application_1/components/homepage.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/utils/colors.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        title: Text(
          "Thrive Labs",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center( // Wrap everything inside Center to align to center
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Align content to center
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
            Text(
              "Select Role",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 30), // Add space between text and buttons
            _buildRoleButton(context, "Admin", Icons.admin_panel_settings),
            SizedBox(height: 20),
            _buildRoleButton(context, "User", Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String role, IconData icon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8, // Centered with margin
      height: 60, // Increase button height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16), // Adjust padding
        ),
        onPressed: () {
          if (role == "Admin") {
            Navigator.pushReplacement(context,  MaterialPageRoute(builder: (context) => AdminScreen()));
          } else {
            Navigator.pushReplacement(context,  MaterialPageRoute(builder: (context) => MainLayout()));
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24), // Role-specific icon
            SizedBox(width: 10), // Space between icon and text
            Text(
              role,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
