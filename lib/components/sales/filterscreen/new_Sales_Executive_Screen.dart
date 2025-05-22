// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:intl/intl.dart';
//
// import '../../../comman_Screens/productcard.dart';
// import '../../../graph/commanbarchar_file.dart';
// import '../../../utils/ApiConfig.dart';
// import '../../../utils/colors.dart'; // Import the package
//
// class NewSalesExecutiveScreen extends StatefulWidget {
//   @override
//   State<NewSalesExecutiveScreen> createState() => _NewSalesExecutiveScreenState();
// }
//
// class _NewSalesExecutiveScreenState extends State<NewSalesExecutiveScreen> {
//   List<String> states = [];
//   List<String> cities = [];
//   List<String> skus = [];
//
//   // List<String> filterTypes = [
//   //   '6months',
//   //   "yeartodate",
//   //   "monthtodate",
//   //   "last30days",
//   //   "year",
//   //   "lastmonth",
//   //   "today",
//   //   "custom",
//   // ];
//
//
//
//   List<String> filterTypes = [
//     //"today",
//     "last30days",
//     "monthtodate",
//     '6months',
//     "yeartodate",
//     "custom",
//   ];
//
//   String? selectedState;
//   String? selectedCity;
//   String? selectedSku;
//   String? selectedFilterType;
//
//   DateTime? startDate;
//   DateTime? endDate;
//
//   //List<SalesSku> salesData = [];
//   // bool isLoading = false;
//   Map<String, dynamic>? salesData;
//   Map<String, dynamic>? adssales;
//   bool isLoading = true;
//
//   String? errorMsg;
//   String errorMessage = '';
//   List<double> values=[];
//   List<String> labels=[];
//   Map<String, double> monthlyTotals = {};
//
//
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   fetchDropdownData();
//   // }
//   @override
//   void initState() {
//     super.initState();
//     selectedFilterType = '6months'; // Set default to "6months"
//     fetchDropdownData();
//     fetchFilteredData(); // Automatically fetch data for 6 months on screen load
//   }
//
//
//   String formatFilterType(String filter) {
//     switch (filter) {
//       case 'today':
//         return 'Today';
//       case '6months':
//         return 'Last 6 Months';
//       case 'last30days':
//         return 'Last 30 Days';
//       case 'yeartodate':
//         return 'Year to Date';
//       case 'monthtodate':
//         return 'Month to Date';
//
//     // case 'year':
//     //   return 'This Year';
//     // case 'lastmonth':
//     //   return 'Last Month';
//       case 'custom':
//         return 'Custom Range';
//       default:
//         return filter;
//     }
//   }
//
//   Future<void> fetchDropdownData() async {
//     try {
//       final stateRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/state?q='));
//       final cityRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/city?q='));
//       final skuRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/sku'));
//
//       if (stateRes.statusCode == 200) states = List<String>.from(json.decode(stateRes.body));
//       if (cityRes.statusCode == 200) cities = List<String>.from(json.decode(cityRes.body));
//       if (skuRes.statusCode == 200) skus = List<String>.from(json.decode(skuRes.body));
//
//       setState(() {});
//     } catch (e) {
//       print('Error fetching dropdown data: $e');
//     }
//   }
//
//   String formatDate(DateTime date) =>
//       "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//
//   Future<void> fetchFilteredData() async {
//     if (selectedFilterType == null) return;
//     setState(() => isLoading = true);
//
//     String url = '';
//
//     if (selectedFilterType == 'custom') {
//       if (startDate == null || endDate == null) {
//         setState(() => isLoading = false);
//         return;
//       }
//
//       final from = formatDate(startDate!);
//       final to = formatDate(endDate!);
//
//       url = '${ApiConfig.baseUrl}/sales/resion?filterType=custom&fromDate=$from&toDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
//     } else {
//       url =
//       '${ApiConfig.baseUrl}/sales/resion?filterType=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
//
//     }
//     //var request = http.Request('GET', url);
//     var request = http.Request('GET', Uri.parse(url));
//
//     try {
//       http.StreamedResponse response = await request.send();
//
//       // if (response.statusCode == 200) {
//       //   final data = await response.stream.bytesToString();
//       //   setState(() {
//       //     salesData = json.decode(data);
//       //     print("Salesdata::::: ${salesData}");
//       //
//       //     // {totalQuantity: 13955, totalSales: 648487.5799999939, breakdown: [{date: December 2024, totalQuantity: 120, totalSales: 4762.249999999998}, {date: January 2025, totalQuantity: 3808, totalSales: 162701.46000000305}, {date: February 2025, totalQuantity: 2731, totalSales: 133437.4900000035}, {date: March 2025, totalQuantity: 3174, totalSales: 151182.1700000036}, {date: April 2025, totalQuantity: 3594, totalSales: 171572.9800000041}, {date: May 2025, totalQuantity: 528, totalSales: 24831.230000000054}], comparison: {previousTotalQuantity: 0, previousTotalSales: 0, quantityChangePercent: 100% Profit, salesChangePercent: 100% Profit}}
//       //
//       //     fetchAdData();
//       //     isLoading = false;
//       //   });
//       // }
//
//       if (response.statusCode == 200) {
//         final data = await response.stream.bytesToString();
//         setState(() {
//           salesData = json.decode(data);
//           print("Salesdata::::: ${salesData}");
//
//           final breakdown = salesData!['breakdown'];
//
//           // Extract totalSales and date
//           // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
//           // labels = breakdown.map<String>((item) => item['date'].toString()).toList();
//
//           print("filte typee :: ${selectedFilterType}");
//
//
//
//           if(selectedFilterType== "last30days")
//           {
//             print("last30days");
//             // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
//             // labels = breakdown.map<String>((item) => item['date'].toString()).toList();
//
//             values = breakdown
//                 .map<double>((item) => (item['totalSales'] as num).roundToDouble())
//                 .toList();
//
//             labels = breakdown
//                 .map<String>((item) {
//               final date = DateTime.parse(item['date']);
//               return '${date.month.toString().padLeft(1, '0')}-${date.day.toString().padLeft(1, '0')}';
//             })
//                 .toList();
//
//           }
//           if(selectedFilterType== "monthtodate")
//           {
//             print("monthtodate");
//             // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
//             // labels = breakdown.map<String>((item) => item['date'].toString()).toList();
//
//             values = breakdown
//                 .map<double>((item) => (item['totalSales'] as num).roundToDouble())
//                 .toList();
//
// // Format dates to MM-DD
//             labels = breakdown
//                 .map<String>((item) {
//               DateTime date = DateTime.parse(item['date']);
//               return "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//             })
//                 .toList();
//
//
//           }
//
//           if(selectedFilterType== "6months")
//           {
//             print("6666666 months");
//             // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
//             // labels = breakdown.map<String>((item) => item['date'].toString()).toList();
//
//
//
//             Map<String, double> monthlyTotals = {};
//
//             for (var item in breakdown) {
//               final fullDate = item['date'].toString(); // e.g., "January 2025"
//
//               DateTime? date;
//               try {
//                 // Use DateFormat to parse "January 2025"
//                 date = DateFormat('MMMM yyyy').parseStrict(fullDate);
//               } catch (e) {
//                 continue; // skip invalid date
//               }
//
//               final month = DateFormat('MMM').format(date); // "Jan"
//               final year = date.year.toString().substring(2); // "25"
//               final label = '$month $year'; // e.g., "Jan 25"
//
//               final sale = (item['totalSales'] as num).toInt().toDouble();
//               monthlyTotals[label] = (monthlyTotals[label] ?? 0) + sale;
//             }
//
// // Step 2: Convert to chart-friendly lists
//             labels = monthlyTotals.keys.toList();
//             values = monthlyTotals.values.toList();
//
//             print("6 month${labels}");
//             print("6 month${values}");
//
//           }
//
//           if(selectedFilterType== "yeartodate")
//           {
//             print("yeartodate");
//             // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
//             // labels = breakdown.map<String>((item) => item['date'].toString()).toList();
//
//             Map<String, double> monthlyTotals = {};
//
// // Summing totalSales by month
//             for (var item in breakdown) {
//               DateTime date = DateTime.parse(item['date']);
//               String monthLabel = DateFormat('MMM').format(date); // e.g., Jan, Feb
//               double totalSales = (item['totalSales'] as num).toDouble();
//
//               if (monthlyTotals.containsKey(monthLabel)) {
//                 monthlyTotals[monthLabel] = monthlyTotals[monthLabel]! + totalSales;
//               } else {
//                 monthlyTotals[monthLabel] = totalSales;
//               }
//             }
//
// // Convert the map to separate lists for chart use
//             labels = monthlyTotals.keys.toList(); // ['Jan', 'Feb', ...]
//             values = monthlyTotals.values.map((val) => val.roundToDouble()).toList(); // Whole numbers
//
//
//           }
//           if(selectedFilterType== "custom")
//           {
//             print("custom");
//             Map<String, double> monthlyTotals = {};
//
//             for (var item in breakdown) {
//               final fullDate = item['date'].toString(); // e.g., "January 2025"
//
//               DateTime? date;
//               try {
//                 // Use DateFormat to parse "January 2025"
//                 date = DateFormat('MMMM yyyy').parseStrict(fullDate);
//               } catch (e) {
//                 continue; // skip invalid date
//               }
//
//               final month = DateFormat('MMM').format(date); // "Jan"
//               final year = date.year.toString().substring(2); // "25"
//               final label = '$month $year'; // e.g., "Jan 25"
//
//               final sale = (item['totalSales'] as num).toInt().toDouble();
//               monthlyTotals[label] = (monthlyTotals[label] ?? 0) + sale;
//             }
//
// // Step 2: Convert to chart-friendly lists
//             labels = monthlyTotals.keys.toList();
//             values = monthlyTotals.values.toList();
//           }
//
//           print("📊 values: $values");
//           print("📅 labels: $labels");
//
//           fetchAdData();
//           isLoading = false;
//         });
//       }
//
//       else {
//         setState(() {
//           errorMessage = response.reasonPhrase ?? "Failed to fetch data.";
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//     }
//
//     finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   Future<void> fetchAdData() async {
//     if (selectedFilterType == null) return;
//
//     setState(() => isLoading = true);
//
//     String url = '';
//
//     if (selectedFilterType == 'custom') {
//       if (startDate == null || endDate == null) {
//         setState(() => isLoading = false);
//         return;
//       }
//
//       final from = formatDate(startDate!);
//       final to = formatDate(endDate!);
//
//       url =
//       '${ApiConfig.baseUrl}/data/filterData?range=custom&startDate=$from&endDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
//     } else {
//       url =
//       '${ApiConfig.baseUrl}/data/filterData?range=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
//     }
//
//     var request = http.Request('GET', Uri.parse(url));
//
//     try {
//       http.StreamedResponse response = await request.send();
//
//       if (response.statusCode == 200) {
//         final data = await response.stream.bytesToString();
//         final jsonResponse = jsonDecode(data);
//
//         setState(() {
//           adssales = jsonResponse; // Entire JSON stored
//           // totalAdSales = double.parse((jsonResponse['totalAdSales'] ?? 0.0).toString()).toStringAsFixed(2);
//           // totalAdSpend = double.parse((jsonResponse['totalAdSpend'] ?? 0.0).toString()).toStringAsFixed(2);
//           print("console:::   ${adssales}");
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMsg = response.reasonPhrase ?? 'Failed to load data';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMsg = '❌ Error: $e';
//         isLoading = false;
//       });
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   void onDropdownChanged(String? value, String type) {
//     setState(() {
//       if (type == 'filter') {
//         selectedFilterType = value;
//         if (value != 'custom') {
//           fetchFilteredData();
//           fetchAdData();
//         }
//       } else if (type == 'state') {
//         selectedState = value;
//         fetchFilteredData();
//       } else if (type == 'city') {
//         selectedCity = value;
//         fetchFilteredData();
//       } else if (type == 'sku') {
//         selectedSku = value;
//         fetchFilteredData();
//       }
//     });
//   }
//
//   Future<void> selectDateRange(BuildContext context) async {
//     final now = DateTime.now();
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(now.year - 2),
//       lastDate: now,
//     );
//
//     if (picked != null) {
//       setState(() {
//         startDate = picked.start;
//         endDate = picked.end;
//       });
//       fetchFilteredData();
//       fetchAdData();
//     }
//   }
//
//
//
//
//   // final List<double> values = [10, 15, 30, 12, 43, 50, 27, 20];
//   // final List<String> labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Next'];
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: const Text("Sales Data Viewer")),
//       body: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: ListView(
//           children: [
//
//             SingleChildScrollView(
//               //  scrollDirection: Axis.horizontal,
//               child: Row(
//                 // crossAxisAlignment: CrossAxisAlignment.end,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//
//                   SizedBox(
//                     width: 190,
//                     height: 40, // Fixed height
//                     child: DropdownButtonFormField<String>(
//                       isDense: true, // Makes dropdown compact
//                       style: TextStyle(fontSize: 12, color: Colors.black), // Smaller font
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Tight padding
//                         hintText: "Select Filter Type",
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.blue, width: 1),
//                         ),
//                       ),
//                       items: filterTypes.map((type) {
//                         return DropdownMenuItem(
//                           value: type,
//                           child: Text(
//                             formatFilterType(type),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                             style: TextStyle(fontSize: 12, color: Colors.black),
//                           ),
//                         );
//                       }).toList(),
//                       value: selectedFilterType,
//                       onChanged: (val) => onDropdownChanged(val, 'filter'),
//                     ),
//                   ),
//
//
//                   if (selectedFilterType == 'custom')
//                     Padding(
//                       padding: const EdgeInsets.only(left: 8.0),
//                       child: ElevatedButton.icon(
//                         onPressed: () => selectDateRange(context),
//                         icon: Icon(Icons.date_range),
//                         label: Text(
//                           startDate != null && endDate != null
//                               ? "${formatDate(startDate!)} - ${formatDate(endDate!)}"
//                               : "Select Date Range",
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ),
//
//                   /*     SizedBox(width: 8), // optional spacing
//                   SizedBox(
//                     width: 150,
//                     child: DropdownSearch<String>(
//                       items: states,
//                       selectedItem: selectedState,
//                       popupProps: PopupProps.menu(
//                         showSearchBox: true,
//                         searchFieldProps: TextFieldProps(
//                           decoration: InputDecoration(
//                             hintText: "Search State",
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       dropdownDecoratorProps: DropDownDecoratorProps(
//                         dropdownSearchDecoration: InputDecoration(
//                           labelText: "State",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       onChanged: (val) => onDropdownChanged(val, 'state'),
//                     ),
//                   ),
//
//                   SizedBox(width: 8),
//                   SizedBox(
//                     width: 150,
//                     child: DropdownSearch<String>(
//                       items: cities,
//                       selectedItem: selectedCity,
//                       popupProps: PopupProps.menu(
//                         showSearchBox: true,
//                         searchFieldProps: TextFieldProps(
//                           decoration: InputDecoration(
//                             hintText: "Search City",
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       dropdownDecoratorProps: DropDownDecoratorProps(
//                         dropdownSearchDecoration: InputDecoration(
//                           labelText: "City",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       onChanged: (val) => onDropdownChanged(val, 'city'),
//                     ),
//                   ),
//
//                   SizedBox(width: 8),
//                   SizedBox(
//                     width: 150,
//                     child: DropdownSearch<String>(
//                       items: skus,
//                       selectedItem: selectedSku,
//                       popupProps: PopupProps.menu(
//                         showSearchBox: true,
//                         searchFieldProps: TextFieldProps(
//                           decoration: InputDecoration(
//                             hintText: "Search SKU",
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       dropdownDecoratorProps: DropDownDecoratorProps(
//                         dropdownSearchDecoration: InputDecoration(
//                           labelText: "SKU",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       onChanged: (val) => onDropdownChanged(val, 'sku'),
//                     ),
//                   ),*/
//
//                 ],
//               ),
//             ),
//
//
//
//             const SizedBox(height: 20),
//             BarChartSample(values: values, labels: labels,isWeb: true,),
//
//             Expanded(
//               child: SingleChildScrollView(
//                 child: isLoading
//                     ? Center(child: CircularProgressIndicator())
//                     : errorMessage.isNotEmpty
//                     ? Center(child: Text(errorMessage))
//                     : Padding(
//                   padding: const EdgeInsets.all(1.0),
//                   child: Column(
//                     children: [
//                       Row(children: [
//                         Expanded(
//                             child: MetricCard(
//                               title: "Overall Sales",
//                               value: '£ ${NumberFormat('#,###').format((salesData?['totalSales'] ?? 0).round())}',
//                               compared: "${salesData?['comparison']['salesChangePercent']}",)),
//                         // title: "Overall Sales", value: '£ ${salesData?['totalSales'].toStringAsFixed(2)}', compared: "${salesData?['comparison']['salesChangePercent']}",)),
//                         SizedBox(width: 8),
//                         Expanded(
//                           child: MetricCard(
//                             title: "Units Orders",
//                             value: "${NumberFormat('#,###').format((salesData?['totalQuantity'] ?? 0).round())}",
//                             compared: "${salesData?['comparison']['quantityChangePercent']}",
//                             //value:"${salesData?['totalQuantity']}", compared: "${salesData?['comparison']['quantityChangePercent']}",
//                           ),),
//
//                       ],),
//                       SizedBox(height: 8,),
//                       // Row(children: [
//                       //   Expanded(
//                       //       child: MetricCard(
//                       //         title: "Organic Sales", value: '\$${salesData!['totalSales'].toStringAsFixed(2)}', compared: "${salesData!['comparison']['salesChangePercent']}",)),
//                       //   const SizedBox(width: 8),
//                       //   Expanded(
//                       //     child: MetricCard(
//                       //       title: "Units Orders", value:"${salesData!['totalQuantity']}", compared: "${salesData!['comparison']['quantityChangePercent']}",),),
//                       //
//                       // ],),
//
//
//                       SizedBox(height: 10,),
//                       Row(
//                         children: [
//
//                           if(selectedFilterType!= "last30days")
//                             Expanded(
//                               child: MetricCardcm(
//                                 title: "AOV",
//                                 //value: "",
//                                 value: "£ ${NumberFormat('#,###').format(
//                                     (((salesData?['totalSales'] ?? 0.0) as num) /
//                                         ((adssales?['totalOrders'] ?? 1) as num)).toInt()
//                                 )}",
//                                 //value: "£ ${(((salesData?['totalSales'] ?? 0.0) as num) / ((adssales?['totalOrders'] ?? 1) as num)).toStringAsFixed(0)}",
//                                 //  totalOrders
//                               ),
//                             ),
//                           if(selectedFilterType== "last30days")
//                             Expanded(
//                               child: MetricCardcm(
//                                 title: "AOV",
//                                 //value: "",
//                                 value: "£ 00",
//                                 //  totalOrders
//                               ),
//                             ),
//                           const SizedBox(width: 8),
//                           if(selectedFilterType!= "last30days")
//
//                             Expanded(
//                             child: MetricCardcm(
//                               title: "Organic Sale",
//                               value: "£ ${NumberFormat('#,###').format(
//                                   ((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).round()
//                               )}",
//                               //value: "£ ${((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).toStringAsFixed(0)}",
//
//                             ),
//                           ),
//
//                           if(selectedFilterType== "last30days")
//                           Expanded(
//                             child: MetricCardcm(
//                               title: "Organic Sale",
//                          value: "£ 00",
//                               //value: "£ ${((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).toStringAsFixed(0)}",
//
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10,),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: MetricCardcm(
//                               title: "Ad Spend",
//                               value: "£ ${NumberFormat('#,###').format(
//                                   (adssales?['totalAdSpend'] ?? 0).toDouble().round()
//                               )}",
//                               // value: "£ ${((adssales?['totalAdSpend'] ?? 0).toDouble()).toStringAsFixed(0)}",
//
//
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: MetricCardcm(
//                               title: "Ad Sales",
//                               value: "£ ${NumberFormat('#,###').format(
//                                   (adssales?['totalAdSales'] ?? 0).toDouble().round()
//                               )}",
//                               //value: "£ ${((adssales?['totalAdSales'] ?? 0).toDouble()).toStringAsFixed(0)}",
//
//
//
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10,),
//                       Row(
//                         children: [
//                           if(selectedFilterType!= "last30days")
//                             Expanded(
//                               child: MetricCardcm(
//                                 title: "ACOS",
//                                 value: "${(((adssales?['totalAdSpend'] ?? 0) / (adssales?['totalAdSales'] ?? 1)) * 100).toStringAsFixed(2)} %",
//
//                               ),
//                             ),
//                           if(selectedFilterType== "last30days")
//                             Expanded(
//                               child: MetricCardcm(
//                                 title: "ACOS",
//                                 value: "0.00 %",
//
//                               ),
//                             ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: MetricCardcm(
//                               title: "TACOS",
//                               value: "${((adssales?['totalAdSales'] ?? 0) / (salesData?['totalSales'] ?? 1) * 100).toStringAsFixed(2)} %",
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8,),
//                       Row(
//                         children: [
//                           if(selectedFilterType!= "last30days")
//                             Expanded(
//                               child: MetricCardcm(
//                                 title: "Organic Sale",
//                                 value: "${(((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0))/(salesData?['totalSales'] ?? 0.0)*100).toStringAsFixed(2)} %",
//                               ),
//                             ),
//
//                           if(selectedFilterType== "last30days")
//                             Expanded(
//                               child: MetricCardcm(
//                                 title: "Organic Sale",
//                                 value: "0.00 %",
//                               ),
//                             ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: MetricCardcm(
//                               title: "",//DOS
//                               value: "",
//                               // value: (adssales!['totalAdSales'] / (double.tryParse(salesData!['totalSales'].toString()) ?? 1)*100).toStringAsFixed(2),
//
//                             ),
//                           ),
//                         ],
//                       ),
//
//                     ],
//                   ),
//
//                   // ListView(
//                   //   children: [
//                   //     Text("Total Quantity: ${salesData!['totalQuantity']}", style: TextStyle(fontSize: 18)),
//                   //     Text("Total Sales: \$${salesData!['totalSales'].toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
//                   //     SizedBox(height: 20),
//                   //     Text("Monthly Breakdown:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   //     ...List.generate(salesData!['breakdown'].length, (index) {
//                   //       final item = salesData!['breakdown'][index];
//                   //       return ListTile(
//                   //         title: Text("${item['date']}"),
//                   //         subtitle: Text("Quantity: ${item['totalQuantity']} - Sales: \$${item['totalSales'].toStringAsFixed(2)}"),
//                   //       );
//                   //     }),
//                   //     SizedBox(height: 20),
//                   //     Text("Comparison:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   //     Text("Previous Quantity: ${salesData!['comparison']['previousTotalQuantity']}"),
//                   //     Text("Previous Sales: \$${salesData!['comparison']['previousTotalSales'].toStringAsFixed(2)}"),
//                   //     Text("Quantity Change: ${salesData!['comparison']['quantityChangePercent']}"),
//                   //     Text("Sales Change: ${salesData!['comparison']['salesChangePercent']}"),
//                   //   ],
//                   // ),
//                 ),
//               ),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MetricCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final String compared;
//
//   const MetricCard({super.key, required this.title, required this.value,required this.compared});
//
//   @override
//   Widget build(BuildContext context) {
//     print(compared);
//     return
//       Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: AppColors.beige,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: const TextStyle(fontSize: 16),
//               // textAlign: TextAlign.left
//             ),
//
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//
//                 Text(
//                   value,
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
//                   ), ),
//
//
//               ],
//             ),
//
//
//             Align(
//               alignment: Alignment.centerRight,
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     compared.contains('Profit')
//                         ? Icons.arrow_upward
//                         : Icons.arrow_downward,
//                     size: 14,
//                     color: compared.contains('Profit')
//                         ? Colors.green
//                         : Colors.red,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     compared.split(' ').first, // e.g., "219.93%"
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.normal,
//                       color: compared.contains('Profit')
//                           ? Colors.green
//                           : Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//
//
//
//           ],
//         ),
//       );
//   }
//
//
// }
//
//
// class MetricCardcm extends StatelessWidget {
//   final String title;
//   final String value;
//
//   const MetricCardcm({super.key, required this.title, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     return
//       Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: AppColors.beige,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: const TextStyle(fontSize: 16),
//               // textAlign: TextAlign.left
//             ),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
//               ),
//               // textAlign: TextAlign.left
//             ),
//           ],
//         ),
//       );
//   }
//
//
// }




import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';

import '../../../comman_Screens/productcard.dart';
import '../../../graph/commanbarchar_file.dart';
import '../../../utils/ApiConfig.dart';
import '../../../utils/colors.dart'; // Import the package

class NewSalesExecutiveScreen extends StatefulWidget {
  @override
  State<NewSalesExecutiveScreen> createState() => _NewSalesExecutiveScreenState();
}

class _NewSalesExecutiveScreenState extends State<NewSalesExecutiveScreen> {
  List<String> states = [];
  List<String> cities = [];
  List<String> skus = [];

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
     //"today",
    //"last30days",
    "lastmonth",
    "monthtodate",
    //'6months',
    //"yeartodate",
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
  bool isLoading = true;

  String? errorMsg;
  String errorMessage = '';
  List<double> values=[];
  List<String> labels=[];
  Map<String, double> monthlyTotals = {};


  // @override
  // void initState() {
  //   super.initState();
  //   fetchDropdownData();
  // }
  @override
  void initState() {
    super.initState();
    selectedFilterType = 'lastmonth'; // Set default to "6months"
    fetchDropdownData();
    fetchFilteredData(); // Automatically fetch data for 6 months on screen load
  }


  String formatFilterType(String filter) {
    switch (filter) {
      case 'today':
        return 'Today';
        case 'lastmonth':
        return 'Last Months';
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
      final stateRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/state?q='));
      final cityRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/city?q='));
      final skuRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/sku'));

      if (stateRes.statusCode == 200) states = List<String>.from(json.decode(stateRes.body));
      if (cityRes.statusCode == 200) cities = List<String>.from(json.decode(cityRes.body));
      if (skuRes.statusCode == 200) skus = List<String>.from(json.decode(skuRes.body));

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

      url = '${ApiConfig.baseUrl}/sales/resion?filterType=custom&fromDate=$from&toDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    } else {
      url =
      '${ApiConfig.baseUrl}/sales/resion?filterType=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';

    }
    //var request = http.Request('GET', url);
    var request = http.Request('GET', Uri.parse(url));

    try {
      http.StreamedResponse response = await request.send();

      // if (response.statusCode == 200) {
      //   final data = await response.stream.bytesToString();
      //   setState(() {
      //     salesData = json.decode(data);
      //     print("Salesdata::::: ${salesData}");
      //
      //     // {totalQuantity: 13955, totalSales: 648487.5799999939, breakdown: [{date: December 2024, totalQuantity: 120, totalSales: 4762.249999999998}, {date: January 2025, totalQuantity: 3808, totalSales: 162701.46000000305}, {date: February 2025, totalQuantity: 2731, totalSales: 133437.4900000035}, {date: March 2025, totalQuantity: 3174, totalSales: 151182.1700000036}, {date: April 2025, totalQuantity: 3594, totalSales: 171572.9800000041}, {date: May 2025, totalQuantity: 528, totalSales: 24831.230000000054}], comparison: {previousTotalQuantity: 0, previousTotalSales: 0, quantityChangePercent: 100% Profit, salesChangePercent: 100% Profit}}
      //
      //     fetchAdData();
      //     isLoading = false;
      //   });
      // }

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        setState(() {
          salesData = json.decode(data);
          print("Salesdata::::: ${salesData}");

          final breakdown = salesData!['breakdown'];

          // Extract totalSales and date
          // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
          // labels = breakdown.map<String>((item) => item['date'].toString()).toList();

          print("filte typee :: ${selectedFilterType}");




          if(selectedFilterType== "lastmonth")
          {
            print("lastmonth");
            values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
            labels = breakdown.map<String>((item) => item['date'].toString()).toList();


          }

          // if(selectedFilterType== "last30days")
          // {
          //   print("last30days");
          //   // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
          //   // labels = breakdown.map<String>((item) => item['date'].toString()).toList();
          //
          //   values = breakdown
          //       .map<double>((item) => (item['totalSales'] as num).roundToDouble())
          //       .toList();
          //
          //   labels = breakdown
          //       .map<String>((item) {
          //     final date = DateTime.parse(item['date']);
          //     return '${date.month.toString().padLeft(1, '0')}-${date.day.toString().padLeft(1, '0')}';
          //   })
          //       .toList();
          //
          // }
          if(selectedFilterType== "monthtodate")
          {
            print("monthtodate");
            // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
            // labels = breakdown.map<String>((item) => item['date'].toString()).toList();

            values = breakdown
                .map<double>((item) => (item['totalSales'] as num).roundToDouble())
                .toList();

// Format dates to MM-DD
            labels = breakdown
                .map<String>((item) {
              DateTime date = DateTime.parse(item['date']);
              return "${date.day.toString().padLeft(1, '0')}";
             // return "${date.month.toString().padLeft(1, '0')}-${date.day.toString().padLeft(1, '0')}";
            })
                .toList();



          }

          if(selectedFilterType== "6months")
          {
            print("6666666 months");
            // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
            // labels = breakdown.map<String>((item) => item['date'].toString()).toList();



            Map<String, double> monthlyTotals = {};

            for (var item in breakdown) {
              final fullDate = item['date'].toString(); // e.g., "January 2025"

              DateTime? date;
              try {
                // Use DateFormat to parse "January 2025"
                date = DateFormat('MMMM yyyy').parseStrict(fullDate);
              } catch (e) {
                continue; // skip invalid date
              }

              final month = DateFormat('MMM').format(date); // "Jan"
              final year = date.year.toString().substring(2); // "25"
              final label = '$month $year'; // e.g., "Jan 25"

              final sale = (item['totalSales'] as num).toInt().toDouble();
              monthlyTotals[label] = (monthlyTotals[label] ?? 0) + sale;
            }

// Step 2: Convert to chart-friendly lists
            labels = monthlyTotals.keys.toList();
            values = monthlyTotals.values.toList();

            print("6 month${labels}");
            print("6 month${values}");

          }

          if(selectedFilterType== "yeartodate")
          {
            print("yeartodate");
            // values = breakdown.map<double>((item) => (item['totalSales'] as num).toDouble()).toList();
            // labels = breakdown.map<String>((item) => item['date'].toString()).toList();

            Map<String, double> monthlyTotals = {};

// Summing totalSales by month
            for (var item in breakdown) {
              DateTime date = DateTime.parse(item['date']);
              String monthLabel = DateFormat('MMM').format(date); // e.g., Jan, Feb
              double totalSales = (item['totalSales'] as num).toDouble();

              if (monthlyTotals.containsKey(monthLabel)) {
                monthlyTotals[monthLabel] = monthlyTotals[monthLabel]! + totalSales;
              } else {
                monthlyTotals[monthLabel] = totalSales;
              }
            }

// Convert the map to separate lists for chart use
            labels = monthlyTotals.keys.toList(); // ['Jan', 'Feb', ...]
            values = monthlyTotals.values.map((val) => val.roundToDouble()).toList(); // Whole numbers


          }
          if(selectedFilterType== "custom")
          {
            print("custom");
            Map<String, double> monthlyTotals = {};

            for (var item in breakdown) {
              final fullDate = item['date'].toString(); // e.g., "January 2025"

              DateTime? date;
              try {
                // Use DateFormat to parse "January 2025"
                date = DateFormat('MMMM yyyy').parseStrict(fullDate);
              } catch (e) {
                continue; // skip invalid date
              }

              final month = DateFormat('MMM').format(date); // "Jan"
              final year = date.year.toString().substring(2); // "25"
              final label = '$month $year'; // e.g., "Jan 25"

              final sale = (item['totalSales'] as num).toInt().toDouble();
              monthlyTotals[label] = (monthlyTotals[label] ?? 0) + sale;
            }

// Step 2: Convert to chart-friendly lists
            labels = monthlyTotals.keys.toList();
            values = monthlyTotals.values.toList();
          }

          print("📊 values: $values");
          print("📅 labels: $labels");

          fetchAdData();
          isLoading = false;
        });
      }

      else {
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
    }

    finally {
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




  // final List<double> values = [10, 15, 30, 12, 43, 50, 27, 20];
  // final List<String> labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Next'];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Sales Data Viewer")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [

            SingleChildScrollView(
              //  scrollDirection: Axis.horizontal,
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  SizedBox(
                    width: 190,
                    height: 40, // Fixed height
                    child: DropdownButtonFormField<String>(
                      isDense: true, // Makes dropdown compact
                      style: TextStyle(fontSize: 12, color: Colors.black), // Smaller font
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Tight padding
                        hintText: "Select Filter Type",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1),
                        ),
                      ),
                      items: filterTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            formatFilterType(type),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(fontSize: 12, color: Colors.black),
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

                  /*     SizedBox(width: 8), // optional spacing
                  SizedBox(
                    width: 150,
                    child: DropdownSearch<String>(
                      items: states,
                      selectedItem: selectedState,
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Search State",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "State",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      onChanged: (val) => onDropdownChanged(val, 'state'),
                    ),
                  ),

                  SizedBox(width: 8),
                  SizedBox(
                    width: 150,
                    child: DropdownSearch<String>(
                      items: cities,
                      selectedItem: selectedCity,
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Search City",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "City",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      onChanged: (val) => onDropdownChanged(val, 'city'),
                    ),
                  ),

                  SizedBox(width: 8),
                  SizedBox(
                    width: 150,
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
                      onChanged: (val) => onDropdownChanged(val, 'sku'),
                    ),
                  ),*/

                ],
              ),
            ),



            const SizedBox(height: 20),
            BarChartSample(values: values, labels: labels),

            Expanded(
              child:
              SingleChildScrollView(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : Padding(
                  padding: const EdgeInsets.all(1.0),
                  child:



                  Column(
                    children: [
                      Row(children: [
                        Expanded(
                            child: MetricCard(
                              title: "Overall Sales",
                              value: '£ ${NumberFormat('#,###').format((salesData?['totalSales'] ?? "0").round())}',
                              compared: "${salesData?['comparison']['salesChangePercent']??"0"}",)
                        ),
                        // title: "Overall Sales", value: '£ ${salesData?['totalSales'].toStringAsFixed(2)}', compared: "${salesData?['comparison']['salesChangePercent']}",)),
                        SizedBox(width: 8),
                        Expanded(
                          child: MetricCard(
                            title: "Units Orders",
                            value: "${NumberFormat('#,###').format((salesData?['totalQuantity'] ?? 0).round())}",
                            compared: "${salesData?['comparison']['quantityChangePercent']}",
                            //value:"${salesData?['totalQuantity']}", compared: "${salesData?['comparison']['quantityChangePercent']}",
                          ),),

                      ],),
                      SizedBox(height: 8,),
                      // Row(children: [
                      //   Expanded(
                      //       child: MetricCard(
                      //         title: "Organic Sales", value: '\$${salesData!['totalSales'].toStringAsFixed(2)}', compared: "${salesData!['comparison']['salesChangePercent']}",)),
                      //   const SizedBox(width: 8),
                      //   Expanded(
                      //     child: MetricCard(
                      //       title: "Units Orders", value:"${salesData!['totalQuantity']}", compared: "${salesData!['comparison']['quantityChangePercent']}",),),
                      //
                      // ],),


                      SizedBox(height: 10,),
                      Row(
                        children: [

                          if(selectedFilterType!= "last30days")
                            Expanded(
                              child: MetricCardcm(
                                title: "AOV",
                                //value: "",
                                value: "£ ${NumberFormat('#,###').format(
                                    (((salesData?['totalSales'] ?? 0.0) as num) /
                                        ((adssales?['totalOrders'] ?? 1) as num)).toInt()
                                )}",
                                //value: "£ ${(((salesData?['totalSales'] ?? 0.0) as num) / ((adssales?['totalOrders'] ?? 1) as num)).toStringAsFixed(0)}",
                                //  totalOrders
                              ),
                            ),
                          if(selectedFilterType== "last30days")
                            Expanded(
                              child: MetricCardcm(
                                title: "AOV",
                                //value: "",
                                value: "£ 00",
                                //  totalOrders
                              ),
                            ),
                          const SizedBox(width: 8),
                          if(selectedFilterType!= "last30days")

                            Expanded(
                              child: MetricCardcm(
                                title: "Organic Sale",
                                value: "£ ${NumberFormat('#,###').format(
                                    ((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).round()
                                )}",
                                //value: "£ ${((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).toStringAsFixed(0)}",

                              ),
                            ),

                          if(selectedFilterType== "last30days")
                            Expanded(
                              child: MetricCardcm(
                                title: "Organic Sale",
                                value: "£ 00",
                                //value: "£ ${((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0)).toStringAsFixed(0)}",

                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCardcm(
                              title: "Ad Spend",
                              value: "£ ${NumberFormat('#,###').format(
                                  (adssales?['totalAdSpend'] ?? 0).toDouble().round()
                              )}",
                              // value: "£ ${((adssales?['totalAdSpend'] ?? 0).toDouble()).toStringAsFixed(0)}",


                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MetricCardcm(
                              title: "Ad Sales",
                              value: "£ ${NumberFormat('#,###').format(
                                  (adssales?['totalAdSales'] ?? 0).toDouble().round()
                              )}",
                              //value: "£ ${((adssales?['totalAdSales'] ?? 0).toDouble()).toStringAsFixed(0)}",



                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          if(selectedFilterType!= "last30days")
                            Expanded(
                              child: MetricCardcm(
                                title: "ACOS",
                                value: "${(((adssales?['totalAdSpend'] ?? 0) / (adssales?['totalAdSales'] ?? 1)) * 100).toStringAsFixed(2)} %",

                              ),
                            ),
                          if(selectedFilterType== "last30days")
                            Expanded(
                              child: MetricCardcm(
                                title: "ACOS",
                                value: "0.00 %",

                              ),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MetricCardcm(
                              title: "TACOS",
                              value: "${((adssales?['totalAdSales'] ?? 0) / (salesData?['totalSales'] ?? 1) * 100).toStringAsFixed(2)} %",
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Row(
                        children: [
                          if(selectedFilterType!= "last30days")
                            Expanded(
                              child: MetricCardcm(
                                title: "Organic Sale",
                                value: "${(((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0))/(salesData?['totalSales'] ?? 0.0)*100).toStringAsFixed(2)} %",
                              ),
                            ),

                          if(selectedFilterType== "last30days")
                            Expanded(
                              child: MetricCardcm(
                                title: "Organic Sale",
                                value: "0.00 %",
                              ),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MetricCardcm(
                              title: "",//DOS
                              value: "",
                              // value: (adssales!['totalAdSales'] / (double.tryParse(salesData!['totalSales'].toString()) ?? 1)*100).toStringAsFixed(2),

                            ),
                          ),
                        ],
                      ),

                    ],
                  ),



                  // ListView(
                  //   children: [
                  //     Text("Total Quantity: ${salesData!['totalQuantity']}", style: TextStyle(fontSize: 18)),
                  //     Text("Total Sales: \$${salesData!['totalSales'].toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
                  //     SizedBox(height: 20),
                  //     Text("Monthly Breakdown:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  //     ...List.generate(salesData!['breakdown'].length, (index) {
                  //       final item = salesData!['breakdown'][index];
                  //       return ListTile(
                  //         title: Text("${item['date']}"),
                  //         subtitle: Text("Quantity: ${item['totalQuantity']} - Sales: \$${item['totalSales'].toStringAsFixed(2)}"),
                  //       );
                  //     }),
                  //     SizedBox(height: 20),
                  //     Text("Comparison:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  //     Text("Previous Quantity: ${salesData!['comparison']['previousTotalQuantity']}"),
                  //     Text("Previous Sales: \$${salesData!['comparison']['previousTotalSales'].toStringAsFixed(2)}"),
                  //     Text("Quantity Change: ${salesData!['comparison']['quantityChangePercent']}"),
                  //     Text("Sales Change: ${salesData!['comparison']['salesChangePercent']}"),
                  //   ],
                  // ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String compared;

  const MetricCard({super.key, required this.title, required this.value,required this.compared});

  @override
  Widget build(BuildContext context) {
    print(compared);
    return
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.beige,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16),
              // textAlign: TextAlign.left
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                  ), ),


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
                    color: compared.contains('Profit')
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    compared.split(' ').first, // e.g., "219.93%"
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: compared.contains('Profit')
                          ? Colors.green
                          : Colors.red,
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
    return
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.beige,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16),
              // textAlign: TextAlign.left
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
              ),
              // textAlign: TextAlign.left
            ),
          ],
        ),
      );
  }


}