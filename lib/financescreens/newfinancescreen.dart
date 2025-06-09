import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../utils/colors.dart';

class NewFinanceSkuScreen extends StatefulWidget {
  final String financeval;
  const NewFinanceSkuScreen({Key? key, required this.financeval}) : super(key: key);

  @override
  State<NewFinanceSkuScreen> createState() => _NewFinanceSkuScreenState();
}

class _NewFinanceSkuScreenState extends State<NewFinanceSkuScreen> {
  List<dynamic> pnlData = [];
  List<String> categories = [];
  List<String> skus = [];
  String selectedRange = 'monthtodate';
  String? selectedCategory;
  String? selectedSku;
  bool isLoading = false;

  String? selectedFilterType;

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



  final Map<String, String> displayNames = {
    'SKU': 'SKU',
    'Product Name': 'Product Name ',
    'Product Category': 'Product Category',
    'Total Sales with tax': 'Gross Revenue',
    'Total Return with tax': 'Return Revenue',
    'Net Sales with tax': 'Net Revenue',
    'Cogs': 'COGS ',
    'CM1': 'CM1',
    'Deal Fee': 'Deal Fee',
    'FBA Inventory Fee': 'FBA Inventory Fee',
    'FBA Reimbursement': 'FBA Reimbursement',
    'Liquidations': 'Liquidations',
    'Storage Fee': 'Storage Fee',
    'fba fees': 'FBA Fees',
    'CM2': 'CM2',
    'Other marketing Expenses': 'Other Marketing Expenses',
    'promotional rebates': 'Discounts',
    'selling fees': 'Selling Fees',
    'Spend': 'Ad Spend',
    'CM3': 'CM3',
  };

  final Map<String, Color> keyColors = {
    'SKU': Colors.green,
    'Product Name': Colors.black,
    'Product Category': Colors.black,
    'Channel': Colors.green,
    'Year-Month': Colors.green,
    'Total Units': Colors.green,
    'Net Sales': Colors.red,
    'Net Sales with tax': Colors.green,
    'Total Sales': Colors.green,
    'Total Sales with tax': Colors.green,
    'Total_Return_Amount': Colors.green,
    'Total Return with tax': Colors.green,
    'Deal Fee': Colors.red,
    'FBA Inventory Fee': Colors.red,
    'fba fees': Colors.red,
    'FBA Reimbursement': Colors.green,
    'selling fees': Colors.red,
    'promotional rebates': Colors.red,
    'Storage Fee': Colors.red,
    'Spend': Colors.red,
    'Other marketing Expenses': Colors.red,
    'Product CoGS': Colors.red,
    'Cogs': Colors.red,
    'Liquidations': Colors.red,
    'CM1': Colors.green,
    'heads_CM2': Colors.green,
    'CM2': Colors.green,
    'heads_CM3': Colors.green,
    'CM3': Colors.green,
  };

  bool _isCurrencyField(String key) {
    const currencyFields = {
      'Total Sales with tax',
      'Total Return with tax',
      'Net Sales with tax',
      'Cogs',
      'CM1',
      'Deal Fee',
      'FBA Inventory Fee',
      'FBA Reimbursement',
      'Liquidations',
      'Storage Fee',
      'fba fees',
      'CM2',
      'Other marketing Expenses',
      'promotional rebates',
      'selling fees',
      'Spend',
      'CM3',
    };
    return currencyFields.contains(key);
  }

  @override
  void initState() {
    super.initState();
    fetchFilters();
    fetchPnlData();
  }

  Future<void> fetchFilters() async {
    final dio = Dio();
    try {
      final categoryRes = await dio.get('https://api.thrivebrands.ai/api/category-list');
      final skuRes = await dio.get('https://api.thrivebrands.ai/api/sku-list');
      if (categoryRes.statusCode == 200 && skuRes.statusCode == 200) {
        setState(() {
          categories = List<String>.from(categoryRes.data.where((e) => e is String && e.trim().isNotEmpty));
          skus = List<String>.from(skuRes.data.where((e) => e is String && e.trim().isNotEmpty));
        });
      }
    } catch (e) {
      print('Error fetching filters: $e');
    }
  }

  Future<void> fetchPnlData() async {
    setState(() => isLoading = true);
    final dio = Dio();
    try {

      //http://localhost:3000/api/pnl-data?sku=6C-BUK7-5RZ2&category=Diet Protein&startMonth=2025-01&endMonth=2025-04
      //https://api.thrivebrands.ai/api/pnl-data?sku=6C-BUK7-5RZ2&category=Diet Protein&startMonth=2025-01&endMonth=2025-04
      //https://api.thrivebrands.ai/api/pnl-data?sku=&category=Diet Protein&startMonth=2025-01&endMonth=2025-04
      String url = 'https://api.thrivebrands.ai/api/pnl-data?range=$selectedRange';
      if (selectedCategory != null && selectedCategory!.isNotEmpty) {
        url += '&category=${Uri.encodeComponent(selectedCategory!)}';
      }
      if (selectedSku != null && selectedSku!.isNotEmpty) {
        url += '&sku=${Uri.encodeComponent(selectedSku!)}';
      }
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        setState(() {
          pnlData = response.data;
        });
      }
    } catch (e) {
      print('Error fetching PnL data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildTable(Map<String, dynamic> data) {
    return Column(
      children: displayNames.entries.map((entry) {
        final key = entry.key;
        if (!data.containsKey(key)) return const SizedBox.shrink();

        final color = keyColors[key] ?? Colors.black;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  displayNames[key] ?? key,  // <== Use display name here
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Builder(
                  builder: (_) {
                    final cmKeys = ['CM1', 'CM2', 'CM3'];
                    final isCmField = cmKeys.contains(key);

                    Color displayColor = color;
                    var value = data[key];

                    if (value is num) {
                      if (value < 0) {
                        value = value.abs();
                        if (isCmField) {
                          displayColor = Colors.red;
                        }
                      }
                      value = value.round();
                    }

                    return Text(
                      _isCurrencyField(key) ? '£ $value' : value.toString(),
                      style: TextStyle(color: displayColor),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  void showBottomSheetDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) => SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Detailed View',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                buildTable(item),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final Map<String, String> rangeOptions = {
    'monthtodate': 'Current Month',
    'lastmonth': 'Previous Month',
    'yeartodate': 'Current Year',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.financeval == "1"
          ? AppBar(
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
        iconTheme: const IconThemeData(color: Colors.white),
      )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  DropdownButton<String>(
                    dropdownColor: Colors.white,
                    value: selectedRange,
                    items: rangeOptions.entries
                        .map(
                          (entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Container(
                          color: selectedRange == entry.key ? Colors.deepPurple[50] : null,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(entry.value),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() {
                        selectedRange = val;
                      });
                      fetchPnlData();
                    },
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      if (selectedCategory != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() => selectedCategory = null);
                            fetchPnlData();
                          },
                        ),
                      DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: selectedCategory,
                        hint: const Text('Category'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...categories.map(
                                (e) => DropdownMenuItem(
                              value: e,
                              child: Container(
                                color: selectedCategory == e ? Colors.deepPurple[50] : null,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(e),
                              ),
                            ),
                          )
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedCategory = val;
                          });
                          fetchPnlData();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      if (selectedSku != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() => selectedSku = null);
                            fetchPnlData();
                          },
                        ),
                      DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: selectedSku,
                        hint: const Text('SKU'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All SKUs'),
                          ),
                          ...skus.map(
                                (e) => DropdownMenuItem(
                              value: e,
                              child: Container(
                                color: selectedSku == e ? Colors.deepPurple[50] : null,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(e),
                              ),
                            ),
                          )
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedSku = val;
                          });
                          fetchPnlData();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : pnlData.isEmpty
                ? const Center(
              child: Text(
                'No Data Found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: pnlData.length,
              itemBuilder: (context, index) {
                final item = pnlData[index];
                return Card(
                  color: AppColors.beige,
                  margin: const EdgeInsets.all(8),
                  elevation: 3,
                  child: InkWell(
                    onTap: () => showBottomSheetDetails(item),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Text(
                              //   'SKU: ${item['SKU']}',
                              //   style: const TextStyle(
                              //     fontWeight: FontWeight.bold,
                              //     fontSize: 16,
                              //   ),
                              // ),

                              Text(
                               // 'Year-Month': item['Year-Month'],
                                '${item['Year-Month']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          buildTable({

                            'SKU': item['SKU'],
                            'Product Name': item['Product Name'],
                            'Product Category': item['Product Category'],
                            'Total Sales with tax': item['Total Sales with tax'],
                          //  'Total Sales with tax': 'Gross Revenue',

                            'CM1': item['CM1'],
                            'CM2': item['CM2'],
                            'CM3': item['CM3'],
                            'Net Sales': item['Net Sales'],
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
