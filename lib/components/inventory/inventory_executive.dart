// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/components/info_card.dart';
// import 'package:flutter_application_1/utils/api_service.dart';
// import 'package:flutter_application_1/utils/colors.dart';
// import 'package:flutter_application_1/utils/data_mapping_serive.dart';
// import 'package:flutter_application_1/utils/date_utils.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../barchart.dart';
//
// class InventoryExecutivePage extends StatefulWidget {
//   @override
//   _InventoryExecutivePageState createState() => _InventoryExecutivePageState();
// }
//
// class _InventoryExecutivePageState extends State<InventoryExecutivePage> {
//   int _selectedIndex = 0;
//   String _selectedUnits = "Total Orders";
//   String _selectedTime = "Last 12 months";
//   String _selectedChannel = "Amazon";
//   final List<double> chartData = [10, 20, 30, 15, 40, 10, 20, 23, 33]; // Example data
//   String _selectedRegion = "United States"; // Default region
//   String errorMessage = '';
//    List<dynamic> responseData = []; // Store API response
//    List<dynamic> totalResponseData = [];
//   bool isLoading = false;
//   bool isTotalValuesLoading = false;
//
//   Map<String, String> uiFields = {
//     "unitCount": "Storage Cost",
//     "orderItemCount": "LTSF Cost",
//     "orderCount": "Amazon Inventory",
//     "averageUnitPrice": "DOS",
//   };
//
//   List<Map<String, dynamic>> cardData = [];
//
//     String _fetchGranularity(String selectedTime) {
//   if (selectedTime == "Today" || selectedTime == "Yesterday") {
//     return "Day";
//   } else if (selectedTime == "Week") {
//     return "Week";
//   } else if (selectedTime == "Month") {
//     return "Month";
//   } else if (selectedTime == "Year") {
//     return "Year";
//   } else if (selectedTime == "Last Week" || selectedTime == "Last Month" || selectedTime == "This Month" || selectedTime == "Last 30 days") {
//     return "Day";
//   } else if (selectedTime == "Last Year" || selectedTime == "Last 6 months" || selectedTime == "Last 12 months") {
//     return "Month";
//   } else {
//     return "Day";
//   }
// }
//
//
//     void _fetchData(String dateRange) async {
//   setState(() {
//     isLoading = true;
//     isTotalValuesLoading = true;
//     errorMessage = "";
//   });
//
//   final totalValues = await ApiService.fetchAnalytics(
//     provider: "AMAZON",
//     models: "orders",
//     region: "IN",
//     dateRange: dateRange,
//     granularity: "Total",
//     timeParameter: _selectedTime
//   );
//
//
//   setState(() {
//     isTotalValuesLoading = false;
//     if (totalValues.containsKey("error")) {
//       errorMessage = totalValues["error"];
//     } else {
//       totalResponseData = totalValues['data']['getOrders'];
//       cardData = DataMapping.formatApiResponse(totalResponseData[0], uiFields, _selectedTime);
//     }
//   });
//   }
//
//    Widget _buildDropdown(String label, List<String> items, String selectedValue,
//       Function(String?) onChanged) {
//     return DropdownButton<String>(
//       value: selectedValue,
//       dropdownColor: AppColors.white,
//       borderRadius: BorderRadius.circular(10),
//       style: GoogleFonts.montserrat(
//                     color: AppColors.gold,
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold
//                   ),
//       items: items.map((item) {
//         return DropdownMenuItem<String>(
//           value: item,
//           child: Text(item),
//         );
//       }).toList(),
//       onChanged: onChanged,
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     String range = DateUtilsHelper.getDateRange(_selectedTime);
//     _fetchData(range);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // Padding(
//           //   padding: const EdgeInsets.all(8.0),
//           //   child: Row(
//           //     mainAxisAlignment: MainAxisAlignment.spaceAround,
//           //     children: [
//           //       _buildDropdown("Channel", ["Amazon", "eBay", "Shopify"], _selectedChannel, (newValue) {
//           //         setState(() {
//           //           _selectedChannel = newValue!;
//           //         });
//           //       }),
//           //      _buildDropdown(
//           //         "Select Time Range",
//           //         [
//           //           "Today",
//           //           "This week",
//           //           "Last 30 days",
//           //           "Last 6 months",
//           //           "Last 12 months",
//           //         ],
//           //         _selectedTime,
//           //         (newValue) {
//           //           setState(() {
//           //             _selectedTime = newValue!;
//           //             String range =
//           //                 DateUtilsHelper.getDateRange(_selectedTime);
//           //              _fetchData(range);
//           //           });
//           //         },
//           //       )
//           //
//           //     ],
//           //   ),
//           // ),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: 10),
//                         isTotalValuesLoading ? SizedBox(height: 10)
//                         :  SizedBox(
//                           child: GridView.builder(
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               crossAxisSpacing: 16,
//                               mainAxisSpacing: 16,
//                               childAspectRatio: 1.7,
//                             ),
//                             itemCount: cardData.length,
//                             itemBuilder: (context, index) {
//                               final card = cardData[index];
//                               return CommonCardComponent(
//                                 title: card["title"],
//                                 value: card["value"],
//                                 percentChange: card["percentChange"],
//                                 comparedTo: card["comparedTo"],
//                               );
//                             },
//                           ),
//                               ),
//
//               SizedBox(height: 10,),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () {},
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Color(0xff073349),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: Text("Inventory Details",style: TextStyle(color: Colors.white)),
//                               ),
//                             ),
//                             SizedBox(width: 16), // Space between buttons
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () {},
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Color(0xff073349),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: Text("Shipment Details",style: TextStyle(color: Colors.white),),
//                               ),
//                             ),
//                           ],
//                         ),
//
//
//                         Divider(color: AppColors.gold, thickness: 0.5),
//
//
//
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }






import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../utils/ApiConfig.dart';

class InventoryExecutivePage extends StatefulWidget {
  const InventoryExecutivePage({Key? key}) : super(key: key);

  @override
  State<InventoryExecutivePage> createState() => _InventoryExecutivePageState();
}

List<dynamic> inventoryList = [];
bool isLoading = true;
String error = '';
String Amazoninventorysum='00';
String LTSFsum='00';
String Storagecostsum='00';
String DOSsum='00';





class _InventoryExecutivePageState extends State<InventoryExecutivePage> {



  @override
  void initState() {
    super.initState();
    fetchExecutiveData();
  }

  Future<void> fetchExecutiveData() async {
    try {
      var dio = Dio();
      var response = await dio.get('${ApiConfig.baseUrl}/inventory');
      //var response = await dio.get(ApiConfig.ukInventory);

      if (response.statusCode == 200) {
        setState(() {
          inventoryList = response.data;
          int totalQuantity = getTotalFulfillableQuantity(inventoryList);
          print("Total afn_fulfillable_quantity: $totalQuantity");
          Amazoninventorysum=totalQuantity.toString();


          int totalsdtorageQuantity = getTotalDOSQuantity(inventoryList);
          print("Storage sum: $totalsdtorageQuantity");
         // DOSsum=totalsdtorageQuantity.toString();

          int LTSF = getTotalLISFCOST(inventoryList);
          print("LTSF sum: $LTSF");
          LTSFsum=LTSF.toString();

          // int StorageCost = getStorageCostQuantity(inventoryList);
          // print("Storage cost sum: $StorageCost");
          // Storagecostsum=StorageCost.toString();


          double storageCostSum = getStorageCostQuantityu(inventoryList);
          print("Total Storage Cost Sum: $storageCostSum");
          Storagecostsum=storageCostSum.toString();

          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error: ${response.statusMessage}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Exception: $e';
        isLoading = false;
      });
    }
  }

  int getTotalFulfillableQuantity(List<dynamic> inventoryList) {
    int total = 0;
    for (var item in inventoryList) {
      if (item['afn_fulfillable_quantity'] != null) {
        total += int.tryParse(item['afn_fulfillable_quantity'].toString()) ?? 0;

      }
    }
    return total;
  }

//   int getTotalDOSQuantity(List<dynamic> inventoryList) {
//     int total = 0;
//     int count = 0;
//
//     for (var item in inventoryList) {
//       if (item['days-of-supply'] != null) {
//         total += int.tryParse(item['days-of-supply'].toString()) ?? 0;
//         count++;
//       }
//     }
//
//     double average = count > 0 ? total / count : 0.0;
//     DOSsum = average.toStringAsFixed(3); // Shows 3 decimal places
//
// // Print total and average to the console
//     print('Total Days of Supply: $total');
//     print('Average Days of Supply: $DOSsum');
//
//     return total;
//   }


  int getTotalDOSQuantity(List<dynamic> inventoryList) {
    int total = 0;
    int count = 0;

    for (var item in inventoryList) {
      if (item['days_of_supply'] != null) {
        total += int.tryParse(item['days_of_supply'].toString()) ?? 0;
        count++;
      }
    }

    double average = count > 0 ? total / count : 0.0;
    int roundedAverage = average.round();
    DOSsum = roundedAverage.toString(); // Shows rounded integer

    // Print total and average to the console
    print('Total Days of Supply: $total');
    print('Rounded Average Days of Supply: $DOSsum');

    return total;
  }



  // int getTotalDOSQuantity(List<dynamic> inventoryList) {
  //   int total = 0;
  //   for (var item in inventoryList) {
  //     if (item['days-of-supply'] != null) {
  //       total += int.tryParse(item['days-of-supply'].toString()) ?? 0;
  //
  //     }
  //   }
  //   return total;
  // }

  int getTotalLISFCOST(List<dynamic> inventoryList) {
    int total = 0;
    for (var item in inventoryList) {
      if (item['estimated_storage_cost_next_month'] != null) {
        total += int.tryParse(item['estimated_storage_cost_next_month'].toString()) ?? 0;
      }
    }
    return total;
    //estimated-ais-301-330-days, estimated-ais-271-300-days, estimated-ais-241-270-days
  }

  int getStorageCostQuantity(List<dynamic> inventoryList) {
    int total = 0;
    for (var item in inventoryList) {
      if (item['quantity_to_be_charged_ais_301_330_days'] != null) {
        total += int.tryParse(item['quantity_to_be_charged_ais_301_330_days'].toString()) ?? 0;
      }
    }
    return total;
    //estimated-ais-301-330-days, estimated-ais-271-300-days, estimated-ais-241-270-days
  }


  double getStorageCostQuantityu(List<dynamic> inventoryList) {
    double total = 0.0;

    for (var item in inventoryList) {
      double day301to330 = double.tryParse(item['estimated_ais_241_270_days']?.toString() ?? '0') ?? 0.0;
      double day271to300 = double.tryParse(item['quantity_to_be_charged_ais_301_330_days']?.toString() ?? '0') ?? 0.0;
      double day241to270 = double.tryParse(item['estimated_ais_301_330_days']?.toString() ?? '0') ?? 0.0;

      double sumForItem = day301to330 + day271to300 + day241to270;

      total += sumForItem;

      // Debug print
      print("Item sum: $sumForItem (301–330: $day301to330, 271–300: $day271to300, 241–270: $day241to270)");
    }

    print("Total Storage Cost Quantityaaaaaaaaa: $total");

    return total;
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [


              Expanded(
                child: MetricCard(
                  title: 'Storage Cost',
                  value: "£ ${Storagecostsum}",
                  description: 'Estimated cost for next month',
                 // value: inventoryList[1].SKU,
                ),
              ),


              SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'LTSF Cost',
                  value: "£ ${LTSFsum}",
                  description: 'Storage cost for stock (more than 180 days)',
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Amazon Inventory',
                  value: Amazoninventorysum,
                  description: 'As of Today',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'DOS',
                  value: "${DOSsum} Days",
                  description: 'For all SKU Average basis',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String description; // New field

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.description, // Required param
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFFAEB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.brown.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

