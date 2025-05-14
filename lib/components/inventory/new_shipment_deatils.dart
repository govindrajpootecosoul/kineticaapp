import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../utils/ApiConfig.dart';
import '../../utils/colors.dart';

class New_shipment_details extends StatefulWidget {
  const New_shipment_details({super.key});

  @override
  State<New_shipment_details> createState() => _New_shipment_detailsState();
}

class _New_shipment_detailsState extends State<New_shipment_details> {
  List<String> _selectedItems = [
    "Current Inventory",
    "Current DOS",
    "Shipment Quantity",
    "Shipment Date"
  ];

  final List<String> _options = [
    "Current Inventory",
    "Current DOS",
    "Shipment Quantity",
    "Shipment Date",
    "Customer Reserved",
    "FC Transfer",
    "FC Processing",
    "Unfulfilled",
    "Inbound Recieving"
  ];

  final Map<String, String> fieldMapping = {
    "Warehouse Inventory": "afn-warehouse-quantity",
    "Total Sellable": "afn-fulfillable-quantity",
    "Inventory Age": "afn-inventory-age-0-to-30-days",
    "DOS": "afn-inbound-receiving-quantity",
    "Customer Reserved": "Customer_reserved",
    "FC Transfer": "afn-fc-transfer",
    "FC Processing": "afn-fc-processing",
    "Unfulfilled": "afn-unfulfillable-quantity",
    "Inbound Recieving": "afn-inbound-receiving-quantity",
  };

  List<dynamic> inventoryList = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchInventoryData();
  }

  Future<void> fetchInventoryData() async {
    try {
      var dio = Dio();
      // var response = await dio.get('http://192.168.50.92:2000/api/data');
      var response = await dio.get(ApiConfig.ukInventory);

      if (response.statusCode == 200) {
        setState(() {
          inventoryList = response.data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //const Text("Inventory Details"),
              // GestureDetector(
              //   onTap: () async {
              //     final List<String>? selectedValues = await showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return MultiSelectDialog(
              //           options: _options,
              //           selectedValues: _selectedItems,
              //         );
              //       },
              //     );
              //     if (selectedValues != null) {
              //       setState(() {
              //         _selectedItems = selectedValues;



              //       });
              //     }
              //   },
              //   child: Container(
              //     padding:
              //     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(8),
              //       color: Colors.white24,
              //     ),
              //     child: const Row(
              //       children: [
              //         Text(
              //           "Filter",
              //           style: TextStyle(
              //               fontSize: 18, fontWeight: FontWeight.bold),
              //         ),
              //         Icon(Icons.arrow_drop_down, color: Colors.black),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : ListView.builder(
        itemCount: inventoryList.length,
        itemBuilder: (context, index) {
          var item = inventoryList[index];

          return

            Card(
            color: AppColors.beige,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: 200,
                          child: Text(
                            //Product: name
                            "${item['SKU'].toString()}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.brown),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://www.kineticasports.com/cdn/shop/files/kinetica-sports-227kg-whey-choc-974567.png?v=1715782106&width=1200',
                                width: 100,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error,
                                    stackTrace) =>
                                const Icon(
                                    Icons.image_not_supported,
                                    size: 80),
                              ),
                            ),
                            const SizedBox(width: 12),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SizedBox(height: 8),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("SKU",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.gold)),


                                    SizedBox(
                                      width: 100, // tweak this value to achieve a wrap around 15 characters
                                      child: Text(
                                        item['SKU'].toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryBlue,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                                //_buildInfoRow("SKU", "product['sellerSku'].toUpperCase()"),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("ASIN",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.gold)),

                                    SizedBox(
                                      width: 100, // tweak this value to achieve a wrap around 15 characters
                                      child: Text(
                                        item['ASIN'].toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryBlue,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                                // _buildInfoRow("ASIN", "product['asin'].toUpperCase()"),
                              ],
                            ),
                            //  SizedBox(width: 16),


                          ],
                        ),
                      ],
                    ),

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: _selectedItems
                          .map((label) => buildInfoRow(
                          label,
                          item[fieldMapping[label]]
                              ?.toString() ??
                              "0"))
                          .toList(),
                    ),



                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child:
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 60, // Fixed width for alignment
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gold, // Background color for title
              borderRadius: BorderRadius.circular(0),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 3), // Space between title and value
          Container(
            width: 80, // Matching width
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cream,
              // Background color for value
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              value.toString().padLeft(4, '0'), // Formatting numbers like "0000"
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );




  }
}

// MultiSelectDialog Widget
class MultiSelectDialog extends StatefulWidget {
  final List<String> options;
  final List<String> selectedValues;

  const MultiSelectDialog({
    Key? key,
    required this.options,
    required this.selectedValues,
  }) : super(key: key);

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Filters"),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.options.map((option) {
            return CheckboxListTile(
              value: _tempSelected.contains(option),
              title: Text(option),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (isChecked) {
                setState(() {
                  if (isChecked!) {
                    _tempSelected.add(option);
                  } else {
                    _tempSelected.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () => Navigator.pop(context, _tempSelected),
            child: const Text("Apply"))
      ],
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:intl/intl.dart';
//
// import '../../utils/ApiConfig.dart';
// import '../../utils/colors.dart';
//
// class New_inventrory_details extends StatefulWidget {
//   const New_inventrory_details({super.key});
//
//   @override
//   State<New_inventrory_details> createState() => _New_inventrory_detailsState();
// }
//
// class _New_inventrory_detailsState extends State<New_inventrory_details> {
//   List<String> _selectedItems = [
//     "Warehouse Inventory",
//     "Total Sellable",
//     "Inventory Age"
//   ];
//
//   final List<String> _options = [
//     "Warehouse Inventory",
//     "Total Sellable",
//     "Inventory Age",
//     "DOS",
//     "Customer Reserved",
//     "FC Transfer",
//     "FC Processing",
//     "Unfulfilled",
//     "Inbound Recieving"
//   ];
//
//   final Map<String, String> fieldMapping = {
//     "Warehouse Inventory": "afn-warehouse-quantity",
//     "Total Sellable": "afn-fulfillable-quantity",
//     "Inventory Age": "afn-inventory-age-0-to-30-days",
//     "DOS": "afn-inbound-receiving-quantity",
//     "Customer Reserved": "Customer_reserved",
//     "FC Transfer": "afn-fc-transfer",
//     "FC Processing": "afn-fc-processing",
//     "Unfulfilled": "afn-unfulfillable-quantity",
//     "Inbound Recieving": "afn-inbound-receiving-quantity",
//   };
//
//   List<dynamic> inventoryList = [];
//   bool isLoading = true;
//   String error = '';
//
//
//
//   final DateFormat formatter = DateFormat('yyyy-MM-dd');
//   String displayedText = '';
//   String selectedOption = 'Today';
//   List<dynamic> allInventory = [];
//
//   DateTime? customStartDate;
//   DateTime? customEndDate;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchInventoryData();
//   }
//
//   Future<void> fetchInventoryData() async {
//     try {
//       var dio = Dio();
//      // var response = await dio.get('http://192.168.50.92:2000/api/data');
//       var response = await dio.get(ApiConfig.ukInventory);
//
//       if (response.statusCode == 200) {
//         setState(() {
//           inventoryList = response.data;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           error = 'Error: ${response.statusMessage}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         error = 'Exception: $e';
//         isLoading = false;
//       });
//     }
//   }
//
//
//   void handleSelection(String selection) {
//     final now = DateTime.now();
//
//     switch (selection) {
//       case 'Today':
//         displayedText = 'Today: ${formatter.format(now)}';
//         break;
//       case 'This Week':
//         final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
//         displayedText = 'This Week: ${formatter.format(startOfWeek)} -- ${formatter.format(now)}';
//         break;
//       case 'Last 30 Days':
//         final start = now.subtract(Duration(days: 30));
//         displayedText = 'Last 30 Days: ${formatter.format(start)} -- ${formatter.format(now)}';
//         break;
//       case 'Last 6 Months':
//         final start = DateTime(now.year, now.month - 6, now.day);
//         displayedText = 'Last 6 Months: ${formatter.format(start)} -- ${formatter.format(now)}';
//         break;
//       case 'Last 12 Months':
//         final start = DateTime(now.year - 1, now.month, now.day);
//         displayedText = 'Last 12 Months: ${formatter.format(start)} -- ${formatter.format(now)}';
//         break;
//       case 'Custom Range':
//         if (customStartDate != null && customEndDate != null) {
//           displayedText = 'Custom: ${formatter.format(customStartDate!)} -- ${formatter.format(customEndDate!)}';
//         } else {
//           displayedText = 'Please select a custom range.';
//         }
//         break;
//     }
//
//     setState(() {
//       selectedOption = selection;
//     });
//
//     filterData();
//   }
//
//   void filterData() {
//     final now = DateTime.now();
//     DateTime? start;
//     DateTime? end;
//
//     switch (selectedOption) {
//       case 'Today':
//         start = DateTime(now.year, now.month, now.day);
//         end = start.add(const Duration(days: 1));
//         break;
//       case 'This Week':
//         start = now.subtract(Duration(days: now.weekday - 1));
//         end = now.add(const Duration(days: 1));
//         break;
//       case 'Last 30 Days':
//         start = now.subtract(const Duration(days: 30));
//         end = now.add(const Duration(days: 1));
//         break;
//       case 'Last 6 Months':
//         start = DateTime(now.year, now.month - 6, now.day);
//         end = now.add(const Duration(days: 1));
//         break;
//       case 'Last 12 Months':
//         start = DateTime(now.year - 1, now.month, now.day);
//         end = now.add(const Duration(days: 1));
//         break;
//       case 'Custom Range':
//         if (customStartDate != null && customEndDate != null) {
//           start = customStartDate;
//           end = customEndDate!.add(const Duration(days: 1));
//         }
//         break;
//     }
//
//     setState(() {
//       final inputFormat = DateFormat('dd-MMM-yyyy'); // Handles 18-Apr-2025 format
//
//       inventoryList = allInventory.where((item)
//       {
//         if (!item.containsKey('Date')) return false;
//         final parts = item['Date'].toString().split('--');
//         if (parts.isEmpty) return false;
//
//         try {
//           final productDate = inputFormat.parse(parts[0].trim());
//           return (start != null &&
//               end != null &&
//               productDate.isAfter(start!.subtract(const Duration(seconds: 1))) &&
//               productDate.isBefore(end!));
//         } catch (_) {
//           return false;
//         }
//       }).toList();
//     });
//   }
//
//   Future<void> selectDateRange(BuildContext context) async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//
//     if (picked != null) {
//       setState(() {
//         customStartDate = picked.start;
//         customEndDate = picked.end;
//         displayedText = 'Custom: ${formatter.format(picked.start)} → ${formatter.format(picked.end)}';
//         selectedOption = 'Custom Range';
//       });
//       filterData();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(60),
//         child: AppBar(
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               //const Text("Inventory Details"),
//               GestureDetector(
//                 onTap: () async {
//                   final List<String>? selectedValues = await showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return MultiSelectDialog(
//                         options: _options,
//                         selectedValues: _selectedItems,
//                       );
//                     },
//                   );
//                   if (selectedValues != null) {
//                     setState(() {
//                       _selectedItems = selectedValues;
//                     });
//                   }
//                 },
//                 child: Container(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     color: Colors.white24,
//                   ),
//                   child: const Row(
//                     children: [
//                       Text(
//                         "Filter",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       Icon(Icons.arrow_drop_down, color: Colors.black),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           const SizedBox(height: 16),
//           DropdownButton<String>(
//             value: selectedOption,
//             items: [
//               'Today',
//               'This Week',
//               'Last 30 Days',
//               'Last 6 Months',
//               'Last 12 Months',
//               'Custom Range'
//             ].map((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {
//               if (newValue != null) {
//                 if (newValue == 'Custom Range') {
//                   selectDateRange(context);
//                 } else {
//                   handleSelection(newValue);
//                 }
//               }
//             },
//           ),
//           const SizedBox(height: 8),
//            Text(displayedText),
//           //show in display
//           const SizedBox(height: 16),
//           Expanded(
//             child:   error.isNotEmpty
//                 ? Center(child: Text(error))
//                 : inventoryList.isEmpty
//                 ? const Center(child: Text('No products found.'))
//                 : ListView.builder(
//               itemCount: inventoryList.length,
//               itemBuilder: (context, index) {
//                 var item = inventoryList[index];
//
//                 return Card(
//                   color: AppColors.beige,
//                   elevation: 0,
//                   margin: const EdgeInsets.only(bottom: 10),
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Row(
//                         children: [
//                           Column(
//                             children: [
//                               SizedBox(
//                                 width: 200,
//                                 child: Text(
//                                   //Product: name
//                                   "${item['SKU'].toString()}",
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 18,
//                                       color: Colors.brown),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Row(
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(8),
//                                     child: Image.network(
//                                       'https://www.kineticasports.com/cdn/shop/files/kinetica-sports-227kg-whey-choc-974567.png?v=1715782106&width=1200',
//                                       width: 100,
//                                       height: 120,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (context, error,
//                                           stackTrace) =>
//                                       const Icon(
//                                           Icons.image_not_supported,
//                                           size: 80),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       // SizedBox(height: 8),
//
//                                       Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text("SKU",
//                                               style: TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: AppColors.gold)),
//
//
//                                           SizedBox(
//                                             width: 100, // tweak this value to achieve a wrap around 15 characters
//                                             child: Text(
//                                               item['SKU'].toString(),
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w800,
//                                                 color: AppColors.primaryBlue,
//                                               ),
//                                               softWrap: true,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       //_buildInfoRow("SKU", "product['sellerSku'].toUpperCase()"),
//
//                                       Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text("ASIN",
//                                               style: TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: AppColors.gold)),
//
//                                           SizedBox(
//                                             width: 100, // tweak this value to achieve a wrap around 15 characters
//                                             child: Text(
//                                               item['ASIN'].toString(),
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w800,
//                                                 color: AppColors.primaryBlue,
//                                               ),
//                                               softWrap: true,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       // _buildInfoRow("ASIN", "product['asin'].toUpperCase()"),
//                                     ],
//                                   ),
//                                   //  SizedBox(width: 16),
//
//
//                                 ],
//                               ),
//                             ],
//                           ),
//
//                           Row(
//                             crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                             children: _selectedItems
//                                 .map((label) => buildInfoRow(
//                                 label,
//                                 item[fieldMapping[label]]
//                                     ?.toString() ??
//                                     "0"))
//                                 .toList(),
//                           ),
//
//
//
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//
//           ),
//         ],
//       ),
//
//
//
//
//
//
//
//
//
//     );
//   }
//
//   Widget buildInfoRow(String label, String value) {
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child:
//       Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Container(
//             width: 80,
//             height: 60, // Fixed width for alignment
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.gold, // Background color for title
//               borderRadius: BorderRadius.circular(0),
//             ),
//             child: Text(
//               label,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           SizedBox(height: 3), // Space between title and value
//           Container(
//             width: 80, // Matching width
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.cream,
//               // Background color for value
//               borderRadius: BorderRadius.circular(5),
//             ),
//             child: Text(
//                value.toString().padLeft(4, '0'), // Formatting numbers like "0000"
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//
//
//
//
//   }
// }
//
// // MultiSelectDialog Widget
// class MultiSelectDialog extends StatefulWidget {
//   final List<String> options;
//   final List<String> selectedValues;
//
//   const MultiSelectDialog({
//     Key? key,
//     required this.options,
//     required this.selectedValues,
//   }) : super(key: key);
//
//   @override
//   _MultiSelectDialogState createState() => _MultiSelectDialogState();
// }
//
// class _MultiSelectDialogState extends State<MultiSelectDialog> {
//   late List<String> _tempSelected;
//
//   @override
//   void initState() {
//     super.initState();
//     _tempSelected = List.from(widget.selectedValues);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text("Select Filters"),
//       content: SingleChildScrollView(
//         child: ListBody(
//           children: widget.options.map((option) {
//             return CheckboxListTile(
//               value: _tempSelected.contains(option),
//               title: Text(option),
//               controlAffinity: ListTileControlAffinity.leading,
//               onChanged: (isChecked) {
//                 setState(() {
//                   if (isChecked!) {
//                     _tempSelected.add(option);
//                   } else {
//                     _tempSelected.remove(option);
//                   }
//                 });
//               },
//             );
//           }).toList(),
//         ),
//       ),
//       actions: [
//         TextButton(
//             onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//         ElevatedButton(
//             onPressed: () => Navigator.pop(context, _tempSelected),
//             child: const Text("Apply"))
//       ],
//     );
//   }
// }






//
//
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:intl/intl.dart';
//
// import '../../utils/ApiConfig.dart';
// import '../../utils/colors.dart';
// import 'inventory_detail.dart'; // Ensure this file is available
//
// class New_shipment_details extends StatefulWidget {
//   const New_shipment_details({super.key});
//
//   @override
//   State<New_shipment_details> createState() =>
//       _New_shipment_detailsState();
// }
//
// class _New_shipment_detailsState extends State<New_shipment_details> {
//   List<String> _selectedItems = [
//   "Current Inventory",
//   "Current DOS",
//   "Shipment Quantity",
//   "Shipment Date"
// ];
//
// final List<String> _options = [
//   "Current Inventory",
//   "Current DOS",
//   "Shipment Quantity",
//   "Shipment Date",
//   "Customer Reserved",
//   "FC Transfer",
//   "FC Processing",
//   "Unfulfilled",
//   "Inbound Recieving"
// ];
//
// final Map<String, String> fieldMapping = {
//   "Warehouse Inventory": "afn-warehouse-quantity",
//   "Total Sellable": "afn-fulfillable-quantity",
//   "Inventory Age": "afn-inventory-age-0-to-30-days",
//   "DOS": "afn-inbound-receiving-quantity",
//   "Customer Reserved": "Customer_reserved",
//   "FC Transfer": "afn-fc-transfer",
//   "FC Processing": "afn-fc-processing",
//   "Unfulfilled": "afn-unfulfillable-quantity",
//   "Inbound Recieving": "afn-inbound-receiving-quantity",
// };
//
//   List<dynamic> inventoryList = [];
//   List<dynamic> allInventory = [];
//
//   bool isLoading = true;
//   String error = '';
//
//   final DateFormat formatter = DateFormat('yyyy-MM-dd');
//   final DateFormat inputFormat = DateFormat('dd-MMM-yyyy');
//
//   String displayedText = '';
//   String selectedOption = 'Today';
//
//   DateTime? customStartDate;
//   DateTime? customEndDate;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchInventoryData();
//   }
//
//   Future<void> fetchInventoryData() async {
//     try {
//       var dio = Dio();
//       var response = await dio.get(ApiConfig.ukInventory);
//
//       if (response.statusCode == 200 && response.data != null) {
//         setState(() {
//           allInventory = List.from(response.data);
//           inventoryList = List.from(response.data);
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           error = 'Error: ${response.statusMessage}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         error = 'Exception: $e';
//         isLoading = false;
//       });
//     }
//   }
//
//   void handleSelection(String selection) {
//     final now = DateTime.now();
//
//     switch (selection) {
//       case 'Today':
//         displayedText = 'Today: ${formatter.format(now)}';
//         break;
//       case 'This Week':
//         final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
//         displayedText =
//         'This Week: ${formatter.format(startOfWeek)} -- ${formatter.format(now)}';
//         break;
//       case 'Last 30 Days':
//         final start = now.subtract(Duration(days: 30));
//         displayedText =
//         'Last 30 Days: ${formatter.format(start)} -- ${formatter.format(now)}';
//         break;
//       case 'Last 6 Months':
//         final start = DateTime(now.year, now.month - 6, now.day);
//         displayedText =
//         'Last 6 Months: ${formatter.format(start)} -- ${formatter.format(now)}';
//         break;
//       case 'Last 12 Months':
//         final start = DateTime(now.year - 1, now.month, now.day);
//         displayedText =
//         'Last 12 Months: ${formatter.format(start)} -- ${formatter.format(now)}';
//         break;
//       case 'Custom Range':
//         if (customStartDate != null && customEndDate != null) {
//           displayedText =
//           'Custom: ${formatter.format(customStartDate!)} -- ${formatter.format(customEndDate!)}';
//         } else {
//           displayedText = 'Please select a custom range.';
//         }
//         break;
//     }
//
//     setState(() {
//       selectedOption = selection;
//     });
//
//     filterData();
//   }
//
//   void filterData() {
//     final now = DateTime.now();
//     DateTime? start;
//     DateTime? end;
//
//     switch (selectedOption) {
//       case 'Today':
//         start = DateTime(now.year, now.month, now.day);
//         end = start.add(Duration(days: 1));
//         break;
//       case 'This Week':
//         start = now.subtract(Duration(days: now.weekday - 1));
//         end = now.add(Duration(days: 1));
//         break;
//       case 'Last 30 Days':
//         start = now.subtract(Duration(days: 30));
//         end = now.add(Duration(days: 1));
//         break;
//       case 'Last 6 Months':
//         start = DateTime(now.year, now.month - 6, now.day);
//         end = now.add(Duration(days: 1));
//         break;
//       case 'Last 12 Months':
//         start = DateTime(now.year - 1, now.month, now.day);
//         end = now.add(Duration(days: 1));
//         break;
//       case 'Custom Range':
//         if (customStartDate != null && customEndDate != null) {
//           start = customStartDate;
//           end = customEndDate!.add(Duration(days: 1));
//         }
//         break;
//     }
//
//     setState(() {
//       inventoryList = allInventory.where((item) {
//         if (!item.containsKey('Date')) return false;
//         final parts = item['Date'].toString().split('--');
//         if (parts.isEmpty) return false;
//
//         try {
//           final productDate = inputFormat.parse(parts[0].trim());
//           return (start != null &&
//               end != null &&
//               productDate.isAfter(start!.subtract(Duration(seconds: 1))) &&
//               productDate.isBefore(end!));
//         } catch (_) {
//           return false;
//         }
//       }).toList();
//     });
//   }
//
//   Future<void> selectDateRange(BuildContext context) async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//
//     if (picked != null) {
//       setState(() {
//         customStartDate = picked.start;
//         customEndDate = picked.end;
//         displayedText =
//         'Custom: ${formatter.format(picked.start)} → ${formatter.format(picked.end)}';
//         selectedOption = 'Custom Range';
//       });
//       filterData();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   // title: const Text("Inventory Details"),
//       //   actions: [
//       //     GestureDetector(
//       //       onTap: () async {
//       //         final List<String>? selectedValues = await showDialog(
//       //           context: context,
//       //           builder: (BuildContext context) {
//       //             return MultiSelectDialog(
//       //               options: _options,
//       //               selectedValues: _selectedItems,
//       //             );
//       //           },
//       //         );
//       //         if (selectedValues != null) {
//       //           setState(() {
//       //             _selectedItems = selectedValues;
//       //           });
//       //         }
//       //       },
//       //       child: Container(
//       //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       //         margin: const EdgeInsets.only(right: 12),
//       //         decoration: BoxDecoration(
//       //           borderRadius: BorderRadius.circular(8),
//       //           color: Colors.white24,
//       //         ),
//       //         child: const Row(
//       //           children: [
//       //             Text(
//       //               "Filter",
//       //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       //             ),
//       //             Icon(Icons.arrow_drop_down, color: Colors.black),
//       //           ],
//       //         ),
//       //       ),
//       //     ),
//       //   ],
//       // ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           const SizedBox(height: 16),
//           DropdownButton<String>(
//             value: selectedOption,
//             items: [
//               'Today',
//               'This Week',
//               'Last 30 Days',
//               'Last 6 Months',
//               'Last 12 Months',
//               'Custom Range'
//             ].map((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {
//               if (newValue != null) {
//                 if (newValue == 'Custom Range') {
//                   selectDateRange(context);
//                 } else {
//                   handleSelection(newValue);
//                 }
//               }
//             },
//           ),
//           const SizedBox(height: 8),
//           Text(displayedText),
//           const SizedBox(height: 16),
//           Expanded(
//             child: error.isNotEmpty
//                 ? Center(child: Text(error))
//                 : inventoryList.isEmpty
//                 ? const Center(child: Text('No products found.'))
//                 : ListView.builder(
//               itemCount: inventoryList.length,
//               itemBuilder: (context, index) {
//                 var item = inventoryList[index];
//                 return
//                   Card(
//                     color: AppColors.beige,
//                     elevation: 0,
//                     margin: const EdgeInsets.only(bottom: 10),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Row(
//                           children: [
//                             Column(
//                               children: [
//                                 SizedBox(
//                                   width: 200,
//                                   child: Text(
//                                     //Product: name
//                                     "${item['SKU'].toString()}",
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 18,
//                                         color: Colors.brown),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 Row(
//                                   children: [
//                                     ClipRRect(
//                                       borderRadius: BorderRadius.circular(8),
//                                       child: Image.network(
//                                         'https://www.kineticasports.com/cdn/shop/files/kinetica-sports-227kg-whey-choc-974567.png?v=1715782106&width=1200',
//                                         width: 100,
//                                         height: 120,
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (context, error,
//                                             stackTrace) =>
//                                         const Icon(
//                                             Icons.image_not_supported,
//                                             size: 80),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//
//                                     Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         // SizedBox(height: 8),
//
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text("SKU",
//                                                 style: TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.bold,
//                                                     color: AppColors.gold)),
//
//
//                                             SizedBox(
//                                               width: 100, // tweak this value to achieve a wrap around 15 characters
//                                               child: Text(
//                                                 item['SKU'].toString(),
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.w800,
//                                                   color: AppColors.primaryBlue,
//                                                 ),
//                                                 softWrap: true,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         //_buildInfoRow("SKU", "product['sellerSku'].toUpperCase()"),
//
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text("ASIN",
//                                                 style: TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.bold,
//                                                     color: AppColors.gold)),
//
//                                             SizedBox(
//                                               width: 100, // tweak this value to achieve a wrap around 15 characters
//                                               child: Text(
//                                                 item['ASIN'].toString(),
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.w800,
//                                                   color: AppColors.primaryBlue,
//                                                 ),
//                                                 softWrap: true,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         // _buildInfoRow("ASIN", "product['asin'].toUpperCase()"),
//                                       ],
//                                     ),
//                                     //  SizedBox(width: 16),
//
//
//                                   ],
//                                 ),
//                               ],
//                             ),
//
//                             Row(
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: _selectedItems
//                                   .map((label) => buildInfoRow(
//                                   label,
//                                   item[fieldMapping[label]]
//                                       ?.toString() ??
//                                       "0"))
//                                   .toList(),
//                             ),
//
//
//
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// Widget buildInfoRow(String label, String value) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//     child:
//     Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Container(
//           width: 80,
//           height: 60,
//           // Fixed width for alignment
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: AppColors.gold, // Background color for title
//             borderRadius: BorderRadius.circular(0),
//           ),
//           child: Text(
//             label,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         SizedBox(height: 3), // Space between title and value
//         Container(
//           width: 80, // Matching width
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: AppColors.cream,
//             // Background color for value
//             borderRadius: BorderRadius.circular(5),
//           ),
//           child: Text(
//             value.toString().padLeft(4, '0'), // Formatting numbers like "0000"
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }