

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../comman_Screens/Inventory_SKU_Card_Screen.dart';
import '../../utils/ApiConfig.dart';
import '../../utils/colors.dart';


class Testingsku extends StatefulWidget {
  const Testingsku({super.key});

  @override
  State<Testingsku> createState() => _TestingskuState();
}

class _TestingskuState extends State<Testingsku> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  String displayedText = '';
  String selectedOption = 'Today';
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
      var response = await dio.get(ApiConfig.pnlData);

      if (response.statusCode == 200) {
        setState(() {
          allInventory = response.data;
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

    setState(() {
      inventoryList = allInventory.where((item) {
        if (!item.containsKey('Inventory age snapshot date')) return false;
        try {
          final productDate = DateTime.parse(item['Inventory age snapshot date'].toString());
          return (start != null &&
              end != null &&
              productDate.isAfter(start!.subtract(const Duration(seconds: 1))) &&
              productDate.isBefore(end!));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Sales SKU Data')),

      appBar: AppBar(
        title: Image.asset('assets/logo.png'),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        iconTheme: IconThemeData(color: Colors.white),
      ),



      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 16),
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
          const SizedBox(height: 8),
          Text(displayedText),
          const SizedBox(height: 16),
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
                return testui(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}



class testui extends StatefulWidget {
  final Map<String, dynamic> product;

  const testui({Key? key, required this.product}) : super(key: key);

  @override
  State<testui> createState() => _testuiState();
}

class _testuiState extends State<testui> {
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(value.toString(), style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget buildLabelValueExpend(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xECD5B0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value.toString(), style: const TextStyle(fontSize: 13)),
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
                product['sku']?.toString() ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              Text(
                product['Date']?.toString() ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                  // const SizedBox(width: 0),
                  Flexible(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabelValue("SKU", product['sku'] ?? "00"),
                        buildLabelValue("Available Inventory",
                            (product['afn-fulfillable-quantity'] ?? 0) + (product['FC_Transfer'] ?? 0)),
                        buildLabelValue("Storage Cost", product['storage-volume'] ?? "00"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabelValue("ASIN", product['ASIN'] ?? "00"),
                        buildLabelValue("DOS", product['days-of-supply'] ?? '00'),
                        buildLabelValue("LTSF Cost", product['estimated-storage-cost-next-month'] ?? '00'),
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
                      fontSize: 30,
                      color: Colors.brown,
                      fontWeight: FontWeight.w500,
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
                    buildLabelValueExpend("Warehouse Inventory", product['afn-warehouse-quantity'] ?? "00"),
                    buildLabelValueExpend("Total Sellable", product['ASIN'] ?? "00"),
                    buildLabelValueExpend("Inventory Age", product['ASIN'] ?? "00"),
                    buildLabelValueExpend("DOS", product['ASIN'] ?? "00"),
                    buildLabelValueExpend("Customer Reserved", product['ASIN'] ?? "00"),
                    buildLabelValueExpend("FC Transfer", product['ASIN'] ?? "00"),
                    buildLabelValueExpend("FC Processing", product['ASIN'] ?? "00"),
                    buildLabelValueExpend("Unfullfilled", product['ASIN'] ?? "00"),
                    buildLabelValueExpend("Inbound Recieving", product['ASIN'] ?? "00"),
                  ],
                ),
                const Divider(height: 30),
                const Center(
                  child: Text(
                    "Shipment Details",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.brown,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    buildLabelValueExpend("Current Inventory", product['afn-warehouse-quantity'] ?? "00"),
                    buildLabelValueExpend("Current DOS", product['ASIN'] ?? "00"),
                    buildLabelValueExpend("Shipment Quantity", product['ASIN'] ?? "00"),
                    buildLabelValueExpend("Shipment Date", product['ASIN'] ?? "00"),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
