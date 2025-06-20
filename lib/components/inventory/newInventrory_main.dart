// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../Provider/sales_SKU_Provider.dart';
// import '../../comman_Screens/Inventory_SKU_Card_Screen.dart';
//
// class NewinventroryMain extends StatelessWidget {
//   const NewinventroryMain({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<InventoryProvider>(context, listen: false);
//     // Fetch data when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       provider.fetchProducts();
//     });
//
//     return Scaffold(
//       body: Consumer<InventoryProvider>(
//         builder: (context, provider, _) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (provider.error.isNotEmpty) {
//             return Center(child: Text(provider.error));
//           } else if (provider.inventoryList.isEmpty) {
//             return const Center(child: Text('No products found.'));
//           }
//
//            return ListView.builder(
//             itemCount: provider.inventoryList.length,
//             itemBuilder: (context, index) {
//               final product = provider.inventoryList[index];
//               return InventorySkuCardScreen(product: product);
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/comman_Screens/Inventory_SKU_Card_Web_Screen.dart';
import 'package:flutter_application_1/utils/check_platform.dart';
import 'package:flutter_application_1/utils/custom_dropdown.dart';
import 'package:provider/provider.dart';

import '../../Provider/sales_SKU_Provider.dart';
import '../../comman_Screens/Inventory_SKU_Card_Screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;

class NewInventoryMain extends StatefulWidget {
  const NewInventoryMain({super.key});

  @override
  State<NewInventoryMain> createState() => _NewInventoryMainState();
}

class _NewInventoryMainState extends State<NewInventoryMain> {
  String selectedSku = 'All';
  bool isWeb = false;
  bool isWideScreen = false;
  String? selectedCategory = 'All';
  List<String> categories = ['All'];
  String? productName = 'All'; // For searching by product
  List<String> productNames = ['All'];

  @override
  void initState() {
    super.initState();
    isWeb = checkPlatform();
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    provider.fetchSKUs().then((_) {
      provider.fetchAllInventory(productName: '', productCategory: '');
    });
    fetchCategories();
    fetchProductNames();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.thrivebrands.ai/api/inventory/productcategory'));

      if (response.statusCode == 200) {
        final List<dynamic> data = await json.decode(response.body);
        setState(() {
          // Start with "All Categories" and add the rest
          categories = ['All'] +
              data.map<String>((category) => category.toString()).toList();
          print('Available Categories: $categories');
        });
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  Future<void> fetchProductNames() async {
    try {
      final response = await http.get(
          Uri.parse('https://api.thrivebrands.ai/api/inventory/productname'));

      if (response.statusCode == 200) {
        final List<dynamic> data = await json.decode(response.body);
        setState(() {
          // Start with "All" and add the rest
          productNames = ['All'] +
              data.map<String>((category) => category.toString()).toList();
          print('Available Products: $productNames');
        });
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading Products: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    isWideScreen = MediaQuery.of(context).size.width > 600;
    int crossAxisCount = MediaQuery.of(context).size.width > 800 ? 2 : 1;

    print('Is wide screen: $isWideScreen');
    return Scaffold(
      //  appBar: AppBar(title: const Text("Inventory Viewer")),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.skuList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          List<String> dropdownItems = ['All', ...provider.skuList];

          return Column(
            children: [
              const SizedBox(height: 20),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: DropdownButtonFormField<String>(
              //     value: selectedSku,
              //     items: dropdownItems.map((sku) {
              //       return DropdownMenuItem(value: sku, child: Text(sku));
              //     }).toList(),
              //     onChanged: (value) {
              //       setState(() => selectedSku = value!);
              //       if (value == 'All') {
              //         provider.fetchAllInventory();
              //       } else {
              //         provider.fetchInventoryBySku(value!);
              //       }
              //     },
              //     decoration: const InputDecoration(
              //       labelText: 'Select SKU',
              //       border: OutlineInputBorder(),
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: Align(
              //     alignment: Alignment.center,
              //     child: ConstrainedBox(
              //       constraints: BoxConstraints(
              //         maxWidth: isWideScreen && isWeb
              //             ? 400
              //             : double.infinity, // Limit width on web
              //       ),
              //       child: DropdownButtonFormField<String>(
              //         value: selectedSku,
              //         items: dropdownItems.map((sku) {
              //           return DropdownMenuItem(value: sku, child: Text(sku));
              //         }).toList(),
              //         onChanged: (value) {
              //           setState(() => selectedSku = value!);
              //           if (value == 'All') {
              //             provider.fetchAllInventory();
              //           } else {
              //             provider.fetchInventoryBySku(value!);
              //           }
              //         },
              //         decoration: customInputDecoration(
              //           labelText: 'Select SKU',
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: [
              //       Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 16),
              //         child: Align(
              //           alignment: Alignment.center,
              //           child: ConstrainedBox(
              //             constraints: BoxConstraints(
              //               maxWidth:
              //                   isWideScreen && isWeb ? 250 : double.infinity,
              //             ),
              //             child: DropdownSearch<String>(
              //               items: dropdownItems, // your list of SKUs
              //               selectedItem: selectedSku,
              //               popupProps: PopupProps.menu(
              //                 showSearchBox: true,
              //                 searchFieldProps: TextFieldProps(
              //                   decoration: InputDecoration(
              //                     hintText: "Search SKU",
              //                     border: OutlineInputBorder(),
              //                   ),
              //                 ),
              //               ),
              //               dropdownDecoratorProps: DropDownDecoratorProps(
              //                 dropdownSearchDecoration:
              //                     customInputDecoration(labelText: 'Select SKU'),
              //               ),
              //               clearButtonProps: ClearButtonProps(isVisible: true),
              //               onChanged: (value) {
              //                 setState(() => selectedSku = value ?? 'All');
              //                 if (value == 'All' ||
              //                     value == null ||
              //                     value == '') {
              //                   provider.fetchAllInventory(
              //                       productName: productName ?? '',
              //                       productCategory: selectedCategory ?? '');
              //                 } else {
              //                   provider.fetchInventoryBySku(
              //                     sku: value,
              //                     productName: productName ?? '',
              //                     productCategory: selectedCategory ?? '',
              //                   );
              //                 }
              //               },
              //             ),
              //           ),
              //         ),
              //       ),
              //       SizedBox(
              //         width: 200,
              //         child: DropdownSearch<String>(
              //           items: categories,
              //           selectedItem: selectedCategory,
              //           popupProps: PopupProps.menu(
              //             showSearchBox: true,
              //             searchFieldProps: TextFieldProps(
              //               decoration: InputDecoration(
              //                 hintText: "Search Category",
              //                 border: OutlineInputBorder(),
              //               ),
              //             ),
              //           ),
              //           dropdownDecoratorProps: DropDownDecoratorProps(
              //             dropdownSearchDecoration:
              //                 customInputDecoration(labelText: 'Select Category'),
              //           ),
              //           clearButtonProps: ClearButtonProps(isVisible: true),
              //           onChanged: (value) async {
              //             setState(() {
              //               selectedCategory = value ?? "All";
              //               if (selectedSku == 'All' ||
              //                   selectedSku == null ||
              //                   selectedSku == '') {
              //                 provider.fetchAllInventory(
              //                   productName: productName ?? 'All',
              //                   productCategory: selectedCategory ?? 'All',
              //                 );
              //               } else {
              //                 provider.fetchInventoryBySku(
              //                   sku: selectedSku ?? '',
              //                   productName: productName ?? 'All',
              //                   productCategory: selectedCategory ?? 'All',
              //                 );
              //               }
              //               fetchCategories(); // If needed to re-fetch; otherwise remove it
              //             });
              //           },
              //         ),
              //       ),
              //       SizedBox(
              //         width: 200,
              //         child: DropdownSearch<String>(
              //           items: productNames,
              //           selectedItem: productName,
              //           popupProps: PopupProps.menu(
              //             showSearchBox: true,
              //             searchFieldProps: TextFieldProps(
              //               decoration: InputDecoration(
              //                 hintText: "Search Product",
              //                 border: OutlineInputBorder(),
              //               ),
              //             ),
              //           ),
              //           dropdownDecoratorProps: DropDownDecoratorProps(
              //             dropdownSearchDecoration:
              //                 customInputDecoration(labelText: 'Select Product'),
              //           ),
              //           clearButtonProps: ClearButtonProps(isVisible: true),
              //           onChanged: (value) async {
              //             setState(() {
              //               productName = value ?? "All";
                
              //               if (selectedSku == 'All' ||
              //                   selectedSku == null ||
              //                   selectedSku == '') {
              //                 provider.fetchAllInventory(
              //                   productName: productName ?? 'All',
              //                   productCategory: selectedCategory ?? 'All',
              //                 );
              //               } else {
              //                 provider.fetchInventoryBySku(
              //                   sku: selectedSku ?? '',
              //                   productName: productName ?? 'All',
              //                   productCategory: selectedCategory ?? 'All',
              //                 );
              //               }
              //               fetchCategories(); // Only include if needed, otherwise remove
              //             });
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
 
              SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 250,
          child: DropdownSearch<String>(
            items: dropdownItems,
            selectedItem: selectedSku,
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                   isDense: false, // Allow full height
                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  hintText: "Search SKU",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration:
                  customInputDecoration(labelText: 'Select SKU'),
            ),
            clearButtonProps: ClearButtonProps(isVisible: true),
            onChanged: (value) {
              setState(() => selectedSku = value ?? 'All');
              if (value == 'All' || value == null || value == '') {
                provider.fetchAllInventory(
                  productName: productName ?? '',
                  productCategory: selectedCategory ?? '',
                );
              } else {
                provider.fetchInventoryBySku(
                  sku: value,
                  productName: productName ?? '',
                  productCategory: selectedCategory ?? '',
                );
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 200,
          child: DropdownSearch<String>(
            items: categories,
            selectedItem: selectedCategory,
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                   isDense: false, // Allow full height
                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  hintText: "Search Category",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration:
                  customInputDecoration(labelText: 'Select Category'),
            ),
            clearButtonProps: ClearButtonProps(isVisible: true),
            onChanged: (value) async {
              setState(() {
                selectedCategory = value ?? "All";
                if (selectedSku == 'All' || selectedSku == null || selectedSku == '') {
                  provider.fetchAllInventory(
                    productName: productName ?? 'All',
                    productCategory: selectedCategory ?? 'All',
                  );
                } else {
                  provider.fetchInventoryBySku(
                    sku: selectedSku ?? '',
                    productName: productName ?? 'All',
                    productCategory: selectedCategory ?? 'All',
                  );
                }
                fetchCategories();
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 200,
          child: DropdownSearch<String>(
            items: productNames,
            selectedItem: productName,
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                   isDense: false, // Allow full height
                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  hintText: "Search Product",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration:
                  customInputDecoration(labelText: 'Select Product'),
            ),
            clearButtonProps: ClearButtonProps(isVisible: true),
            onChanged: (value) async {
              setState(() {
                productName = value ?? "All";
                if (selectedSku == 'All' || selectedSku == null || selectedSku == '') {
                  provider.fetchAllInventory(
                    productName: productName ?? 'All',
                    productCategory: selectedCategory ?? 'All',
                  );
                } else {
                  provider.fetchInventoryBySku(
                    sku: selectedSku ?? '',
                    productName: productName ?? 'All',
                    productCategory: selectedCategory ?? 'All',
                  );
                }
                fetchCategories();
              });
            },
          ),
        ),
      ],
    ),
  ),
),

              const SizedBox(height: 20),
              if (provider.isLoading)
                const CircularProgressIndicator()
              else if (provider.error.isNotEmpty)
                Text(provider.error)
              else if (provider.inventoryList.isEmpty)
                const Text('No inventory data found.')
              else
                isWideScreen && isWeb
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: MasonryGridView.count(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            itemCount: provider.inventoryList.length,
                            itemBuilder: (context, index) {
                              final product = provider.inventoryList[index];
                              return InventorySkuCardWebScreen(
                                  product: product);
                            },
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: provider.inventoryList.length,
                          itemBuilder: (context, index) {
                            final product = provider.inventoryList[index];
                            return InventorySkuCardScreen(product: product);
                          },
                        ),
                      ),
            ],
          );
        },
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:dio/dio.dart';
//
// import '../../comman_Screens/Inventory_SKU_Card_Screen.dart';
// import '../../utils/ApiConfig.dart';
// import '../../utils/colors.dart';
//
//
// class NewinventroryMain extends StatefulWidget {
//   const NewinventroryMain({super.key});
//
//   @override
//   State<NewinventroryMain> createState() => _NewinventroryMainState();
// }
//
// class _NewinventroryMainState extends State<NewinventroryMain> {
//   final DateFormat formatter = DateFormat('yyyy-MM-dd');
//   String displayedText = '';
//   String selectedOption = 'Today';
//   bool isLoading = true;
//   String error = '';
//   List<dynamic> inventoryList = [];
//   List<dynamic> allInventory = [];
//
//   DateTime? customStartDate;
//   DateTime? customEndDate;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchProducts();
//   }
//
//   Future<void> fetchProducts() async {
//     try {
//       var dio = Dio();
//       var response = await dio.get(ApiConfig.ukInventory);
//
//       if (response.statusCode == 200) {
//         setState(() {
//           allInventory = response.data;
//           filterData();
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           error = 'Error: ${response.statusMessage}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         error = 'Exception: $e';
//         isLoading = false;
//       });
//     }
//   }
//
//   void handleSelection(String selection) {
//     final now = DateTime.now();
//
//     switch (selection) {
//       case 'Today':
//         displayedText = 'Today: ${formatter.format(now)}';
//         break;
//       case 'This Week':
//         final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
//         displayedText = 'This Week: ${formatter.format(startOfWeek)} -- ${formatter.format(now)}';
//         break;
//       case 'Last 30 Days':
//         final start = now.subtract(Duration(days: 30));
//         displayedText = 'Last 30 Days: ${formatter.format(start)} -- ${formatter.format(now)}';
//         break;
//       case 'Last 6 Months':
//         final start = DateTime(now.year, now.month - 6, now.day);
//         displayedText = 'Last 6 Months: ${formatter.format(start)} -- ${formatter.format(now)}';
//         break;
//       case 'Last 12 Months':
//         final start = DateTime(now.year - 1, now.month, now.day);
//         displayedText = 'Last 12 Months: ${formatter.format(start)} -- ${formatter.format(now)}';
//         break;
//       case 'Custom Range':
//         if (customStartDate != null && customEndDate != null) {
//           displayedText = 'Custom: ${formatter.format(customStartDate!)} -- ${formatter.format(customEndDate!)}';
//         } else {
//           displayedText = 'Please select a custom range.';
//         }
//         break;
//     }
//
//     setState(() {
//       selectedOption = selection;
//     });
//
//     filterData();
//   }
//
//   void filterData() {
//     final now = DateTime.now();
//     DateTime? start;
//     DateTime? end;
//
//     switch (selectedOption) {
//       case 'Today':
//         start = DateTime(now.year, now.month, now.day);
//         end = start.add(const Duration(days: 1));
//         break;
//       case 'This Week':
//         start = now.subtract(Duration(days: now.weekday - 1));
//         end = now.add(const Duration(days: 1));
//
//         break;
//       case 'Last 30 Days':
//         start = now.subtract(const Duration(days: 30));
//         end = now.add(const Duration(days: 1));
//         break;
//       case 'Last 6 Months':
//         start = DateTime(now.year, now.month - 6, now.day);
//         end = now.add(const Duration(days: 1));
//         break;
//       case 'Last 12 Months':
//         start = DateTime(now.year - 1, now.month, now.day);
//         end = now.add(const Duration(days: 1));
//         break;
//       case 'Custom Range':
//         if (customStartDate != null && customEndDate != null) {
//           start = customStartDate;
//           end = customEndDate!.add(const Duration(days: 1));
//         }
//         break;
//     }
//
//
//     setState(() {
//       final inputFormat = DateFormat('dd-MMM-yyyy'); // Handles 18-Apr-2025 format
//
//       inventoryList = allInventory.where((item) {
//         if (!item.containsKey('Date')) return false;
//         final parts = item['Date'].toString().split('--');
//         if (parts.isEmpty) return false;
//
//         try {
//           final productDate = inputFormat.parse(parts[0].trim());
//           return (start != null &&
//               end != null &&
//               productDate.isAfter(start!.subtract(const Duration(seconds: 1))) &&
//               productDate.isBefore(end!));
//         } catch (_) {
//           return false;
//         }
//       }).toList();
//     });
//
//
//   }
//
//   Future<void> selectDateRange(BuildContext context) async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//
//     if (picked != null) {
//       setState(() {
//         customStartDate = picked.start;
//         customEndDate = picked.end;
//         displayedText = 'Custom: ${formatter.format(picked.start)} → ${formatter.format(picked.end)}';
//         selectedOption = 'Custom Range';
//       });
//       filterData();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: const Text('Sales SKU Data')),
//
//       appBar: AppBar(
//         title: Image.asset('assets/logo.png'),
//         centerTitle: true,
//         backgroundColor: AppColors.primaryBlue,
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//
//
//
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           const SizedBox(height: 16),
//           DropdownButton<String>(
//             value: selectedOption,
//             items: [
//               'Today',
//               'This Week',
//               'Last 30 Days',
//               'Last 6 Months',
//               'Last 12 Months',
//               'Custom Range'
//             ].map((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {
//               if (newValue != null) {
//                 if (newValue == 'Custom Range') {
//                   selectDateRange(context);
//                 } else {
//                   handleSelection(newValue);
//                 }
//               }
//             },
//           ),
//           const SizedBox(height: 8),
//           Text(displayedText),
//           const SizedBox(height: 16),
//           Expanded(
//             child: error.isNotEmpty
//                 ? Center(child: Text(error))
//                 : inventoryList.isEmpty
//                 ? const Center(child: Text('No products found.'))
//                 : ListView.builder(
//               itemCount: inventoryList.length,
//               itemBuilder: (context, index) {
//                 final product = inventoryList[index];
//                 //return ProductCard(product: product);
//                 return InventorySkuCardScreen(product: product);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }