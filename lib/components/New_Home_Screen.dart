import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/check_platform.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../comman_Screens/productcard.dart';
import '../../../utils/colors.dart';
import '../financescreens/Finance_Executive_Screen.dart';
import '../graph/commanbarchar_file.dart';
import '../utils/ApiConfig.dart'; // Import the package

class NewHomeScreen extends StatefulWidget {
  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen>  with SingleTickerProviderStateMixin{
  List<String> states = [];
  List<String> cities = [];
  List<String> skus = [];
  bool isWeb = false;
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: 'Account Level'),
    Tab(text: 'ASINs'),
  ];

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
    // "today",
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

  //List<SalesSku> salesData = [];
  // bool isLoading = false;
  Map<String, dynamic>? salesData;
  Map<String, dynamic>? adssales;
  //bool isLoading = true;
  String errorMessage = '';

  // double? totalAdSales;
  // double? totalAdSpend;
  // String? errorMsg;

  // double totalAdSales = 0.0;
  // double totalAdSpend = 0.0;
  bool isLoading = false;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    isWeb = checkPlatform();
    _tabController = TabController(length: myTabs.length, vsync: this);
    selectedFilterType = '6months'; // Set default to "6months"
    fetchDropdownData();

    fetchFilteredData();
    fetchAdData(); // Automatically fetch data for 6 months on screen load
  }

   @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      final stateRes =
          await http.get(Uri.parse('${ApiConfig.baseUrl}/state?q='));
      final cityRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/city?q='));
      final skuRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/sku'));

      if (stateRes.statusCode == 200)
        states = List<String>.from(json.decode(stateRes.body));
      if (cityRes.statusCode == 200)
        cities = List<String>.from(json.decode(cityRes.body));
      if (skuRes.statusCode == 200)
        skus = List<String>.from(json.decode(skuRes.body));

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
          '${ApiConfig.baseUrl}/sales/resion?filterType=custom&fromDate=$from&toDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    } else {
      url =
          '${ApiConfig.baseUrl}/sales/resion?filterType=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    }
    //var request = http.Request('GET', url);

    var request = http.Request('GET', Uri.parse(url));

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();

        setState(() {
          salesData = json.decode(data);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.reasonPhrase ?? "Failed to fetch data.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchAdData() async {
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
          '${ApiConfig.baseUrl}/data/filterData?range=custom&startDate=$from&endDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    } else {
      url =
          '${ApiConfig.baseUrl}/data/filterData?range=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    }

    var request = http.Request('GET', Uri.parse(url));

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(data);

        setState(() {
          adssales = jsonResponse; // Entire JSON stored
          // totalAdSales = double.parse((jsonResponse['totalAdSales'] ?? 0.0).toString()).toStringAsFixed(2);
          // totalAdSpend = double.parse((jsonResponse['totalAdSpend'] ?? 0.0).toString()).toStringAsFixed(2);
          print("console:::   ${adssales}");
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = response.reasonPhrase ?? 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = '❌ Error: $e';
        isLoading = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

/*  Future<void> fetchAdData() async {
    if (selectedFilterType == null) return;
    setState(() => isLoading = true);
    // final url = Uri.parse(
    //   'http://localhost:4000/api/data/filterData?range=custom&startDate=2025-01-01&endDate=2025-05-01&sku=200855',
    // );
    String url = '';

    if (selectedFilterType == 'custom') {
      if (startDate == null || endDate == null) {
        setState(() => isLoading = false);
        return;
      }

      final from = formatDate(startDate!);
      final to = formatDate(endDate!);


      print(to);
      print(from);
      print("objectttt");

      url ='http://192.168.50.92:4000/api/data/filterData?range=custom&startDate=$from&endDate=$to&sku=${selectedSku ?? ''}}';
      print("print custom url ${url}");
    } else {
      url ='http://192.168.50.92:4000/api/data/filterData?range=$selectedFilterType&sku=${selectedSku ?? ''}';
      print("print url ${url}");
    }

    try {

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        setState(() {
          totalAdSales = double.parse((jsonResponse['totalAdSales']?.toDouble() ?? 0.0).toStringAsFixed(2));
          totalAdSpend = double.parse((jsonResponse['totalAdSpend']?.toDouble() ?? 0.0).toStringAsFixed(2));
          print("qwertyuio:: ${totalAdSales}");
          print("qwertyuio:: ${totalAdSpend}");
          isLoading = false;
        });


      } else {
        setState(() {
          errorMsg = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = '❌ Error: $e';
        isLoading = false;
      });
    }
  }*/

  void onDropdownChanged(String? value, String type) {
    setState(() {
      if (type == 'filter') {
        selectedFilterType = value;
        if (value != 'custom') {
          fetchFilteredData();
          fetchAdData();
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
      fetchAdData();
    }
  }

  final List<double> values = [10, 1500, 3000, 1102, 4003, 5000, 2007, 2700];
  final List<String> labels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
    'Next'
  ];

  void _showDateRangePicker(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        PickerDateRange? selectedRange; // Store the selected range

        return StatefulBuilder(
          // Use StatefulBuilder for state within the dialog
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: AppColors.beige,
              title: Text('Select Date Range'),
              content: Container(
                width: 300,
                height: 350,
                child: SfDateRangePicker(
                  backgroundColor: AppColors.white,
                  selectionColor: AppColors.gold,
                  todayHighlightColor: AppColors.gold,
                  rangeSelectionColor: AppColors.gold,
                  endRangeSelectionColor: AppColors.gradientStart,
                  startRangeSelectionColor: AppColors.gradientStart,
                  selectionMode: DateRangePickerSelectionMode.range,
                  navigationMode: DateRangePickerNavigationMode.scroll,
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    if (args.value is PickerDateRange) {
                      print(
                          "Selected Range: ${args.value.startDate} to ${args.value.endDate}");
                      selectedRange = args.value;
                      setState(() {
                        startDate = args.value?.startDate;
                        endDate = args.value?.endDate;
                      });
                    }
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.gold),
                  ),
                  onPressed: () {
                    // _selectedTime = 'Last 12 months';
                    // String range =
                    //               DateUtilsHelper.getDateRange(_selectedTime);
                    //           _fetchData(range);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Apply', style: TextStyle(color: AppColors.gold)),
                  onPressed: () {
                    if (selectedRange != null) {
                      // setState(() {
                      // String range =
                      //           DateUtilsHelper.getDateRangeFromDates(selectedRange?.startDate, selectedRange?.endDate);
                      // _fetchData(range);
                      fetchFilteredData();
                      fetchAdData();
                      // });
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
          indicatorSize: TabBarIndicatorSize.tab,
          tabAlignment: TabAlignment.fill,
          indicator: BoxDecoration(
            color: AppColors.gold,
            // borderRadius: BorderRadius.circular(50),
          ),
          
          indicatorColor: Colors.black,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SingleChildScrollView(
                // scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 190,
                      height: 33, // Fixed height
                      child: DropdownButtonFormField<String>(
                        isDense: true, // Makes dropdown compact
                        style: TextStyle(
                            fontSize: 12, color: Colors.black), // Smaller font
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8), // Tight padding
                          hintText: "Select Filter Type",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 1,),
                            borderRadius: BorderRadius.circular(50)
                          ),
                          
                        ),
                        items: filterTypes.map((type) {
                          return DropdownMenuItem(
                            onTap: (){},
                            value: type,
                            child: Padding(
                             padding: const EdgeInsets.only(right: 10), 
                              child: Text(
                                formatFilterType(type),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(fontSize: 12, color: Colors.black),
                              ),
                            ),
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
                          onPressed: () => _showDateRangePicker(context),
                          // onPressed: () => selectDateRange(context),
        
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
                    //
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
                    //
                    // SizedBox(width: 8),
                    // SizedBox(
                    //   width: 150,
                    //   child: DropdownSearch<String>(
                    //     items: skus,
                    //     selectedItem: selectedSku,
                    //     popupProps: PopupProps.menu(
                    //       showSearchBox: true,
                    //       searchFieldProps: TextFieldProps(
                    //         decoration: InputDecoration(
                    //           hintText: "Search SKU",
                    //           border: OutlineInputBorder(),
                    //         ),
                    //       ),
                    //     ),
                    //     dropdownDecoratorProps: DropDownDecoratorProps(
                    //       dropdownSearchDecoration: InputDecoration(
                    //         labelText: "SKU",
                    //         border: OutlineInputBorder(),
                    //       ),
                    //     ),
                    //     onChanged: (val) => onDropdownChanged(val, 'sku'),
                    //   ),
                    // ),
                  ],
                ),
              ),
              // 🔼 Your dropdown and filter widgets here...
        
              //   const SizedBox(height: 20),
        
              BarChartSample(values: values, labels: labels, isWeb: isWeb),
        
              /// This is your scrollable main content
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                        ? Center(child: Text(errorMessage))
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                // Your sales data cards here
                                Row(
                                  children: [
                                    Expanded(
                                      child: MetricCard(
                                        title: "Overall Sales",
                                        value:
                                            '£ ${salesData?['totalSales'].toStringAsFixed(2)}',
                                        compared:
                                            "${salesData?['comparison']['salesChangePercent']}",
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: MetricCard(
                                        title: "Units Orders",
                                        value: "${salesData?['totalQuantity']}",
                                        compared:
                                            "${salesData?['comparison']['quantityChangePercent']}",
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: MetricCardcm(
                                        title: "AOV",
                                        //value: "",
                                        value:
                                            "£ ${(((salesData?['totalSales'] ?? 0.0) as num) / ((adssales?['totalOrders'] ?? 1) as num)).toStringAsFixed(2)}",
        
                                        //  totalOrders
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: MetricCardcm(
                                        title: "Organic Sales",
                                        value:
                                            "£ ${((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).toStringAsFixed(2)}",
                                        //value: salesData!['totalSales'] - adssales!['totalAdSales'],
                                        //  value: ((double.tryParse(salesData!['totalSales'].toString()))-adssales!['totalAdSales']).toStringAsFixed(2),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: MetricCardcm(
                                        title: "Ad Spend",
                                        value:
                                            "£ ${((adssales?['totalAdSpend'] ?? 0).toDouble()).toStringAsFixed(2)}",
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: MetricCardcm(
                                        title: "Ad Sales",
                                        value:
                                            "£ ${((adssales?['totalAdSales'] ?? 0).toDouble()).toStringAsFixed(2)}",
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: MetricCardcm(
                                        title: "ACOS",
                                        value:
                                            '${(adssales?['totalAdSpend'] / adssales?['totalAdSales'] * 100).toStringAsFixed(2) ?? "00"} %',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: MetricCardcm(
                                        title: "TACOS",
                                        value:
                                            "${((adssales?['totalAdSales'] ?? 0) / (salesData?['totalSales'] ?? 1) * 100).toStringAsFixed(2)} %",
                                      ),
                                    ),
                                  ],
                                ),
        
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: MetricCardcm(
                                          title: "Organic Sales %",
                                          value:
                                              "${(((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)) / (salesData?['totalSales'] ?? 0.0) * 100).toStringAsFixed(2)}%"
        
                                          //  value: (adssales!['totalAdSpend'] / adssales!['totalAdSales']*100).toStringAsFixed(2) ?? "00",
        
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: MetricCardcm(
                                        title: "", //DOS
                                        value: "",
                                        // value: (adssales!['totalAdSales'] / (double.tryParse(salesData!['totalSales'].toString()) ?? 1)*100).toStringAsFixed(2),
                                      ),
                                    ),
                                  ],
                                ),
        
                                const SizedBox(height: 10),
                                if (!isLoading)
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FinanceExecutiveScreen(),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'View full P&L',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.gold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.arrow_forward,
                                            color: AppColors.gold),
                                      ],
                                    ),
                                  ),
                                Divider(color: AppColors.gold, thickness: 0.5),
        
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
              ),
        
              /// 🔽 Fixed bottom section (not scrollable)
              // Column(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     // Row(
              //     //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     //   children: [
              //     //     Expanded(
              //     //         child: InkWell(
              //     //             onTap: () {
              //     //               print("CM1 Clicked");
              //     //               showDialog(
              //     //                 context: context,
              //     //                 builder: (_) => AlertDialog(
              //     //                   title: Text('CM1 '),
              //     //                   content: Text('This is a popup message'),
              //     //                   actions: [
              //     //                     TextButton(
              //     //                       onPressed: () => Navigator.pop(context),
              //     //                       child: Text('OK'),
              //     //                     )
              //     //                   ],
              //     //                 ),
              //     //               );
              //     //             },
              //     //         child: MetricCardcm(title: "CM ₁", value: "00.0")),
              //     //     ),
              //     //     const SizedBox(width: 8),
              //     //     Expanded(
              //     //
              //     //       child: InkWell(
              //     //           onTap: () {
              //     //             print("CM2 Clicked");
              //     //             showDialog(
              //     //               context: context,
              //     //               builder: (_) => AlertDialog(
              //     //                 title: Text('CM2 '),
              //     //                 content: Text('This is a popup message'),
              //     //                 actions: [
              //     //                   TextButton(
              //     //                     onPressed: () => Navigator.pop(context),
              //     //                     child: Text('OK'),
              //     //                   )
              //     //                 ],
              //     //               ),
              //     //             );
              //     //           },
              //     //           child: MetricCardcm(title: "CM ₂", value: "00.0")),
              //     //     ),
              //     //     const SizedBox(width: 8),
              //     //     Expanded(
              //     //
              //     //       child: InkWell(
              //     //           onTap: () {
              //     //             print("CM3 Clicked");
              //     //             showDialog(
              //     //               context: context,
              //     //               builder: (_) => AlertDialog(
              //     //                 title: Text('CM3 '),
              //     //                 content: Text('This is a popup message'),
              //     //                 actions: [
              //     //                   TextButton(
              //     //                     onPressed: () => Navigator.pop(context),
              //     //                     child: Text('OK'),
              //     //                   )
              //     //                 ],
              //     //               ),
              //     //             );
              //     //           },
              //     //           child: MetricCardcm(title: "CM ₃", value: "00.0")),
              //     //     ),
              //     //   ],
              //     // ),
              //     const SizedBox(height: 10),
              //     if (!isLoading)
              //       TextButton(
              //         onPressed: () {
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => FinanceExecutiveScreen(),
              //             ),
              //           );
              //         },
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Text(
              //               'View full P&L',
              //               style: TextStyle(
              //                 fontWeight: FontWeight.bold,
              //                 color: AppColors.gold,
              //               ),
              //             ),
              //             const SizedBox(width: 8),
              //             Icon(Icons.arrow_forward, color: AppColors.gold),
              //           ],
              //         ),
              //       ),
              //     Divider(color: AppColors.gold, thickness: 0.5),
              //   ],
              // ),
            ],
          )),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                // Your second tab content here
                Center(child: Text("Second Tab Content")),
              ],
            ),
          ),
          ],
        ),
      );
    // );
  }
} //write complete steps for create bussines account in google play console for publish app in android play store briefly explainin  excel sheet and also use links because this sheet in shared with client and client is non tech so  explain proper understand and purchase accound what we need whats kinds or id name etc

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String compared;

  const MetricCard(
      {super.key,
      required this.title,
      required this.value,
      required this.compared});

  @override
  Widget build(BuildContext context) {
    print(compared);
    return Container(
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
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  compared.contains('Profit')
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 14,
                  color:
                      compared.contains('Profit') ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  compared.split(' ').first, // e.g., "219.93%"
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color:
                        compared.contains('Profit') ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MetricCardcm extends StatelessWidget {
  final String title;
  final String value;

  const MetricCardcm({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            // textAlign: TextAlign.left
          ),
        ],
      ),
    );
  }
}
