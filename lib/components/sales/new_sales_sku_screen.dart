// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../Provider/sales_SKU_Provider.dart';
// import '../../comman_Screens/productcard.dart';
//
// class NewSalesSkuScreen extends StatefulWidget {
//   const NewSalesSkuScreen({super.key});
//
//   @override
//   State<NewSalesSkuScreen> createState() => _NewSalesSkuScreenState();
// }
//
// class _NewSalesSkuScreenState extends State<NewSalesSkuScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => Provider.of<SalesSkuProvider>(context, listen: false).fetchProducts());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<SalesSkuProvider>(context);
//     return Scaffold(
//       body: provider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : provider.error.isNotEmpty
//           ? Center(child: Text(provider.error))
//           : provider.inventoryList.isEmpty
//           ? const Center(child: Text('No products found.'))
//           : ListView.builder(
//         itemCount: provider.inventoryList.length,
//         itemBuilder: (context, index) {
//           final product = provider.inventoryList[index];
//           return ProductCard(product: product);
//         },
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../comman_Screens/Inventory_SKU_Card_Screen.dart';
import '../../comman_Screens/productcard.dart';
import '../../utils/ApiConfig.dart';
import '../../utils/colors.dart';


class NewSalesSkuScreen extends StatefulWidget {
  const NewSalesSkuScreen({super.key});

  @override
  State<NewSalesSkuScreen> createState() => _NewSalesSkuScreenState();
}

class _NewSalesSkuScreenState extends State<NewSalesSkuScreen> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  String displayedText = '';
  String selectedOption = 'This Week';
  bool isLoading = true;
  String error = '';
  List<dynamic> inventoryList = [];
  List<dynamic> allInventory = [];

  DateTime? customStartDate;
  DateTime? customEndDate;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      var dio = Dio();
      var response = await dio.get(ApiConfig.salesSku);

      if (response.statusCode == 200) {
        setState(() {
          allInventory = response.data;
          filterData();
          print("Sales sku data response :: ${allInventory}");
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error: ${response.statusMessage}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Exception: $e';
        isLoading = false;
      });
    }
  }
  void handleSelection(String selection) {
    final now = DateTime.now();

    switch (selection) {
      case 'Today':
        displayedText = 'Today: ${formatter.format(now)}';
        break;
      case 'This Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        displayedText = 'This Week: ${formatter.format(startOfWeek)} -- ${formatter.format(now)}';
        break;
      case 'Last 30 Days':
        final start = now.subtract(Duration(days: 30));
        displayedText = 'Last 30 Days: ${formatter.format(start)} -- ${formatter.format(now)}';
        break;
      case 'Last 6 Months':
        final start = DateTime(now.year, now.month - 6, now.day);
        displayedText = 'Last 6 Months: ${formatter.format(start)} -- ${formatter.format(now)}';
        break;
      case 'Last 12 Months':
        final start = DateTime(now.year - 1, now.month, now.day);
        displayedText = 'Last 12 Months: ${formatter.format(start)} -- ${formatter.format(now)}';
        break;
      case 'Custom Range':
        if (customStartDate != null && customEndDate != null) {
          displayedText = 'Custom: ${formatter.format(customStartDate!)} -- ${formatter.format(customEndDate!)}';
        } else {
          displayedText = 'Please select a custom range.';
        }
        break;
    }

    setState(() {
      selectedOption = selection;
    });

    filterData();
  }
  void filterData() {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    switch (selectedOption) {
      case 'Today':
        start = DateTime(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1));
        break;
      case 'This Week':
        start = now.subtract(Duration(days: now.weekday - 1));
        end = now.add(const Duration(days: 1));
        break;
      case 'Last 30 Days':
        start = now.subtract(const Duration(days: 30));
        end = now.add(const Duration(days: 1));
        break;
      case 'Last 6 Months':
        start = DateTime(now.year, now.month - 6, now.day);
        end = now.add(const Duration(days: 1));
        break;
      case 'Last 12 Months':
        start = DateTime(now.year - 1, now.month, now.day);
        end = now.add(const Duration(days: 1));
        break;
      case 'Custom Range':
        if (customStartDate != null && customEndDate != null) {
          start = customStartDate;
          end = customEndDate!.add(const Duration(days: 1));
        }
        break;
    }


    DateTime excelSerialToDate(int serial) {
      return DateTime(1900, 1, 1).add(Duration(days: serial - 2)); // Excel starts at 1 Jan 1900, but there's a bug with 1900 being considered a leap year
    }

    setState(() {
      inventoryList = allInventory.where((item) {
        if (!item.containsKey('purchase-date')) return false;

        final rawDate = item['purchase-date'];
        DateTime purchaseDate;

        try {
          // Check if it's a serial number (int or numeric string)
          if (rawDate is int || RegExp(r'^\d+$').hasMatch(rawDate.toString())) {
            purchaseDate = excelSerialToDate(int.parse(rawDate.toString()));
          } else {
            purchaseDate = DateTime.parse(rawDate.toString());
          }

          return (start != null && end != null && purchaseDate.isAfter(start!) && purchaseDate.isBefore(end!));
        } catch (_) {
          return false;
        }
      }).toList();
    });


    // setState(() {
    //   inventoryList = allInventory.where((item) {
    //     if (!item.containsKey('purchase-date')) return false;
    //     final parts = item['purchase-date'].toString().split('--');
    //     if (parts.length != 2) return false;
    //
    //     try {
    //       final intervalStart = DateTime.parse(parts[0].trim());
    //       final intervalEnd = DateTime.parse(parts[1].trim());
    //
    //       return (start != null &&
    //           end != null &&
    //           intervalStart.isBefore(end!) &&
    //           intervalEnd.isAfter(start!));
    //     } catch (_) {
    //       return false;
    //     }
    //   }).toList();
    // });
  }
  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        customStartDate = picked.start;
        customEndDate = picked.end;
        displayedText = 'Custom: ${formatter.format(picked.start)} → ${formatter.format(picked.end)}';
        selectedOption = 'Custom Range';
      });
      filterData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Sales SKU Data')),

      // appBar: AppBar(
      //   title: Image.asset('assets/logo.png'),
      //   centerTitle: true,
      //   backgroundColor: AppColors.primaryBlue,
      //   iconTheme: IconThemeData(color: Colors.white),
      // ),



      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment:MainAxisAlignment.end,
            children: [
              //Text(displayedText),
              DropdownButton<String>(
                value: selectedOption,
                items: [
                  'Today',
                  'This Week',
                  'Last 30 Days',
                  'Last 6 Months',
                  'Last 12 Months',
                  'Custom Range'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    if (newValue == 'Custom Range') {
                      selectDateRange(context);
                    } else {
                      handleSelection(newValue);
                    }
                  }
                },
              ),
              SizedBox(width: 15,)
            ],
          ),

         // const SizedBox(height: 8),

         // const SizedBox(height: 16),
          Expanded(
            child: error.isNotEmpty
                ? Center(child: Text(error))
                : inventoryList.isEmpty
                ? const Center(child: Text('No products found.'))
                : ListView.builder(
              itemCount: inventoryList.length,
              itemBuilder: (context, index) {
                final product = inventoryList[index];
                //return ProductCard(product: product);
                return ProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}