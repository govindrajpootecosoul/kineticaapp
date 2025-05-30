// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/components/loading_screen.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../main.dart';
// import 'admin/admin-home.dart';
// import 'homepage.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../utils/colors.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   Future<void> loginUser() async {
//     final url = Uri.parse(
//         "https://hidden-cecile-rishabhgadhia-69e2a871.koyeb.app/auth/login");
//
//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "email": emailController.text,
//         "password": passwordController.text,
//       }),
//     );
//
//     final responseData = jsonDecode(response.body);
//     if (response.statusCode == 201) {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString("jwt_token", responseData['data']['token']);
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoadingScreen()),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MainLayout()),
//         // AdminScreen() : MainLayout())
//       );
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   SnackBar(content: Text("Invalid credentials")),
//       // );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryBlue,
//       body: Stack(
//         children: [
//           // Background Image
//           Positioned.fill(
//             child: Image.asset(
//               "assets/login-bg.png",
//               fit: BoxFit.cover,
//             ),
//           ),
//
//           // Login Form
//           Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 30),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Image.asset('assets/vectorai.png', width: 330, height: 200),
//                   const SizedBox(height: 40),
//
//                   Text(
//                     "Welcome Back\nEnter your email to sign in",
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.montserrat(
//                       fontSize: 16,
//                       color: Colors.white70,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   _buildTextField(emailController, "Email Address"),
//                   const SizedBox(height: 15),
//
//                   _buildTextField(passwordController, "Password", isPassword: true),
//                   const SizedBox(height: 20),
//
//                   // Login Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.gold,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//
//                       //without login
//                       onPressed: (){
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (context) => MainLayout()),
//                           // AdminScreen() : MainLayout())
//                         );
//                       },
//                      // loginUser,
//                       child: const Text(
//                         "Continue",
//                         style: TextStyle(fontSize: 16, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Signup Link
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("New Account?", style: TextStyle(color: Colors.white70)),
//                       const SizedBox(width: 5),
//                       GestureDetector(
//                         onTap: () {
//                           // Handle Sign Up
//                         },
//                         child: Text(
//                           "Sign Up Now",
//                           style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//
//                   Text(
//                     "By clicking continue, you agree to our Terms of Service and Privacy Policy",
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.white70, fontSize: 12),
//                   ),
//                   const SizedBox(height: 20),
//
//                   Image.asset('assets/newlogo.png', width: 125),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String labelText, {bool isPassword = false}) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.2),
//         labelText: labelText,
//         labelStyle: const TextStyle(color: Colors.white),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/loading_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    final url = Uri.parse(
        "https://hidden-cecile-rishabhgadhia-69e2a871.koyeb.app/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text,
        "password": passwordController.text,
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt_token", responseData['data']['token']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoadingScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/login-bg.png",
              fit: BoxFit.cover,
            ),
          ),

          // Login Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/vectorai.png', width: 330, height: 200),
                  const SizedBox(height: 40),

                  Text(
                    "Welcome Back\nEnter your email to sign in",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(emailController, "Email Address"),
                  const SizedBox(height: 15),

                  _buildTextField(passwordController, "Password", isPassword: true),
                  const SizedBox(height: 20),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: loginUser,
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Signup Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New Account?", style: TextStyle(color: Colors.white70)),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          // Handle Sign Up
                        },
                        child: Text(
                          "Sign Up Now",
                          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "By clicking continue, you agree to our Terms of Service and Privacy Policy",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 20),

                  Image.asset('assets/newlogo.png', width: 125),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}