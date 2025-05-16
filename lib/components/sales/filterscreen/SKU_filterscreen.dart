import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/ApiConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

import '../../../comman_Screens/productcard.dart'; // Import the package

class Filter_SalesSkuScreen extends StatefulWidget {
  @override
  State<Filter_SalesSkuScreen> createState() => _Filter_SalesSkuScreenState();
}

class _Filter_SalesSkuScreenState extends State<Filter_SalesSkuScreen> {
  List<String> states = [];
  List<String> cities = [];
  List<String> skus = [];

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
    "today",
    "last30days",
    "monthtodate",
    '6months',
    "yeartodate",
    "custom",
  ];

  String? selectedState;
  String? selectedCity;
  String? selectedSku;
  String? selectedFilterType;

  DateTime? startDate;
  DateTime? endDate;

  List<SalesSku> salesData = [];
  bool isLoading = false;

  // @override
  // void initState() {
  //   super.initState();
  //   fetchDropdownData();
  // }

  @override
  void initState() {
    super.initState();
    selectedFilterType = '6months'; // Set default to "6months"
    fetchDropdownData();
    fetchFilteredData(); // Automatically fetch data for 6 months on screen load
  }

  String formatFilterType(String filter) {
    switch (filter) {
      case 'today':
        return 'Today';
      case '6months':
        return 'Last 6 Months';
      case 'last30days':
        return 'Last 30 Days';
      case 'yeartodate':
        return 'Year to Date';
      case 'monthtodate':
        return 'Month to Date';

      // case 'year':
      //   return 'This Year';
      // case 'lastmonth':
      //   return 'Last Month';
      case 'custom':
        return 'Custom Range';
      default:
        return filter;
    }
  }

  Future<void> fetchDropdownData() async {
    try {
      final stateRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/state?q='));
      final cityRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/city?q='));
      final skuRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/sku'));

      if (stateRes.statusCode == 200) states = List<String>.from(json.decode(stateRes.body));
      if (cityRes.statusCode == 200) cities = List<String>.from(json.decode(cityRes.body));
      if (skuRes.statusCode == 200) skus = List<String>.from(json.decode(skuRes.body));

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
    }
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final parsedJson = json.decode(response.body);
        List<SalesSku> tempSalesData = [];

        for (var item in parsedJson) {
          print("qwertyuiop::: ${parsedJson}");
          var sku = item['SKU'];
          var totalQuantity = item['totalQuantity'];
          var totalSales = item['totalSales'];
          var records = item['records'];

          List<SalesRecord> recordList = [];
          for (var record in records) {
            recordList.add(SalesRecord.fromJson(record));
          }

          tempSalesData.add(SalesSku(
            sku: sku,
            totalQuantity: totalQuantity,
            totalSales: totalSales,
            records: recordList,
          ));
        }

        setState(() => salesData = tempSalesData);
      } else {
        print('Failed to fetch sales data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching filtered data: $e');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // appBar: AppBar(title: const Text("Sales Data Viewer")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [

                  SizedBox(
                    width: 190,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: "Select Filter Type",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1),
                        ),
                      ),
                      items: filterTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(formatFilterType(type),
                            overflow: TextOverflow.ellipsis,),
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

                  // SizedBox(width: 8), // optional spacing
                  // SizedBox(
                  //   width: 150,
                  //   child: DropdownSearch<String>(
                  //     items: states,
                  //     selectedItem: selectedState,
                  //     popupProps: PopupProps.menu(
                  //       showSearchBox: true,
                  //       searchFieldProps: TextFieldProps(
                  //         decoration: InputDecoration(
                  //           hintText: "Search State",
                  //           border: OutlineInputBorder(),
                  //         ),
                  //       ),
                  //     ),
                  //     dropdownDecoratorProps: DropDownDecoratorProps(
                  //       dropdownSearchDecoration: InputDecoration(
                  //         labelText: "State",
                  //         border: OutlineInputBorder(),
                  //       ),
                  //     ),
                  //     onChanged: (val) => onDropdownChanged(val, 'state'),
                  //   ),
                  // ),

                  // SizedBox(width: 8),
                  // SizedBox(
                  //   width: 150,
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
                  //       dropdownSearchDecoration: InputDecoration(
                  //         labelText: "City",
                  //         border: OutlineInputBorder(),
                  //       ),
                  //     ),
                  //     onChanged: (val) => onDropdownChanged(val, 'city'),
                  //   ),
                  // ),

                  SizedBox(width: 8),
                  SizedBox(
                    width: 150,
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
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "SKU",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      onChanged: (val) => onDropdownChanged(val, 'sku'),
                    ),
                  ),

                ],
              ),
            ),



            const SizedBox(height: 20),

            // Expanded(
            //   child: isLoading
            //       ? const Center(child: CircularProgressIndicator())
            //       : salesData.isEmpty
            //       ? const Center(child: Text("No records found"))
            //       : ListView.builder(
            //     itemCount: salesData.length,
            //     itemBuilder: (context, index) {
            //       final data = salesData[index];
            //       return
            //
            //
            //         Card(
            //         margin: const EdgeInsets.symmetric(vertical: 5),
            //         child: ListTile(
            //           title: Text(data.sku),
            //           subtitle: Column(
            //            // crossAxisAlignment: CrossAxisAlignment.start,
            //            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //
            //             children: [
            //               // Text("Total Quantity: ${data.totalQuantity}"),
            //               // Text("Total Sales: £${data.totalSales}"),
            //               Column(
            //                 children: data.records.map((r) {
            //                   return ListTile(
            //                   //  title: Text(r.productName),
            //                     subtitle: Column(
            //                       //crossAxisAlignment: CrossAxisAlignment.start,
            //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                       children: [
            //                         Row(children: [
            //                           Text("SKU\n${data.sku}"),
            //                           Text("Unitorder\n${data.totalQuantity}"),
            //                           Text("Organic Sales\n${r.purchaseDate.split('T')[0]}"),
            //                         ],),
            //
            //                         Row(
            //                           crossAxisAlignment:CrossAxisAlignment.start,
            //                           children: [
            //                           Text("ASIN \n${r.asin}"),
            //                           Text("OverAll Sales\n ${data.totalQuantity}"),
            //                           Text("Return Revenue %\n${"N/A"}"),
            //                         ],),
            //
            //                         // Text("Order ID: ${r.orderID}"),
            //                         // Text("asin ID: ${r.asin}"),
            //                         // Text("Date: ${r.purchaseDate.split('T')[0]}"),
            //                         // Text("City: ${r.city}, State: ${r.state}"),
            //                         // Text("Qty: ${r.quantity}, Total: £${r.totalSales}"),
            //                       ],
            //                     ),
            //                   );
            //                 }).toList(),
            //               ),
            //             ],
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),


            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : salesData.isEmpty
                  ? const Center(child: Text("No data found."))
                  : ListView(
                children: salesData.expand((skuData) {
                  return skuData.records.map((record) {
                    final Map<String, dynamic> product = {
                      'name': record.productName,
                      'SKU': skuData.sku,
                      'Quantity': skuData.totalQuantity,
                      //'organicSales': record.organicSalesPercentage,
                      'asin': record.asin,
                      'Total_Sales': skuData.totalSales,
                      //'returnRevenue': record.returnRevenuePercentage,
                    };
                    return ProductCard(product: product);
                  }).toList();
                }).toList(),
              ),
            ),


            // Expanded(
            //   child: isLoading
            //       ? const Center(child: CircularProgressIndicator())
            //       : salesData.isEmpty
            //       ? const Center(child: Text("No data found."))
            //       : ListView.builder(
            //     itemCount: salesData.length,
            //     itemBuilder: (context, index) {
            //       final skuData = salesData[index];
            //       return Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: skuData.records.map((record) {
            //           final Map<String, dynamic> product = {
            //             'name': record.productName,
            //             'SKU': skuData.sku,
            //             'Quantity': skuData.totalQuantity,
            //             //'organicSales': record.organicSalesPercentage,
            //             'asin': record.asin,
            //             'Total_Sales': skuData.totalSales,
            //             //'returnRevenue': record.returnRevenuePercentage,
            //           };
            //           return ProductCard(product: product);
            //         }).toList(),
            //       );
            //     },
            //   ),
            // ),

          ],
        ),
      ),
    );
  }
}

class SalesRecord {
  final String orderID;
  final String purchaseDate;
  final String productName;
  final String asin;
  final int quantity;
  final double totalSales;
  final String city;
  final String state;

  SalesRecord({
    required this.orderID,
    required this.purchaseDate,
    required this.productName,
    required this.asin,
    required this.quantity,
    required this.totalSales,
    required this.city,
    required this.state,
  });

  factory SalesRecord.fromJson(Map<String, dynamic> json) {
    return SalesRecord(
      orderID: json['orderID'],
      purchaseDate: json['purchaseDate'],
      productName: json['productName'],
      asin: json['asin'],
      quantity: json['quantity'],
      totalSales: (json['totalSales'] as num).toDouble(),
      city: json['city'],
      state: json['state'],
    );
  }
}

class SalesSku {
  final String sku;
  final int totalQuantity;
  final double totalSales;
  final List<SalesRecord> records;

  SalesSku({
    required this.sku,
    required this.totalQuantity,
    required this.totalSales,
    required this.records,
  });
}
