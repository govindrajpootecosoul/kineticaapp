import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/custom_dropdown.dart';
import 'package:flutter_application_1/utils/formatNumberStringWithComma.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../utils/ApiConfig.dart';
import '../utils/colors.dart';

class FinanceExecutiveScreen extends StatefulWidget {
  final String productval;

  const FinanceExecutiveScreen({Key? key, required this.productval})
      : super(key: key);

  @override
  _FinanceExecutiveScreenState createState() => _FinanceExecutiveScreenState();
}

class _FinanceExecutiveScreenState extends State<FinanceExecutiveScreen> {
  List<dynamic> allData = [];
  Map<String, double>? selectedMonthData;
  List<String> availableMonths = [];
  String? selectedMonth;
  String? selectedCategory = 'All Categories';
  List<String> categories = ['All Categories'];
  bool isLoading = false;
  bool isWideScreen = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.thrivebrands.ai/api/category-list'));

      if (response.statusCode == 200) {
        final List<dynamic> data = await json.decode(response.body);
        setState(() {
          // Start with "All Categories" and add the rest
          categories = ['All Categories'] +
              data.map<String>((category) => category.toString()).toList();
          print('Available Categories: $categories');
        });
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });
    try {
      // final response = await http.get(Uri.parse(ApiConfig.pnlData));
           Uri url = Uri.parse(ApiConfig.pnlData);
      Map<String, String> queryParams = {
        // 'range': 'lastmonth',
      };

      // Add category if selected
      if (widget.productval == "0" && selectedCategory != "All Categories") {
        queryParams['category'] = selectedCategory!;
      } else {
        // queryParams['category'] = '';
      }

      // Handle date range selection
      // if (useCustomRange && startDate != null && endDate != null) {
      //   queryParams['startMonth'] = DateFormat('yyyy-MM').format(startDate!);
      //   queryParams['endMonth'] = DateFormat('yyyy-MM').format(endDate!);
      // } else if (selectedMonth != null && !useCustomRange) {
      //   final selectedYearMonth = DateFormat('yyyy-MM')
      //       .format(DateFormat('MMMM yyyy').parse(selectedMonth!));
      //   queryParams['startMonth'] = selectedYearMonth;
      //   queryParams['endMonth'] = selectedYearMonth;
      // }

      url = url.replace(queryParameters: queryParams);
      print("Fetching data from: $url");
      final response = await http.get(url);
      print("Response : ${response.body}");

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
          isLoading = false; // Hide loading indicator
        });
        //  final categoriesSet = data
        //       .map((e) {
        //         final category = e['Product Category'];
        //         if (category == null) return null;
        //         if (category is String) return category;
        //         return category
        //             .toString(); // Convert numbers/other types to string
        //       })
        //       .where((category) => category != null) // Remove nulls
        //       .map((category) => category!) // Cast away nulls after filtering
        //       .toSet()
        //       .toList();
        //   categoriesSet.sort();
        //   categories = categoriesSet;
        //   print('Available Categories: $categories');
      } else {
        setState(() {
          isLoading = false; // Hide loading indicator
        });
         print('Failed to load data: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
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
        'Total Sales with tax':
            sumField(selectedMonthList, 'Total Sales with tax'),
        'Total Return with tax': sumField(selectedMonthList,
            'Total Return with tax'), // Assuming returns are 'Total Units', adjust if needed
        'Net Sales with tax': sumField(selectedMonthList,
            'Net Sales with tax'), // Your JSON doesn't have COGS? Set 0 or handle accordingly
        'Total Sales': sumField(selectedMonthList, 'Total Sales'),
        'Total_Return_Amount':
            sumField(selectedMonthList, 'Total_Return_Amount'),
        'Net Sales': sumField(selectedMonthList, 'Net Sales'),
        'Cogs': sumField(selectedMonthList, 'Cogs'),
        'CM1': sumField(selectedMonthList, 'CM1'),
        'Deal Fee': sumField(selectedMonthList, 'Deal Fee'),
        'FBA Inventory Fee': sumField(selectedMonthList, 'FBA Inventory Fee'),
        'FBA Reimbursement': sumField(selectedMonthList, 'FBA Reimbursement'),
        'Liquidations': sumField(selectedMonthList, 'Liquidations'),
        'Storage Fee': sumField(selectedMonthList, 'Storage Fee'),
        'fba fees': sumField(selectedMonthList, 'fba fees'),
        'CM2': sumField(selectedMonthList, 'CM2'),
        'Other marketing Expenses':
            sumField(selectedMonthList, 'Other marketing Expenses'),
        'promotional rebates':
            sumField(selectedMonthList, 'promotional rebates'),
        'selling fees': sumField(selectedMonthList, 'selling fees'),
        'Spend': sumField(selectedMonthList, 'Spend'),
        'CM3': sumField(selectedMonthList, 'CM3'),
      };
    });
  }

  Widget dataRow(String title, double? value, double? percent,
      {Color? valueColor}) {
    value ??= 0.0;
    valueColor = value < 0 ? Colors.red : valueColor;
    bool isCM = title == 'CM1' || title == 'CM2' || title == 'CM3';

    final rowContent = Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isCM ? FontWeight.bold : FontWeight.normal,
                      fontSize: isCM ? 18 : 14,
                    ),
                  ),
                ),
/*              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '£ ${formatNumberStringWithComma(value.round().toString())}',
                  style: TextStyle(
                    color: valueColor ?? Colors.black,
                    fontWeight: isCM ? FontWeight.bold : FontWeight.w600,
                    fontSize: isCM ? 16 : 14,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),*/

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '£ ${formatNumberStringWithComma(value.abs().round().toString())}',
                    style: TextStyle(
                      color: valueColor ?? Colors.black,
                      fontWeight: isCM ? FontWeight.bold : FontWeight.w600,
                      fontSize: isCM ? 16 : 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${(percent! * 100).toStringAsFixed(2)}%",
                    style: TextStyle(
                      // color: valueColor ?? Colors.black,
                      // fontWeight: isCM ? FontWeight.bold : FontWeight.w600,
                      fontSize: isCM ? 16 : 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ));

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

  Widget dataRow1(String title, double? value, {Color? valueColor}) {
    value ??= 0.0;
    valueColor = value < 0 ? Colors.red : valueColor;
    bool isCM = title == 'CM1' || title == 'CM2' || title == 'CM3';

    final rowContent = Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isCM ? FontWeight.bold : FontWeight.normal,
                      fontSize: isCM ? 18 : 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '£ ${formatNumberStringWithComma(value.round().toString())}',
                    style: TextStyle(
                      color: valueColor ?? Colors.black,
                      fontWeight: isCM ? FontWeight.bold : FontWeight.w600,
                      fontSize: isCM ? 16 : 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "",
                    style: TextStyle(
                      // color: valueColor ?? Colors.black,
                      // fontWeight: isCM ? FontWeight.bold : FontWeight.w600,
                      fontSize: isCM ? 16 : 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ));

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
    isWideScreen = MediaQuery.of(context).size.width > 600;
    return SafeArea(
      child: Scaffold(
        appBar: widget.productval == "1"
            ? AppBar(
                // centerTitle: true,
                backgroundColor: AppColors.primaryBlue,
                iconTheme: IconThemeData(
                    color: Colors.white), // 👈 sets back arrow color to white
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
                flexibleSpace: Container(
                  child: Image.asset('assets/logo.png'),
                ),
              )
            : null,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              :  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month filter dropdown
                  kIsWeb && isWideScreen ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Profit & Loss",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.brown,
                              fontSize: 24),
                        ),
                        Row(
                          children: [
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
                            if(widget.productval == "0")
                            SizedBox(
                              width: 10,
                            ),
                            if(widget.productval == "0")
                            SizedBox(
                              width: 160,
                              child: DropdownButtonFormField<String>(
                                value: selectedCategory,
                                decoration: customInputDecoration(),
                                isExpanded: true,
                                items: categories
                                    .map((category) => DropdownMenuItem(
                                          value: category,
                                          child: Text(category),
                                        ))
                                    .toList(),
                                onChanged: (value) async{
                                  setState(() {
                                    selectedCategory = value ??
                                        "All Categories"; // Default to "All Categories"
                                    fetchData(); // Fetch data with new category
                                    updateSelectedMonthData();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ) : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Profit & Loss",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.brown,
                              fontSize: 24),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                            if(widget.productval == "0")
                            SizedBox(
                              width: 10,
                            ),
                            if(widget.productval == "0")
                            SizedBox(
                              width: 160,
                              child: DropdownButtonFormField<String>(
                                value: selectedCategory,
                                decoration: customInputDecoration(),
                                isExpanded: true,
                                items: categories
                                    .map((category) => DropdownMenuItem(
                                          value: category,
                                          child: Text(category),
                                        ))
                                    .toList(),
                                onChanged: (value) async{
                                  setState(() {
                                    selectedCategory = value ??
                                        "All Categories"; // Default to "All Categories"
                                    fetchData(); // Fetch data with new category
                                    updateSelectedMonthData();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (selectedMonthData != null && allData.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              dataRow1("Gross Revenue:",
                                  selectedMonthData!['Total Sales with tax'],
                                  valueColor: selectedMonthData![
                                              'Total Sales with tax']! <
                                          0
                                      ? Colors.green
                                      : Colors.green),
                              dataRow1(
                                  "Return Revenue:",
                                  selectedMonthData!['Total Return with tax']
                                      ?.abs(),
                                  valueColor: selectedMonthData![
                                              'Total Return with tax']! <
                                          0
                                      ? Colors.red
                                      : Colors.red),

                              //dataRow("Net Revenue with tax:", selectedMonthData!['Net Sales with tax'],selectedMonthData!['Net Sales with tax'/'Total Sales with tax'], valueColor: selectedMonthData!['Net Sales with tax']! < 0 ? Colors.red : Colors.green),

                              dataRow1(
                                "Net Revenue:",
                                selectedMonthData!['Net Sales with tax'],
                                valueColor:
                                    (selectedMonthData!['Net Sales with tax'] ??
                                                0) <
                                            0
                                        ? Colors.green
                                        : Colors.green,
                              ),

                              // dataRow1("Orders Revenue:", selectedMonthData!['Total Sales'], valueColor: selectedMonthData!['Total Sales']! < 0 ? Colors.green : Colors.green),
                              // dataRow("Returns Revenue:", selectedMonthData!['Total_Return_Amount'],(selectedMonthData!['Total_Return_Amount'] ?? 0) / (selectedMonthData!['Total Sales with tax'] ?? 1), valueColor: selectedMonthData!['Total_Return_Amount']! < 0 ? Colors.red : Colors.red),
                              // dataRow("Net Revenue:", selectedMonthData!['Net Sales'],(selectedMonthData!['Net Sales'] ?? 0) / (selectedMonthData!['Total Sales with tax'] ?? 1), valueColor: selectedMonthData!['Net Sales']! < 0 ? Colors.green : Colors.green),
                              dataRow(
                                  "Cogs:",
                                  selectedMonthData!['Cogs'],
                                  (selectedMonthData!['Cogs'] ?? 0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor: selectedMonthData!['Cogs']! < 0
                                      ? Colors.red
                                      : Colors.red),
                              dataRow(
                                  "CM1",
                                  selectedMonthData!['CM1'],
                                  (selectedMonthData!['CM1'] ?? 0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor: selectedMonthData!['CM1']! < 0
                                      ? Colors.red
                                      : Colors.green),
                              dataRow(
                                  "Deal Fee:",
                                  selectedMonthData!['Deal Fee'],
                                  (selectedMonthData!['Deal Fee'] ?? 0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor:
                                      selectedMonthData!['Deal Fee']! < 0
                                          ? Colors.red
                                          : Colors.red),
                              dataRow(
                                  "FBA Inventory Fee:",
                                  selectedMonthData!['FBA Inventory Fee'],
                                  (selectedMonthData!['FBA Inventory Fee'] ??
                                          0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor:
                                      selectedMonthData!['FBA Inventory Fee']! <
                                              0
                                          ? Colors.red
                                          : Colors.red),
                              dataRow(
                                  "FBA Reimbursement:",
                                  selectedMonthData!['FBA Reimbursement'],
                                  (selectedMonthData!['FBA Reimbursement'] ??
                                          0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor:
                                      selectedMonthData!['FBA Reimbursement']! <
                                              0
                                          ? Colors.green
                                          : Colors.green),
                              dataRow(
                                  "Liquidations:",
                                  selectedMonthData!['Liquidations'],
                                  (selectedMonthData!['Liquidations'] ?? 0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor:
                                      selectedMonthData!['Liquidations']! < 0
                                          ? Colors.red
                                          : Colors.red),
                              dataRow(
                                  "Storage Fee:",
                                  selectedMonthData!['Storage Fee'],
                                  (selectedMonthData!['Storage Fee'] ?? 0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor:
                                      selectedMonthData!['Storage Fee']! < 0
                                          ? Colors.red
                                          : Colors.red),
                              dataRow(
                                  "FBA Fees:",
                                  selectedMonthData!['fba fees'],
                                  (selectedMonthData!['fba fees'] ?? 0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor:
                                      selectedMonthData!['fba fees']! < 0
                                          ? Colors.red
                                          : Colors.red),
                              dataRow(
                                  "CM2",
                                  selectedMonthData!['CM2'],
                                  (selectedMonthData!['CM2'] ?? 0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor: selectedMonthData!['CM2']! < 0
                                      ? Colors.red
                                      : Colors.green),
                              dataRow(
                                  "Other Marketing Expenses:",
                                  selectedMonthData![
                                      'Other marketing Expenses'],
                                  (selectedMonthData![
                                              'Other marketing Expenses'] ??
                                          0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor: selectedMonthData![
                                              'Other marketing Expenses']! <
                                          0
                                      ? Colors.red
                                      : Colors.red),
                              dataRow(
                                  "Discounts:",
                                  selectedMonthData!['promotional rebates'],
                                  (selectedMonthData!['promotional rebates'] ??
                                          0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor: selectedMonthData![
                                              'promotional rebates']! <
                                          0
                                      ? Colors.red
                                      : Colors.red),
                              dataRow(
                                  "Selling Fess:",
                                  selectedMonthData!['selling fees'],
                                  (selectedMonthData!['selling fees'] ?? 0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor:
                                      selectedMonthData!['selling fees']! < 0
                                          ? Colors.red
                                          : Colors.red),
                              dataRow(
                                  "Ad Spend:",
                                  selectedMonthData!['Spend'],
                                  (selectedMonthData!['Spend'] ?? 0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor: selectedMonthData!['Spend']! < 0
                                      ? Colors.red
                                      : Colors.red),
                              dataRow(
                                  "CM3",
                                  selectedMonthData!['CM3'],
                                  (selectedMonthData!['CM3'] ?? 0) /
                                      (selectedMonthData![
                                              'Total Sales with tax'] ??
                                          1),
                                  valueColor: selectedMonthData!['CM3']! < 0
                                      ? Colors.red
                                      : Colors.green),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

///working pnl code

/*import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/custom_dropdown.dart';
import 'package:flutter_application_1/utils/formatNumberStringWithComma.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../utils/ApiConfig.dart';
import '../utils/colors.dart';

class FinanceExecutiveScreen extends StatefulWidget {

  final String productval;

  const FinanceExecutiveScreen({Key? key, required this.productval}) : super(key: key);

  @override
  _FinanceExecutiveScreenState createState() => _FinanceExecutiveScreenState();
}

class _FinanceExecutiveScreenState extends State<FinanceExecutiveScreen> {
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
      child:

      // Row(
      //   children: [
      //     Expanded(
      //       flex: 2,
      //       child: Align(
      //         alignment: Alignment.centerLeft,
      //         child: Text(
      //           title,
      //           style: TextStyle(
      //             fontWeight: isCM ? FontWeight.bold : FontWeight.normal,
      //             fontSize: isCM ? 18 : 14,
      //           ),
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       flex: 1,
      //       child: Align(
      //         alignment: Alignment.centerRight,
      //         child: Text(
      //           '£ ${formatNumberStringWithComma(value.round().toString())}',
      //           style: TextStyle(
      //             color: valueColor ?? Colors.black,
      //             fontWeight: isCM ? FontWeight.bold : FontWeight.w600,
      //             fontSize: isCM ? 16 : 14,
      //           ),
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       flex: 1,
      //       child: Align(
      //         alignment: Alignment.centerRight,
      //         child: Text(
      //           '£ ${formatNumberStringWithComma(value.round().toString())}',
      //           style: TextStyle(
      //             color: valueColor ?? Colors.black,
      //             fontWeight: isCM ? FontWeight.bold : FontWeight.w600,
      //             fontSize: isCM ? 16 : 14,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ));


        Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: isCM ? FontWeight.bold : FontWeight.normal,
                    fontSize: isCM ? 18 : 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '£ ${formatNumberStringWithComma(value.round().toString())}',
                  style: TextStyle(
                    color: valueColor ?? Colors.black,
                    fontWeight: isCM ? FontWeight.bold : FontWeight.w600,
                    fontSize: isCM ? 16 : 14,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '%',
                  style: TextStyle(
                    // color: valueColor ?? Colors.black,
                    // fontWeight: isCM ? FontWeight.bold : FontWeight.w600,
                    fontSize: isCM ? 16 : 14,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ));




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
    return SafeArea(
      child: Scaffold(

        appBar:
        widget.productval == "1"
            ?
        AppBar(
          // centerTitle: true,
          backgroundColor: AppColors.primaryBlue,
          iconTheme: IconThemeData(
              color: Colors.white), // 👈 sets back arrow color to white
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
          flexibleSpace: Container(
            child: Image.asset('assets/logo.png'),
          ),
        ):null,


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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              dataRow("Amazon Revenue",
                                  selectedMonthData!['Total Sales'],
                                  valueColor:
                                      selectedMonthData!['Total Sales']! < 0
                                          ? Colors.red
                                          : Colors.green),
                              dataRow("Amazon Returns",
                                  selectedMonthData!['Total Returns'],
                                  valueColor:
                                      selectedMonthData!['Total Returns']! < 0
                                          ? Colors.red
                                          : Colors.green),
                              dataRow("Net Revenue",
                                  selectedMonthData!['Total Sales'],
                                  valueColor:
                                      selectedMonthData!['Total Sales']! < 0
                                          ? Colors.red
                                          : Colors.green),
                              dataRow("COGS", selectedMonthData!['COGS'],
                                  valueColor: selectedMonthData!['COGS']! < 0
                                      ? Colors.red
                                      : Colors.green),
                              dataRow("CM1", selectedMonthData!['CM1'],
                                  valueColor: selectedMonthData!['CM1']! < 0
                                      ? Colors.red
                                      : Colors.green),
                              dataRow(
                                  "Inventory", selectedMonthData!['Inventory'],
                                  valueColor: selectedMonthData!['Inventory']! < 0
                                      ? Colors.red
                                      : Colors.green),
                              dataRow("Liquidation Cost",
                                  selectedMonthData!['Liquidations'],
                                  valueColor:
                                      selectedMonthData!['Liquidations']! < 0
                                          ? Colors.red
                                          : Colors.green),
                              dataRow("Reimbursement",
                                  selectedMonthData!['FBA Reimbursement'],
                                  valueColor:
                                      selectedMonthData!['FBA Reimbursement']! < 0
                                          ? Colors.red
                                          : Colors.green),
                              dataRow("Storage Fee",
                                  selectedMonthData!['Storage Fee'],
                                  valueColor:
                                      selectedMonthData!['Storage Fee']! < 0
                                          ? Colors.red
                                          : Colors.green),
                              dataRow("Shipping Service",
                                  selectedMonthData!['Shipping Service'],
                                  valueColor:
                                      selectedMonthData!['Shipping Service']! < 0
                                          ? Colors.red
                                          : Colors.green),
                              dataRow("CM2", selectedMonthData!['CM2'],
                                  valueColor: selectedMonthData!['CM2']! < 0
                                      ? Colors.red
                                      : Colors.green),
                              dataRow("Ad Spend", selectedMonthData!['Ad Spend'],
                                  valueColor: selectedMonthData!['Ad Spend']! < 0
                                      ? Colors.red
                                      : Colors.green),
                              dataRow(
                                  "Discounts", selectedMonthData!['Discounts'],
                                  valueColor: selectedMonthData!['Discounts']! < 0
                                      ? Colors.red
                                      : Colors.green),
                              dataRow("Net Selling Fee",
                                  selectedMonthData!['Net Selling Fee'],
                                  valueColor:
                                      selectedMonthData!['Net Selling Fee']! < 0
                                          ? Colors.red
                                          : Colors.green),
                              dataRow("Final Service Fee",
                                  selectedMonthData!['Final Service Fee'],
                                  valueColor:
                                      selectedMonthData!['Final Service Fee']! < 0
                                          ? Colors.red
                                          : Colors.green),
                              dataRow("CM3", selectedMonthData!['CM3'],
                                  valueColor: selectedMonthData!['CM3']! < 0
                                      ? Colors.red
                                      : Colors.green),




                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
*/
