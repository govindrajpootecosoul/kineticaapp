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
