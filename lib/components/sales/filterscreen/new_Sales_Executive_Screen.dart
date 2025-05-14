import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

import '../../../comman_Screens/productcard.dart';
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
    "today",
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
  bool isLoading = true;

  String? errorMsg;
  String errorMessage = '';

  // @override
  // void initState() {
  //   super.initState();
  //   fetchDropdownData();
  // }
  @override
  void initState() {
    super.initState();
    selectedFilterType = '6months'; // Set default to "6months"
    fetchDropdownData();
    fetchFilteredData(); // Automatically fetch data for 6 months on screen load
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
      final stateRes = await http.get(Uri.parse('http://192.168.50.92:4000/api/state?q='));
      final cityRes = await http.get(Uri.parse('http://192.168.50.92:4000/api/city?q='));
      final skuRes = await http.get(Uri.parse('http://192.168.50.92:4000/api/sku'));

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

      url = 'http://192.168.50.92:4000/api/sales/resion?filterType=custom&fromDate=$from&toDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    } else {
      url =
      'http://192.168.50.92:4000/api/sales/resion?filterType=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';

    }
    //var request = http.Request('GET', url);
    var request = http.Request('GET', Uri.parse(url));

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        setState(() {
          salesData = json.decode(data);
          fetchAdData();
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
      'http://192.168.50.92:4000/api/data/filterData?range=custom&startDate=$from&endDate=$to&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
    } else {
      url =
      'http://192.168.50.92:4000/api/data/filterData?range=$selectedFilterType&sku=${selectedSku ?? ''}&city=${selectedCity ?? ''}&state=${selectedState ?? ''}';
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
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: "Select Filter Type",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1),
                        ),
                      ),
                      items: filterTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(formatFilterType(type),
                            overflow: TextOverflow.ellipsis,),
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

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage))
                  : Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(
                            child: MetricCard(
                              title: "Overall Sales", value: '\$${salesData!['totalSales'].toStringAsFixed(2)}', compared: "${salesData!['comparison']['salesChangePercent']}",)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MetricCard(
                            title: "Units Orders", value:"${salesData!['totalQuantity']}", compared: "${salesData!['comparison']['quantityChangePercent']}",),),

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
                          Expanded(
                            child: MetricCardcm(
                              title: "AOV",
                              //value: "",
                              value: (((salesData?['totalSales'] ?? 0.0) as num) / ((adssales?['totalOrders'] ?? 1) as num)).toStringAsFixed(2),



                              //  totalOrders
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MetricCardcm(
                              title: "Organic Sale",
                              value: ((salesData!['totalSales'] ?? 0.0) - (adssales!['totalAdSales'] ?? 0.0))
                                  .toStringAsFixed(2),
                              //value: salesData!['totalSales'] - adssales!['totalAdSales'],
                              //  value: ((double.tryParse(salesData!['totalSales'].toString()))-adssales!['totalAdSales']).toStringAsFixed(2),


                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCardcm(
                              title: "Adspend",
                              value: (adssales!['totalAdSpend']).toStringAsFixed(2),


                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MetricCardcm(
                              title: "Adsales",
                              value: (adssales!['totalAdSales']).toStringAsFixed(2),


                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCardcm(
                              title: "ACOS",
                              value: (adssales!['totalAdSpend'] / adssales!['totalAdSales']*100).toStringAsFixed(2) ?? "00",

                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MetricCardcm(
                              title: "TACOS",
                              value: (adssales!['totalAdSales'] / (double.tryParse(salesData!['totalSales'].toString()) ?? 1)*100).toStringAsFixed(2),

                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCardcm(
                              title: "OS %",
                              value: (((salesData!['totalSales'] ?? 0.0) - (adssales!['totalAdSales'] ?? 0.0))/(salesData!['totalSales'] ?? 0.0)*100).toStringAsFixed(2),

                              //  value: (adssales!['totalAdSpend'] / adssales!['totalAdSales']*100).toStringAsFixed(2) ?? "00",

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