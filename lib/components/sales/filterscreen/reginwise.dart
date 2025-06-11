import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/financescreens/Finance_Executive_Web_Screen.dart';
import 'package:flutter_application_1/utils/check_platform.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../cm1.dart';
import '../../../comman_Screens/productcard.dart';
import '../../../graph/commanbarchar_file.dart';
import '../../../utils/ApiConfig.dart';
import '../../../utils/chart_config.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_dropdown.dart';
import '../../../utils/formatNumberStringWithComma.dart';
import '../../Dashboard.dart';
// Import the package

//int zeroInStockRateSkuCount = 0;

class Filter_SalesRereginwiseScreen extends StatefulWidget {
  ///final List<dynamic> data;
  @override
  State<Filter_SalesRereginwiseScreen> createState() =>
      _Filter_SalesRereginwiseScreenState();
}

class _Filter_SalesRereginwiseScreenState
    extends State<Filter_SalesRereginwiseScreen> {
  List<String> states = [];
  List<String> cities = [];
  List<String> skus = [];
  bool isWeb = false;

  List<dynamic> inventoryList = [];
  //bool isLoading = true;
  String error = '';

  // String Instock = '00';
  // String Overstock = '00';
  // String Understock = '00';
  String DaysInStock = '00';

  int understockCount = 0;
  int overstockCount = 0;
  int balancedCount = 0;
  //int zeroInStockRateSkuCount = 0;

  //final Map<String, int> stockCounts = countStockStatus();

  //late TabController _tabController;

  // final List<Tab> myTabs = const [
  //   Tab(text: 'Account Level'),
  //   Tab(text: 'ASINs'),
  // ];

  // List<String> filterTypes = [
  //   '6months',
  //   "yeartodate",
  //   "monthtodate",
  //   "last30days",
  //   "year",
  //   "lastmonth",
  //   "today",
  //   "custom",
  // ];

  List<String> filterTypes = [
    // "today",
    //"week",
    //"last30days",
    "lastmonth",
    "monthtodate",
    //"previousyear",
    // "currentyear",
    "yeartodate",
    "custom"
    // "monthtodate",
    // "lastmonth",
    //'6months',
    //"yeartodate",
    // "custom",
  ];

  String formatFilterType(String filter) {
    switch (filter) {
      // case 'today':
      //   return 'Today';
      //   case 'week':
      //   return 'Week';
      // case '6months':
      //   return 'Last 6 Months';
      // case 'last30days':
      //   return 'Last 30 Days';
      // case 'yeartodate':
      //   return 'Year to Date';
      case 'lastmonth':
        return 'Previous Month';
      case 'monthtodate':
        return 'Current Month';

      // case 'year':
      //   return 'This Year';
      //   case 'previousyear':
      //     return 'Previous Year';
      // case 'currentyear':
      case 'yeartodate':
        return 'Current Year';
      case 'custom':
        return 'Custom Range';
      default:
        return filter;
    }
  }

/*  List<String> filterTypes = [
    // "today",
    //"week",
    //"last30days",
    "monthtodate",
    "lastmonth",
    //'6months',
    //"yeartodate",
    "custom",
  ];*/

  String? selectedState;
  String? selectedCity;
  String? selectedSku;
  String? selectedFilterType;

  DateTime? startDate;
  DateTime? endDate;

  //List<SalesSku> salesData = [];
  // bool isLoading = false;
  Map<String, dynamic>? salesData;
  Map<String, dynamic>? adssales;
  //bool isLoading = true;
  String errorMessage = '';

  // double? totalAdSales;
  // double? totalAdSpend;
  // String? errorMsg;

  // double totalAdSales = 0.0;
  // double totalAdSpend = 0.0;
  bool isLoading = false;
  String? errorMsg;

  List<double> values = [10, 20, 30];
  List<String> labels = [];
  Map<String, double> monthlyTotals = {};

  @override
  void initState() {
    super.initState();
    isWeb = checkPlatform();
    //_tabController = TabController(length: myTabs.length, vsync: this);
    selectedFilterType = 'lastmonth'; // Set default to "6months"
    fetchDropdownData();

    fetchFilteredData();
    fetchExecutiveData();
    fetchAdData(); // Automatically fetch data for 6 months on screen load
  }

  @override
  void dispose() {
    // _tabController.dispose();
    super.dispose();
  }
  //inventory data
  // double calculateTotalDaysInStock(List<dynamic> data) {
  //   double totalCost = 0.0;
  //
  //   for (var item in data) {
  //     final cost = double.tryParse(
  //         item['InStock_Rate_Percent'].toString()) ??
  //         0.0;
  //     totalCost += cost;
  //   }
  //   // Round to nearest whole number
  //   return totalCost.roundToDouble();
  // }

  Map<String, int> countStockStatus(List<dynamic> data) {
    Map<String, int> statusCounts = {
      'Understock': 0,
      'Overstock': 0,
      'Balanced': 0,
    };

    for (var item in data) {
      final status = item['Stock_Status']?.toString();
      if (status != null && statusCounts.containsKey(status)) {
        statusCounts[status] = statusCounts[status]! + 1;
      }
    }

    return statusCounts;
  }

  int calculateTotalDaysInStock(List<dynamic> data) {
    double totalCost = 0.0;
    int count = 0;

    for (var item in data) {
      final cost = double.tryParse(item['InStock_Rate_Percent'].toString());
      if (cost != null) {
        totalCost += cost;
        count++;
      }
    }

    if (count == 0) return 0;

    // Return rounded whole number
    return (totalCost / count).round();
  }

  // Future<void> fetchExecutiveData() async {
  //   try {
  //     var dio = Dio();
  //     var response = await dio.get('${ApiConfig.baseUrl}/inventory');
  //
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = response.data;
  //
  //       // Calculate DaysInStock average
  //       double totaldayinstock = calculateTotalDaysInStock(data);
  //       String daysInStockFormatted = formatNumberStringWithComma(totaldayinstock.toString());
  //
  //       // Count stock statuses
  //       Map<String, int> statusCounts = {
  //         'Understock': 0,
  //         'Overstock': 0,
  //         'Balanced': 0,
  //       };
  //
  //       for (var item in data) {
  //         final status = item['Stock_Status']?.toString();
  //         if (status != null && statusCounts.containsKey(status)) {
  //           statusCounts[status] = statusCounts[status]! + 1;
  //         }
  //       }
  //
  //       setState(() {
  //         inventoryList = data;
  //         DaysInStock = daysInStockFormatted;
  //
  //         understockCount = statusCounts['Understock'] ?? 0;
  //         overstockCount = statusCounts['Overstock'] ?? 0;
  //         balancedCount = statusCounts['Balanced'] ?? 0;
  //
  //         isLoading = false;
  //       });
  //     } else {
  //       setState(() {
  //         error = 'Error: ${response.statusMessage}';
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       error = 'Exception: $e';
  //       isLoading = false;
  //     });
  //   }
  // }

  Future<void> fetchExecutiveData() async {
    try {
      var dio = Dio();
      var response = await dio.get('${ApiConfig.baseUrl}/inventory');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;

        // Calculate DaysInStock average
        int totaldayinstock = calculateTotalDaysInStock(data);
        String daysInStockFormatted =
            formatNumberStringWithComma(totaldayinstock.toString());

        // Count stock statuses
        Map<String, int> statusCounts = {
          'Understock': 0,
          'Overstock': 0,
          'Balanced': 0,
        };

        int zeroInStockRateCount =
            0; // NEW variable to count SKUs with 0 InStock_Rate_Percent

        for (var item in data) {
          final status = item['Stock_Status']?.toString();
          if (status != null && statusCounts.containsKey(status)) {
            statusCounts[status] = statusCounts[status]! + 1;
          }

          // Check if InStock_Rate_Percent == 0 and count it
          final rateStr = item['InStock_Rate_Percent']?.toString() ?? '0';
          final rate = double.tryParse(rateStr) ?? 0;
          if (rate == 0) {
            zeroInStockRateCount++;
          }
        }

        setState(() {
          inventoryList = data;
          DaysInStock = daysInStockFormatted;

          understockCount = statusCounts['Understock'] ?? 0;
          overstockCount = statusCounts['Overstock'] ?? 0;
          balancedCount = statusCounts['Balanced'] ?? 0;

          zeroInStockRateSkuCount =
              zeroInStockRateCount; // Update new variable here

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

  // Future<void> fetchExecutiveData() async {
  //   try {
  //     var dio = Dio();
  //     var response = await dio.get('${ApiConfig.baseUrl}/inventory');
  //     //var response = await dio.get(ApiConfig.ukInventory);
  //
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         inventoryList = response.data;
  //
  //         double totaldayinstock = calculateTotalDaysInStock(inventoryList);
  //         DaysInStock= formatNumberStringWithComma(totaldayinstock.toString());
  //
  //
  //         isLoading = false;
  //       });
  //     } else {
  //       setState(() {
  //         error = 'Error: ${response.statusMessage}';
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       error = 'Exception: $e';
  //       isLoading = false;
  //     });
  //   }
  // }

  // String formatFilterType(String filter) {
  //   switch (filter) {
  //   // case 'today':
  //   //   return 'Today';
  //   //   case 'week':
  //   //   return 'Week';
  //   // case '6months':
  //   //   return 'Last 6 Months';
  //   // case 'last30days':
  //   //   return 'Last 30 Days';
  //   // case 'yeartodate':
  //   //   return 'Year to Date';
  //     case 'monthtodate':
  //       return 'Current Month';
  //
  //   // case 'year':
  //   //   return 'This Year';
  //     case 'lastmonth':
  //       return 'Last Month';
  //     case 'custom':
  //       return 'Custom Range';
  //     default:
  //       return filter;
  //   }
  // }

  Future<void> fetchDropdownData() async {
    try {
      final stateRes =
          await http.get(Uri.parse('${ApiConfig.baseUrl}/state?q='));
      final cityRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/city?q='));
      final skuRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/sku'));

      if (stateRes.statusCode == 200)
        states = List<String>.from(json.decode(stateRes.body));
      if (cityRes.statusCode == 200)
        cities = List<String>.from(json.decode(cityRes.body));
      if (skuRes.statusCode == 200)
        skus = List<String>.from(json.decode(skuRes.body));

      setState(() {
        // Automatically fetch data for 6 months on screen load
      });
    } catch (e) {
      print('Error fetching dropdown data: $e');
    }
  }

  String formatDateads_api(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
  }

  String formatDate(DateTime date) =>
      "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Future<void> fetchFilteredData() async {
    if (selectedFilterType == null) return;
    setState(() => isLoading = true);

    String url = '';

    if (selectedFilterType == 'custom') {
      if (startDate == null || endDate == null) {
        setState(() => isLoading = false);
        return;
      }

      final from = formatDate(startDate!);
      final to = formatDate(endDate!);

      url =
          '${ApiConfig.baseUrl}/sales/resion?filterType=custom&fromDate=$from&toDate=$to}';
    } else {
      url =
          // 'http://192.168.18.131:3000/api/sales/resion?filterType=lastmonth';
          '${ApiConfig.baseUrl}/sales/resion?filterType=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    }
    //var request = http.Request('GET', url);

    var request = http.Request('GET', Uri.parse(url));

    try {
      http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         final data = await response.stream.bytesToString();
// print("qwertyuio:::  ${json.decode(data)}");
//
//         setState(() {
//           salesData = json.decode(data);
//           isLoading = false;
//         });
//       }

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        setState(() {
          salesData = json.decode(data);
          print("Salesdata::::: ${salesData}");

          final breakdown = salesData!['breakdown'];

          // Extract totalSales and date
          // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
          // labels = breakdown.map<String>((item) => item['date'].toString()).toList();

          print("filte typee :: ${selectedFilterType}");

          if (selectedFilterType == "last30days") {
            print("last30days");
            values = breakdown
                .map<double>((item) => (item['totalSales'] as num).toDouble())
                .toList();
            labels = breakdown
                .map<String>((item) => item['date'].toString())
                .toList();

            // values = breakdown
            //     .map<double>((item) => (item['totalSales'] as num).roundToDouble())
            //     .toList();
            //
            // labels = breakdown
            //     .map<String>((item) {
            //   final date = DateTime.parse(item['date']);
            //   return '${date.month.toString().padLeft(1, '0')}-${date.day.toString().padLeft(1, '0')}';
            // })
            //     .toList();
          }

          if (selectedFilterType == "monthtodate") {
            print("monthtodate");
            // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
            // labels = breakdown.map<String>((item) => item['date'].toString()).toList();

            values = breakdown
                .map<double>(
                    (item) => (item['totalSales'] as num).roundToDouble())
                .toList();

// Format dates to MM-DD
            labels = breakdown.map<String>((item) {
              DateTime date = DateTime.parse(item['date']);
              return "${date.day.toString().padLeft(1, '0')}";
              //return "${date.month.toString().padLeft(0, '0')}-${date.day.toString().padLeft(1, '0')}";
            }).toList();
          }

          if (selectedFilterType == "lastmonth") {
            print("6666666 months");
            //   values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
            //   labels = breakdown.map<String>((item) => item['date'].toString()).toList();
            values = breakdown
                .map<double>((item) => (item['totalSales'] as num).toDouble())
                .toList();

            // Only show day (1, 2, 3...) as label
            labels = breakdown.map<String>((item) {
              DateTime date = DateTime.parse(item['date'].toString());
              return date.day.toString();
            }).toList();

            print(values);
            print(labels);
            print("6666666 months");
          }

          if (selectedFilterType == "yeartodate") {
            print("yeartodate");
            // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
            // labels = breakdown.map<String>((item) => item['date'].toString()).toList();

            Map<String, double> monthlyTotals = {};

// Summing totalSales by month
            for (var item in breakdown) {
              DateTime date = DateTime.parse(item['date']);
              String monthLabel =
                  DateFormat('MMM').format(date); // e.g., Jan, Feb
              double totalSales = (item['totalSales'] as num).toDouble();

              if (monthlyTotals.containsKey(monthLabel)) {
                monthlyTotals[monthLabel] =
                    monthlyTotals[monthLabel]! + totalSales;
              } else {
                monthlyTotals[monthLabel] = totalSales;
              }
            }

// Convert the map to separate lists for chart use
            labels = monthlyTotals.keys.toList(); // ['Jan', 'Feb', ...]
            values = monthlyTotals.values
                .map((val) => val.roundToDouble())
                .toList(); // Whole numbers
          }
          if (selectedFilterType == "custom") {
            print("custom");

            values = breakdown
                .map<double>((item) => (item['totalSales'] as num).toDouble())
                .toList();
            labels = breakdown
                .map<String>((item) => item['date'].toString())
                .toList();

            Map<String, double> monthWiseSum = {};
            String getMonthKey(String date) => date.substring(0, 7);

            for (int i = 0; i < labels.length; i++) {
              String monthKey = getMonthKey(labels[i]);
              double saleValue = values[i];

              if (monthWiseSum.containsKey(monthKey)) {
                monthWiseSum[monthKey] = monthWiseSum[monthKey]! + saleValue;
              } else {
                monthWiseSum[monthKey] = saleValue;
              }
            }

            String formatMonthLabel(String monthKey) {
              final year = monthKey.substring(2, 4);
              final month = int.parse(monthKey.substring(5, 7));
              return "$year-$month";
            }

            labels =
                monthWiseSum.keys.map((key) => formatMonthLabel(key)).toList();
            values = monthWiseSum.values.toList();

            print("📅 Month Labels: $labels");
            print("📊 Month Values: $values");
          }

          // print("📊 values: $values");
          // print("📅 labels: $labels");

          fetchAdData();
          isLoading = false;
        });
      }

      // else {
      //   setState(() {
      //     errorMessage = response.reasonPhrase ?? "Failed to fetch data.";
      //     print("errro:e: ${errorMessage}");
      //     isLoading = true;
      //   });
      // }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        print("errro:: ${e}");
        isLoading = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  String formatShortYearMonth(String date) {
    DateTime parsedDate = DateTime.parse(date);
    String shortYear = parsedDate.year.toString().substring(0); // "25"
    String month = parsedDate.month.toString().padLeft(2, '0'); // "04"
    return '$shortYear-$month';
  }

  Future<void> fetchAdData() async {
    if (selectedFilterType == null) return;

    setState(() => isLoading = true);

    String url = '';

    if (selectedFilterType == 'custom') {
      if (startDate == null || endDate == null) {
        setState(() => isLoading = false);
        return;
      }

      final from = formatDateads_api(startDate!);
      final to = formatDateads_api(endDate!);

      url =
          '${ApiConfig.baseUrl}/data/filterData?range=custom&startDate=$from&endDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';

      print("print url custom ads data ${url}");
    } else {
      url =
          '${ApiConfig.baseUrl}/data/filterData?range=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    }

    var request = http.Request('GET', Uri.parse(url));

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(data);

        setState(() {
          adssales = jsonResponse; // Entire JSON stored
          // totalAdSales = double.parse((jsonResponse['totalAdSales'] ?? 0.0).toString()).toStringAsFixed(2);
          // totalAdSpend = double.parse((jsonResponse['totalAdSpend'] ?? 0.0).toString()).toStringAsFixed(2);
          print("console:::   ${adssales}");
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = response.reasonPhrase ?? 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = '❌ Error: $e';
        isLoading = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void onDropdownChanged(String? value, String type) {
    setState(() {
      if (type == 'filter') {
        selectedFilterType = value;
        if (value != 'custom') {
          fetchFilteredData();
          fetchAdData();
        }
      } else if (type == 'state') {
        selectedState = value;
        fetchFilteredData();
      } else if (type == 'city') {
        selectedCity = value;
        fetchFilteredData();
      } else if (type == 'sku') {
        selectedSku = value;
        fetchFilteredData();
      }
    });
  }

  Future<void> selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      fetchFilteredData();
      fetchAdData();
    }
  }

  Future<void> _showMonthYearRangePicker(BuildContext context) async {
    final now = DateTime.now();
    DateTime tempStartDate = startDate ?? DateTime(now.year, now.month);
    DateTime tempEndDate = endDate ?? DateTime(now.year, now.month);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Helper to get months based on selected year (disable future months)
            List<DropdownMenuItem<int>> buildMonthItems(int selectedYear) {
              int maxMonth = (selectedYear == now.year) ? now.month : 12;
              return List.generate(maxMonth, (i) {
                int month = i + 1;
                return DropdownMenuItem(
                  value: month,
                  child: Text(month.toString().padLeft(2, '0')),
                );
              });
            }

            return AlertDialog(
              backgroundColor: AppColors.beige,
              title: Text('Select Month & Year Range'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Start"),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: tempStartDate.month,
                          items: buildMonthItems(tempStartDate.year),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                tempStartDate =
                                    DateTime(tempStartDate.year, val);
                                if (tempEndDate.isBefore(tempStartDate)) {
                                  tempEndDate = tempStartDate;
                                }
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          value: tempStartDate.year,
                          items: List.generate(10, (i) {
                            int year = now.year - 9 + i;
                            if (year > now.year) return null;
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).whereType<DropdownMenuItem<int>>().toList(),
                          onChanged: (val) {
                            if (val != null) {
                              int newMonth = tempStartDate.month;
                              if (val == now.year && newMonth > now.month) {
                                newMonth = now.month;
                              }
                              setState(() {
                                tempStartDate = DateTime(val, newMonth);
                                if (tempEndDate.isBefore(tempStartDate)) {
                                  tempEndDate = tempStartDate;
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text("End"),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: tempEndDate.month,
                          items: buildMonthItems(tempEndDate.year),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                tempEndDate = DateTime(tempEndDate.year, val);
                                if (tempEndDate.isBefore(tempStartDate)) {
                                  tempStartDate = tempEndDate;
                                }
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          value: tempEndDate.year,
                          items: List.generate(10, (i) {
                            int year = now.year - 9 + i;
                            if (year > now.year) return null;
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).whereType<DropdownMenuItem<int>>().toList(),
                          onChanged: (val) {
                            if (val != null) {
                              int newMonth = tempEndDate.month;
                              if (val == now.year && newMonth > now.month) {
                                newMonth = now.month;
                              }
                              setState(() {
                                tempEndDate = DateTime(val, newMonth);
                                if (tempEndDate.isBefore(tempStartDate)) {
                                  tempStartDate = tempEndDate;
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child:
                      Text('Cancel', style: TextStyle(color: AppColors.gold)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Apply', style: TextStyle(color: AppColors.gold)),
                  onPressed: () {
                    startDate = tempStartDate;
                    endDate = tempEndDate;
                    fetchFilteredData();
                    fetchAdData();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

//old date picker days wise
  // void _showDateRangePicker(BuildContext context) async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       PickerDateRange? selectedRange; // Store the selected range
  //
  //       return StatefulBuilder(
  //         // Use StatefulBuilder for state within the dialog
  //         builder: (BuildContext context, StateSetter setState) {
  //           return AlertDialog(
  //             backgroundColor: AppColors.beige,
  //             title: Text('Select Date Range'),
  //             content: Container(
  //               width: 300,
  //               height: 350,
  //               child: SfDateRangePicker(
  //                 backgroundColor: AppColors.white,
  //                 selectionColor: AppColors.gold,
  //                 todayHighlightColor: AppColors.gold,
  //                 rangeSelectionColor: AppColors.gold,
  //                 endRangeSelectionColor: AppColors.gradientStart,
  //                 startRangeSelectionColor: AppColors.gradientStart,
  //                 selectionMode: DateRangePickerSelectionMode.range,
  //                 navigationMode: DateRangePickerNavigationMode.scroll,
  //                 onSelectionChanged:
  //                     (DateRangePickerSelectionChangedArgs args) {
  //                   if (args.value is PickerDateRange) {
  //                     print(
  //                         "Selected Range: ${args.value.startDate} to ${args.value.endDate}");
  //                     selectedRange = args.value;
  //                     setState(() {
  //                       startDate = args.value?.startDate;
  //                       endDate = args.value?.endDate;
  //                     });
  //                   }
  //                 },
  //               ),
  //             ),
  //             actions: <Widget>[
  //               TextButton(
  //                 child: Text(
  //                   'Cancel',
  //                   style: TextStyle(color: AppColors.gold),
  //                 ),
  //                 onPressed: () {
  //                   // _selectedTime = 'Last 12 months';
  //                   // String range =
  //                   //               DateUtilsHelper.getDateRange(_selectedTime);
  //                   //           _fetchData(range);
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //               TextButton(
  //                 child: Text('Apply', style: TextStyle(color: AppColors.gold)),
  //                 onPressed: () {
  //                   if (selectedRange != null) {
  //                     // setState(() {
  //                     // String range =
  //                     //           DateUtilsHelper.getDateRangeFromDates(selectedRange?.startDate, selectedRange?.endDate);
  //                     // _fetchData(range);
  //                     fetchFilteredData();
  //                     fetchAdData();
  //                     // });
  //                     Navigator.of(context).pop();
  //                   }
  //                 },
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  String formatDatepnl(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    // final stockCounts = countStockStatus(data);
    final config = getChartConfig('monthtodate');
    // print("custom datre value ${formatDate(startDate!)}");
    // print("custom datre value ${formatDate(endDate!)}");

    //Organic
    var totalSales =
        double.tryParse(salesData?['totalSales']?.toString() ?? '0') ?? 0;
    var totalAdSalesCurrent = double.tryParse(
            adssales?["current"]?['totalAdSales']?.toString() ?? '0') ??
        0;
    var totalAdSalesPrevious = double.tryParse(
            adssales?["previous"]?['totalAdSales']?.toString() ?? '0') ??
        0;
    var previousTotalSales = double.tryParse(
            salesData?["comparison"]?['previousTotalSales']?.toString() ??
                '0') ??
        0;

    var organivc = totalSales - totalAdSalesCurrent;
    var organivp = previousTotalSales - totalAdSalesPrevious;

    var organicavg =
        organivp != 0 ? ((organivc - organivp) / organivp) * 100 : 0;

    print("Organic avg percentage: $organicavg");

//AOV
    var totalSalesss = salesData?['totalSales'];
    var totalOrders = salesData?['totalOrders'];
    var previousTotalSalesss = salesData?["comparison"]?['previousTotalSales'];
    var previousTotalOrderss = salesData?["comparison"]?['previousTotalOrders'];

    double? aov;
    double? aovp;
    double? per;

    if (totalSalesss != null &&
        totalOrders != null &&
        previousTotalSalesss != null &&
        previousTotalOrderss != null &&
        totalOrders != 0 &&
        previousTotalOrderss != 0) {
      aov = totalSalesss / totalOrders;
      aovp = previousTotalSalesss / previousTotalOrderss;
      per = ((aov! - aovp!) / aovp) * 100;

      print("AOV: $aov, AOVP: $aovp, Change %: $per");
    } else {
      print("Error: One or more values are null or division by zero.");
    }

    print("AOV percentage change: $per");

    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 190,
                      height: 33, // Fixed height
                      child: DropdownButtonFormField<String>(
                        isDense: true, // Makes dropdown compact
                        style: TextStyle(
                            fontSize: 12, color: Colors.black), // Smaller font
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8), // Tight padding
                          hintText: "Select Filter Type",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        items: filterTypes.map((type) {
                          return DropdownMenuItem(
                            onTap: () {},
                            value: type,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                formatFilterType(type),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                            ),
                          );
                        }).toList(),
                        value: selectedFilterType,
                        onChanged: (val) => onDropdownChanged(val, 'filter'),
                      ),
                    ),

                    if (selectedFilterType == 'custom')
                      ElevatedButton.icon(
                        onPressed: () => _showMonthYearRangePicker(context),

                        //onPressed: () => _showDateRangePicker(context),

                        icon: Icon(Icons.date_range),

                        label: Text(
                          startDate != null && endDate != null
                              ? "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}/ ${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}"
                              : "Select Date Range",
                          overflow: TextOverflow.ellipsis,
                        ),

                        // label: Text(
                        //   startDate != null && endDate != null
                        //       ? "${formatDate(startDate!)}-${formatDate(endDate!)}"
                        //       : "Select Date Range",
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                      ),

                    ////////////////////////////////////
                    //filter

                    SizedBox(width: 8), // optional spacing
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: DropdownSearch<String>(
                        items: states,
                        selectedItem: selectedState,
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: "Search State",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                            // dropdownSearchDecoration: InputDecoration(
                            //   labelText: "State",
                            //   border: OutlineInputBorder(),
                            // ),
                            dropdownSearchDecoration:
                                customInputDecoration(labelText: "State")),
                        clearButtonProps: ClearButtonProps(isVisible: true),
                        onChanged: (val) => onDropdownChanged(val, 'state'),
                      ),
                    ),
                    // SizedBox(width: 8),
                    // SizedBox(
                    //   width: 150,
                    //   height: 50,
                    //   child: DropdownSearch<String>(
                    //     items: cities,
                    //     selectedItem: selectedCity,
                    //     popupProps: PopupProps.menu(
                    //       showSearchBox: true,
                    //       searchFieldProps: TextFieldProps(
                    //         decoration: InputDecoration(
                    //           hintText: "Search City",
                    //           border: OutlineInputBorder(),
                    //         ),
                    //       ),
                    //     ),
                    //     dropdownDecoratorProps: DropDownDecoratorProps(
                    //       // dropdownSearchDecoration: InputDecoration(
                    //       //   labelText: "City",
                    //       //   border: OutlineInputBorder(),
                    //       // ),
                    //       dropdownSearchDecoration:
                    //           customInputDecoration(labelText: "City"),
                    //     ),
                    //     clearButtonProps: ClearButtonProps(isVisible: true),
                    //     onChanged: (val) => onDropdownChanged(val, 'city'),
                    //   ),
                    // ),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: DropdownSearch<String>(
                        items: skus,
                        selectedItem: selectedSku,
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: "Search SKU",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          // dropdownSearchDecoration: InputDecoration(
                          //   labelText: "SKU",
                          //   border: OutlineInputBorder(),
                          // ),
                          dropdownSearchDecoration:
                              customInputDecoration(labelText: "SKU"),
                        ),
                        clearButtonProps: ClearButtonProps(isVisible: true),
                        onChanged: (val) => onDropdownChanged(val, 'sku'),
                      ),
                    )

                    ////////////////////////////////////
                  ],
                ),
              ),
              // 🔼 Your dropdown and filter widgets here...

              const SizedBox(height: 40),

              BarChartSample(values: values, labels: labels, isWeb: isWeb),

              //BarChartSample(values: values, labels: labels, isWeb: isWeb, activeCount: config['activeCount'],),

              /// This is your scrollable main content
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage))
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              // Align(
                              //   alignment: Alignment.center,
                              //   child: Text(
                              //     "Sales",
                              //     style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),
                              //   ),
                              // ),

                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Sales ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: (salesData != null &&
                                              salesData!['comparison']
                                                          ?['previousPeriod']
                                                      ?['startDate'] !=
                                                  null &&
                                              salesData!['comparison']
                                                          ?['previousPeriod']
                                                      ?['endDate'] !=
                                                  null)
                                          ? 'Compared with ${formatShortYearMonth(salesData!['comparison']['previousPeriod']['startDate'])} To ${formatShortYearMonth(salesData!['comparison']['previousPeriod']['endDate'])}'
                                          : 'Comparison data unavailable',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )

                                    // TextSpan(
                                    //   text: 'as of ${salesData?['comparison']['previousPeriod']['startDate']}/${salesData?['comparison']['previousPeriod']['endDate']}',
                                    //   style: TextStyle(
                                    //     fontSize: 14,
                                    //     fontWeight: FontWeight.w400,
                                    //   ),
                                    // ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),

                              Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: MetricCard(
                                              title: "Revenue",
                                              value:
                                                  '£ ${NumberFormat('#,###').format((salesData?['totalSales'] ?? 0).round())}',
                                              //compared: "",
                                              // ${salesData?['totalSales']??"0"}\n
                                              // ((currentSales - previousSales) / previousSales) * 100;
                                              //compared: "${((salesData?['totalSales']?? 0 - salesData?['comparison']!['previousTotalSales']??0) / salesData?['comparison']['previousTotalSales']??0) * 100}",
                                              //compared: "${(((salesData?['totalSales'] ?? 0) as num) - ((salesData?['comparison']?['previousTotalSales'] ?? 0) as num)) / ((salesData?['comparison']?['previousTotalSales'] ?? 1) as num) * 100}",
                                              compared:
                                                  "${(((((salesData?['totalSales'] ?? 0) as num) - ((salesData?['comparison']?['previousTotalSales'] ?? 0) as num)) / ((salesData?['comparison']?['previousTotalSales'] ?? 1) as num)) * 100).toStringAsFixed(2)}",
                                            )
                                                //  compared: "${salesData?['totalSales']??"0"}/${salesData?['comparison']['previousTotalSales']??"0"}",)
                                                ),
                                            // title: "Overall Sales", value: '£ ${salesData?['totalSales'].toStringAsFixed(2)}', compared: "${salesData?['comparison']['salesChangePercent']}",)),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: MetricCard(
                                                title: "Units Ordered",
                                                value:
                                                    "${NumberFormat('#,###').format((salesData?['totalQuantity'] ?? 0).round())}",

                                                // compared: "${salesData?['comparison']['quantityChangePercent']?? "0"}",
                                                //compared: "${salesData?['comparison']['previousTotalOrders']?? "0"}",
                                                // compared: "${(((salesData?['totalQuantity'] ?? 0) - (salesData?['comparison']?['previousTotalQuantity'] ?? 0)) / (salesData?['comparison']?['previousTotalQuantity'] ?? 1)) * 100}",
                                                compared:
                                                    "${((((salesData?['totalQuantity'] ?? 0) - (salesData?['comparison']?['previousTotalQuantity'] ?? 0)) / (salesData?['comparison']?['previousTotalQuantity'] ?? 1)) * 100).toStringAsFixed(2)}",

                                                //value:"${salesData?['totalQuantity']}", compared: "${salesData?['comparison']['quantityChangePercent']}",
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Row(
                                          children: [
                                            // Expanded(
                                            //   child: MetricCardcm(
                                            //     title: "AOV",
                                            //     //value: "",
                                            //     value: "£ ${NumberFormat('#,###').format(
                                            //         (((salesData?['totalSales'] ?? 0.0) as num) /
                                            //             ((adssales?['totalOrders'] ?? 1) as num)).toInt()
                                            //     )}",
                                            //     //value: "£ ${(((salesData?['totalSales'] ?? 0.0) as num) / ((adssales?['totalOrders'] ?? 1) as num)).toStringAsFixed(0)}",
                                            //     //  totalOrders
                                            //   ),
                                            // ),

                                            Expanded(
                                              child: MetricCard(
                                                  title: "AOV",
                                                  //value: "",
                                                  //value: "£ ${((salesData?['totalSales'])/(salesData?['totalOrders']))}",
                                                  value:
                                                      "£ ${(salesData?['totalOrders'] == 0) ? 0 : ((salesData?['totalSales'] ?? 0) / (salesData?['totalOrders'] ?? 0)).toStringAsFixed(2)}",

                                                  // value: "£ ${NumberFormat('#,###').format((((salesData?['totalSales'] ?? 0.0) as num) / (((salesData?['totalQuantity'] == 0 ? 1 : salesData?['totalQuantity']) ?? 1) as num)).toInt())}",
                                                  //compared: "${salesData?['comparison']['aovChangePercentQty']??"0"}",
                                                  //compared: "${((salesData?['totalSales'] - salesData?['comparison']['previousTotalQuantity']??"0") / salesData?['comparison']['previousTotalQuantity']??"0") * 100}",

                                                  // compared: "${((((salesData?['totalSales']) / (salesData?['totalOrders']) - (salesData?["comparison"]?['previousTotalSales'])) / (salesData?['comparison']['previousTotalOrders'])))* 100 }",
                                                  compared:
                                                      per?.toStringAsFixed(2) ??
                                                          "0.00"

                                                  //value: "£ ${(((salesData?['totalSales'] ?? 0.0) as num) / ((adssales?['totalSales'] ?? 1) as num)).toStringAsFixed(0)}",
                                                  //  totalOrders
                                                  ),
                                            ),

                                            const SizedBox(width: 8),

                                            Expanded(
                                              child: MetricCard(
                                                title: "Organic Revenue",
                                                value:
                                                    "£ ${NumberFormat('#,###').format(((double.tryParse(salesData?['totalSales'].toString() ?? '0') ?? 0) - (double.tryParse(adssales?["current"]?['totalAdSales'].toString() ?? '0') ?? 0)).round())}",

                                                //double.parse(adssales?['current']?['totalAdSales'] ?? '0'
                                                // compared: "${salesData?['comparison']['organicSalesChangePercent']??"0"}",
                                                compared: organicavg
                                                    .toStringAsFixed(2),
                                                //  compared: "(${salesData?['totalSales']??"0"})",
                                                //value: "£ ${((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).toStringAsFixed(0)}",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),

                              // Container(
                              //     decoration: BoxDecoration(
                              //       color: Colors.white,
                              //       borderRadius: BorderRadius.circular(12),
                              //       border: Border.all(color: Colors.grey),
                              //     ),
                              //     child: Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: Column(
                              //         children: [
                              //           Row(
                              //             children: [
                              //               Expanded(
                              //                   child: MetricCard(
                              //                 title: "Revenue",
                              //                 value:
                              //                     '£ ${NumberFormat('#,###').format((salesData?['totalSales'] ?? 0).round())}',
                              //                 compared:
                              //                     "${salesData?['comparison']['salesChangePercent'] ?? "0"}",
                              //               )),
                              //               // title: "Overall Sales", value: '£ ${salesData?['totalSales'].toStringAsFixed(2)}', compared: "${salesData?['comparison']['salesChangePercent']}",)),
                              //               SizedBox(width: 8),
                              //               Expanded(
                              //                 child: MetricCard(
                              //                   title: "Units Ordered",
                              //                   value:
                              //                       "${NumberFormat('#,###').format((salesData?['totalQuantity'] ?? 0).round())}",
                              //                   compared:
                              //                       "${salesData?['comparison']['quantityChangePercent']}",
                              //                   //value:"${salesData?['totalQuantity']}", compared: "${salesData?['comparison']['quantityChangePercent']}",
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //           SizedBox(
                              //             height: 8,
                              //           ),
                              //           Row(
                              //             children: [
                              //               // Expanded(
                              //               //   child: MetricCardcm(
                              //               //     title: "AOV",
                              //               //     //value: "",
                              //               //     value: "£ ${NumberFormat('#,###').format(
                              //               //         (((salesData?['totalSales'] ?? 0.0) as num) /
                              //               //             ((adssales?['totalOrders'] ?? 1) as num)).toInt()
                              //               //     )}",
                              //               //     //value: "£ ${(((salesData?['totalSales'] ?? 0.0) as num) / ((adssales?['totalOrders'] ?? 1) as num)).toStringAsFixed(0)}",
                              //               //     //  totalOrders
                              //               //   ),
                              //               // ),

                              //               Expanded(
                              //                 child: MetricCard(
                              //                   title: "AOV",
                              //                   //value: "",
                              //                   value:
                              //                       "£ ${NumberFormat('#,###').format((((salesData?['totalSales'] ?? 0.0) as num) / (((salesData?['totalQuantity'] == 0 ? 1 : salesData?['totalQuantity']) ?? 1) as num)).toInt())}",
                              //                   compared:
                              //                       "${salesData?['comparison']['aovChangePercentQty']}",
                              //                   //value: "£ ${(((salesData?['totalSales'] ?? 0.0) as num) / ((adssales?['totalSales'] ?? 1) as num)).toStringAsFixed(0)}",
                              //                   //  totalOrders
                              //                 ),
                              //               ),

                              //               const SizedBox(width: 8),

                              //               Expanded(
                              //                 child: MetricCard(
                              //                   title: "Organic Revenue",
                              //                   value:
                              //                       "£ ${NumberFormat('#,###').format(((double.tryParse(salesData?['totalSales'].toString() ?? '0') ?? 0) - (double.tryParse(adssales?["current"]?['totalAdSales'].toString() ?? '0') ?? 0)).round())}",
                              //                   compared:
                              //                       "${salesData?['comparison']['organicSalesChangePercent']}",
                              //                   //value: "£ ${((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).toStringAsFixed(0)}",
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         ],
                              //       ),
                              //     )),

                              SizedBox(
                                height: 8,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Ads",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: MetricCardads(
                                                title: "Ad Spend",
                                                // title: Salesvaluepnl.toString(),
                                                // value: "£ ${NumberFormat('#,###').format((adssales?['totalAdSpend'] ?? 0).toDouble().round())}",
                                                // value: "£ ${NumberFormat('#,###').format((adssales?['totalAdSpend'] ?? 0).toDouble().round())}",

                                                value:
                                                    "£ ${NumberFormat('#,##0', 'en_GB').format(double.parse(adssales?['current']?['totalAdSpend'] ?? '0'))}",

                                                compared:
                                                    '${(adssales?['change']?['adSpendChangePercent'])}',

                                                // value: "£ ${(adssales?['current']?['totalAdSpend'])}",
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: MetricCardads(
                                                title: "Ad Revenue",
                                                // value: "£ ${NumberFormat('#,###').format(
                                                //     (adssales?['totalAdSales'] ?? 0).toDouble().round()
                                                // )}",
                                                //value: "£ ${((adssales?['totalAdSales'] ?? 0).toDouble()).toStringAsFixed(0)}",

                                                value:
                                                    "£ ${NumberFormat('#,##0', 'en_GB').format(double.parse(adssales?['current']?['totalAdSales'] ?? '0'))}",

                                                compared:
                                                    '${(adssales?['change']?['adSalesChangePercent'])}',
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            if (selectedFilterType !=
                                                "last30days")
                                              Expanded(
                                                child: MetricCardads(
                                                  title: "ACOS",
                                                  value:
                                                      "${(adssales?["current"]?['ACOS'] ?? 0)} %",

                                                  // value: "£ ${NumberFormat('#,##0', 'en_GB').format(double.parse(adssales?['current']?['ACOS'] ?? '0'))}",

                                                  compared:
                                                      '${(adssales?['change']?['acosChangePercent'])}',
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                            Salesvaluepnl != 0
                                                ? Expanded(
                                                    child: MetricCardcm(
                                                      title: "TACOS",
                                                      value:
                                                          "${((double.parse(adssales?["current"]?['totalAdSpend'] ?? '0') / Salesvaluepnl) * 100).toStringAsFixed(2)} %",

                                                      // value: "${((adssales?['totalAdSpend'] ?? 0) / (Salesvaluepnl) * 100).toStringAsFixed(2)} %",
                                                    ),
                                                  )
                                                : Expanded(
                                                    child: MetricCardcm(
                                                      title: "TACOS",
                                                      value: "0 %",
                                                    ),
                                                  ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: MetricCardcm(
                                                title: "Organic Revenue",
                                                value: (() {
                                                  final totalSales =
                                                      double.tryParse(
                                                              '${salesData?['totalSales']}') ??
                                                          0;
                                                  final totalAdSales =
                                                      double.tryParse(
                                                              '${adssales?["current"]?['totalAdSales']}') ??
                                                          0;

                                                  if (totalSales == 0)
                                                    return "0.00 %"; // avoid division by zero

                                                  final organicRevenue =
                                                      ((totalSales -
                                                                  totalAdSales) /
                                                              totalSales) *
                                                          100;
                                                  return "${organicRevenue.toStringAsFixed(2)} %";
                                                })(),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: MetricCardcm(
                                                title: "ROAS",
                                                value: (() {
                                                  final totalSales =
                                                      double.tryParse(
                                                              "${salesData?['totalSales']}") ??
                                                          0;
                                                  final totalAdSpend = double
                                                          .tryParse(
                                                              "${adssales?["current"]?['totalAdSpend']}") ??
                                                      1; // avoid division by 0

                                                  final roas = totalAdSpend == 0
                                                      ? 0
                                                      : (totalSales /
                                                          totalAdSpend);
                                                  return roas
                                                      .toStringAsFixed(2);
                                                })(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                              SizedBox(
                                height: 8,
                              ),
                              // Container(
                              //     decoration: BoxDecoration(
                              //       color: Colors.white,
                              //       borderRadius: BorderRadius.circular(12),
                              //       border: Border.all(color: Colors.grey),
                              //     ),
                              //     child:Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: Column(children: [
                              //         Row(
                              //           children: [
                              //             Expanded(
                              //               child: MetricCardcm(
                              //                 title: "Organic Revenue",
                              //                 value:
                              //                 "${(((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)) / (salesData?['totalSales'] ?? 0.0) * 100).toStringAsFixed(2)} %",
                              //               ),
                              //             ),
                              //             const SizedBox(width: 8),
                              //             Expanded(
                              //               child: MetricCardcm(
                              //                 title: "ROAS",
                              //                 value:
                              //                 "${(((salesData?['totalSales'] ?? 1)/(adssales?['totalAdSpend'] ?? 0) )).toStringAsFixed(2)} ",
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //
                              //       ],),
                              //     )
                              // ),

                              // SizedBox(height: 8,),
                              // Text.rich(
                              //   TextSpan(
                              //     children: [
                              //       TextSpan(
                              //         text: 'Inventory ',
                              //         style: TextStyle(
                              //           fontSize: 18,
                              //           fontWeight: FontWeight.w600,
                              //         ),
                              //       ),
                              //       TextSpan(
                              //         text: 'as of today',
                              //         style: TextStyle(
                              //           fontSize: 14,
                              //           fontWeight: FontWeight.w400,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              //   textAlign: TextAlign.center,
                              // ),
                              //
                              // Container(
                              //     decoration: BoxDecoration(
                              //       color: Colors.white,
                              //       borderRadius: BorderRadius.circular(12),
                              //       border: Border.all(color: Colors.grey),
                              //     ),
                              //     child:Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: Column(children: [
                              //
                              //         // Column(
                              //         //   crossAxisAlignment: CrossAxisAlignment.start,
                              //         //   children: [
                              //         //     Text('Days in Stock: $DaysInStock'),
                              //         //     Text('Understock: $understockCount'),
                              //         //     Text('Overstock: $overstockCount'),
                              //         //     Text('Balanced: $balancedCount'),
                              //         //     Text('SKUs with InStock Rate 0: $zeroInStockRateSkuCount'),
                              //         //
                              //         //   ],
                              //         // ),
                              //
                              //
                              //         Row(
                              //           children: [
                              //             Expanded(
                              //               child: MetricCardinvetory(
                              //                 title: "InStock Rate",
                              //                 value: "${DaysInStock} %",
                              //                 compared: "",
                              //               ),
                              //             ),
                              //
                              //             const SizedBox(width: 8),
                              //             Expanded(
                              //               child: MetricCardinvetory(
                              //                 title: "Active SKU OOS",
                              //                 value: '$zeroInStockRateSkuCount',
                              //                 compared: "SKU Counts",
                              //
                              //                 // value: "${(((adssales?['totalAdSales'] ?? 0) / (adssales?['totalAdSpend'] ?? 1)) * 100).toStringAsFixed(2)} %",
                              //
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //         SizedBox(height: 8,),
                              //         Row(
                              //           children: [
                              //             Expanded(
                              //               child: MetricCardinvetory(
                              //                 title: "Over Stock",
                              //                 value:"$overstockCount",
                              //                 compared: "SKU Counts",
                              //                 // value: "${(((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0))/(salesData?['totalSales'] ?? 0.0)*100).toStringAsFixed(2)} %",
                              //               ),
                              //             ),
                              //
                              //             const SizedBox(width: 8),
                              //             Expanded(
                              //               child: MetricCardinvetory(
                              //                 title: "Under Stock",
                              //                 value: "$understockCount",
                              //                 compared: "SKU Counts",
                              //                 // value: "${(((adssales?['totalAdSales'] ?? 0) / (adssales?['totalAdSpend'] ?? 1)) * 100).toStringAsFixed(2)} %",
                              //
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //
                              //       ],),
                              //     )
                              // ),
                              //
                            ],
                          ),
                        ),

              //
              // Text.rich(
              //   TextSpan(
              //     children: [
              //       TextSpan(
              //         text: 'Finance ',
              //         style: TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //       // TextSpan(
              //       //   text: 'as of ${formatShortYearMonth(salesData?['comparison']['previousPeriod']['startDate'])} To ${formatShortYearMonth(salesData?['comparison']['previousPeriod']['endDate'])}',
              //       //   style: TextStyle(
              //       //     fontSize: 14,
              //       //     fontWeight: FontWeight.w400,
              //       //   ),
              //       // ),
              //
              //
              //     ],
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              // if (selectedFilterType != 'custom')
              //   Row(
              //     children: [
              //       SizedBox(
              //
              //         height: 250,
              //         width: MediaQuery.of(context).size.width * 0.95,
              //         ///https://api.thrivebrands.ai/api/pnl-data-cmm?date=${widget.startDate}
              //
              //         child:PnLSummaryScreen(startDate: "https://api.thrivebrands.ai/api/pnl-data-cmm?date=${selectedFilterType}",
              //
              //
              //           //'https://api.thrivebrands.ai/api/pnl-data-cmm?startDate=${widget.startDate}&endDate=${widget.endDate}',
              //         ),),
              //     ],
              //   ),
              //
              // if (selectedFilterType == 'custom')
              //
              //
              //   if (startDate != null && endDate != null)
              //
              //
              //     Row(
              //       children: [
              //         SizedBox(
              //           height: 250,
              //           width: MediaQuery.of(context).size.width * 0.95,
              //           child: PnLSummaryScreen(
              //             startDate: "https://api.thrivebrands.ai/api/pnl-data-cmm?startDate=${formatDatepnl(startDate!)}&endDate=${formatDatepnl(endDate!)}",
              //           ),
              //         ),
              //       ],
              //     )
              //   else
              //     const SizedBox(), // or a loader / error message

              Divider(color: AppColors.gold, thickness: 0.5),
            ],
          )),
    );
    // );
  }
} //write complete steps for create bussines account in google play console for publish app in android play store briefly explainin  excel sheet and also use links because this sheet in shared with client and client is non tech so  explain proper understand and purchase accound what we need whats kinds or id name etc

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String compared;

  const MetricCard(
      {super.key,
      required this.title,
      required this.value,
      required this.compared});

  @override
  Widget build(BuildContext context) {
    print(compared);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, style: const TextStyle(fontSize: 16),
            // textAlign: TextAlign.left
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon(
                //   compared.contains('Profit')
                //       ? Icons.arrow_upward
                //       : Icons.arrow_downward,
                //   size: 14,
                //   color:
                //   compared.contains('Profit') ? Colors.green : Colors.red,
                // ),
                const SizedBox(width: 4),
                // Text(
                //   compared.split(' ').first, // e.g., "219.93%"
                //   style: TextStyle(
                //     fontSize: 12,
                //     fontWeight: FontWeight.normal,
                //    // color: compared.contains('Profit') ? Colors.green : Colors.red,
                //   ),
                // ),
                Icon(
                  compared.toString().trim().startsWith('-')
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  size: 14,
                  color: compared.trim().startsWith('-')
                      ? Colors.red
                      : Colors.green,
                ),
                const SizedBox(width: 4),
                // Text(
                //   compared.toString(),
                //   style: TextStyle(
                //     fontSize: 12,
                //     fontWeight: FontWeight.normal,
                //     color: compared.trim().startsWith('-') ? Colors.red : Colors.green,
                //   ),
                // ),

                Text(
                  "${compared.toString().replaceFirst('-', '')} %", // Remove only the first '-' sign
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: compared.trim().startsWith('-')
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Align(
          //   alignment: Alignment.centerRight,
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(
          //         compared.contains('Profit')
          //             ? Icons.arrow_upward
          //             : Icons.arrow_downward,
          //         size: 14,
          //         color:
          //             compared.contains('Profit') ? Colors.green : Colors.red,
          //       ),
          //       const SizedBox(width: 4),
          //       Text(
          //         compared.split(' ').first, // e.g., "219.93%"
          //         style: TextStyle(
          //           fontSize: 12,
          //           fontWeight: FontWeight.normal,
          //           color:
          //               compared.contains('Profit') ? Colors.green : Colors.red,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class MetricCardcm extends StatelessWidget {
  final String title;
  final String value;

  const MetricCardcm({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, style: const TextStyle(fontSize: 16),
            // textAlign: TextAlign.left
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            // textAlign: TextAlign.left
          ),
        ],
      ),
    );
  }
}

class MetricCardinvetory extends StatelessWidget {
  final String title;
  final String value;
  final String compared;

  const MetricCardinvetory(
      {super.key,
      required this.title,
      required this.value,
      required this.compared});

  @override
  Widget build(BuildContext context) {
    //  print(compared);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, style: const TextStyle(fontSize: 16),
            // textAlign: TextAlign.left
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon(
                //   compared.contains('Profit')
                //       ? Icons.arrow_upward
                //       : Icons.arrow_downward,
                //   size: 14,
                //   color:
                //   compared.contains('Profit') ? Colors.green : Colors.red,
                // ),
                const SizedBox(width: 4),
                Text(
                  compared, // e.g., "219.93%"
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    //  color: compared.contains('Profit') ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/custom_dropdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';

import '../../../cm1.dart';
import '../../../comman_Screens/productcard.dart';
import '../../../graph/commanbarchar_file.dart';
import '../../../utils/ApiConfig.dart';
import '../../../utils/chart_config.dart';
import '../../../utils/colors.dart'; // Import the package

class Filter_SalesRereginwiseScreen extends StatefulWidget {
  @override
  State<Filter_SalesRereginwiseScreen> createState() =>
      _Filter_SalesRereginwiseScreenState();
}

class _Filter_SalesRereginwiseScreenState
    extends State<Filter_SalesRereginwiseScreen> {
  List<String> states = [];
  List<String> cities = [];
  List<String> skus = [];
  bool isWeb = false;

  // List<String> filterTypes = [
  //   '6months',
  //   "yeartodate",
  //   "monthtodate",
  //   "last30days",
  //   "year",
  //   "lastmonth",
  //   "today",
  //   "custom",
  // ];

  List<String> filterTypes = [
    //"today",
    //"last30days",
    "monthtodate",
    "lastmonth",
    //'6months',
    //"yeartodate",
    "custom",
  ];

  String? selectedState;
  String? selectedCity;
  String? selectedSku;
  String? selectedFilterType;

  DateTime? startDate;
  DateTime? endDate;

  //List<SalesSku> salesData = [];
  // bool isLoading = false;
  Map<String, dynamic>? salesData;
  Map<String, dynamic>? adssales;

  List<double> values = [];
  List<String> labels = [];
  Map<String, double> monthlyTotals = {};

  bool isLoading = true;

  String? errorMsg;
  String errorMessage = '';

  // @override
  // void initState() {
  //   super.initState();
  //   fetchDropdownData();
  // }
  @override
  void initState() {
    super.initState();
    print("Hello Filter_SalesRereginwiseScreen initState called");
    selectedFilterType = 'lastmonth'; // Set default to "6months"
    fetchDropdownData();
    fetchFilteredData(); // Automatically fetch data for 6 months on screen load
  }

  String formatFilterType(String filter) {
    switch (filter) {
      // case 'today':
      //   return 'Today';
      // case '6months':
      //   return 'Last 6 Months';
      // case 'last30days':
      //   return 'Last 30 Days';
      case 'yeartodate':
        return 'Current Year';
      case 'monthtodate':
        return 'Current Month';

      // case 'year':
      //   return 'This Year';
      case 'lastmonth':
        return 'Previous Month';
      case 'custom':
        return 'Custom Range';
      default:
        return filter;
    }
  }

  Future<void> fetchDropdownData() async {
    try {
      final stateRes =
          await http.get(Uri.parse('${ApiConfig.baseUrl}/state?q='));
      final cityRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/city?q='));
      final skuRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/sku'));

      if (stateRes.statusCode == 200)
        states = List<String>.from(json.decode(stateRes.body));
      if (cityRes.statusCode == 200)
        cities = List<String>.from(json.decode(cityRes.body));
      if (skuRes.statusCode == 200)
        skus = List<String>.from(json.decode(skuRes.body));

      setState(() {});
    } catch (e) {
      print('Error fetching dropdown data: $e');
    }
  }

  String formatDate(DateTime date) =>
      "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Future<void> fetchFilteredData() async {
    if (selectedFilterType == null) return;
    setState(() => isLoading = true);

    String url = '';
    print("selectedFilterType :::>>>  ${selectedFilterType}");

    if (selectedFilterType == 'custom') {
      if (startDate == null || endDate == null) {
        setState(() => isLoading = false);
        return;
      }

      final from = formatDate(startDate!);
      final to = formatDate(endDate!);

      url =
          '${ApiConfig.baseUrl}/sales/resion?filterType=custom&fromDate=$from&toDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    } else {
      url =
          '${ApiConfig.baseUrl}/sales/resion?filterType=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    }
    //var request = http.Request('GET', url);
    var request = http.Request('GET', Uri.parse(url));

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        setState(() {
          salesData = json.decode(data);
          print("Salesdata::::: ${salesData}");

          final breakdown = salesData!['breakdown'];

          // Extract totalSales and date
          // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
          // labels = breakdown.map<String>((item) => item['date'].toString()).toList();

          print("filte typee :: ${selectedFilterType}");

          if (selectedFilterType == "last30days") {
            print("last30days");
            // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
            // labels = breakdown.map<String>((item) => item['date'].toString()).toList();

            values = breakdown
                .map<double>(
                    (item) => (item['totalSales'] as num).roundToDouble())
                .toList();

            labels = breakdown.map<String>((item) {
              final date = DateTime.parse(item['date']);
              return '${date.month.toString().padLeft(1, '0')}-${date.day.toString().padLeft(1, '0')}';
            }).toList();
          }
          if (selectedFilterType == "monthtodate") {
            print("monthtodate");
            // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
            // labels = breakdown.map<String>((item) => item['date'].toString()).toList();

            values = breakdown
                .map<double>(
                    (item) => (item['totalSales'] as num).roundToDouble())
                .toList();

// Format dates to MM-DD
            labels = breakdown.map<String>((item) {
              DateTime date = DateTime.parse(item['date']);
              return "${date.day.toString().padLeft(2, '0')}";
              //return "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
            }).toList();
          }

          if (selectedFilterType == "lastmonth") {
            print("6666666 months");
            // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
            // labels = breakdown.map<String>((item) => item['date'].toString()).toList();

            Map<String, double> monthlyTotals = {};

            for (var item in breakdown) {
              final fullDate = item['date'].toString(); // e.g., "January 2025"

              DateTime? date;
              try {
                // Use DateFormat to parse "January 2025"
                date = DateFormat('MMMM yyyy').parseStrict(fullDate);
              } catch (e) {
                continue; // skip invalid date
              }

              final month = DateFormat('MMM').format(date); // "Jan"
              final year = date.year.toString().substring(2); // "25"
              final label = '$month $year'; // e.g., "Jan 25"

              final sale = (item['totalSales'] as num).toInt().toDouble();
              monthlyTotals[label] = (monthlyTotals[label] ?? 0) + sale;
            }

// Step 2: Convert to chart-friendly lists
            labels = monthlyTotals.keys.toList();
            values = monthlyTotals.values.toList();

            print("6 month${labels}");
            print("6 month${values}");
          }

          if (selectedFilterType == "yeartodate") {
            print("yeartodate");
            // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
            // labels = breakdown.map<String>((item) => item['date'].toString()).toList();

            Map<String, double> monthlyTotals = {};

// Summing totalSales by month
            for (var item in breakdown) {
              DateTime date = DateTime.parse(item['date']);
              String monthLabel =
                  DateFormat('MMM').format(date); // e.g., Jan, Feb
              double totalSales = (item['totalSales'] as num).toDouble();

              if (monthlyTotals.containsKey(monthLabel)) {
                monthlyTotals[monthLabel] =
                    monthlyTotals[monthLabel]! + totalSales;
              } else {
                monthlyTotals[monthLabel] = totalSales;
              }
            }

// Convert the map to separate lists for chart use
            labels = monthlyTotals.keys.toList(); // ['Jan', 'Feb', ...]
            values = monthlyTotals.values
                .map((val) => val.roundToDouble())
                .toList(); // Whole numbers
          }
          if (selectedFilterType == "custom") {
            print("custom");
            Map<String, double> monthlyTotals = {};

            for (var item in breakdown) {
              final fullDate = item['date'].toString(); // e.g., "January 2025"

              DateTime? date;
              try {
                // Use DateFormat to parse "January 2025"
                date = DateFormat('MMMM yyyy').parseStrict(fullDate);
              } catch (e) {
                continue; // skip invalid date
              }

              final month = DateFormat('MMM').format(date); // "Jan"
              final year = date.year.toString().substring(2); // "25"
              final label = '$month $year'; // e.g., "Jan 25"

              final sale = (item['totalSales'] as num).toInt().toDouble();
              monthlyTotals[label] = (monthlyTotals[label] ?? 0) + sale;
            }

// Step 2: Convert to chart-friendly lists
            labels = monthlyTotals.keys.toList();
            values = monthlyTotals.values.toList();
          }

          print("📊 values: $values");
          print("📅 labels: $labels");

          fetchAdData();
          isLoading = false;
        });
      }

      // if (response.statusCode == 200) {
      //   final data = await response.stream.bytesToString();
      //   setState(() {
      //
      //     salesData = json.decode(data);
      //     fetchAdData();
      //     isLoading = false;
      //   });
      // }
      else {
        setState(() {
          errorMessage = response.reasonPhrase ?? "Failed to fetch data.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchAdData() async {
    if (selectedFilterType == null) return;

    setState(() => isLoading = true);

    String url = '';

    if (selectedFilterType == 'custom') {
      if (startDate == null || endDate == null) {
        setState(() => isLoading = false);
        return;
      }

      final from = formatDate(startDate!);
      final to = formatDate(endDate!);

      url =
          '${ApiConfig.baseUrl}/data/filterData?range=custom&startDate=$from&endDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    } else {
      url =
          '${ApiConfig.baseUrl}/data/filterData?range=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    }

    var request = http.Request('GET', Uri.parse(url));

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(data);

        setState(() {
          adssales = jsonResponse; // Entire JSON stored
          // totalAdSales = double.parse((jsonResponse['totalAdSales'] ?? 0.0).toString()).toStringAsFixed(2);
          // totalAdSpend = double.parse((jsonResponse['totalAdSpend'] ?? 0.0).toString()).toStringAsFixed(2);
          print("console:::   ${adssales}");
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = response.reasonPhrase ?? 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = '❌ Error: $e';
        isLoading = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void onDropdownChanged(String? value, String type) {
    setState(() {
      if (type == 'filter') {
        selectedFilterType = value;
        if (value != 'custom') {
          fetchFilteredData();
          fetchAdData();
        }
      } else if (type == 'state') {
        selectedState = value;
        fetchFilteredData();
      } else if (type == 'city') {
        selectedCity = value;
        fetchFilteredData();
      } else if (type == 'sku') {
        selectedSku = value;
        fetchFilteredData();
      }
    });
  }

  Future<void> selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      fetchFilteredData();
      fetchAdData();
    }
  }

  // final List<double> values = [100, 150, 300, 112, 403, 500, 207, 270];
  // final List<String> labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Next'];
  String formatShortYearMonth(String date) {
    DateTime parsedDate = DateTime.parse(date);
    String shortYear = parsedDate.year.toString().substring(2); // "25"
    String month = parsedDate.month.toString().padLeft(2, '0'); // "04"
    return '$shortYear-$month';
  }

  @override
  Widget build(BuildContext context) {
    final config = getChartConfig('monthtodate');
    return Scaffold(
      // appBar: AppBar(title: const Text("Sales Data Viewer")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 190,
                    height: 50, // Fixed height
                    child: DropdownButtonFormField<String>(
                      isDense: true, // Makes dropdown compact
                      style: TextStyle(
                          fontSize: 12, color: Colors.black), // Smaller font
                      decoration: customInputDecoration(
                        hintText: "Select Filter Type",
                      ),
                      items: filterTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            formatFilterType(type),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        );
                      }).toList(),
                      value: selectedFilterType,
                      onChanged: (val) => onDropdownChanged(val, 'filter'),
                    ),
                  ),

                  if (selectedFilterType == 'custom')
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: () => selectDateRange(context),
                        icon: Icon(Icons.date_range),
                        label: Text(
                          startDate != null && endDate != null
                              ? "${formatDate(startDate!)} - ${formatDate(endDate!)}"
                              : "Select Date Range",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                  SizedBox(width: 8), // optional spacing
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: DropdownSearch<String>(
                      items: states,
                      selectedItem: selectedState,
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Search State",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                          // dropdownSearchDecoration: InputDecoration(
                          //   labelText: "State",
                          //   border: OutlineInputBorder(),
                          // ),
                          dropdownSearchDecoration:
                              customInputDecoration(labelText: "State")),
                      clearButtonProps: ClearButtonProps(isVisible: true),
                      onChanged: (val) => onDropdownChanged(val, 'state'),
                    ),
                  ),
                  // SizedBox(width: 8),
                  // SizedBox(
                  //   width: 150,
                  //   height: 50,
                  //   child: DropdownSearch<String>(
                  //     items: cities,
                  //     selectedItem: selectedCity,
                  //     popupProps: PopupProps.menu(
                  //       showSearchBox: true,
                  //       searchFieldProps: TextFieldProps(
                  //         decoration: InputDecoration(
                  //           hintText: "Search City",
                  //           border: OutlineInputBorder(),
                  //         ),
                  //       ),
                  //     ),
                  //     dropdownDecoratorProps: DropDownDecoratorProps(
                  //       // dropdownSearchDecoration: InputDecoration(
                  //       //   labelText: "City",
                  //       //   border: OutlineInputBorder(),
                  //       // ),
                  //       dropdownSearchDecoration:
                  //           customInputDecoration(labelText: "City"),
                  //     ),
                  //     clearButtonProps: ClearButtonProps(isVisible: true),
                  //     onChanged: (val) => onDropdownChanged(val, 'city'),
                  //   ),
                  // ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: DropdownSearch<String>(
                      items: skus,
                      selectedItem: selectedSku,
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Search SKU",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        // dropdownSearchDecoration: InputDecoration(
                        //   labelText: "SKU",
                        //   border: OutlineInputBorder(),
                        // ),
                        dropdownSearchDecoration:
                            customInputDecoration(labelText: "SKU"),
                      ),
                      clearButtonProps: ClearButtonProps(isVisible: true),
                      onChanged: (val) => onDropdownChanged(val, 'sku'),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            //BarChartSample(values: values, labels: labels),
            BarChartSample(values: values, labels: labels, isWeb: isWeb),

            isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : SingleChildScrollView(
              child:

              Column(
                children: [
                  // Align(
                  //   alignment: Alignment.center,
                  //   child: Text(
                  //     "Sales",
                  //     style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),
                  //   ),
                  // ),

                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Sales ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: (salesData != null &&
                              salesData!['comparison']?['previousPeriod']?['startDate'] != null &&
                              salesData!['comparison']?['previousPeriod']?['endDate'] != null)
                              ? 'Compared with ${formatShortYearMonth(salesData!['comparison']['previousPeriod']['startDate'])} To ${formatShortYearMonth(salesData!['comparison']['previousPeriod']['endDate'])}'
                              : 'Comparison data unavailable',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        )



                        // TextSpan(
                        //   text: 'as of ${salesData?['comparison']['previousPeriod']['startDate']}/${salesData?['comparison']['previousPeriod']['endDate']}',
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     fontWeight: FontWeight.w400,
                        //   ),
                        // ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child:Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: [
                          Row(children: [
                            Expanded(
                                child: MetricCard(
                                  title: "Overall Sales",
                                  value: '£ ${NumberFormat('#,###').format((salesData?['totalSales'] ?? 0).round())}',
                                  compared: "${salesData?['comparison']['salesChangePercent']??"0"}",)
                            ),
                            // title: "Overall Sales", value: '£ ${salesData?['totalSales'].toStringAsFixed(2)}', compared: "${salesData?['comparison']['salesChangePercent']}",)),
                            SizedBox(width: 8),
                            Expanded(
                              child: MetricCard(
                                title: "Units Ordered",
                                value: "${NumberFormat('#,###').format((salesData?['totalQuantity'] ?? 0).round())}",
                                compared: "${salesData?['comparison']['quantityChangePercent']}",
                                //value:"${salesData?['totalQuantity']}", compared: "${salesData?['comparison']['quantityChangePercent']}",
                              ),),

                          ],),
                          SizedBox(height: 8,),
                          Row(
                            children: [

                              // Expanded(
                              //   child: MetricCardcm(
                              //     title: "AOV",
                              //     //value: "",
                              //     value: "£ ${NumberFormat('#,###').format(
                              //         (((salesData?['totalSales'] ?? 0.0) as num) /
                              //             ((adssales?['totalOrders'] ?? 1) as num)).toInt()
                              //     )}",
                              //     //value: "£ ${(((salesData?['totalSales'] ?? 0.0) as num) / ((adssales?['totalOrders'] ?? 1) as num)).toStringAsFixed(0)}",
                              //     //  totalOrders
                              //   ),
                              // ),



                              Expanded(
                                child: MetricCard(
                                  title: "AOV",
                                  //value: "",
                                  value: "£ ${NumberFormat('#,###').format(
                                      (((salesData?['totalSales'] ?? 0.0) as num) / (((adssales?['totalOrders'] == 0 ? 1 : adssales?['totalOrders']) ?? 1) as num)).toInt()
                                  )}",
                                  compared: "${salesData?['comparison']['aovChangePercent']}",
                                  //value: "£ ${(((salesData?['totalSales'] ?? 0.0) as num) / ((adssales?['totalSales'] ?? 1) as num)).toStringAsFixed(0)}",
                                  //  totalOrders
                                ),
                              ),


                              const SizedBox(width: 8),

                              Expanded(
                                child: MetricCard(
                                  title: "Organic Sales",
                                  value: "£ ${NumberFormat('#,###').format(
                                      ((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).round()
                                  )}",
                                  compared: "${salesData?['comparison']['organicSalesChangePercent']}",
                                  //value: "£ ${((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).toStringAsFixed(0)}",

                                ),
                              ),
                            ],
                          ),

                        ],),
                      )
                  ),

                  SizedBox(height: 8,),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Ads",
                      style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child:Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: [
                          Row(
                            children: [
                              Expanded(
                                child: MetricCardcm(
                                  title: "Ad Spend",
                                  // title: Salesvaluepnl.toString(),
                                  value: "£ ${NumberFormat('#,###').format(
                                      (adssales?['totalAdSpend'] ?? 0).toDouble().round()
                                  )}",
                                  // value: "£ ${((adssales?['totalAdSpend'] ?? 0).toDouble()).toStringAsFixed(0)}",


                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: MetricCardcm(
                                  title: "Ad Sales",
                                  value: "£ ${NumberFormat('#,###').format(
                                      (adssales?['totalAdSales'] ?? 0).toDouble().round()
                                  )}",
                                  //value: "£ ${((adssales?['totalAdSales'] ?? 0).toDouble()).toStringAsFixed(0)}",



                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              if(selectedFilterType!= "last30days")
                                Expanded(
                                  child: MetricCardcm(
                                    title: "ACOS",
                                    value: "${(((adssales?['totalAdSpend'] ?? 0) / (adssales?['totalAdSales'] ?? 1)) * 100).toStringAsFixed(2)} %",
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: MetricCardcm(
                                  title: "TACOS",
                                  value: "${((adssales?['totalAdSpend'] ?? 0) / (Salesvaluepnl) * 100).toStringAsFixed(2)} %",
                                ),
                              ),
                            ],
                          ),
                        ],),
                      )
                  ),
                  SizedBox(height: 8,),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child:Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: [
                          Row(
                            children: [
                              Expanded(
                                child: MetricCardcm(
                                  title: "Organic Sales",
                                  value:
                                  "${(((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)) / (salesData?['totalSales'] ?? 0.0) * 100).toStringAsFixed(2)} %",
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: MetricCardcm(
                                  title: "ROAS",
                                  value:
                                  "${(((adssales?['totalAdSpend'] ?? 0) / (salesData?['totalSales'] ?? 1))).toStringAsFixed(2)} ",
                                ),
                              ),
                            ],
                          ),

                        ],),
                      )
                  ),

                  // SizedBox(height: 8,),
                  // Text.rich(
                  //   TextSpan(
                  //     children: [
                  //       TextSpan(
                  //         text: 'Inventory ',
                  //         style: TextStyle(
                  //           fontSize: 18,
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //       TextSpan(
                  //         text: 'as of today',
                  //         style: TextStyle(
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.w400,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  //
                  // Container(
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(12),
                  //       border: Border.all(color: Colors.grey),
                  //     ),
                  //     child:Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: Column(children: [
                  //
                  //         // Column(
                  //         //   crossAxisAlignment: CrossAxisAlignment.start,
                  //         //   children: [
                  //         //     Text('Days in Stock: $DaysInStock'),
                  //         //     Text('Understock: $understockCount'),
                  //         //     Text('Overstock: $overstockCount'),
                  //         //     Text('Balanced: $balancedCount'),
                  //         //     Text('SKUs with InStock Rate 0: $zeroInStockRateSkuCount'),
                  //         //
                  //         //   ],
                  //         // ),
                  //
                  //
                  //         Row(
                  //           children: [
                  //             Expanded(
                  //               child: MetricCardinvetory(
                  //                 title: "InStock Rate",
                  //                 value: "${DaysInStock} %",
                  //                 compared: "",
                  //               ),
                  //             ),
                  //
                  //             const SizedBox(width: 8),
                  //             Expanded(
                  //               child: MetricCardinvetory(
                  //                 title: "Active SKU OOS",
                  //                 value: '$zeroInStockRateSkuCount',
                  //                 compared: "SKU Counts",
                  //
                  //                 // value: "${(((adssales?['totalAdSales'] ?? 0) / (adssales?['totalAdSpend'] ?? 1)) * 100).toStringAsFixed(2)} %",
                  //
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //         SizedBox(height: 8,),
                  //         Row(
                  //           children: [
                  //             Expanded(
                  //               child: MetricCardinvetory(
                  //                 title: "Over Stock",
                  //                 value:"$overstockCount",
                  //                 compared: "SKU Counts",
                  //                 // value: "${(((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0))/(salesData?['totalSales'] ?? 0.0)*100).toStringAsFixed(2)} %",
                  //               ),
                  //             ),
                  //
                  //             const SizedBox(width: 8),
                  //             Expanded(
                  //               child: MetricCardinvetory(
                  //                 title: "Under Stock",
                  //                 value: "$understockCount",
                  //                 compared: "SKU Counts",
                  //                 // value: "${(((adssales?['totalAdSales'] ?? 0) / (adssales?['totalAdSpend'] ?? 1)) * 100).toStringAsFixed(2)} %",
                  //
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //
                  //       ],),
                  //     )
                  // ),
                  //





                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String compared;

  const MetricCard(
      {super.key,
      required this.title,
      required this.value,
      required this.compared});

  @override
  Widget build(BuildContext context) {
    print(compared);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, style: const TextStyle(fontSize: 16),
            // textAlign: TextAlign.left
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  compared.contains('Profit')
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 14,
                  color:
                      compared.contains('Profit') ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  compared.split(' ').first, // e.g., "219.93%"
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color:
                        compared.contains('Profit') ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MetricCardcm extends StatelessWidget {
  final String title;
  final String value;

  const MetricCardcm({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, style: const TextStyle(fontSize: 16),
            // textAlign: TextAlign.left
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            // textAlign: TextAlign.left
          ),
        ],
      ),
    );
  }
}
*/
