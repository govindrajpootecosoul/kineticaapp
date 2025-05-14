import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddUserDialog extends StatefulWidget {
  final Function onUserAdded;

  AddUserDialog({required this.onUserAdded});

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String email = "";
  String password = "";
  List<String> selectedRoles = [];

  Future<void> createUser() async {
    final response = await http.post(
      Uri.parse("https://hidden-cecile-rishabhgadhia-69e2a871.koyeb.app/auth/signup"), // Update with actual API
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": name,
        "email": email,
        "password": password,
        "roles": selectedRoles,
      }),
    );

    if (response.statusCode == 201) {
      widget.onUserAdded();
      Navigator.pop(context);
    } else {
      print("Error adding user: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cream,
      title: Text("Add New User", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(decoration: InputDecoration(labelText: "Name", labelStyle: TextStyle(color: AppColors.gold)), onChanged: (val) => name = val),
            TextFormField(decoration: InputDecoration(labelText: "Email", labelStyle: TextStyle(color: AppColors.gold)), onChanged: (val) => email = val),
            TextFormField(decoration: InputDecoration(labelText: "Password", labelStyle: TextStyle(color: AppColors.gold)), obscureText: true, onChanged: (val) => password = val),
            CheckboxListTile(
              title: Text("Admin",
              style: TextStyle(
                color: AppColors.gold
              ),),
              
              activeColor: AppColors.gold,
              value: selectedRoles.contains("Admin"),
              onChanged: (bool? value) {
                setState(() {
                  value! ? selectedRoles.add("Admin") : selectedRoles.remove("Admin");
                });
              },
            ),
            CheckboxListTile(
              title: Text("User",
              style: TextStyle(
                color: AppColors.gold
              ),
              ),
              activeColor: AppColors.gold,
              value: selectedRoles.contains("User"),
              onChanged: (bool? value) {
                setState(() {
                  value! ? selectedRoles.add("User") : selectedRoles.remove("User");
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(onPressed: createUser, child: Text("Submit")),
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
      ],
    );
  }
}
