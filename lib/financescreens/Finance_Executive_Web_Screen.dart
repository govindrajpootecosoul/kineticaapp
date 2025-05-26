import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/custom_dropdown.dart';
import 'package:flutter_application_1/utils/formatNumberStringWithComma.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../utils/ApiConfig.dart';

class FinanceExecutiveWebScreen extends StatefulWidget {
  @override
  _FinanceExecutiveWebScreenState createState() =>
      _FinanceExecutiveWebScreenState();
}

class _FinanceExecutiveWebScreenState extends State<FinanceExecutiveWebScreen> {
  List<dynamic> allData = [];
  Map<String, double>? selectedMonthData;
  List<String> availableMonths = [];
  String? selectedMonth;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.pnlData));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Store data locally
        allData = data;

        // Extract unique months in "yyyy-MM" format, then convert to readable "MMMM yyyy"
        final monthsSet =
            allData.map<String>((e) => e['Year-Month'] as String).toSet();

        // Sort months in ascending order
        final monthsList = monthsSet.toList();
        monthsList.sort((a, b) {
          final dateA = DateFormat('yyyy-MM').parse(a);
          final dateB = DateFormat('yyyy-MM').parse(b);
          return dateA.compareTo(dateB);
        });

        setState(() {
          availableMonths = monthsList
              .map((e) => DateFormat('MMMM yyyy')
                  .format(DateFormat('yyyy-MM').parse(e)))
              .toList();
          selectedMonth =
              availableMonths.isNotEmpty ? availableMonths.first : null;
          updateSelectedMonthData();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void updateSelectedMonthData() {
    if (selectedMonth == null) return;

    // Convert selectedMonth "MMMM yyyy" back to "yyyy-MM" for filtering
    final selectedYearMonth = DateFormat('yyyy-MM')
        .format(DateFormat('MMMM yyyy').parse(selectedMonth!));

    // Filter data by selected month
    final selectedMonthList =
        allData.where((e) => e['Year-Month'] == selectedYearMonth).toList();

    // Sum up all required fields safely, defaulting to 0.0 if null
    double sumField(List<dynamic> list, String key) {
      return list.fold(0.0, (sum, e) {
        final val = e[key];
        if (val == null) return sum;
        if (val is int) return sum + val.toDouble();
        if (val is double) return sum + val;
        if (val is String) return sum + (double.tryParse(val) ?? 0.0);
        return sum;
      });
    }

    setState(() {
      selectedMonthData = {
        'Total Sales': sumField(selectedMonthList, 'Total Sales'),
        'Total Returns': sumField(selectedMonthList,
            'Total Units'), // Assuming returns are 'Total Units', adjust if needed
        'COGS': sumField(selectedMonthList,
            'Cogs'), // Your JSON doesn't have COGS? Set 0 or handle accordingly
        'CM1': sumField(selectedMonthList, 'CM1'),
        'Inventory': sumField(selectedMonthList, 'FBA Inventory Fee'),
        'Liquidations': sumField(selectedMonthList, 'Liquidations'),
        'FBA Reimbursement': sumField(selectedMonthList, 'FBA Reimbursement'),
        'Storage Fee': sumField(selectedMonthList, 'Storage Fee'),
        'Shipping Service': 0.0, // No shipping service key in JSON
        'Ad Spend': sumField(selectedMonthList, 'Spend'),
        'Discounts': sumField(selectedMonthList, 'promotional rebates'),
        'Net Selling Fee': sumField(selectedMonthList, 'selling fees'),
        'Final Service Fee': sumField(selectedMonthList, 'fba fees'),
        'CM2': sumField(selectedMonthList, 'CM2'),
        'CM3': sumField(selectedMonthList, 'CM3'),
      };
    });
  }

  Widget dataRow(String title, double? value, {Color? valueColor}) {
    value ??= 0.0;
    valueColor = value < 0 ? Colors.red : valueColor;
    bool isCM = title == 'CM1' || title == 'CM2' || title == 'CM3';

    final rowContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isCM ? FontWeight.bold : FontWeight.normal,
                fontSize: isCM ? 18 : 14,
              ),
            ),
          ),
          Text(
            //  '\£ ${value.toStringAsFixed(2)}',
            '\£ ${formatNumberStringWithComma(value.round().toString())}',
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontWeight: isCM ? FontWeight.bold : FontWeight.w600,
              fontSize: isCM ? 16 : 14,
            ),
          ),
        ],
      ),
    );

    if (isCM) {
      return Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: rowContent,
      );
    } else {
      return rowContent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        iconTheme: IconThemeData(
            color: Colors.white), // 👈 sets back arrow color to white
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             const Text(
              'Finance > Executive',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Image.asset(
              'assets/logo.png',
              height: 72,
            ),
           const SizedBox(width: 8),
           const SizedBox(width: 8),
          ],
        ),
        centerTitle: true,

        // title: Expanded(
        //   child: Text(
        //     'Finance > Executive',
        //     style: TextStyle(
        //       color: Colors.white,
        //       fontSize: 18,
        //       fontWeight: FontWeight.w600,
        //     ),
        //   ),
        // ),
        // flexibleSpace: Container(
        //   child: Center(
        //     child: Image.asset('assets/logo.png'),
        //   ),
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: allData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: 600), // No constraint for mobile
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        // 🔥 Make everything scrollable
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Month filter dropdown
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Profit & Loss",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.brown,
                                      fontSize: 24),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedMonth,
                                    decoration: customInputDecoration(),
                                    isExpanded: true,
                                    items: availableMonths
                                        .map((month) => DropdownMenuItem(
                                              value: month,
                                              child: Text(month),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedMonth = value;
                                        updateSelectedMonthData();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            if (selectedMonthData != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  dataRow("Amazon Revenue",
                                      selectedMonthData!['Total Sales']),
                                  dataRow("Amazon Returns",
                                      selectedMonthData!['Total Returns']),
                                  dataRow("Net Revenue",
                                      selectedMonthData!['Total Sales']),
                                  dataRow("COGS", selectedMonthData!['COGS']),
                                  dataRow("CM1", selectedMonthData!['CM1']),
                                  dataRow("Inventory",
                                      selectedMonthData!['Inventory']),
                                  dataRow("Liquidation Cost",
                                      selectedMonthData!['Liquidations']),
                                  dataRow("Reimbursement",
                                      selectedMonthData!['FBA Reimbursement']),
                                  dataRow("Storage Fee",
                                      selectedMonthData!['Storage Fee']),
                                  dataRow("Shipping Service",
                                      selectedMonthData!['Shipping Service']),
                                  dataRow("CM2", selectedMonthData!['CM2']),
                                  dataRow("Ad Spend",
                                      selectedMonthData!['Ad Spend']),
                                  dataRow("Discounts",
                                      selectedMonthData!['Discounts']),
                                  dataRow("Net Selling Fee",
                                      selectedMonthData!['Net Selling Fee']),
                                  dataRow("Final Service Fee",
                                      selectedMonthData!['Final Service Fee']),
                                  dataRow("CM3", selectedMonthData!['CM3']),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
