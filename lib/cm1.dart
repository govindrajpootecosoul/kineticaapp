import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/formatNumberStringWithComma.dart';

import 'financescreens/Finance_Executive_Screen.dart';
import 'financescreens/Finance_Executive_Web_Screen.dart';

double Salesvaluepnl = 0;

class PnLSummaryScreen extends StatefulWidget {
  final String startDate;


  const PnLSummaryScreen({
    super.key,
    required this.startDate,

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

    if (oldWidget.startDate != widget.startDate ) {
      fetchPnLData(); // re-fetch data
    }
  }

  Future<void> fetchPnLData() async {
    try {
      var dio = Dio();
      // var response = await dio.get(
      //   'https://api.thrivebrands.ai/api/pnl-data-cm?startDate=2025-2&endDate=2025-3',
      // );

      var response = await dio.get(widget.startDate
        //'https://api.thrivebrands.ai/api/pnl-data-cmm?date=${widget.startDate}',
        //'https://api.thrivebrands.ai/api/pnl-data-cmm?startDate=${widget.startDate}&endDate=${widget.endDate}',
      );

      print("Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data['summary'] != null) {
        setState(() {
          pnlData = Map<String, dynamic>.from(response.data['summary']);
          Salesvaluepnl= (pnlData['Total Sales with tax'] ?? 0).toDouble();
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
  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  void showPopup(String title, Map<String, dynamic> data) {
    if (kIsWeb) {
       showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 300,
            child: ListView(
              shrinkWrap: true,
              children: data.entries.map((entry) {
                print(
                    "Entry: ${entry.key} - ${formatNumberStringWithComma(entry.value.toString())}");
                return ListTile(
                  title: Text(entry.key),

                  subtitle: Text(
                    "£${formatNumberStringWithComma(double.tryParse(entry.value.toString())?.round().toString() ?? '0')}",
                  ),

                  /* subtitle: Text(
                      "£${formatNumberStringWithComma(entry.value.toString())}" ??
                          'N/A'),*/
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
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: data.entries.map((entry) {
                print(
                    "Entry: ${entry.key} - ${formatNumberStringWithComma(entry.value.toString())}");
                return ListTile(
                  title: Text(entry.key),

                  subtitle: Text(
                    "£${formatNumberStringWithComma(double.tryParse(entry.value.toString())?.round().toString() ?? '0')}",
                  ),

                  /* subtitle: Text(
                      "£${formatNumberStringWithComma(entry.value.toString())}" ??
                          'N/A'),*/
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
  }

  Widget buildContainer(
      String title, double value, double totalSales, VoidCallback onTap) {
    double percent = totalSales != 0 ? (value / totalSales) * 100 : 0;
    return GestureDetector(
      onTap: onTap,
      child:

        Container(
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
                //  Text("${percent.round()}%", style: const TextStyle(fontSize: 16)),
                  Text(
                    "${percent.round()}%",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),



    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalSales = (pnlData['Total Sales with tax'] ?? 0).toDouble();

    final double cm1 = (pnlData['CM1'] ?? 0).toDouble();
    final double cm2 = (pnlData['CM2'] ?? 0).toDouble();
    final double cm3 = (pnlData['CM3'] ?? 0).toDouble();

    // These are just keys being filtered from the main pnlData map for each CM
    // final Map<String, dynamic> cm1Details = {
    //   for (var key in [
    //     'Total Sales with tax',
    //     'Total Return with tax',
    //     'Net Sales with tax',
    //     'Total Sales',
    //     'Total_Return_Amount',
    //     'Net Sales',
    //     'Cogs'
    //   ])
    //     key: pnlData[key] ?? 'N/A',
    // };

    final Map<String, String> cm1KeyMap = {
      'Total Sales with tax': 'Gross Revenue',
      'Total Return with tax': 'Return',
      'Net Sales with tax': 'Net Revenue ',
      'Cogs': 'Cogs',
    };

    final Map<String, dynamic> cm1Details = {
      for (var key in cm1KeyMap.keys)
        cm1KeyMap[key]!: pnlData[key] ?? 'N/A',
    };

    // final Map<String, dynamic> cm2Details = {
    //   for (var key in [
    //     'Deal Fee',
    //     'FBA Inventory Fee',
    //     'FBA Reimbursement',
    //     'Liquidations',
    //     'Storage Fee',
    //     'fba fees'
    //   ])
    //     key: pnlData[key] ?? 'N/A',
    // };


    final Map<String, String> cm2KeyMap = {
      'Deal Fee': 'Deal Fee',
      'FBA Inventory Fee': 'FBA Inventory Fee',
      'FBA Reimbursement': 'FBA Reimbursement',
      'Liquidations': 'Liquidations',
      'Storage Fee': 'Storage Fee',
      'fba fees': 'FBA Fees',
    };

    final Map<String, dynamic> cm2Details = {
      for (var key in cm2KeyMap.keys)
        cm2KeyMap[key]!: pnlData[key] ?? 'N/A',
    };


    // final Map<String, dynamic> cm3Details = {
    //   for (var key in ['Other marketing Expenses', 'promotional rebates', 'selling fees','Spend'])
    //     key: pnlData[key] ?? 'N/A',
    // };


    final Map<String, String> cm3KeyMap = {
      'Other marketing Expenses': 'Other Marketing Expenses',
      'promotional rebates': 'Discounts',
      'selling fees': 'Selling Fess',
      'Spend': 'Ad Spend',

    };

    final Map<String, dynamic> cm3Details = {
      for (var key in cm3KeyMap.keys)
        cm3KeyMap[key]!: pnlData[key] ?? 'N/A',
    };

    return Scaffold(
      // appBar: AppBar(title: const Text('PnL Summary')),
      body: SizedBox(
        height: 230,
        width: MediaQuery.of(context).size.width * 1,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Text("Error: $errorMessage",
                style: const TextStyle(color: Colors.red)),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [


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
                            child: buildContainer("CM1", cm1, totalSales, () => showPopup("CM1 Details", cm1Details)),
                        ),
                        // title: "Overall Sales", value: '£ ${salesData?['totalSales'].toStringAsFixed(2)}', compared: "${salesData?['comparison']['salesChangePercent']}",)),
                        SizedBox(width: 8),
                        Expanded(
                          child: buildContainer("CM2", cm2, totalSales, () => showPopup("CM2 Details", cm2Details)),
                        ),

                      ],),
                      SizedBox(height: 8,),
                      Row(
                        children: [

                          Expanded(
                            child: buildContainer("CM3", cm3, totalSales, () => showPopup("CM3 Details", cm3Details)),
                          ),


                          const SizedBox(width: 8),
                          Expanded(
                            child:              InkWell(
                                onTap: () {
                                  print(" View full P&L Clicked");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => 
                                      // kIsWeb ? FinanceExecutiveScreen(productval: "1") :
                                      //CMReportScreen(),
                                      FinanceExecutiveScreen(productval:"1"),
                                    ),
                                  );
                                },
                                //child: MetricCardcm(title: "View",value: "P&L",)
                                child: MetricCardcm1(title: "View",value: "P&L",)
                            ),
                          ),
                        ],
                      ),

                    ],),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MetricCardcm1 extends StatelessWidget {
  final String title;
  final String value;

  const MetricCardcm1({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            // textAlign: TextAlign.left
          ),
        ],
      ),
    );
  }
}
