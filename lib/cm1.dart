import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/utils/colors.dart';

class PnLSummaryScreen extends StatefulWidget {


  final String startDate;
  final String endDate;

  const PnLSummaryScreen({
    super.key,
    required this.startDate,
    required this.endDate,
  });
 // const PnLSummaryScreen({super.key});

  @override
  State<PnLSummaryScreen> createState() => _PnLSummaryScreenState();
}

class _PnLSummaryScreenState extends State<PnLSummaryScreen> {
  Map<String, dynamic> pnlData = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPnLData();
  }
  @override
  void didUpdateWidget(covariant PnLSummaryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.startDate != widget.startDate || oldWidget.endDate != widget.endDate) {
      fetchPnLData(); // re-fetch data
    }
  }

  Future<void> fetchPnLData() async {
    try {
      var dio = Dio();
      // var response = await dio.get(
      //   'https://api.thrivebrands.ai/api/pnl-data-cm?startDate=2025-2&endDate=2025-3',
      // );

      var response = await dio.get(
        'https://api.thrivebrands.ai/api/pnl-data-cm?startDate=${widget.startDate}&endDate=${widget.endDate}',
      );

      print("Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data['summary'] != null) {
        setState(() {
          pnlData = Map<String, dynamic>.from(response.data['summary']);
          isLoading = false;
          print("Parsed pnlData: $pnlData");
        });
      } else {
        setState(() {
          errorMessage = 'Unexpected data format or empty response';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'API error: $e';
        isLoading = false;
      });
      print("API Call Error: $e");
    }
  }

  void showPopup(String title, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: data.entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value?.toString() ?? 'N/A'),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget buildContainer(String title, double value, double totalSales, VoidCallback onTap) {
    double percent = totalSales != 0 ? (value / totalSales) * 100 : 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          //color: Colors.blue.shade100,
          color: AppColors.beige,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("${percent.round()}%", style: const TextStyle(fontSize: 16)),

            // Text("${percent.toStringAsFixed(2)}%", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {



    final double totalSales = (pnlData['Total Sales'] ?? 0).toDouble();
    final double cm1 = (pnlData['CM1'] ?? 0).toDouble();
    final double cm2 = (pnlData['CM2'] ?? 0).toDouble();
    final double cm3 = (pnlData['CM3'] ?? 0).toDouble();

    // These are just keys being filtered from the main pnlData map for each CM
    final Map<String, dynamic> cm1Details = {
      for (var key in ['Deal Fee', 'FBA Inventory Fee', 'FBA Reimbursement', 'Liquidations', 'Other marketing Expenses', 'Storage Fee'])
        key: pnlData[key] ?? 'N/A',
    };

    final Map<String, dynamic> cm2Details = {
      for (var key in ['Total Sales', 'Total Units', 'fba fees', 'promotional rebates', 'selling fees'])
        key: pnlData[key] ?? 'N/A',
    };

    final Map<String, dynamic> cm3Details = {
      for (var key in ['selling fees', 'Product CoGS', 'Cogs'])
        key: pnlData[key] ?? 'N/A',
    };

    return Scaffold(
     // appBar: AppBar(title: const Text('PnL Summary')),
      body: SizedBox(
        height: 150,
        width: 324,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Error: $errorMessage", style: const TextStyle(color: Colors.red)),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  buildContainer("CM1", cm1, totalSales, () => showPopup("CM1 Details", cm1Details)),
                  SizedBox(width: 8,),
                  buildContainer("CM2", cm2, totalSales, () => showPopup("CM2 Details", cm2Details)),
                  SizedBox(width: 8,),
                  buildContainer("CM3", cm3, totalSales, () => showPopup("CM3 Details", cm3Details)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
