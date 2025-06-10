import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/admin/admin-home.dart';
import 'package:flutter_application_1/components/homepage.dart';
import 'package:flutter_application_1/components/role-selection.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  List<String> _countries = [];
  List<String> _roles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Future<void> _loadData() async {
  //   try {
  //     await Future.delayed(Duration(seconds: 3)); 
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? token = prefs.getString("jwt_token");
  //     final url = Uri.parse("https://hidden-cecile-rishabhgadhia-69e2a871.koyeb.app/auth/user-data");
  //     final response = await http.get(
  //     url,
  //     headers: {
  //       "Content-Type": "application/json",
  //       "authorization": "Bearer $token"
  //       },
  //   );
  //   final responseData = jsonDecode(response.body);
  //   print(responseData);
  //   String name = responseData["name"];
  //   List<dynamic> roles = responseData["roles"];


  //   // Store metadata in SharedPreferences
  //   await prefs.setString('name', name);
  //   await prefs.setStringList('roles', roles.map((e) => e.toString()).toList());

  //   // Redirect based on role
  //   navigateBasedOnRoles(context, roles);
    



  //     // // Mock API response
  //     // List<String> fetchedCountries = ["United States", "India", "Canada", "Australia"];
  //     // List<String> fetchedRoles = ["Admin", "User"];

  //     // setState(() {
  //     //   _countries = fetchedCountries;
  //     //   _roles = fetchedRoles;
  //     // });

  //     // // Navigate to Home Screen after loading
  //     // Navigator.pushReplacementNamed(context, '/home', arguments: {
  //     //   "countries": _countries,
  //     //   "roles": _roles,
  //     // });
  //   } catch (e) {
  //     print("Error fetching data: $e");
  //   }
  // }



  Future<void> _loadData() async {
  try {
    await Future.delayed(Duration(seconds: 3));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("jwt_token");
    String? userId = prefs.getString("user_id");

    if (token == null || userId == null) {
      throw Exception("Missing token or user ID");
    }

    final url = Uri.parse("https://vectorauthbackend.onrender.com/auth/user/$userId");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $token"
      },
    );

    final responseData = jsonDecode(response.body);
    print("responseData =====> $responseData");
    print("User data response ===> ${responseData['roles']}");

    String name = responseData["name"];
    List<dynamic> roles = responseData["roles"];
    print("roles =======> $roles");

    await prefs.setString('name', name);
    await prefs.setStringList('roles', roles.map((e) => e.toString().toUpperCase()).toList());
    // roles = roles.map((e) => e.toString().toUpperCase()) as List;
    roles = roles.map((e) => e.toString().toUpperCase()).toList();
  print("roles 2 =======> $roles");
    navigateBasedOnRoles(context, roles);
  } catch (e) {
    print("Error fetching user data: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error loading user data")),
    );
  }
}


 void navigateBasedOnRoles(BuildContext context, List<dynamic> roles) {
  Widget targetScreen = (roles.length == 1)
      ? (roles.contains("ADMIN") ? AdminScreen() : MainLayout())
      : RoleSelectionScreen();

  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => targetScreen));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitWave(
              color: Colors.black,
              size: 50.0,
            ), // Bar chart loader effect
            SizedBox(height: 20),
            Text("Getting things ready...", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  } 
}
