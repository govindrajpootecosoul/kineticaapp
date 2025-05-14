import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../utils/ApiConfig.dart';

class FinanceExecutiveScreen extends StatefulWidget {
  @override
  _FinanceExecutiveScreenState createState() => _FinanceExecutiveScreenState();
}

class _FinanceExecutiveScreenState extends State<FinanceExecutiveScreen> {
  List<dynamic> allData = [];
  dynamic selectedMonthData;
  List<String> availableMonths = [];
  String? selectedMonth;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(ApiConfig.pnlData));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      allData = data;

      // Extract unique months
      final months = allData.map((e) {
        final date = excelDateToDateTime(e['Year-Month']);
        return DateFormat.yMMMM().format(date); // "April 2025"
      }).toSet().toList();

      months.sort((a, b) => a.compareTo(b)); // sort by date
      setState(() {
        availableMonths = months;
        selectedMonth = months.isNotEmpty ? months.first : null;
        updateSelectedMonthData();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  DateTime excelDateToDateTime(int serial) {
    return DateTime.fromMillisecondsSinceEpoch(((serial - 25569) * 86400000), isUtc: true);
  }

  void updateSelectedMonthData() {
    if (selectedMonth == null) return;

    final selectedMonthList = allData.where((e) {
      return DateFormat.yMMMM().format(excelDateToDateTime(e['Year-Month'])) == selectedMonth;
    }).toList();

    // Sum up all values for the selected month
    selectedMonthData = {
      'Total Sales': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Total Sales'] ?? 0.0)),
      'Total Returns': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Total Returns'] ?? 0.0)),
      'COGS': selectedMonthList.fold(0.0, (sum, e) => sum + (e['COGS'] ?? 0.0)),
      'CM1': selectedMonthList.fold(0.0, (sum, e) => sum + (e['CM1'] ?? 0.0)),
      'Inventory': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Inventory'] ?? 0.0)),
      'Liquidations': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Liquidations'] ?? 0.0)),
      'FBA Reimbursement': selectedMonthList.fold(0.0, (sum, e) => sum + (e['FBA Reimbursement'] ?? 0.0)),
      'Storage Fee': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Storage Fee'] ?? 0.0)),
      'Shipping Service': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Shipping Service'] ?? 0.0)),
      'Ad Spend': selectedMonthList.fold(0.0, (sum, e) => sum + (e['Spend'] ?? 0.0)),
      'Discounts': selectedMonthList.fold(0.0, (sum, e) => sum + (e['promotional rebates'] ?? 0.0)),
      'Net Selling Fee': selectedMonthList.fold(0.0, (sum, e) => sum + (e['selling fees'] ?? 0.0)),
      'Final Service Fee': selectedMonthList.fold(0.0, (sum, e) => sum + (e['fba fees'] ?? 0.0)),
      'CM2': selectedMonthList.fold(0.0, (sum, e) => sum + (e['CM2'] ?? 0.0)),
      'CM3': selectedMonthList.fold(0.0, (sum, e) => sum + (e['CM3'] ?? 0.0)),
    };

    setState(() {});
  }

  Widget dataRow(String title, dynamic value, {Color? valueColor}) {
    // Check for negative values and apply red color
    valueColor = value != null && value < 0 ? Colors.red : valueColor;

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
            '\$ ${value != null ? value.toStringAsFixed(2) : "0.00"}',
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
      appBar: AppBar(title: Text('Finance Executive')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: allData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month filter dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Profit & Loss",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.brown,fontSize: 24),),

                SizedBox(
                  width: 160,
                  child: DropdownButton<String>(
                    value: selectedMonth,
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      dataRow("Amazon Revenue", selectedMonthData['Total Sales'],
                          valueColor: selectedMonthData['Total Sales'] < 0 ? Colors.red : Colors.green),
                      dataRow("Amazon Returns", selectedMonthData['Total Returns'],
                          valueColor: selectedMonthData['Total Returns'] < 0 ? Colors.red : Colors.green),
                      dataRow("Net Revenue", selectedMonthData['Total Sales'],
                          valueColor: selectedMonthData['Total Sales'] < 0 ? Colors.red : Colors.green),
                      dataRow("COGS", selectedMonthData['COGS'],
                          valueColor: selectedMonthData['COGS'] < 0 ? Colors.red : Colors.green),
                      dataRow("CM1", selectedMonthData['CM1'],
                          valueColor: selectedMonthData['CM1'] < 0 ? Colors.red : Colors.green),
                      dataRow("Inventory", selectedMonthData['Inventory'],
                          valueColor: selectedMonthData['Inventory'] < 0 ? Colors.red : Colors.green),
                      dataRow("Liquidation Cost", selectedMonthData['Liquidations'],
                          valueColor: selectedMonthData['Liquidations'] < 0 ? Colors.red : Colors.green),
                      dataRow("Reimbursement", selectedMonthData['FBA Reimbursement'],
                          valueColor: selectedMonthData['FBA Reimbursement'] < 0 ? Colors.red : Colors.green),
                      dataRow("Storage Fee", selectedMonthData['Storage Fee'],
                          valueColor: selectedMonthData['Storage Fee'] < 0 ? Colors.red : Colors.green),
                      dataRow("Shipping Service", selectedMonthData['Shipping Service'],
                          valueColor: selectedMonthData['Shipping Service'] < 0 ? Colors.red : Colors.green),
                      dataRow("CM2", selectedMonthData['CM2'],
                          valueColor: selectedMonthData['CM2'] < 0 ? Colors.red : Colors.green),
                      dataRow("Ad Spend", selectedMonthData['Ad Spend'],
                          valueColor: selectedMonthData['Ad Spend'] < 0 ? Colors.red : Colors.green),
                      dataRow("Discounts", selectedMonthData['Discounts'],
                          valueColor: selectedMonthData['Discounts'] < 0 ? Colors.red : Colors.green),
                      dataRow("Net Selling Fee", selectedMonthData['Net Selling Fee'],
                          valueColor: selectedMonthData['Net Selling Fee'] < 0 ? Colors.red : Colors.green),
                      dataRow("Final Service Fee", selectedMonthData['Final Service Fee'],
                          valueColor: selectedMonthData['Final Service Fee'] < 0 ? Colors.red : Colors.green),
                      dataRow("CM3", selectedMonthData['CM3'],
                          valueColor: selectedMonthData['CM3'] < 0 ? Colors.red : Colors.green),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
