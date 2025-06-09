import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../financescreens/Finance_Executive_Screen.dart';
import '../utils/ApiConfig.dart';
import '../utils/colors.dart';
import '../utils/date_dropdown.dart';
import 'inventory/inventory_executive.dart';

class New_HomePage extends StatefulWidget {
  @override
  _New_HomePageState createState() => _New_HomePageState();
}

class _New_HomePageState extends State<New_HomePage> {
  List<dynamic> allData = [];
  dynamic selectedMonthData;
  dynamic selectedMonthDataa;
  List<String> availableMonths = [];
  String? selectedMonth;

  bool isLoading = true;
  String error = '';
  List<dynamic> inventoryList = [];
  List<dynamic> allInventory = [];


  double totalUnitCount = 0.0;
  double totalOrderItemCount = 0.0;
  double totalOrderCount = 0.0;
  double totalSalesAmount = 0.0;


  // @override
  // void initState() {
  //   super.initState();
  //   fetchData();
  //   fetchProducts();
  // }


  @override
  void initState() {
    super.initState();

    // Initialize startDate and endDate with default values (or fetch them from somewhere if required)
    final now = DateTime.now();
    DateTime startDate = now;  // Default to 'now'
    DateTime endDate = now.add(const Duration(days: 1)); // Default to 'tomorrow'

    // You can change the initialization of startDate and endDate based on your needs
    fetchData();  // This method can stay as is
    fetchProducts(startDate, endDate);  // Pass startDate and endDate to fetchProducts
  }



  //date filter
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  String displayedText = '';
  String selectedOption = 'This Week';


  DateTime? customStartDate;
  DateTime? customEndDate;

/*/////salesSku
  Future<void> fetchProducts() async {
    try {
      var dio = Dio();
      var response = await dio.get(ApiConfig.salesSku);

      if (response.statusCode == 200) {
        setState(() {
          allInventory = response.data;
          filterData();
          print("Sales sku data response filterData :: ${filterData}");
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
  }*/

///mmmmm
 /* Future<void> fetchProducts() async {
    try {
      var dio = Dio();
      var response = await dio.get(ApiConfig.salesSku);

      if (response.statusCode == 200) {
        setState(() {
          allInventory = response.data;
          isLoading = false;

          // Replace with your desired date range
          DateTime startDate = DateTime(2025, 4, 1);
          DateTime endDate = DateTime(2025, 5, 1);


          print("Sales sku data response filterData :: ${filterData}");

          // Process and print summary
          processInventoryData(allInventory, startDate, endDate);
          final filteredData = _filterDataByDateRange(allInventory, startDate, endDate);

          setState(() {
            totalUnitCount = _calculateTotalField(filteredData, 'unitCount');
            totalOrderItemCount = _calculateTotalField(filteredData, 'orderItemCount');
            totalOrderCount = _calculateTotalField(filteredData, 'orderCount');
            totalSalesAmount = _calculateTotalField(filteredData, 'totalSalesamount');
          });

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
  }*/



  /// Call this function after fetching your API data
  void processInventoryData(List<dynamic> inventoryData, DateTime startDate, DateTime endDate) {
    final filteredData = _filterDataByDateRange(inventoryData, startDate, endDate);

    final totalUnitCount = _calculateTotalField(filteredData, 'unitCount');
    final totalOrderItemCount = _calculateTotalField(filteredData, 'orderItemCount');
    final totalOrderCount = _calculateTotalField(filteredData, 'orderCount');
    final totalSalesAmount = _calculateTotalField(filteredData, 'totalSalesamount');

    print("🔹 Filtered Items: ${filteredData.length}");
    print("🔹 Total Unit Count: $totalUnitCount");
    print("🔹 Total Order Item Count: $totalOrderItemCount");
    print("🔹 Total Order Count: $totalOrderCount");
    print("🔹 Total Sales Amount: £$totalSalesAmount");
  }

  /// Filter data by checking interval overlap with selected range
  List<dynamic> _filterDataByDateRange(List<dynamic> data, DateTime startDate, DateTime endDate) {
    return data.where((item) {
      final interval = item['interval'];
      if (interval == null || !(interval is String) || !interval.contains('--')) return false;

      final parts = interval.split('--');
      if (parts.length != 2) return false;

      try {
        final itemStart = DateTime.parse(parts[0]);
        final itemEnd = DateTime.parse(parts[1]);
        return itemEnd.isAfter(startDate) && itemStart.isBefore(endDate);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  /// Calculate the sum of a numeric field across the data list
  double _calculateTotalField(List<dynamic> data, String fieldName) {
    return data.fold(0.0, (sum, item) {
      final value = item[fieldName];
      if (value is int || value is double) return sum + value;
      if (value is String) return sum + (double.tryParse(value) ?? 0.0);
      return sum;
    });
  }


  void handleSelection(String selection) {
    final now = DateTime.now();

    // Initialize startDate and endDate with default values
    DateTime startDate = now;  // Default to 'now'
    DateTime endDate = now.add(const Duration(days: 1)); // Default endDate to 'tomorrow'

    switch (selection) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1)); // End of today
        displayedText = 'Today: ${formatter.format(startDate)}';
        break;
      case 'This Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Start of the week (Monday)
        startDate = startOfWeek;
        endDate = now.add(const Duration(days: 1)); // End of today
        displayedText = 'This Week: ${formatter.format(startDate)} -- ${formatter.format(now)}';
        break;
      case 'Last 30 Days':
        startDate = now.subtract(const Duration(days: 30));
        endDate = now.add(const Duration(days: 1)); // End of today
        displayedText = 'Last 30 Days: ${formatter.format(startDate)} -- ${formatter.format(now)}';
        break;
      case 'Last 6 Months':
        startDate = DateTime(now.year, now.month - 6, now.day); // 6 months ago
        endDate = now.add(const Duration(days: 1)); // End of today
        displayedText = 'Last 6 Months: ${formatter.format(startDate)} -- ${formatter.format(now)}';
        break;
      case 'Last 12 Months':
        startDate = DateTime(now.year - 1, now.month, now.day); // 12 months ago
        endDate = now.add(const Duration(days: 1)); // End of today
        displayedText = 'Last 12 Months: ${formatter.format(startDate)} -- ${formatter.format(now)}';
        break;
      case 'Custom Range':
        if (customStartDate != null && customEndDate != null) {
          startDate = customStartDate!;
          endDate = customEndDate!.add(const Duration(days: 1)); // Add one day to include the full end date
          displayedText = 'Custom: ${formatter.format(startDate)} -- ${formatter.format(endDate)}';
        } else {
          displayedText = 'Please select a custom range.';
          return; // Exit if no custom date range is selected
        }
        break;
    }

    // Update the selected option and filter data
    setState(() {
      selectedOption = selection;
    });

    fetchProducts(startDate, endDate); // Fetch products with dynamic date range
  }


  Future<void> fetchProducts(DateTime startDate, DateTime endDate) async {
    try {
      var dio = Dio();
      var response = await dio.get(ApiConfig.salesSku, queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      });

      if (response.statusCode == 200) {
        setState(() {
          allInventory = response.data;
          isLoading = false;

          print("Sales sku data response filterData :: ${filterData}");

          // Process and print summary
          processInventoryData(allInventory, startDate, endDate);
          final filteredData = _filterDataByDateRange(allInventory, startDate, endDate);

          setState(() {
            totalUnitCount = _calculateTotalField(filteredData, 'unitCount');
            totalOrderItemCount = _calculateTotalField(filteredData, 'orderItemCount');
            totalOrderCount = _calculateTotalField(filteredData, 'orderCount');
            totalSalesAmount = _calculateTotalField(filteredData, 'totalSalesamount');
          });
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

  void filterData(DateTime startDate, DateTime endDate) {
    setState(() {
      inventoryList = allInventory.where((item) {
        if (!item.containsKey('interval')) return false;
        final parts = item['interval'].toString().split('--');
        if (parts.length != 2) return false;

        try {
          final intervalStart = DateTime.parse(parts[0].trim());
          final intervalEnd = DateTime.parse(parts[1].trim());

          // Return items that fall within the selected date range
          return intervalStart.isBefore(endDate) && intervalEnd.isAfter(startDate);
        } catch (_) {
          return false;
        }
      }).toList();
    });
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

      // Fetch products with custom date range
      fetchProducts(customStartDate!, customEndDate!);
    }
  }



/*


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
        print("start date ::: ${start}");
        print("end  date ::: ${end}");
        break;
      case 'This Week':
        start = now.subtract(Duration(days: now.weekday - 1));
        end = now.add(const Duration(days: 1));
        print("start date ::: ${start}");
        print("end  date ::: ${end}");
        break;
      case 'Last 30 Days':
        start = now.subtract(const Duration(days: 30));
        end = now.add(const Duration(days: 1));
        print("start date ::: ${start}");
        print("end  date ::: ${end}");
        break;
      case 'Last 6 Months':
        start = DateTime(now.year, now.month - 6, now.day);
        end = now.add(const Duration(days: 1));
        print("start date ::: ${start}");
        print("end  date ::: ${end}");
        break;
      case 'Last 12 Months':
        start = DateTime(now.year - 1, now.month, now.day);
        end = now.add(const Duration(days: 1));
        print("start date ::: ${start}");
        print("end  date ::: ${end}");
        break;
      case 'Custom Range':
        if (customStartDate != null && customEndDate != null) {
          start = customStartDate;
          end = customEndDate!.add(const Duration(days: 1));
        }
        break;
    }

    setState(() {
      inventoryList = allInventory.where((item) {
        if (!item.containsKey('interval')) return false;
        final parts = item['interval'].toString().split('--');
        if (parts.length != 2) return false;

        try {
          final intervalStart = DateTime.parse(parts[0].trim());
          final intervalEnd = DateTime.parse(parts[1].trim());

          return (start != null &&
              end != null &&
              intervalStart.isBefore(end!) &&
              intervalEnd.isAfter(start!));
        } catch (_) {
          return false;
        }
      }).toList();
    });
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
*/

  //




  // Future<void> fetchData() async {
  //   final response = await http.get(Uri.parse(ApiConfig.pnlData));
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     allData = data;
  //
  //     // Extract unique months
  //     final months = allData.map((e) {
  //       final date = excelDateToDateTime(e['Year-Month']);
  //       return DateFormat.yMMMM().format(date); // "April 2025"
  //     }).toSet().toList();
  //
  //     months.sort((a, b) => a.compareTo(b)); // sort by date
  //     setState(() {
  //       availableMonths = months;
  //       selectedMonth = months.isNotEmpty ? months.first : null;
  //       updateSelectedMonthData();
  //     });
  //   } else {
  //     throw Exception('Failed to load data');
  //   }
  // }





////  pnlData
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(ApiConfig.pnlData));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      allData = data;

      // Extract unique months from data
      final months = allData.map((e) {
        final date = excelDateToDateTime(e['Year-Month']);
        return DateFormat.yMMMM().format(date); // e.g., "April 2025"
      }).toSet().toList();

      // Sort months in ascending order
      months.sort((a, b) {
        final dateA = DateFormat.yMMMM().parse(a);
        final dateB = DateFormat.yMMMM().parse(b);
        return dateA.compareTo(dateB);
      });

      // Get current month as "MMMM yyyy"
      final currentMonth = DateFormat.yMMMM().format(DateTime.now());

      // Find current month in list or fallback to previous month
      String? selected;
      if (months.contains(currentMonth)) {
        selected = currentMonth;
      } else {
        // Find the most recent month before current month
        for (int i = months.length - 1; i >= 0; i--) {
          final monthDate = DateFormat.yMMMM().parse(months[i]);
          if (monthDate.isBefore(DateTime.now())) {
            selected = months[i];
            break;
          }
        }
      }

      setState(() {
        availableMonths = months;
        selectedMonth = selected;
        updateSelectedMonthData();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  DateTime excelDateToDateTime(int serial) {
    return DateTime.fromMillisecondsSinceEpoch(((serial - 25569) * 86400000), isUtc: true);
  }

  void updateSelectedMonthData() {
    if (selectedMonth == null) return;

    final selectedMonthList = allData.where((e) {
      return DateFormat.yMMMM().format(excelDateToDateTime(e['Year-Month'])) == selectedMonth;
    }).toList();

    // Sum up all values for the selected month
    selectedMonthData = {
      'Total Sales': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Total Sales'] ?? 0.0)),
      'Total Returns': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Total Returns'] ?? 0.0)),
      'COGS': selectedMonthList.fold(0.0, (sum, e) => sum + (e['COGS'] ?? 0.0)),
      'CM1': selectedMonthList.fold(0.0, (sum, e) => sum + (e['CM1'] ?? 0.0)),
      'Inventory': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Inventory'] ?? 0.0)),
      'Liquidations': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Liquidations'] ?? 0.0)),
      'FBA Reimbursement': selectedMonthList.fold(0.0, (sum, e) => sum + (e['FBA Reimbursement'] ?? 0.0)),
      'Storage Fee': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Storage Fee'] ?? 0.0)),
      'Shipping Service': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Shipping Service'] ?? 0.0)),
      'Ad Spend': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Spend'] ?? 0.0)),
      'Discounts': selectedMonthList.fold(0.0, (sum, e) => sum + (e['promotional rebates'] ?? 0.0)),
      'Net Selling Fee': selectedMonthList.fold(0.0, (sum, e) => sum + (e['selling fees'] ?? 0.0)),
      'Final Service Fee': selectedMonthList.fold(0.0, (sum, e) => sum + (e['fba fees'] ?? 0.0)),
      'CM2': selectedMonthList.fold(0.0, (sum, e) => sum + (e['CM2'] ?? 0.0)),
      'CM3': selectedMonthList.fold(0.0, (sum, e) => sum + (e['CM3'] ?? 0.0)),
    };

    setState(() {});
  }
  ////

  Widget dataRow(String title, dynamic value, {Color? valueColor}) {
    // Check for negative values and apply red color
    valueColor = value != null && value < 0 ? Colors.red : valueColor;

    bool isCM = title == 'CM1' || title == 'CM2' || title == 'CM3';

    final rowContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isCM ? FontWeight.bold : FontWeight.normal,
                fontSize: isCM ? 18 : 14,
              ),
            ),
          ),
          Text(
            '\$ ${value != null ? value.toStringAsFixed(2) : "0.00"}',
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontWeight: isCM ? FontWeight.bold : FontWeight.w600,
              fontSize: isCM ? 16 : 14,
            ),
          ),
        ],
      ),
    );

    if (isCM) {
      return Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: rowContent,
      );
    } else {
      return rowContent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  appBar: AppBar(title: Text('Finance Executive')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: allData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month filter dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
               // Text("Profit & Loss",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.brown,fontSize: 24),),
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




                //
                // SizedBox(
                //   width: 160,
                //   child: DropdownButton<String>(
                //     value: selectedMonth,
                //     isExpanded: true,
                //     items: availableMonths
                //         .map((month) => DropdownMenuItem(
                //       value: month,
                //       child: Text(month),
                //     ))
                //         .toList(),
                //     onChanged: (value) {
                //       setState(() {
                //         selectedMonth = value;
                //         updateSelectedMonthData();
                //       });
                //     },
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 20),
            if (selectedMonthData != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            // isLoading
                            //     ? SpinKitWave(
                            //   color: AppColors.gold,
                            //   size: 50.0,
                            // )
                            //     : BarChartComponent(
                            //   apiData: responseData,
                            //   yAxisMetric:
                            //   _selectedUnits == 'Units Sold'
                            //       ? 'unitCount'
                            //       : 'totalSales',
                            //   granularity:
                            //   _fetchGranularity(_selectedTime),
                            // ),
                            SizedBox(height: 10),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     Text(
                            //       'Updated \${updatedAt}',
                            //       style: TextStyle(
                            //           color: AppColors.gold,
                            //           fontWeight: FontWeight.bold),
                            //     )
                            //   ],
                            // ),
                            Divider(
                                color: AppColors.gold,
                                thickness: 0.5), // Adds a line
                            SizedBox(height: 10),
                            // isLoading
                            //     ? SizedBox(height: 10)
                            //     :
                      Column(
                              children: [
                                // Text("data"),



                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [






                                    Expanded(
                                        child: MetricCard(
                                            title: "Overall Sales", value: totalSalesAmount.toString() ??"0")),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: MetricCard(
                                            title: "Units Orders", value:totalUnitCount.toString() )),

                                    //  Text("Total Unit Count: $totalUnitCount"),
                                    //         Text("Total Order Item Count: $totalOrderItemCount"),
                                    //         Text("Total Order Count: $totalOrderCount"),
                                    //         Text("Total Sales Amount: £$totalSalesAmount"),

                                  ],
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                        child: MetricCard(
                                            title: "Amazon Inventory", value: "00")),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: MetricCard(
                                            title: "Sellable \nInventory", value:"00" )),

                                  ],
                                ),

                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                        child: MetricCard(
                                            title: "AOV", value: "00")),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: MetricCard(
                                            title: "Organic Sale%", value:"00" )),

                                  ],
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                        child: MetricCard(
                                            title: "Ad Spend", value: "00")),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: MetricCard(
                                            title: "Ad Sales", value:"00" )),

                                  ],
                                ),

                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                        child: MetricCard(
                                            title: "ACOS", value: "00")),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: MetricCard(
                                            title: "TACOS", value:"00" )
                                    ),

                                  ],
                                ),

                              ],
                            ),

                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                    child: MetricCard(
                                        title: "CM ₁", value: selectedMonthData['CM1'].toStringAsFixed(0)??"00.0")),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: MetricCard(
                                        title: "CM ₂",value: selectedMonthData['CM2'].toStringAsFixed(0)??"00.0")),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: MetricCard(
                                        title: "CM ₃",value: selectedMonthData['CM3'].toStringAsFixed(0)??"00.0")),
                              ],
                            ),
                            isLoading
                                ? SizedBox(height: 10)
                                : TextButton(
                              onPressed: () {

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => FinanceExecutiveScreen(productval:"1")),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Centers the text
                                children: [
                                  Text(
                                    'View full P&L',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                      8), // Space between text and icon
                                  Icon(Icons.arrow_forward,
                                      color: AppColors.gold),
                                ],
                              ),
                            ),

                            Divider(color: AppColors.gold, thickness: 0.5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),



              // Expanded(
              //   child: SingleChildScrollView(
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         dataRow("Amazon Revenue", selectedMonthData['Total Sales'],
              //             valueColor: selectedMonthData['Total Sales'] < 0 ? Colors.red : Colors.green),
              //         dataRow("Amazon Returns", selectedMonthData['Total Returns'],
              //             valueColor: selectedMonthData['Total Returns'] < 0 ? Colors.red : Colors.green),
              //         dataRow("Net Revenue", selectedMonthData['Total Sales'],
              //             valueColor: selectedMonthData['Total Sales'] < 0 ? Colors.red : Colors.green),
              //         dataRow("COGS", selectedMonthData['COGS'],
              //             valueColor: selectedMonthData['COGS'] < 0 ? Colors.red : Colors.green),
              //         dataRow("CM1", selectedMonthData['CM1'],
              //             valueColor: selectedMonthData['CM1'] < 0 ? Colors.red : Colors.green),
              //         dataRow("Inventory", selectedMonthData['Inventory'],
              //             valueColor: selectedMonthData['Inventory'] < 0 ? Colors.red : Colors.green),
              //         dataRow("Liquidation Cost", selectedMonthData['Liquidations'],
              //             valueColor: selectedMonthData['Liquidations'] < 0 ? Colors.red : Colors.green),
              //         dataRow("Reimbursement", selectedMonthData['FBA Reimbursement'],
              //             valueColor: selectedMonthData['FBA Reimbursement'] < 0 ? Colors.red : Colors.green),
              //         dataRow("Storage Fee", selectedMonthData['Storage Fee'],
              //             valueColor: selectedMonthData['Storage Fee'] < 0 ? Colors.red : Colors.green),
              //         dataRow("Shipping Service", selectedMonthData['Shipping Service'],
              //             valueColor: selectedMonthData['Shipping Service'] < 0 ? Colors.red : Colors.green),
              //         dataRow("CM2", selectedMonthData['CM2'],
              //             valueColor: selectedMonthData['CM2'] < 0 ? Colors.red : Colors.green),
              //         dataRow("Ad Spend", selectedMonthData['Ad Spend'],
              //             valueColor: selectedMonthData['Ad Spend'] < 0 ? Colors.red : Colors.green),
              //         dataRow("Discounts", selectedMonthData['Discounts'],
              //             valueColor: selectedMonthData['Discounts'] < 0 ? Colors.red : Colors.green),
              //         dataRow("Net Selling Fee", selectedMonthData['Net Selling Fee'],
              //             valueColor: selectedMonthData['Net Selling Fee'] < 0 ? Colors.red : Colors.green),
              //         dataRow("Final Service Fee", selectedMonthData['Final Service Fee'],
              //             valueColor: selectedMonthData['Final Service Fee'] < 0 ? Colors.red : Colors.green),
              //         dataRow("CM3", selectedMonthData['CM3'],
              //             valueColor: selectedMonthData['CM3'] < 0 ? Colors.red : Colors.green),
              //       ],
              //     ),
              //   ),
              // ),
          ],
        ),
      ),
    );
  }
}



class MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const MetricCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.beige,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16),
              // textAlign: TextAlign.left
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
              ),
              // textAlign: TextAlign.left
            ),
          ],
        ),
      );
  }


}


