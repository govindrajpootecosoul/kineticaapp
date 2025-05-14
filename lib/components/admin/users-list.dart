import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/components/admin/add-user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token'); // Get stored token

    if (token == null) {
      print("No token found");
      setState(() => isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse("https://hidden-cecile-rishabhgadhia-69e2a871.koyeb.app/auth/allUsers"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

      
      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
      setState(() => isLoading = false);
    }
  }

  void openAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(onUserAdded: fetchUsers),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: openAddUserDialog,
            child: Text("Add New User", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: "Search users...",
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
          ),
          SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.gold))
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      if (!user["name"].toLowerCase().contains(searchQuery)) return SizedBox();
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(user["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(user["email"]),
                          leading: Icon(Icons.person, color: AppColors.gold),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
