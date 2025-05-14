import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/admin/admin-home.dart';
import 'package:flutter_application_1/components/admin/users-list.dart';
import 'package:flutter_application_1/components/homepage.dart';
import 'package:flutter_application_1/components/inventory/inventory_main.dart';
import 'package:flutter_application_1/components/login-screen.dart';
import 'package:flutter_application_1/components/marketing/marekting_main.dart';
import 'package:flutter_application_1/components/sales/sales.dart';
import 'package:flutter_application_1/components/sales/sales_main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Provider/sales_SKU_Provider.dart';
import 'components/New_Home_Screen.dart';
import 'components/inventory/inventory_tab_screen.dart';
import 'components/inventory/newInventrory_main.dart';
import 'components/new_hoome.dart';
import 'components/profit_loss.dart';
import 'financescreens/Finance_Executive_Screen.dart';
import 'financescreens/finance_sku.dart';

// void main() {
//   runApp(MyApp());
// }

void main() async {

  runApp(
     // await dotenv.load(fileName: ".env");
      MultiProvider(
      providers: [
      ChangeNotifierProvider(create: (_) => SalesSkuProvider()),
  ChangeNotifierProvider(create: (_) => InventoryProvider()),
  ],
  child:  MyApp(),
  ),
  );
}


class MyApp extends StatelessWidget {
  Future<bool> _isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("jwt_token"); // Fetch token
    return token != null && token.isNotEmpty; // Return true if token exists
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _isUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return MainLayout();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  //int _selectedIndex = -1; // Default: nothing selected
  String selectedSubItem = "";
  String _selectedRegion = "United Kingdom";
  String username = "";

  final List<Widget> _pages = [
    // HomePage(),
    //New_HomePage(),
    NewHomeScreen(),// Home page body
    SalesMainPage(),
    InventoryTabScreen(),// Sales page body (Add this in `pages/sales_page.dart`)
   // InventoryMainPage(),
    //NewinventroryMain(),
    MarketingMainPage(), // Placeholder for Menu
  ];

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<dynamic> countriesMap = [
    {"name": "United States", "code": "us"},
    {"name": "Canada", "code": "ca"},
    {"name": "India", "code": "in"},
    {"name": "Australia", "code": "au"},
    {"name": "United Kingdom", "code": "gb"},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username =
          prefs.getString('name') ?? "Guest"; // Provide default value if null
      setRegion(_selectedRegion);
    });
  }

  void setRegion(String region) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('region', region);
  }

  String? getCountryCode(String selectedRegion) {
    var country = countriesMap.firstWhere(
      (country) =>
          country["name"].toLowerCase() == selectedRegion.toLowerCase(),
      orElse: () => null, // Return null if not found
    );

    return country?["code"]; // Get the code or return null
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Container(
          color: AppColors.beige,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                  height: 80, // Set your desired height
                  padding: EdgeInsets.all(0),
                  child: DrawerHeader(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Row(children: [
                        Image.network(
                          "https://flagcdn.com/w40/${getCountryCode(_selectedRegion)}.png",
                          width: 30,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                        Spacer(), // Push settings icon to right

                        // Settings Icon
                        Icon(
                          Icons.settings,
                          color: Colors.black54,
                        ),
                      ]))),
              ...countriesMap.map((country) {
                return ListTile(
                  leading: Image.network(
                    "https://flagcdn.com/w20/${country['code']}.png",
                    width: 20,
                    height: 15,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.flag, color: Colors.grey),
                  ),
                  title: Container(
                    child: Text(
                      country["name"]!,
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                  ),
                  trailing: _selectedRegion == country["name"]
                      ? Icon(Icons.check_circle, color: Colors.black)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedRegion = country["name"]!;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
      endDrawer: Drawer(
        child: Container(
          color: AppColors.beige,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: AppColors.primaryBlue),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Push items apart
                  children: [
                    // Username Text
                    Text(
                      username,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),

                    IconButton(
                        icon: Icon(Icons.logout, color: Colors.white),
                        onPressed: () => logout(context)),
                  ],
                ),
              ),

              _buildMenuItem(
                  Icons.bar_chart, "Sales", ["Executive", "SKU", "Region"], () {
                setState(() {
                  _selectedIndex = 1;
                  _scaffoldKey.currentState?.closeEndDrawer();
                });
              }),


              _buildMenuItem(Icons.campaign, "Advertising",
                  ["Executive", "Campaigns", "Ad Groups", "Targeting", ""], () {
                setState(() {
                  _selectedIndex = 3;
                  _scaffoldKey.currentState?.closeEndDrawer();
                });
              }),
              _buildMenuItem(Icons.inventory, "Performance", [""], () {
                setState(() {
                  // _selectedIndex = 2;
                  _scaffoldKey.currentState?.closeEndDrawer();
                });
              }),
              _buildMenuItem(Icons.inventory, "Inventory", ["SKU"], () {
                setState(() {
                  _selectedIndex = 2;
                  _scaffoldKey.currentState?.closeEndDrawer();
                });
              }),





              ExpansionTile(
                leading: Icon(Icons.attach_money),
                title: Text("Finance"),
                children: [
                  ListTile(
                    title: Text("Executive"),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                        selectedSubItem = "Executive";

                        Navigator.push(
                          context,
                         // MaterialPageRoute(builder: (context) => ProfitLossPage()),
                          MaterialPageRoute(builder: (context) => FinanceExecutiveScreen()),
                            //ProfitLossPage
                        );
                        // Navigator.pop(context); // Close drawer
                      });
                    },
                  ),
                  ListTile(
                    title: Text("SKU"),
                    onTap: () {
                      setState(() {
                        // _selectedIndex = 0;
                        // selectedSubItem = "SKU";
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NewFinanceSkuScreen()),
                          //ProfitLossPage
                        );
                       // Navigator.pop(context); // Close drawer
                      });
                    },
                  ),
                ],
              ),


              // Drawer(
              //   child: ListView(
              //     children: [
              //       ExpansionTile(
              //         leading: Icon(Icons.attach_money),
              //         title: Text("Finance"),
              //         children: [
              //           ListTile(
              //             title: Text("Executive"),
              //             onTap: () {
              //               setState(() {
              //                 _selectedIndex = 0;
              //                 selectedSubItem = "Executive";
              //                 Navigator.push(
              //                   context,
              //                   MaterialPageRoute(builder: (context) => NewinventroryMain()),
              //                 );
              //                // Navigator.pop(context); // Close drawer
              //               });
              //             },
              //           ),
              //           ListTile(
              //             title: Text("SKU"),
              //             onTap: () {
              //               setState(() {
              //                 _selectedIndex = 0;
              //                 selectedSubItem = "SKU";
              //                 Navigator.pop(context); // Close drawer
              //               });
              //             },
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),





              // _buildMenuItem(Icons.attach_money, "Finance", ["Executive","SKU"], () {
              //
              //   setState(() {
              //     _selectedIndex = 0;
              //
              //     print("Finance");
              //     print(_selectedIndex);
              //
              //       // Navigator.push(
              //       //   context,
              //       //   MaterialPageRoute(builder: (context) => NewinventroryMain()),
              //       // );
              //
              //    // _scaffoldKey.currentState?.closeEndDrawer();
              //   });
              // }),
              _buildMenuItem(Icons.inventory, "Pricing", [""], () {
                setState(() {
                  // _selectedIndex = 2;
                  _scaffoldKey.currentState?.closeEndDrawer();
                });
              }),

              _buildMenuItem(Icons.inventory, "User Permission", [""], () {
                setState(() {
                  // _selectedIndex = 2;
                  _scaffoldKey.currentState?.closeEndDrawer();
                });
              }),

              _buildMenuItem(Icons.account_circle, "Account", [], () {
                setState(() {
                  _selectedIndex = 0;
                  print("account");
                  _scaffoldKey.currentState?.closeEndDrawer();
                });
              }),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        title: Image.asset('assets/logo.png'),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Padding(
              padding: EdgeInsets.only(left: 8), // Add left padding
              child: Row(
                mainAxisSize: MainAxisSize.max, // Keeps Row compact
                children: [
                  Flexible(
                    // Prevents overflow
                    child: Image.network(
                      "https://flagcdn.com/w40/${getCountryCode(_selectedRegion)}.png",
                      width: 70,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Dynamically change body
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
             // BottomNavigationBarItem(icon: Icon(Icons.home), label: 'New_HomePage'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart), label: 'Sales'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.inventory), label: 'Inventory'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.campaign_outlined), label: 'Marketing'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: AppColors.gradientStart,
            onTap: _onItemTapped,
            backgroundColor: AppColors.beige,
            type: BottomNavigationBarType.fixed,
          ),
          // Floating AI Button
          Positioned(
              top: -30, // Move button upwards to overlap
              left: MediaQuery.of(context).size.width / 2 -
                  30, // Center the button
              child: FloatingActionButton(
                onPressed: () {
                  print("AI Button Clicked");
                },
                backgroundColor: AppColors.primaryBlue,
                elevation: 5,
                shape: CircleBorder(),
                child: ClipOval(
                  child: Image.asset(
                    'assets/ai.png', // Replace with your image path
                    width: 40, // Adjust size if needed
                    height: 40,
                    fit: BoxFit.cover, // Ensures it covers the entire button
                  ),
                ),
              )),
        ],
      ),
    );
  }

      Widget _buildMenuItem(
          IconData icon, String title, List<String> subItems, VoidCallback onTap) {
        return ExpansionTile(
          leading: Icon(icon, color: AppColors.primaryBlue), // Main menu icon
          title:
          GestureDetector(
            onTap: onTap, // Handle menu item click
            child: Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          children: subItems.isNotEmpty
              ? subItems
                  .map((subItem) => ListTile(
                        title: Text(subItem),
                        onTap: () {

                          print("Selected index:::");

                          print("print subtitle:::");
                          print(subItem);
                         // print(_selectedIndex);
                          // Handle submenu item click
                        },
                      ))
                  .toList()
              : [],
        );
      }

  // Widget _buildMenuItem(
  //     IconData icon,
  //     String title,
  //     List<String> subItems,
  //     VoidCallback onTap,
  //     ) {
  //   return ExpansionTile(
  //     leading: Icon(icon, color: AppColors.primaryBlue),
  //     title: GestureDetector(
  //       onTap: onTap,
  //       child: Text(
  //         title,
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
  //       ),
  //     ),
  //     children: subItems.isNotEmpty
  //         ? subItems.asMap().entries.map((entry) {
  //       int index = entry.key;
  //       String subItem = entry.value;
  //
  //       return ListTile(
  //         title: Text(subItem),
  //         onTap: () {
  //           print("Selected sub-item index: $index");
  //           print("Selected sub-item: $subItem");
  //           print("Selected menu title: $title");
  //           print("Selected _selectedIndex: $_selectedIndex");
  //
  //           // You can update selected index if needed
  //           setState(() {
  //             _selectedIndex = index;
  //           });
  //
  //           // Example: Navigate if SKU is selected
  //           if (subItem == "SKU") {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => NewinventroryMain()),
  //             );
  //           }
  //
  //           // Optionally close drawer
  //           _scaffoldKey.currentState?.closeEndDrawer();
  //         },
  //       );
  //     }).toList()
  //         : [],
  //   );
  // }


}
