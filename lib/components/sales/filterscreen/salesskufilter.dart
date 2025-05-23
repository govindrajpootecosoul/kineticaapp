



import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

import '../../../comman_Screens/productcard.dart'; // Adjust this import based on your file structure
import 'package:flutter_application_1/utils/ApiConfig.dart'; // Ensure your base URL is correct

class Filter_SalesSkuScreenn extends StatefulWidget {
  @override
  State<Filter_SalesSkuScreenn> createState() => _Filter_SalesSkuScreenState();
}

class _Filter_SalesSkuScreenState extends State<Filter_SalesSkuScreenn> {
  List<String> states = [];
  List<String> cities = [];
  List<String> skus = [];

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
  String? selectedFilterType = '6months';

  DateTime? startDate;
  DateTime? endDate;

  List<SalesSku> salesData = [];
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    selectedFilterType = 'monthtodate'; // Set default to "6months"
    fetchDropdownData();
    fetchFilteredData(); // Automatically fetch data for 6 months on screen load
  }


  String formatFilterType(String filter) {
    switch (filter) {
      case 'today':
        return 'Today';
      case 'last30days':
        return 'Last 30 Days';
      case 'monthtodate':
        return 'Month to Date';
      case '6months':
        return 'Last 6 Months';
      case 'yeartodate':
        return 'Year to Date';
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

  Future<void> fetchFilteredData() async {
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
      url = '${ApiConfig.baseUrl}/sales?filterType=custom&fromDate=$from&toDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    } else {

      //url = '${ApiConfig.baseUrl}/sales?filterType=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
      url='https://api.thrivebrands.ai/api/sales?filterType=lastmonth';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final parsedJson = json.decode(response.body);
        List<SalesSku> tempSalesData = [];

        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        for (var item in parsedJson) {
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
        if (value != 'custom') fetchFilteredData();
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
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "SKU",
                          border: OutlineInputBorder(),
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
                      'asin': record.asin,
                      'Total_Sales': skuData.totalSales,
                    };
                    return ProductCard(product: product);
                  }).toList();
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data classes
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
      totalSales: (json['totalSales'] is int)
          ? (json['totalSales'] as int).toDouble()
          : json['totalSales'].toDouble(),
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

  factory SalesSku.fromJson(Map<String, dynamic> json) {
    return SalesSku(
      sku: json['SKU'],
      totalQuantity: json['totalQuantity'],
      totalSales: (json['totalSales'] is int)
          ? (json['totalSales'] as int).toDouble()
          : json['totalSales'].toDouble(),
      records: (json['records'] as List)
          .map((record) => SalesRecord.fromJson(record))
          .toList(),
    );
  }
}


