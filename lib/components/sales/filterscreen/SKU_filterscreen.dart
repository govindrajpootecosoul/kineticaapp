/*
import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/components/sales/filterscreen/sales_sku_expandable_card.dart.dart';
import 'package:flutter_application_1/components/sales/filterscreen/sales_sku_expandable_web_card.dart';
import 'package:flutter_application_1/utils/custom_dropdown.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;

import '../../../utils/ApiConfig.dart';

class Filter_SalesSkuScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<Filter_SalesSkuScreen> {
  List<dynamic> salesData = [];
  bool isLoading = true;

  // @override
  // void initState() {
  //   super.initState();
  //   fetchSalesData();
  // }

  List<String> states = [];
  List<String> cities = [];
  List<String> skus = [];

  List<String> filterTypes = [
   // "today",
   // "last30days",
    "monthtodate",
   // '6months',
    "yeartodate",
    "custom",
  ];

  String? selectedState;
  String? selectedCity;
  String? selectedSku;
  String? selectedFilterType = 'monthtodate';

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    selectedFilterType = 'monthtodate'; // Set default to "6months"
    fetchDropdownData();
    fetchSalesData(); // Automatically fetch data for 6 months on screen load
  }

  String formatFilterType(String filter) {
    switch (filter) {
      // case 'today':
      //   return 'Today';
      // case 'last30days':
      //   return 'Last 30 Days';
      case 'monthtodate':
        return 'Current Month';
      // case '6months':
      //   return 'Last 6 Months';
      case 'yeartodate':
        return 'Current Year';
      case 'custom':
        return 'Custom Range';
      default:
        return filter;
    }
  }

  String formatDate(DateTime date) =>
      "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Future<void> fetchDropdownData() async {
    try {
      final stateRes =
          await http.get(Uri.parse('${ApiConfig.baseUrl}/state?q='));
      final cityRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/city?q='));
      final skuRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/sku'));

      if (stateRes.statusCode == 200) {
        states = List<String>.from(json.decode(stateRes.body));
      }
      if (cityRes.statusCode == 200) {
        cities = List<String>.from(json.decode(cityRes.body));
      }
      if (skuRes.statusCode == 200) {
        skus = List<String>.from(json.decode(skuRes.body));
      }

      setState(() {});
    } catch (e) {
      print('Error fetching dropdown data: $e');
    }
  }

  Future<void> fetchSalesData() async {
    if (selectedFilterType == null) return;
    setState(() => isLoading = true);

    String url;
    print("filterTypes::::: ${selectedFilterType}");

    if (selectedFilterType == 'custom') {
      if (startDate == null || endDate == null) {
        setState(() => isLoading = false);
        return;
      }
      final from = formatDate(startDate!);
      final to = formatDate(endDate!);
      url =
          '${ApiConfig.baseUrl}/sales?filterType=custom&fromDate=$from&toDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    } else {
      url =
          '${ApiConfig.baseUrl}/sales?filterType=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
      //url='https://api.thrivebrands.ai/api/sales?filterType=lastmonth';
    }
    try {
      var dio = Dio();
      //var response = await dio.get('https://api.thrivebrands.ai/api/sales?filterType=lastmonth');
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        setState(() {
          salesData = response.data; // direct assign JSON List<dynamic>
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusMessage}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void onDropdownChanged(String? value, String type) {
    setState(() {
      if (type == 'filter') {
        selectedFilterType = value;
        if (value != 'custom') fetchSalesData();
      } else if (type == 'state') {
        selectedState = value;
        fetchSalesData();
      } else if (type == 'city') {
        selectedCity = value;
        fetchSalesData();
      } else if (type == 'sku') {
        selectedSku = value;
        fetchSalesData();
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
      fetchSalesData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        // appBar: AppBar(title: Text('Sales Data')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // appBar: AppBar(title: Text('Sales Data')),
      body: Column(
        children: [
          SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 190,
                  child:
                      // DropdownButtonFormField<String>(
                      //   decoration: InputDecoration(
                      //     hintText: "Select Filter Type",
                      //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(color: Colors.blue, width: 1),
                      //     ),
                      //   ),
                      DropdownButtonFormField<String>(
                    isDense: true,
                    // value: value,
                    // onChanged: onChanged,
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    iconEnabledColor: Colors.black,
                    dropdownColor: Colors.white,
                    decoration: customInputDecoration(
                      hintText: "Select Filter Type",
                    ),
                    items: filterTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(formatFilterType(type),
                            overflow: TextOverflow.ellipsis),
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
                SizedBox(width: 8),
                SizedBox(
                  width: 250,
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
                      dropdownSearchDecoration: customInputDecoration(
                        labelText: "SKU",
                      ),
                    ),
                    clearButtonProps: ClearButtonProps(isVisible: true),
                    onChanged: (val) => onDropdownChanged(val, 'sku'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: salesData.length,
          //     itemBuilder: (context, index) {
          //       var item = salesData[index];
          //       var records = item['records'] as List<dynamic>;

          //       return Card(
          //         margin: EdgeInsets.all(8),
          //         child: ExpansionTile(
          //           title: Text('SKU: ${item['SKU']}'),
          //           subtitle: Text(
          //               'Total Quantity: ${item['totalQuantity']}, Total Sales: £${(item['totalSales'] as num).toStringAsFixed(2)}'),
          //           children: records.map<Widget>((record) {
          //             return ListTile(
          //               title: Text(record['productName']),
          //               subtitle: Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text('Order ID: ${record['orderID']}'),
          //                   Text(
          //                       'Purchase Date: ${record['purchaseDate'].split("T")[0]}'),
          //                   Text('Status: ${record['orderStatus']}'),
          //                   Text('Quantity: ${record['quantity']}'),
          //                   Text(
          //                       'Sales: £${(record['totalSales'] as num).toStringAsFixed(2)}'),
          //                 ],
          //               ),
          //             );
          //           }).toList(),
          //         ),
          //       );
          //     },
          //   ),
          // ),
          kIsWeb
              ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: MasonryGridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            itemCount: salesData.length,
                            itemBuilder: (context, index) {
                              return SalesSkuExpandableWebCard(item: salesData[index]);
                            },
                          ),
                        ),
                      )
              : 
          Expanded(
            child: ListView.builder(
              itemCount: salesData.length,
              itemBuilder: (context, index) {
                return SalesSkuExpandableCard(item: salesData[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
*/




import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/components/sales/filterscreen/sales_sku_expandable_card.dart.dart';
import 'package:flutter_application_1/components/sales/filterscreen/sales_sku_expandable_web_card.dart';
import 'package:flutter_application_1/utils/custom_dropdown.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;

import '../../../utils/ApiConfig.dart';

class Filter_SalesSkuScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<Filter_SalesSkuScreen> {
  List<dynamic> salesData = [];
  bool isLoading = true;

  List<String> states = [];
  List<String> cities = [];
  List<String> skus = [];

  // List<String> filterTypes = [
  //   "monthtodate",
  //   "yeartodate",
  //   "custom",
  // ];

  List<String> filterTypes = [
    // "today",
    //"week",
    //"last30days",
    "lastmonth",
    "monthtodate",
    // "previousyear",
    // "currentyear",
    "yeartodate",
    //"custom"
    // "monthtodate",
    // "lastmonth",
    //'6months',
    //"yeartodate",
    // "custom",
  ];

  String? selectedState;
  String? selectedCity;
  String? selectedSku;
  String? selectedFilterType = 'monthtodate';

  DateTime? startDate;
  DateTime? endDate;
  bool isWideScreen = false;

  @override
  void initState() {
    super.initState();
    selectedFilterType = 'monthtodate';
    fetchDropdownData();
    fetchSalesData();
  }


  // String formatFilterType(String filter) {
  //   switch (filter) {
  //     case 'monthtodate':
  //       return 'Current Month';
  //     case 'yeartodate':
  //       return 'Current Year';
  //     case 'custom':
  //       return 'Custom Range';
  //     default:
  //       return filter;
  //   }
  // }

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
      // case 'custom':
      //   return 'Custom Range';
      default:
        return filter;
    }
  }

  String formatDate(DateTime date) =>
      "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Future<void> fetchDropdownData() async {
    try {
      final stateRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/state?q='));
      final cityRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/city?q='));
      final skuRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/sku'));

      if (stateRes.statusCode == 200) {
        states = List<String>.from(json.decode(stateRes.body));
      }
      if (cityRes.statusCode == 200) {
        cities = List<String>.from(json.decode(cityRes.body));
      }
      if (skuRes.statusCode == 200) {
        skus = List<String>.from(json.decode(skuRes.body));
      }

      setState(() {});
    } catch (e) {
      print('Error fetching dropdown data: $e');
    }
  }

  // Future<void> fetchSalesData() async {
  //   if (selectedFilterType == null) return;
  //   setState(() => isLoading = true);

  //   final sku = Uri.encodeComponent(selectedSku ?? '');
  //   final city = Uri.encodeComponent(selectedCity ?? '');
  //   final state = Uri.encodeComponent(selectedState ?? '');

  //   String url;

  //   if (selectedFilterType == 'custom') {
  //     if (startDate == null || endDate == null) {
  //       setState(() => isLoading = false);
  //       return;
  //     }
  //     final from = formatDate(startDate!);
  //     final to = formatDate(endDate!);
  //     url = '${ApiConfig.baseUrl}/sales?filterType=custom&fromDate=$from&toDate=$to&sku=$sku&city=$city&state=$state';
  //   } else {
  //     url = '${ApiConfig.baseUrl}/sales?filterType=$selectedFilterType&sku=$sku&city=$city&state=$state';
  //   }

  //   try {
  //     var dio = Dio();
  //     var response = await dio.get(url);

  //     if (response.statusCode == 200) {
  //       setState(() {
  //         salesData = response.data;
  //         isLoading = false;
  //       });
  //     } else {
  //       print('Error: ${response.statusMessage}');
  //       setState(() => isLoading = false);
  //     }
  //   } catch (e) {
  //     print('Exception: $e');
  //     setState(() => isLoading = false);
  //   }
  // }

  Future<void> fetchSalesData() async {
    if (selectedFilterType == null) return;
    setState(() => isLoading = true);

    final sku = Uri.encodeComponent(selectedSku ?? '');
    final city = Uri.encodeComponent(selectedCity ?? '');
    final state = Uri.encodeComponent(selectedState ?? '');

    String url;

    if (selectedFilterType == 'custom') {
      if (startDate == null || endDate == null) {
        setState(() {
          isLoading = false;
          salesData = [];
        });
        return;
      }
      final from = formatDate(startDate!);
      final to = formatDate(endDate!);
      url =
      '${ApiConfig.baseUrl}/sales?filterType=custom&fromDate=$from&toDate=$to&sku=$sku&city=$city&state=$state';
    } else {
      url =
      '${ApiConfig.baseUrl}/sales?filterType=$selectedFilterType&sku=$sku&city=$city&state=$state';
    }

    try {
      var dio = Dio();
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;

        setState(() {
          salesData = (data is List) ? data : [];
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusMessage}');
        setState(() {
          salesData = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        salesData = [];
        isLoading = false;
      });
    }
  }

  void onDropdownChanged(String? value, String type) {
    setState(() {
      if (type == 'filter') {
        selectedFilterType = value;
        if (value != 'custom') fetchSalesData();
      } else if (type == 'state') {
        selectedState = value;
        fetchSalesData();
      } else if (type == 'city') {
        selectedCity = value;
        fetchSalesData();
      } else if (type == 'sku') {
        selectedSku = value;
        fetchSalesData();
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
      fetchSalesData();
    }
  }

  @override
  Widget build(BuildContext context) {
    isWideScreen = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<String>(
                    isDense: true,
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    iconEnabledColor: Colors.black,
                    dropdownColor: Colors.white,
                    decoration: customInputDecoration(hintText: "Select Filter Type"),
                    items: filterTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(formatFilterType(type), overflow: TextOverflow.ellipsis),
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
                SizedBox(width: 8),
                SizedBox(
                  width: 250,
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
                      dropdownSearchDecoration: customInputDecoration(labelText: "SKU"),
                    ),
                    clearButtonProps: ClearButtonProps(isVisible: true),
                    onChanged: (val) => onDropdownChanged(val, 'sku'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child:salesData.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'No Data Found for the selected filter',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )

                : kIsWeb && isWideScreen
                ? Padding(
              padding: const EdgeInsets.all(10),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                itemCount: salesData.length,
                itemBuilder: (context, index) {
                  return SalesSkuExpandableWebCard(item: salesData[index]);
                },
              ),
            )
                : ListView.builder(
              itemCount: salesData.length,
              itemBuilder: (context, index) {
                return SalesSkuExpandableCard(item: salesData[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}






// import 'dart:convert';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_application_1/components/sales/filterscreen/sales_sku_expandable_card.dart.dart';
// import 'package:flutter_application_1/components/sales/filterscreen/sales_sku_expandable_web_card.dart';
// import 'package:flutter_application_1/utils/custom_dropdown.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:http/http.dart' as http;
//
// import '../../../utils/ApiConfig.dart';
//
// class Filter_SalesSkuScreen extends StatefulWidget {
//   @override
//   _SalesScreenState createState() => _SalesScreenState();
// }
//
// class _SalesScreenState extends State<Filter_SalesSkuScreen> {
//   List<dynamic> salesData = [];
//   bool isLoading = true;
//
//   List<String> states = [];
//   List<String> cities = [];
//   List<String> skus = [];
//
//   List<String> filterTypes = [
//     "monthtodate",
//     "yeartodate",
//     "custom",
//   ];
//
//   String? selectedState;
//   String? selectedCity;
//   String? selectedSku;
//   String? selectedFilterType = 'monthtodate';
//
//   DateTime? startDate;
//   DateTime? endDate;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedFilterType = 'monthtodate';
//     fetchDropdownData();
//     fetchSalesData();
//   }
//
//   String formatFilterType(String filter) {
//     switch (filter) {
//       case 'monthtodate':
//         return 'Current Month';
//       case 'yeartodate':
//         return 'Current Year';
//       case 'custom':
//         return 'Custom Range';
//       default:
//         return filter;
//     }
//   }
//
//   String formatDate(DateTime date) =>
//       "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//
//   Future<void> fetchDropdownData() async {
//     try {
//       final stateRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/state?q='));
//       final cityRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/city?q='));
//       final skuRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/sku'));
//
//       if (stateRes.statusCode == 200) {
//         states = List<String>.from(json.decode(stateRes.body));
//       }
//       if (cityRes.statusCode == 200) {
//         cities = List<String>.from(json.decode(cityRes.body));
//       }
//       if (skuRes.statusCode == 200) {
//         skus = List<String>.from(json.decode(skuRes.body));
//       }
//
//       setState(() {});
//     } catch (e) {
//       print('Error fetching dropdown data: $e');
//     }
//   }
//
//   Future<void> fetchSalesData() async {
//     if (selectedFilterType == null) return;
//     setState(() => isLoading = true);
//
//     final sku = Uri.encodeComponent(selectedSku ?? '');
//     final city = Uri.encodeComponent(selectedCity ?? '');
//     final state = Uri.encodeComponent(selectedState ?? '');
//
//     String url;
//
//     if (selectedFilterType == 'custom') {
//       if (startDate == null || endDate == null) {
//         setState(() => isLoading = false);
//         return;
//       }
//       final from = formatDate(startDate!);
//       final to = formatDate(endDate!);
//       url = '${ApiConfig.baseUrl}/sales?filterType=custom&fromDate=$from&toDate=$to&sku=$sku&city=$city&state=$state';
//     } else {
//       url = '${ApiConfig.baseUrl}/sales?filterType=$selectedFilterType&sku=$sku&city=$city&state=$state';
//     }
//
//     try {
//       var dio = Dio();
//       var response = await dio.get(url);
//
//       if (response.statusCode == 200) {
//         setState(() {
//           salesData = response.data;
//           isLoading = false;
//         });
//       } else {
//         print('Error: ${response.statusMessage}');
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       print('Exception: $e');
//       setState(() => isLoading = false);
//     }
//   }
//
//   void onDropdownChanged(String? value, String type) {
//     setState(() {
//       if (type == 'filter') {
//         selectedFilterType = value;
//         if (value != 'custom') fetchSalesData();
//       } else if (type == 'state') {
//         selectedState = value;
//         fetchSalesData();
//       } else if (type == 'city') {
//         selectedCity = value;
//         fetchSalesData();
//       } else if (type == 'sku') {
//         selectedSku = value;
//         fetchSalesData();
//       }
//     });
//   }
//
//   Future<void> selectDateRange(BuildContext context) async {
//     final now = DateTime.now();
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(now.year - 2),
//       lastDate: now,
//     );
//
//     if (picked != null) {
//       setState(() {
//         startDate = picked.start;
//         endDate = picked.end;
//       });
//       fetchSalesData();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           SizedBox(height: 20),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 SizedBox(
//                   width: 190,
//                   child: DropdownButtonFormField<String>(
//                     isDense: true,
//                     style: TextStyle(fontSize: 12, color: Colors.black),
//                     iconEnabledColor: Colors.black,
//                     dropdownColor: Colors.white,
//                     decoration: customInputDecoration(hintText: "Select Filter Type"),
//                     items: filterTypes.map((type) {
//                       return DropdownMenuItem(
//                         value: type,
//                         child: Text(formatFilterType(type), overflow: TextOverflow.ellipsis),
//                       );
//                     }).toList(),
//                     value: selectedFilterType,
//                     onChanged: (val) => onDropdownChanged(val, 'filter'),
//                   ),
//                 ),
//                 if (selectedFilterType == 'custom')
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8.0),
//                     child: ElevatedButton.icon(
//                       onPressed: () => selectDateRange(context),
//                       icon: Icon(Icons.date_range),
//                       label: Text(
//                         startDate != null && endDate != null
//                             ? "${formatDate(startDate!)} - ${formatDate(endDate!)}"
//                             : "Select Date Range",
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                 SizedBox(width: 8),
//                 SizedBox(
//                   width: 250,
//                   height: 50,
//                   child: DropdownSearch<String>(
//                     items: skus,
//                     selectedItem: selectedSku,
//                     popupProps: PopupProps.menu(
//                       showSearchBox: true,
//                       searchFieldProps: TextFieldProps(
//                         decoration: InputDecoration(
//                           hintText: "Search SKU",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                     dropdownDecoratorProps: DropDownDecoratorProps(
//                       dropdownSearchDecoration: customInputDecoration(labelText: "SKU"),
//                     ),
//                     clearButtonProps: ClearButtonProps(isVisible: true),
//                     onChanged: (val) => onDropdownChanged(val, 'sku'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: salesData.isEmpty
//                 ? Center(
//               child: Text(
//                 'No Data Found',
//                 style: TextStyle(fontSize: 18, color: Colors.grey),
//               ),
//             )
//                 : kIsWeb
//                 ? Padding(
//               padding: const EdgeInsets.all(10),
//               child: MasonryGridView.count(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 10,
//                 crossAxisSpacing: 10,
//                 itemCount: salesData.length,
//                 itemBuilder: (context, index) {
//                   return SalesSkuExpandableWebCard(item: salesData[index]);
//                 },
//               ),
//             )
//                 : ListView.builder(
//               itemCount: salesData.length,
//               itemBuilder: (context, index) {
//                 return SalesSkuExpandableCard(item: salesData[index]);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//


/*
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Filter_SalesSkuScreen extends StatefulWidget {
  const Filter_SalesSkuScreen({Key? key}) : super(key: key);
  @override
  State<Filter_SalesSkuScreen> createState() => _Filter_SalesSkuScreenState();
}
class _Filter_SalesSkuScreenState extends State<Filter_SalesSkuScreen> {
  List<dynamic> salesData = [];
  List<String> skus = [];
  List<String> states = [];
  String? selectedSku;
  String? selectedState;
  String selectedDateFilter = 'monthtodate';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
    fetchSalesData();
  }

  Future<void> fetchDropdownData() async {
    final dio = Dio();
    try {
      final skuRes = await dio.get('https://api.thrivebrands.ai/api/sku?q=');
      final stateRes = await dio.get('https://api.thrivebrands.ai/api/state?q=');

      if (skuRes.statusCode == 200 && stateRes.statusCode == 200) {
        setState(() {
          skus = List<String>.from(skuRes.data);
          states = List<String>.from(stateRes.data);
        });
      }
    } catch (e) {
      print('Dropdown fetch error: $e');
    }
  }

  Future<void> fetchSalesData() async {
    setState(() => isLoading = true);
    final dio = Dio();

    final params = {
      'filterType': selectedDateFilter,
    };

    if (selectedSku != null && selectedSku!.isNotEmpty) params['sku'] = selectedSku!;
    if (selectedState != null && selectedState!.isNotEmpty) params['state'] = selectedState!;

    final uri = Uri.https('api.thrivebrands.ai', '/api/sales', params);

    try {
      final response = await dio.getUri(uri);
      if (response.statusCode == 200) {
        setState(() {
          salesData = response.data;
        });
      } else {
        setState(() => salesData = []);
      }
    } catch (e) {
      print('Sales data error: $e');
      setState(() => salesData = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showDetailPopup(Map<String, dynamic> record) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text('Detailed View',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple)),
              ),
              const SizedBox(height: 10),
              ...record.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text('${entry.key}:',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold))),
                    Expanded(flex: 7, child: Text(entry.value.toString())),
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSalesItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: const Color(0xFFF7EFD7),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKU: ${item['SKU']}',
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Total Quantity: ${item['totalQuantity']}'),
            Text('Total Sales: ${item['totalSales']}'),
            const SizedBox(height: 10),
            const Text('Orders:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...((item['records'] as List<dynamic>).map((record) => ListTile(
              title: Text('Order ID: ${record['orderID']}'),
              subtitle: Text('Status: ${record['orderStatus']}'),
              onTap: () => showDetailPopup(record),
            ))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Data'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: selectedDateFilter,
                  items: const [
                    DropdownMenuItem(value: 'monthtodate', child: Text('Current Month')),
                    DropdownMenuItem(value: 'lastmonth', child: Text('Previous Month')),
                  ],
                  onChanged: (val) {
                    setState(() => selectedDateFilter = val!);
                  },
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  hint: const Text('Select SKU'),
                  value: selectedSku,
                  items: skus.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    setState(() => selectedSku = val);
                  },
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  hint: const Text('Select State'),
                  value: selectedState,
                  items: states.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    setState(() => selectedState = val);
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: fetchSalesData,
                  child: const Text('Filter'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : salesData.isEmpty
                ? const Center(child: Text('No data found'))
                : ListView.builder(
              itemCount: salesData.length,
              itemBuilder: (context, index) => buildSalesItem(salesData[index]),
            ),
          ),
        ],
      ),
    );
  }
}
*/
