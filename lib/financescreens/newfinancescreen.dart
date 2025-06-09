import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../utils/colors.dart';

class NewFinanceSkuScreen extends StatefulWidget {
  final String financeval;
  const NewFinanceSkuScreen({Key? key, required this.financeval}) : super(key: key);

  @override
  State<NewFinanceSkuScreen> createState() => _PnlDataScreenState();
}

class _PnlDataScreenState extends State<NewFinanceSkuScreen> {
  List<dynamic> pnlData = [];
  List<String> categories = [];
  List<String> skus = [];
  String selectedRange = 'monthtodate';
  String? selectedCategory;
  String? selectedSku;
  bool isLoading = false;
  //
  // final List<String> orderedKeys = [
  //   'SKU',
  //   'Product Name',
  //   'Product Category',
  //   'Channel',
  //   'Year-Month',
  //   'Total Units',
  //   'Net Sales',
  //   'Net Sales with tax',
  //   'Total Sales',
  //   'Total Sales with tax',
  //   'Total_Return_Amount',
  //   'Total Return with tax',
  //   'Deal Fee',
  //   'FBA Inventory Fee',
  //   'fba fees',
  //   'FBA Reimbursement',
  //   'selling fees',
  //   'promotional rebates',
  //   'Storage Fee',
  //   'Spend',
  //   'Other marketing Expenses',
  //   'Product CoGS',
  //   'Cogs',
  //   'CM1',
  //   'heads_CM2',
  //   'CM2',
  //   'heads_CM3',
  //   'CM3',
  // ];


  final List<String> orderedKeys = [
    'Product Name',
    'Product Category',
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
  ];


  final Map<String, Color> keyColors = {
    'SKU': Colors.green,
    'Product Name': Colors.green,
    'Product Category': Colors.green,
    'Channel': Colors.green,
    'Year-Month': Colors.green,
    'Total Units': Colors.green,
    'Net Sales': Colors.green,
    'Net Sales with tax': Colors.green,
    'Total Sales': Colors.green,
    'Total Sales with tax': Colors.green,
    'Total_Return_Amount': Colors.green,
    'Total Return with tax': Colors.green,
    'Deal Fee': Colors.green,
    'FBA Inventory Fee': Colors.green,
    'fba fees': Colors.green,
    'FBA Reimbursement': Colors.green,
    'selling fees': Colors.green,
    'promotional rebates': Colors.green,
    'Storage Fee': Colors.green,
    'Spend': Colors.green,
    'Other marketing Expenses': Colors.green,
    'Product CoGS': Colors.green,
    'Cogs': Colors.green,
    'Liquidations': Colors.green,
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
      children: orderedKeys.map((key) {
        if (data.containsKey(key)) {
          final color = keyColors[key] ?? Colors.black;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    key,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                     // color: color,
                    ),
                  ),
                ),
        /*        Expanded(
                  flex: 6,
                  child: Text(
                    data[key].toString(),
                    style:  TextStyle(color: color),
                  ),
                ),*/

                Expanded(
                  flex: 6,
                  child: Text(
                    _isCurrencyField(key) ? '£ ${data[key]}' : data[key].toString(),
                    style: TextStyle(color: color),
                  ),
                ),


              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
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
                  child: Text('Detailed View',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
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


  Map<String, String> rangeOptions = {
    'monthtodate': 'Current Month',
    'lastmonth': 'Previous Month',
    'yeartodate': 'Current Year',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      widget.financeval == "1"
          ?
      AppBar(
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
      ):null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  /*DropdownButton<String>(
                    dropdownColor: Colors.white,
                    value: selectedRange,
                    items: [
                      'monthtodate',
                      'lastmonth',
                      'yeartodate',
                      //'custom'
                    ]
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Container(
                        color: selectedRange == e ? Colors.deepPurple[50] : null,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(e),
                      ),
                    ))
                        .toList(),
                    onChanged: (val) => setState(() {
                      selectedRange = val!;
                      fetchPnlData();
                    }),
                  ),*/


                DropdownButton<String>(
                dropdownColor: Colors.white,
                value: selectedRange,
                items: rangeOptions.entries
                    .map((entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Container(
                    color: selectedRange == entry.key ? Colors.deepPurple[50] : null,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(entry.value),
                  ),
                ))
                    .toList(),
                onChanged: (val) => setState(() {
                  selectedRange = val!;
                  fetchPnlData();
                }),
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
                          ...categories.map((e) => DropdownMenuItem(
                            value: e,
                            child: Container(
                              color: selectedCategory == e ? Colors.deepPurple[50] : null,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(e),
                            ),
                          ))
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
                          ...skus.map((e) => DropdownMenuItem(
                            value: e,
                            child: Container(
                              color: selectedSku == e ? Colors.deepPurple[50] : null,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(e),
                            ),
                          ))
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
                 // color: const Color(0xFFF7EFD7),
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
                          Text(
                            'SKU: ${item['SKU']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          buildTable({
                            'Product Name': item['Product Name'],
                            'Deal Fee': item['Deal Fee'],
                            'FBA Inventory Fee': item['FBA Inventory Fee'],
                            'FBA Reimbursement': item['FBA Reimbursement'],
                            'Liquidations': item['Liquidations'],
                            'Net Sales': item['Net Sales'],
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )

        ],
      ),
    );
  }
}
