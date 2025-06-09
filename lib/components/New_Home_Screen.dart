import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/financescreens/Finance_Executive_Web_Screen.dart';
import 'package:flutter_application_1/utils/check_platform.dart';
import 'package:flutter_application_1/utils/custom_dropdown.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../comman_Screens/productcard.dart';
import '../../../utils/colors.dart';
import '../financescreens/Finance_Executive_Screen.dart';
import '../graph/commanbarchar_file.dart';
import '../utils/ApiConfig.dart';
import '../utils/chart_config.dart';
import 'Dashboard.dart'; // Import the package

class NewHomeScreen extends StatefulWidget {
  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen>
    with SingleTickerProviderStateMixin {
  List<String> states = [];
  List<String> cities = [];
  List<String> skus = [];
  bool isWeb = false;
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: 'Account Level'),
    //Tab(text: 'ASINs'),
  ];


  List<String> filterTypes = [
    // "today",
    //"week",
    //"last30days",
    "lastmonth",
    "monthtodate",
    "previousyear",
    // "currentyear",
    "yeartodate",
    "custom"
    // "monthtodate",
    // "lastmonth",
    //'6months',
    //"yeartodate",
    // "custom",
  ];



/*  List<String> filterTypes = [

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
  Map<String, dynamic>? salesData;
  Map<String, dynamic>? adssales;
  String errorMessage = '';

  bool isLoading = false;
  String? errorMsg;

  List<double> values = [10, 20, 30];
  List<String> labels = [];
  Map<String, double> monthlyTotals = {};

  @override
  void initState() {
    super.initState();
    isWeb = checkPlatform();
    _tabController = TabController(length: myTabs.length, vsync: this);
    selectedFilterType = 'lastmonth'; // Set default to "6months"
    fetchDropdownData();
    fetchFilteredData();
    fetchAdData(); // Automatically fetch data for 6 months on screen load
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String formatFilterType(String filter) {
    switch (filter) {

      case 'monthtodate':
        return 'Current Month';
      case 'lastmonth':
        return 'Last Month';
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
//
//   Future<void> fetchFilteredData() async {
//     if (selectedFilterType == null) return;
//     setState(() => isLoading = true);
//
//     String url = '';
//
//     if (selectedFilterType == 'custom') {
//       if (startDate == null || endDate == null) {
//         setState(() => isLoading = false);
//         return;
//       }
//
//       final from = formatDate(startDate!);
//       final to = formatDate(endDate!);
//
//       url =
//           '${ApiConfig.baseUrl}/sales/resion?filterType=custom&fromDate=$from&toDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
//     } else {
//       url =
//           '${ApiConfig.baseUrl}/sales/resion?filterType=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
//     }
//     //var request = http.Request('GET', url);
//
//     var request = http.Request('GET', Uri.parse(url));
//
//     try {
//       http.StreamedResponse response = await request.send();
//
//
//       if (response.statusCode == 200) {
//         final data = await response.stream.bytesToString();
//
//         setState(() {
//           salesData = json.decode(data);
//           print("Salesdata::::: ${salesData}");
//
//           final breakdown = salesData!['breakdown'];
//
//           print("filte typee :: ${selectedFilterType}");
//
//           if (selectedFilterType == "last30days") {
//             print("last30days");
//
//             values = breakdown
//                 .map<double>(
//                     (item) => (item['totalSales'] as num).roundToDouble())
//                 .toList();
//
//             labels = breakdown.map<String>((item) {
//               final date = DateTime.parse(item['date']);
//               return '${date.month.toString().padLeft(1, '0')}-${date.day.toString().padLeft(1, '0')}';
//             }).toList();
//           }
//           if (selectedFilterType == "monthtodate") {
//             print("monthtodate");
//
//             values = breakdown
//                 .map<double>(
//                     (item) => (item['totalSales'] as num).roundToDouble())
//                 .toList();
//
// // Format dates to MM-DD
//             labels = breakdown.map<String>((item) {
//               DateTime date = DateTime.parse(item['date']);
//               return "${date.day.toString().padLeft(1, '0')}";
//               //return "${date.month.toString().padLeft(0, '0')}-${date.day.toString().padLeft(1, '0')}";
//             }).toList();
//           }
//
//           if (selectedFilterType == "lastmonth") {
//             print("6666666 months");
//             // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
//             // labels = breakdown.map<String>((item) => item['date'].toString()).toList();
//
//             Map<String, double> monthlyTotals = {};
//
//             for (var item in breakdown) {
//               final fullDate = item['date'].toString(); // e.g., "January 2025"
//
//               DateTime? date;
//               try {
//                 // Use DateFormat to parse "January 2025"
//                 date = DateFormat('MMMM yyyy').parseStrict(fullDate);
//               } catch (e) {
//                 continue; // skip invalid date
//               }
//
//               final month = DateFormat('MMM').format(date); // "Jan"
//               final year = date.year.toString().substring(2); // "25"
//               final label = '$month $year'; // e.g., "Jan 25"
//
//               final sale = (item['totalSales'] as num).toInt().toDouble();
//               monthlyTotals[label] = (monthlyTotals[label] ?? 0) + sale;
//             }
//
// // Step 2: Convert to chart-friendly lists
//             labels = monthlyTotals.keys.toList();
//             values = monthlyTotals.values.toList();
//
//             print("6 month${labels}");
//             print("6 month${values}");
//           }
//
//           if (selectedFilterType == "yeartodate") {
//             print("yeartodate");
//             // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
//             // labels = breakdown.map<String>((item) => item['date'].toString()).toList();
//
//             Map<String, double> monthlyTotals = {};
//
// // Summing totalSales by month
//             for (var item in breakdown) {
//               DateTime date = DateTime.parse(item['date']);
//               String monthLabel =
//                   DateFormat('MMM').format(date); // e.g., Jan, Feb
//               double totalSales = (item['totalSales'] as num).toDouble();
//
//               if (monthlyTotals.containsKey(monthLabel)) {
//                 monthlyTotals[monthLabel] =
//                     monthlyTotals[monthLabel]! + totalSales;
//               } else {
//                 monthlyTotals[monthLabel] = totalSales;
//               }
//             }
//
// // Convert the map to separate lists for chart use
//             labels = monthlyTotals.keys.toList(); // ['Jan', 'Feb', ...]
//             values = monthlyTotals.values
//                 .map((val) => val.roundToDouble())
//                 .toList(); // Whole numbers
//           }
//           if (selectedFilterType == "custom") {
//             print("custom");
//             Map<String, double> monthlyTotals = {};
//
//             for (var item in breakdown) {
//               final fullDate = item['date'].toString(); // e.g., "January 2025"
//
//               DateTime? date;
//               try {
//                 // Use DateFormat to parse "January 2025"
//                 date = DateFormat('MMMM yyyy').parseStrict(fullDate);
//               } catch (e) {
//                 continue; // skip invalid date
//               }
//
//               final month = DateFormat('MMM').format(date); // "Jan"
//               final year = date.year.toString().substring(2); // "25"
//               final label = '$month $year'; // e.g., "Jan 25"
//
//               final sale = (item['totalSales'] as num).toInt().toDouble();
//               monthlyTotals[label] = (monthlyTotals[label] ?? 0) + sale;
//             }
//
// // Step 2: Convert to chart-friendly lists
//             labels = monthlyTotals.keys.toList();
//             values = monthlyTotals.values.toList();
//           }
//
//           print("📊 values: $values");
//           print("📅 labels: $labels");
//
//           fetchAdData();
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = response.reasonPhrase ?? "Failed to fetch data.";
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }




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
      '${ApiConfig.baseUrl}/sales/resion?filterType=custom&fromDate=$from&toDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    } else {
      url =
      '${ApiConfig.baseUrl}/sales/resion?filterType=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    }

    var request = http.Request('GET', Uri.parse(url));

    try {
      http.StreamedResponse response = await request.send();

      final rawData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(rawData);

        // Check if API returned "No records found."
        if (data is Map && data.containsKey('message') && data['message'] == "No records found.") {
          setState(() {
            salesData = {};
            labels = [];
            values = [];
            errorMessage = "No records found.";
            isLoading = false;
          });
          return;
        }

        setState(() {
          salesData = data;
          final breakdown = salesData!['breakdown'];

          values = [];
          labels = [];

          if (selectedFilterType == "last30days") {
            values = breakdown
                .map<double>((item) => (item['totalSales'] as num).roundToDouble())
                .toList();

            labels = breakdown.map<String>((item) {
              final date = DateTime.parse(item['date']);
              return '${date.month.toString().padLeft(1, '0')}-${date.day.toString().padLeft(1, '0')}';
            }).toList();
          }

          if (selectedFilterType == "monthtodate") {
            values = breakdown
                .map<double>((item) => (item['totalSales'] as num).roundToDouble())
                .toList();

            labels = breakdown.map<String>((item) {
              DateTime date = DateTime.parse(item['date']);
              return "${date.day.toString().padLeft(1, '0')}";
            }).toList();
          }

          if (selectedFilterType == "lastmonth" || selectedFilterType == "custom") {
            Map<String, double> monthlyTotals = {};
            for (var item in breakdown) {
              final fullDate = item['date'].toString();

              DateTime? date;
              try {
                date = DateFormat('MMMM yyyy').parseStrict(fullDate);
              } catch (e) {
                continue;
              }

              final month = DateFormat('MMM').format(date);
              final year = date.year.toString().substring(2);
              final label = '$month $year';
              final sale = (item['totalSales'] as num).toInt().toDouble();
              monthlyTotals[label] = (monthlyTotals[label] ?? 0) + sale;
            }

            labels = monthlyTotals.keys.toList();
            values = monthlyTotals.values.toList();
          }

          if (selectedFilterType == "yeartodate") {
            Map<String, double> monthlyTotals = {};
            for (var item in breakdown) {
              DateTime date = DateTime.parse(item['date']);
              String monthLabel = DateFormat('MMM').format(date);
              double totalSales = (item['totalSales'] as num).toDouble();
              monthlyTotals[monthLabel] = (monthlyTotals[monthLabel] ?? 0) + totalSales;
            }

            labels = monthlyTotals.keys.toList();
            values = monthlyTotals.values.map((val) => val.roundToDouble()).toList();
          }

          print("📊 values: $values");
          print("📅 labels: $labels");


          fetchAdData();

          isLoading = false;
          //errorMessage = null;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          salesData = {};
          labels = [];
          values = [];
          errorMessage = "Data not found (404).";
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch data: ${response.reasonPhrase}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
        isLoading = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchAdData() async {
    if (selectedFilterType == null) return;

    setState(() {
      isLoading = true;
      errorMsg = null;
      adssales = null; // Clear previous data
    });

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

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);

        if (jsonResponse is Map && jsonResponse.containsKey("message") && jsonResponse["message"] == "No records found.") {
          setState(() {
            adssales = null;
            errorMsg = "No records found.";
            isLoading = false;
          });
        } else {
          setState(() {
            adssales = jsonResponse;
            errorMsg = null;
            isLoading = false;
            print("📊 Ad sales data: $adssales");
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          adssales = null;
          errorMsg = "Data not found (404)";
          isLoading = false;
        });
      } else {
        setState(() {
          adssales = null;
          errorMsg = "Error: ${response.reasonPhrase ?? 'Failed to load data'}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        adssales = null;
        errorMsg = '❌ Error: $e';
        isLoading = false;
      });
    }
  }


  // Future<void> fetchAdData() async {
  //   if (selectedFilterType == null) return;
  //
  //   setState(() => isLoading = true);
  //
  //   String url = '';
  //
  //   if (selectedFilterType == 'custom') {
  //     if (startDate == null || endDate == null) {
  //       setState(() => isLoading = false);
  //       return;
  //     }
  //
  //     final from = formatDate(startDate!);
  //     final to = formatDate(endDate!);
  //
  //     url =
  //         '${ApiConfig.baseUrl}/data/filterData?range=custom&startDate=$from&endDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
  //   } else {
  //     url =
  //         '${ApiConfig.baseUrl}/data/filterData?range=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
  //   }
  //
  //   var request = http.Request('GET', Uri.parse(url));
  //
  //   try {
  //     http.StreamedResponse response = await request.send();
  //
  //     if (response.statusCode == 200) {
  //       final data = await response.stream.bytesToString();
  //       final jsonResponse = jsonDecode(data);
  //
  //       setState(() {
  //         adssales = jsonResponse; // Entire JSON stored
  //         // totalAdSales = double.parse((jsonResponse['totalAdSales'] ?? 0.0).toString()).toStringAsFixed(2);
  //         // totalAdSpend = double.parse((jsonResponse['totalAdSpend'] ?? 0.0).toString()).toStringAsFixed(2);
  //         print("console:::   ${adssales}");
  //         isLoading = false;
  //       });
  //     } else {
  //       setState(() {
  //         errorMsg = response.reasonPhrase ?? 'Failed to load data';
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       errorMsg = '❌ Error: $e';
  //       isLoading = false;
  //     });
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }

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

  void _showDateRangePicker(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        PickerDateRange? selectedRange; // Store the selected range

        return StatefulBuilder(
          // Use StatefulBuilder for state within the dialog
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: AppColors.beige,
              title: Text('Select Date Range'),
              content: Container(
                width: 300,
                height: 350,
                child: SfDateRangePicker(
                  backgroundColor: AppColors.white,
                  selectionColor: AppColors.gold,
                  todayHighlightColor: AppColors.gold,
                  rangeSelectionColor: AppColors.gold,
                  endRangeSelectionColor: AppColors.gradientStart,
                  startRangeSelectionColor: AppColors.gradientStart,
                  selectionMode: DateRangePickerSelectionMode.range,
                  navigationMode: DateRangePickerNavigationMode.scroll,
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    if (args.value is PickerDateRange) {
                      print(
                          "Selected Range: ${args.value.startDate} to ${args.value.endDate}");
                      selectedRange = args.value;
                      setState(() {
                        startDate = args.value?.startDate;
                        endDate = args.value?.endDate;
                      });
                    }
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.gold),
                  ),
                  onPressed: () {
                    // _selectedTime = 'Last 12 months';
                    // String range =
                    //               DateUtilsHelper.getDateRange(_selectedTime);
                    //           _fetchData(range);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Apply', style: TextStyle(color: AppColors.gold)),
                  onPressed: () {
                    if (selectedRange != null) {
                      // setState(() {
                      // String range =
                      //           DateUtilsHelper.getDateRangeFromDates(selectedRange?.startDate, selectedRange?.endDate);
                      // _fetchData(range);
                      fetchFilteredData();
                      fetchAdData();
                      // });
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = getChartConfig('monthtodate');
    return Scaffold(

      appBar: AppBar(
        toolbarHeight: 0, // Removes extra space above TabBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            tabs: myTabs,
            indicatorSize: TabBarIndicatorSize.tab,
            tabAlignment: TabAlignment.fill,
            indicator: BoxDecoration(
              color: AppColors.gold,
            ),
            indicatorColor: Colors.black,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          Dashboard(),

          // Padding(
          //     padding: const EdgeInsets.all(10.0),
          //     child: ListView(
          //       // mainAxisAlignment: MainAxisAlignment.end,
          //       children: [
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.end,
          //           children: [
          //             CustomDropdown(
          //               value: selectedFilterType,
          //               items: filterTypes,
          //               hintText: "Select Filter Type",
          //               onChanged: (val) => onDropdownChanged(val, 'filter'),
          //             ),
          //             if (selectedFilterType == 'custom')
          //               Padding(
          //                 padding: const EdgeInsets.only(left: 8.0),
          //                 child: ElevatedButton.icon(
          //                   onPressed: () => _showDateRangePicker(context),
          //                   // onPressed: () => selectDateRange(context),
          //
          //                   icon: Icon(Icons.date_range),
          //                   label: Text(
          //                     startDate != null && endDate != null
          //                         ? "${formatDate(startDate!)} - ${formatDate(endDate!)}"
          //                         : "Select Date Range",
          //                     overflow: TextOverflow.ellipsis,
          //                   ),
          //                 ),
          //               ),
          //           ],
          //         ),
          //         // 🔼 Your dropdown and filter widgets here...
          //
          //         //   const SizedBox(height: 20),
          //
          //        // BarChartSample(values: values, labels: labels, isWeb: isWeb),
          //         BarChartSample(values: values, labels: labels, isWeb: isWeb, activeCount: config['activeCount'],),
          //
          //         /// This is your scrollable main content
          //         isLoading
          //             ? Center(child: CircularProgressIndicator())
          //             : errorMessage.isNotEmpty
          //                 ? Center(child: Text(errorMessage))
          //                 : SingleChildScrollView(
          //                     child: Column(
          //                       children: [
          //                         Row(
          //                           children: [
          //                             Expanded(
          //                                 child: MetricCard(
          //                               title: "Overall Sales",
          //                               value:
          //                                   '£ ${NumberFormat('#,###').format((salesData?['totalSales'] ?? 0).round())}',
          //                               compared:
          //                                   "${salesData?['comparison']['salesChangePercent'] ?? "0"}",
          //                             )),
          //                             // title: "Overall Sales", value: '£ ${salesData?['totalSales'].toStringAsFixed(2)}', compared: "${salesData?['comparison']['salesChangePercent']}",)),
          //                             SizedBox(width: 8),
          //                             Expanded(
          //                               child: MetricCard(
          //                                 title: "Units Ordered",
          //                                 value:
          //                                     "${NumberFormat('#,###').format((salesData?['totalQuantity'] ?? 0).round())}",
          //                                 compared:
          //                                     "${salesData?['comparison']['quantityChangePercent']}",
          //                                 //value:"${salesData?['totalQuantity']}", compared: "${salesData?['comparison']['quantityChangePercent']}",
          //                               ),
          //                             ),
          //                           ],
          //                         ),
          //                         SizedBox(
          //                           height: 8,
          //                         ),
          //                         SizedBox(
          //                           height: 10,
          //                         ),
          //                         Row(
          //                           children: [
          //                             if (selectedFilterType != "last30days")
          //                               Expanded(
          //                                 child: MetricCardcm(
          //                                   title: "AOV",
          //                                   //value: "",
          //                                   value:
          //                                       "£ ${NumberFormat('#,###').format((((salesData?['totalSales'] ?? 0.0) as num) / ((adssales?['totalOrders'] ?? 1) as num)).toInt())}",
          //                                   //value: "£ ${(((salesData?['totalSales'] ?? 0.0) as num) / ((adssales?['totalOrders'] ?? 1) as num)).toStringAsFixed(0)}",
          //                                   //  totalOrders
          //                                 ),
          //                               ),
          //                             if (selectedFilterType == "last30days")
          //                               Expanded(
          //                                 child: MetricCardcm(
          //                                   title: "AOV",
          //                                   //value: "",
          //                                   value: "£ 00",
          //                                   //  totalOrders
          //                                 ),
          //                               ),
          //                             const SizedBox(width: 8),
          //                             if (selectedFilterType != "last30days")
          //                               Expanded(
          //                                 child: MetricCardcm(
          //                                   title: "Organic Sales",
          //                                   value:
          //                                       "£ ${NumberFormat('#,###').format(((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).round())}",
          //                                   //value: "£ ${((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).toStringAsFixed(0)}",
          //                                 ),
          //                               ),
          //                             if (selectedFilterType == "last30days")
          //                               Expanded(
          //                                 child: MetricCardcm(
          //                                   title: "Organic Sales",
          //                                   value: "£ 00",
          //                                   //value: "£ ${((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).toStringAsFixed(0)}",
          //                                 ),
          //                               ),
          //                           ],
          //                         ),
          //                         SizedBox(
          //                           height: 10,
          //                         ),
          //                         Row(
          //                           children: [
          //                             Expanded(
          //                               child: MetricCardcm(
          //                                 title: "Ad Spend",
          //                                 value:
          //                                     "£ ${NumberFormat('#,###').format((adssales?['totalAdSpend'] ?? 0).toDouble().round())}",
          //                                 // value: "£ ${((adssales?['totalAdSpend'] ?? 0).toDouble()).toStringAsFixed(0)}",
          //                               ),
          //                             ),
          //                             const SizedBox(width: 8),
          //                             Expanded(
          //                               child: MetricCardcm(
          //                                 title: "Ad Sales",
          //                                 value:
          //                                     "£ ${NumberFormat('#,###').format((adssales?['totalAdSales'] ?? 0).toDouble().round())}",
          //                                 //value: "£ ${((adssales?['totalAdSales'] ?? 0).toDouble()).toStringAsFixed(0)}",
          //                               ),
          //                             ),
          //                           ],
          //                         ),
          //                         SizedBox(
          //                           height: 10,
          //                         ),
          //                         Row(
          //                           children: [
          //                             if (selectedFilterType != "last30days")
          //                               Expanded(
          //                                 child: MetricCardcm(
          //                                   title: "ACOS",
          //                                   value:
          //                                       "${(((adssales?['totalAdSpend'] ?? 0) / (adssales?['totalAdSales'] ?? 1)) * 100).toStringAsFixed(2)} %",
          //                                 ),
          //                               ),
          //                             if (selectedFilterType == "last30days")
          //                               Expanded(
          //                                 child: MetricCardcm(
          //                                   title: "ACOS",
          //                                   value: "0.00 %",
          //                                 ),
          //                               ),
          //                             const SizedBox(width: 8),
          //                             Expanded(
          //                               child: MetricCardcm(
          //                                 title: "TACOS",
          //                                 value:
          //                                     "${((adssales?['totalAdSales'] ?? 0) / (salesData?['totalSales'] ?? 0) * 100).toStringAsFixed(2)} %",
          //                               ),
          //                             ),
          //                           ],
          //                         ),
          //                         SizedBox(
          //                           height: 8,
          //                         ),
          //                         Row(
          //                           children: [
          //                             if (selectedFilterType != "last30days")
          //                               Expanded(
          //                                 child: MetricCardcm(
          //                                   title: "Organic Sales",
          //                                   value:
          //                                       "${(((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)) / (salesData?['totalSales'] ?? 0.0) * 100).toStringAsFixed(2)} %",
          //                                 ),
          //                               ),
          //                             if (selectedFilterType == "last30days")
          //                               Expanded(
          //                                 child: MetricCardcm(
          //                                   title: "Organic Sales",
          //                                   value: "0.00 %",
          //                                 ),
          //                               ),
          //                             const SizedBox(width: 8),
          //                             Expanded(
          //                               child: MetricCardcm(
          //                                 title: "ROAS",
          //                                 value:
          //                                     "${(((adssales?['totalAdSpend'] ?? 0) / (salesData?['totalSales'] ?? 1))).toStringAsFixed(2)} ",
          //                               ),
          //                             ),
          //                           ],
          //                         ),
          //                       ],
          //                     ),
          //
          //
          //                   ),
          //
          //         /// 🔽 Fixed bottom section (not scrollable)
          //         Column(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             const SizedBox(height: 10),
          //             const SizedBox(height: 10),
          //             if (!isLoading)
          //               TextButton(
          //                 onPressed: () {
          //                   Navigator.push(
          //                     context,
          //                     MaterialPageRoute(
          //                       builder: (context) => kIsWeb
          //                           ? FinanceExecutiveWebScreen()
          //                           : FinanceExecutiveScreen(),
          //                     ),
          //                   );
          //                 },
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     Text(
          //                       'View full P&L',
          //                       style: TextStyle(
          //                         fontWeight: FontWeight.bold,
          //                         color: AppColors.gold,
          //                       ),
          //                     ),
          //                     const SizedBox(width: 8),
          //                     Icon(Icons.arrow_forward, color: AppColors.gold),
          //                   ],
          //                 ),
          //               ),
          //             Divider(color: AppColors.gold, thickness: 0.5),
          //           ],
          //         ),
          //       ],
          //     )),


        ],
      ),
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
