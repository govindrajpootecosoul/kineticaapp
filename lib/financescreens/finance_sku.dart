import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/financescreens/product_info_card.dart';
import 'package:flutter_application_1/utils/check_platform.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../utils/ApiConfig.dart';
import '../utils/colors.dart';
import 'package:http/http.dart' as http;

class NewFinanceSkuScreen extends StatefulWidget {
  const NewFinanceSkuScreen({super.key});

  @override
  State<NewFinanceSkuScreen> createState() => _SalesSkuPageState();
}

class _SalesSkuPageState extends State<NewFinanceSkuScreen> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  String displayedText = '';
  String selectedOption = 'Today';
  bool isLoading = true;
  String error = '';
  List<dynamic> inventoryList = [];
  List<dynamic> allInventory = [];

  DateTime? customStartDate;
  DateTime? customEndDate;
  List<dynamic> allData = [];
  Map<String, double>? selectedMonthData;
  List<String> availableMonths = [];
  String? selectedMonth;
  String selectedYearMonth = "";
  bool isWeb = false;

  @override
  void initState() {
    super.initState();
    isWeb = checkPlatform();
    // fetchProducts();
    fetchAvailableMonths(); // Get month list
    fetchData(); // Fetch all data initially
    print("fetchProducts in initState");
  }

  Future<void> fetchAvailableMonths() async {
    try {
      final response =
          await http.get(Uri.parse("${ApiConfig.pnlData}/?sku=&date="));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final monthsSet =
            data.map<String>((e) => e['Year-Month'] as String).toSet();
        final monthsList = monthsSet.toList();
        monthsList.sort((a, b) {
          final dateA = DateFormat('yyyy-MM').parse(a);
          final dateB = DateFormat('yyyy-MM').parse(b);
          return dateA.compareTo(dateB);
        });

        setState(() {
          availableMonths = [
            "All",
            ...monthsList.map((e) =>
                DateFormat('MMMM yyyy').format(DateFormat('yyyy-MM').parse(e)))
          ];
          selectedMonth =
              availableMonths.isNotEmpty ? availableMonths.first : null;
        });
      }
    } catch (e) {
      print("Error fetching months: $e");
    }
  }

  // Future<void> fetchData() async {
  //   isLoading = true;
  //   try {
  //     final response =
  //         await http.get(Uri.parse("${ApiConfig.pnlData}/?sku=&date="));
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);

  //       // Store data locally
  //       allData = data;

  //       // Extract unique months in "yyyy-MM" format, then convert to readable "MMMM yyyy"
  //       final monthsSet =
  //           allData.map<String>((e) => e['Year-Month'] as String).toSet();

  //       // Sort months in ascending order
  //       final monthsList = monthsSet.toList();
  //       monthsList.sort((a, b) {
  //         final dateA = DateFormat('yyyy-MM').parse(a);
  //         final dateB = DateFormat('yyyy-MM').parse(b);
  //         return dateA.compareTo(dateB);
  //       });

  //       setState(() {
  //         availableMonths = monthsList
  //             .map((e) => DateFormat('MMMM yyyy')
  //                 .format(DateFormat('yyyy-MM').parse(e)))
  //             .toList();
  //         selectedMonth =
  //             availableMonths.isNotEmpty ? availableMonths.first : null;
  //         updateSelectedMonthData();
  //       });
  //       isLoading = false;
  //       print("availableMonths ==========================> $availableMonths");
  //     } else {
  //       isLoading = false;
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //     isLoading = false;
  //     print('Error fetching data: $e');
  //   }
  // }

  Future<void> fetchData({String date = ""}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.pnlData}/?sku=&date=$date"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          inventoryList = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void updateSelectedMonthData() {
    if (selectedMonth == null) return;

    // Convert selectedMonth "MMMM yyyy" back to "yyyy-MM" for filtering
    // setState(() {
    selectedYearMonth = DateFormat('yyyy-MM')
        .format(DateFormat('MMMM yyyy').parse(selectedMonth!));
    // });

    fetchData();
  }

  Future<void> fetchProducts() async {
    isLoading = true;
    try {
      var dio = Dio();
      print("dio in fetchProducts");
      var response = await dio.get(ApiConfig.pnlData);

      if (response.statusCode == 200) {
        setState(() {
          allInventory = response.data;
          print("allInventory ==========================> ${allInventory[0]}");
          filterData();
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
        displayedText =
            'This Week: ${formatter.format(startOfWeek)} -- ${formatter.format(now)}';
        break;
      case 'Last 30 Days':
        final start = now.subtract(Duration(days: 30));
        displayedText =
            'Last 30 Days: ${formatter.format(start)} -- ${formatter.format(now)}';
        break;
      case 'Last 6 Months':
        final start = DateTime(now.year, now.month - 6, now.day);
        displayedText =
            'Last 6 Months: ${formatter.format(start)} -- ${formatter.format(now)}';
        break;
      case 'Last 12 Months':
        final start = DateTime(now.year - 1, now.month, now.day);
        displayedText =
            'Last 12 Months: ${formatter.format(start)} -- ${formatter.format(now)}';
        break;
      case 'Custom Range':
        if (customStartDate != null && customEndDate != null) {
          displayedText =
              'Custom: ${formatter.format(customStartDate!)} -- ${formatter.format(customEndDate!)}';
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
    print("start date ==============> $start");
    print("end date ==============> $end");
    print("selectedOption ==============> $selectedOption");
    setState(() {
      inventoryList = allInventory.where((item) {
        if (!item.containsKey('Year-Month')) return false;

        final parts = item['Year-Month'].toString().split('--');
        print(parts);

        if (parts.isEmpty) return false;

        try {
          final excelSerial =
              int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), ''));
          if (excelSerial == null) return false;

          // Excel epoch starts from 1899-12-30 in Dart (to handle leap year bug)
          final excelEpoch = DateTime(1899, 12, 30);
          final productDate = excelEpoch.add(Duration(days: excelSerial));

          print(productDate.toIso8601String());

          return (start != null &&
              end != null &&
              productDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
              productDate.isBefore(end));
        } catch (_) {
          return false;
        }
      }).toList();
    });

    // setState(() {
    //   inventoryList = allInventory.where((item) {
    //     // if (!item.containsKey('Year-Month')) return false;
    //     // final parts = item['Year-Month'].toString().split('--');
    //
    //     if (!item.containsKey('interval')) return false;
    //     final parts = item['interval'].toString().split('--');
    //
    //
    //     print(parts);
    //     print("date formateeeeeeeee.........");
    //     if (parts.isEmpty) return false;
    //
    //     try {
    //       final product5Date = DateTime.parse(parts[0]);
    //       return (start != null &&
    //           end != null &&
    //           productDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
    //           productDate.isBefore(end));
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
        displayedText =
            'Custom: ${formatter.format(picked.start)} → ${formatter.format(picked.end)}';
        selectedOption = 'Custom Range';
      });
      filterData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Sales SKU Data')),

      appBar: AppBar(
        // title: Image.asset('assets/logo.png'),
        title: const Text(
          'Finance SKU',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
                // DropdownButton<String>(
                //   value: selectedOption,
                //   items: [
                //     'Today',
                //     'This Week',
                //     'Last 30 Days',
                //     'Last 6 Months',
                //     'Last 12 Months',
                //     'Custom Range'
                //   ].map((String value) {
                //     return DropdownMenuItem<String>(
                //       value: value,
                //       child: Text(value),
                //     );
                //   }).toList(),
                //   onChanged: (String? newValue) {
                //     if (newValue != null) {
                //       if (newValue == 'Custom Range') {
                //         selectDateRange(context);
                //       } else {
                //         handleSelection(newValue);
                //       }
                //     }
                //   },
                // ),
                SizedBox(
                  width: 160,
                  child: DropdownButton<String>(
                      value: selectedMonth,
                      isExpanded: true,
                      items: availableMonths
                          .map((month) => DropdownMenuItem(
                                value: month,
                                child: Text(month),
                              ))
                          .toList(),
                      // onChanged: (value) {
                      //   setState(() {
                      //     selectedMonth = value;
                      //     updateSelectedMonthData();
                      //   });
                      // },
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          selectedMonth = value;
                        });

                        if (value == "All") {
                          fetchData(); // No date filter
                        } else {
                          final formattedDate = DateFormat('yyyy-MM')
                              .format(DateFormat('MMMM yyyy').parse(value));
                          fetchData(date: formattedDate);
                        }
                      }),
                ),
                const SizedBox(height: 8),
                // Text(displayedText),
                //show in display
                const SizedBox(height: 16),
                // Expanded(
                //   child: error.isNotEmpty
                //       ? Center(child: Text(error))
                //       : inventoryList.isEmpty
                //           ? const Center(child: Text('No products found.'))
                //           : ListView.builder(
                //               itemCount: inventoryList.length,
                //               itemBuilder: (context, index) {
                //                 final product = inventoryList[index];
                //                 return ProductCard(product: product);
                //               },
                //             ),
                // ),
                // Expanded(
                //   child: error.isNotEmpty
                //       ? Center(child: Text(error))
                //       : inventoryList.isEmpty
                //           ? const Center(child: Text('No products found.'))
                //           : ListView.builder(
                //               itemCount: inventoryList.length,
                //               itemBuilder: (context, index) {
                //                 final product = inventoryList[index];
                //                 return ProductInfoCard(product: product);
                //               },
                //             ),
                // ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: isWeb
                        ? MasonryGridView.count(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            itemCount: inventoryList.length,
                            itemBuilder: (context, index) {
                              final product = inventoryList[index];
                              return Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth: 400), // Adjust as needed
                                  child: ProductInfoCard(
                                      product:
                                          product), // or InventorySkuCardScreen
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: inventoryList.length,
                            itemBuilder: (context, index) {
                              final product = inventoryList[index];
                              return ProductInfoCard(
                                  product:
                                      product); // or InventorySkuCardScreen
                            },
                          ),
                  ),
                )
              ],
            ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Widget buildLabelValue(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(value.toString(), style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return GestureDetector(
      onTap: _toggleExpand,
      child: Card(
        color: AppColors.beige,
        margin: const EdgeInsets.all(10),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['product-name']?.toString() ?? '',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Flexible(
                  //   flex: 3,
                  //   child: Image.network(
                  //     "https://www.kineticasports.com/cdn/shop/files/kinetica-sports-227kg-whey-choc-974567.png?v=1715782106&width=1200",
                  //     height: 130,
                  //     fit: BoxFit.fitHeight,
                  //   ),
                  // ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabelValue("SKU", product['SKU'] ?? "00"),
                        buildLabelValue("Date", product['interval'] ?? "N/A"),
                        //  buildLabelValue("Sales", product['Total Sales']?? "00"),
                        buildLabelValue(
                            "Sales",
                            ((product['Total Sales'] ?? 0).toDouble())
                                .toStringAsFixed(0)),

                        // buildLabelValue("CM2", product['CM2']?? "00"),
                        buildLabelValue(
                            "CM2",
                            ((product['CM2'] ?? 0).toDouble())
                                .toStringAsFixed(0)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabelValue("ASIN", product['asin'] ?? "N/A"),
                        // buildLabelValue("CM1", product['CM1']?? '00'),
                        //buildLabelValue("CM3", product['CM3']?? '00'),
                        buildLabelValue(
                            "CM1",
                            ((product['CM1'] ?? 0).toDouble())
                                .toStringAsFixed(0)),

                        buildLabelValue(
                            "CM3",
                            ((product['CM3'] ?? 0).toDouble())
                                .toStringAsFixed(0)),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const Divider(height: 30),
                const Center(
                  child: Text(
                    "Inventory Details",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.brown,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    buildLabelValueExpend("Warehouse Inventory",
                        product['afn-warehouse-quantity'] ?? "00"),
                    buildLabelValueExpend("Total Sellable",
                        product['afn-fulfillable-quantity'] ?? "00"),
                    buildLabelValueExpend(
                        "Inventory Age",
                        (product['inv-age-0-to-30-days'] ?? "00") +
                            (product['inv-age-31-to-60-days'] ?? "00") +
                            (product['inv-age-61-to-90-days'] ?? "00") +
                            (product['inv-age-91-to-180-days'] ?? "00") +
                            (product['inv-age-181-to-270-days'] ?? "00") +
                            (product['inv-age-271-to-365-days'] ?? "00") +
                            (product['inv-age-365-plus-days'] ?? "00")),
                    buildLabelValueExpend(
                        "DOS", product['days-of-supply'] ?? "00"),
                    buildLabelValueExpend("Customer Reserved",
                        product['Customer_reserved'] ?? "00"),
                    buildLabelValueExpend(
                        "FC Transfer", product['FC_Transfer'] ?? "00"),
                    buildLabelValueExpend(
                        "FC Processing", product['FC_Processing'] ?? "00"),
                    buildLabelValueExpend("Unfullfilled",
                        product['afn-unsellable-quantity'] ?? "00"),
                    buildLabelValueExpend("Inbound Recieving",
                        product['afn-inbound-receiving-quantity'] ?? "00"),
                  ],
                ),
                const Divider(height: 30),
                // const Center(
                //   child: Text(
                //     "Shipment Details",
                //     style: TextStyle(
                //       fontSize: 30,
                //       color: Colors.brown,
                //       fontWeight: FontWeight.w500,
                //       decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
                // GridView.count(
                //   shrinkWrap: true,
                //   crossAxisCount: 3,
                //   crossAxisSpacing: 1,
                //   mainAxisSpacing: 1,
                //   physics: const NeverScrollableScrollPhysics(),
                //   children: [
                //     buildLabelValueExpend("Current Inventory", product['afn-warehouse-quantity'] ?? "N/A"),
                //     buildLabelValueExpend("Current DOS", product['ASIN'] ?? "N/A"),
                //     buildLabelValueExpend("Shipment Quantity", product['ASIN'] ?? "N/A"),
                //     buildLabelValueExpend("Shipment Date", product['ASIN'] ?? "N/A"),
                //   ],
                // ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildLabelValueExpend(String label, dynamic value) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      //color: const Color(0xECD5B0),
      color: Colors.white60,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Text(value.toString(), style: const TextStyle(fontSize: 13)),
      ],
    ),
  );
}
