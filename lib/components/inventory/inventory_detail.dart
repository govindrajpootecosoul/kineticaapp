import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/api_service.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/date_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

// Parsing JSON response

class InventoryDetails extends StatefulWidget {
  //final InventoryController controller = Get.put(InventoryController());
  @override
  _InventoryDetailsState createState() => _InventoryDetailsState();
}

class _InventoryDetailsState extends State<InventoryDetails> {
  String _selectedChannel = "Amazon";
  String _selectedTime = "Last 12 months";
  List<String> _selectedItems = [
    "Warehouse INV.",  // Default selected option
  "Total Sellable",  // Default selected option
  "Inventory Age"
  ]; // Stores selected values
  final List<String> _options = [
    "Warehouse INV.",
    "Total Sellable",
    "Inventory Age",
    "DOS",
    "Customer Reserved",
    "FC Transfer",
    "FC Processing",
    "Unfulfilled",
    "Inbound Recieving"
  ];
 List<dynamic> products = [];
     bool isLoading = false;
  String errorMessage = "";

  void _fetchData(String dateRange) async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    final result = await ApiService.fetchAnalytics(
        provider: "AMAZON",
        models: "inventory",
        region: "IN",
        dateRange: dateRange,
        granularity: ApiService.fetchGranularity(_selectedTime),
        timeParameter: _selectedTime);

    setState(() {
      isLoading = false;
      if (result.containsKey("error")) {
        errorMessage = result["error"];
      } else {
        products = result["data"]["getInventory"];

      }
    });
  }

  @override
  void initState() {
    super.initState();
    String range = DateUtilsHelper.getDateRange(_selectedTime);
    _fetchData(range);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?  SpinKitWave(
                color: AppColors.gold,
                size: 50.0,
              )
            : Scaffold(
        backgroundColor: AppColors.white,
        body:

        Column(
          children: [
            // Dropdown Filters
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: [
            //       _buildDropdown("Channel", ["Amazon", "eBay", "Shopify"],
            //           _selectedChannel, (newValue) {
            //         setState(() {
            //           _selectedChannel = newValue!;
            //         });
            //       }),
            //       _buildDropdown(
            //         "Select Time Range",
            //         [
            //           "Today",
            //           "This week",
            //           "Last 30 days",
            //           "Last 6 months",
            //           "Last 12 months",
            //           "Custom"
            //         ],
            //         _selectedTime,
            //         (newValue) {
            //           setState(() {
            //             _selectedTime = newValue!;
            //           });
            //         },
            //       ),
            //     ],
            //   ),
            // ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () async {
                  final List<String>? selectedValues = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MultiSelectDialog(
                        options: _options,
                        selectedValues: _selectedItems,
                      );
                    },
                  );
                  if (selectedValues != null) {
                    setState(() {
                      _selectedItems = selectedValues;
                    });
                  }
                },
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 80,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              "Filter", // Display selected items
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    )),
              ),
            ),
            // Product List
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index], options: _options, selecteditems: _selectedItems);
                },
              ),
            ),
          ],
        ));



  }

  Widget _buildDropdown(String label, List<String> items, String selectedValue,
      Function(String?) onChanged) {
    return DropdownButton<String>(
      value: selectedValue,
      dropdownColor: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      style: GoogleFonts.montserrat(
                    color: AppColors.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  List<String> options;
  List<String> selecteditems;

  ProductCard({Key? key, required this.product, required this.options, required this.selecteditems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Card(
      color: AppColors.beige, // Beige background
      elevation: 0,
      margin: EdgeInsets.only(bottom: 10),
      child:  SingleChildScrollView(
  scrollDirection: Axis.horizontal,  // Enable full horizontal scrolling
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Row(
      children: [

        Column(
          children: [
            SizedBox(
              width: 200,
              child: Text(
                "product['productName']",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.brown),
               // maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://www.kineticasports.com/cdn/shop/files/kinetica-sports-227kg-whey-choc-974567.png?v=1715782106&width=1200',
                  width: 100,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.image_not_supported, size: 80),
                ),
              ),
              SizedBox(width: 12),
              // Product Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  SizedBox(height: 8),
                  _buildInfoRow("SKU", "product['sellerSku'].toUpperCase()"),
                  _buildInfoRow("ASIN", "product['asin'].toUpperCase()"),
                ],
              ),
              SizedBox(width: 16),
            ],),
          ],
        ),
        // Product Image
     // Space before inventory details

        // Inventory Details (Scrollable)
        Row(
          children: options.where((option) => selecteditems.contains(option))
          .map((option) {
            switch (option) {
              case "Warehouse INV.":
                return _buildInventoryColumn("Warehouse\nInventory",
                    product['totalQuantity'] ?? 0);
              case "Total Sellable":
                return _buildInventoryColumn(
                    "Total\nSellable",
                    product['inventoryDetails']?['fulfillableQuantity'] ?? 0
                );
              case "Inventory Age":
                return _buildInventoryColumn(
                    "Inventory Age",
                    product['inventoryDetails']?['researchingQuantity']
                            ?['totalResearchingQuantity'] ?? 0);
              case "DOS":
                return _buildInventoryColumn(
                    "DOS", product['dos'] ?? 0);
              case "Customer Reserved":
                return _buildInventoryColumn(
                    "Customer Reserved",
                    product['inventoryDetails']?['reservedQuantity']
                            ?['pendingCustomerOrderQuantity'] ?? 0);
              case "FC Transfer":
                return _buildInventoryColumn(
                    "FC Transfer",
                    product['inventoryDetails']?['reservedQuantity']
                            ?['pendingTransshipmentQuantity'] ?? 0);
              case "FC Processing":
                return _buildInventoryColumn(
                    "FC Processing",
                    product['inventoryDetails']?['reservedQuantity']
                            ?['fcProcessingQuantity'] ?? 0);
              case "Unfulfilled":
                return _buildInventoryColumn(
                    "Unfulfilled",
                    product['inventoryDetails']?['unfulfillableQuantity']
                            ?['totalUnfulfillableQuantity'] ?? 0);
              case "Inbound Recieving":
                return _buildInventoryColumn(
                    "Inbound Recieving",
                    product['inventoryDetails']?['inboundReceivingQuantity'] ?? 0);
              default:
                return SizedBox(); // Return an empty widget if no match
            }
          }).toList(),
        ),
      ],
    ),
  ),
),

    );
  }

  Widget _buildInfoRow(String label, String value) {
    return

      Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.gold)),
        // Text(value,
        //     style: TextStyle(
        //         fontSize: 14,
        //         fontWeight: FontWeight.w800,
        //         color: AppColors.primaryBlue)),

        SizedBox(
          width: 100, // tweak this value to achieve a wrap around 15 characters
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlue,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryColumn(String title, int value) {
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
              title,
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
            child: Text("asdfgh",
             // value.toString().padLeft(4, '0'), // Formatting numbers like "0000"
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

class MultiSelectDialog extends StatefulWidget {
  final List<String> options;
  final List<String> selectedValues;

  MultiSelectDialog({required this.options, required this.selectedValues});

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _tempSelectedValues;

  @override
  void initState() {
    super.initState();
    _tempSelectedValues = List.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      alignment: Alignment.centerRight,
      backgroundColor: AppColors.filterbg,
      title: Text(
        "Filters",
        style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 19),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: widget.options.map((option) {
            return Column(
              children: [
                CheckboxListTile(
                  selectedTileColor: AppColors.primaryBlue,
                  checkColor: Colors.transparent,
                  title: Text(
                    option,
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                  value: _tempSelectedValues.contains(option),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _tempSelectedValues.add(option);
                      } else {
                        _tempSelectedValues.remove(option);
                      }
                    });
                  },
                ),
                Divider(
                  color: Colors.black, // Black border
                  thickness: 1, // Thickness of the border
                  height: 1, // Space between divider and list item
                ),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(
              context, widget.selectedValues), // Cancel without saving
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black),
          ),
        ),
        GestureDetector(
            onTap: () => Navigator.pop(
                context, _tempSelectedValues), // Save selected values
            child: Container(
              padding: EdgeInsets.all(15),
              width: 70,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.beige),
              child: Text("Apply"),
            )),
      ],
    );
  }
}













//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controller_class/inventory_controller.dart';
// import '../../model_class/inventory_model_class.dart';
//
// class InventoryPage extends StatelessWidget {
//   final InventoryController controller = Get.put(InventoryController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Inventory List'),
//       ),
//       body:
//
//       Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         }
//
//         if (controller.inventoryList.isEmpty) {
//           return Center(child: Text('No data available'));
//         }
//
//         return ListView.builder(
//           itemCount: controller.inventoryList.length,
//           itemBuilder: (context, index) {
//             Welcome item = controller.inventoryList[index];
//             return
//
//             //   ListTile(
//             //   title: Text('SKU: ${item.sku}'),
//             //   subtitle: Text('Country: ${item.country.toString().split('.').last}'),
//             // );
//
//
//
//             Card(
//               color: AppColors.beige, // Beige background
//               elevation: 0,
//               margin: EdgeInsets.only(bottom: 10),
//               child:  SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,  // Enable full horizontal scrolling
//                 child: Padding(
//                   padding: EdgeInsets.all(12),
//                   child: Row(
//                     children: [
//
//                       Column(
//                         children: [
//                           SizedBox(
//                             width: 200,
//                             child: Text(
//                               "product['productName']",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                   color: Colors.brown),
//                               // maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           Row(children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.network(
//                                 'https://www.kineticasports.com/cdn/shop/files/kinetica-sports-227kg-whey-choc-974567.png?v=1715782106&width=1200',
//                                 width: 100,
//                                 height: 120,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     Icon(Icons.image_not_supported, size: 80),
//                               ),
//                             ),
//                             SizedBox(width: 12),
//                             // Product Info
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//
//
//                                 SizedBox(height: 8),
//                                 _buildInfoRow("SKU", "product['sellerSku'].toUpperCase()"),
//                                 _buildInfoRow("ASIN", "product['asin'].toUpperCase()"),
//                               ],
//                             ),
//                             SizedBox(width: 16),
//                           ],),
//                         ],
//                       ),
//                       // Product Image
//                       // Space before inventory details
//
//                       // Inventory Details (Scrollable)
//                       Row(
//                         children: options.where((option) => selecteditems.contains(option))
//                             .map((option) {
//                           switch (option) {
//                             case "Warehouse INV.":
//                               return _buildInventoryColumn("Warehouse\nInventory",
//                                   product['totalQuantity'] ?? 0);
//                             case "Total Sellable":
//                               return _buildInventoryColumn(
//                                   "Total\nSellable",
//                                   product['inventoryDetails']?['fulfillableQuantity'] ?? 0
//                               );
//                             case "Inventory Age":
//                               return _buildInventoryColumn(
//                                   "Inventory Age",
//                                   product['inventoryDetails']?['researchingQuantity']
//                                   ?['totalResearchingQuantity'] ?? 0);
//                             case "DOS":
//                               return _buildInventoryColumn(
//                                   "DOS", product['dos'] ?? 0);
//                             case "Customer Reserved":
//                               return _buildInventoryColumn(
//                                   "Customer Reserved",
//                                   product['inventoryDetails']?['reservedQuantity']
//                                   ?['pendingCustomerOrderQuantity'] ?? 0);
//                             case "FC Transfer":
//                               return _buildInventoryColumn(
//                                   "FC Transfer",
//                                   product['inventoryDetails']?['reservedQuantity']
//                                   ?['pendingTransshipmentQuantity'] ?? 0);
//                             case "FC Processing":
//                               return _buildInventoryColumn(
//                                   "FC Processing",
//                                   product['inventoryDetails']?['reservedQuantity']
//                                   ?['fcProcessingQuantity'] ?? 0);
//                             case "Unfulfilled":
//                               return _buildInventoryColumn(
//                                   "Unfulfilled",
//                                   product['inventoryDetails']?['unfulfillableQuantity']
//                                   ?['totalUnfulfillableQuantity'] ?? 0);
//                             case "Inbound Recieving":
//                               return _buildInventoryColumn(
//                                   "Inbound Recieving",
//                                   product['inventoryDetails']?['inboundReceivingQuantity'] ?? 0);
//                             default:
//                               return SizedBox(); // Return an empty widget if no match
//                           }
//                         }).toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//             );
//
//
//           },
//         );
//       }),
//       // floatingActionButton: FloatingActionButton(
//       //   onPressed: controller.fetchInventory,
//       //   child: Icon(Icons.refresh),
//       // ),
//     );
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/utils/api_service.dart';
// import 'package:flutter_application_1/utils/colors.dart';
// import 'package:flutter_application_1/utils/date_utils.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// // Parsing JSON response
//
// class InventoryDetails extends StatefulWidget {
//   @override
//   _InventoryDetailsState createState() => _InventoryDetailsState();
// }
//
// class _InventoryDetailsState extends State<InventoryDetails> {
//   String _selectedChannel = "Amazon";
//   String _selectedTime = "Last 12 months";
//   List<String> _selectedItems = [
//     "Warehouse INV.",  // Default selected option
//     "Total Sellable",  // Default selected option
//     "Inventory Age"
//   ]; // Stores selected values
//   final List<String> _options = [
//     "Warehouse INV.",
//     "Total Sellable",
//     "Inventory Age",
//     "DOS",
//     "Customer Reserved",
//     "FC Transfer",
//     "FC Processing",
//     "Unfulfilled",
//     "Inbound Recieving"
//   ];
//   List<dynamic> products = [];
//   bool isLoading = false;
//   String errorMessage = "";
//
//   void _fetchData(String dateRange) async {
//     setState(() {
//       isLoading = true;
//       errorMessage = "";
//     });
//
//     final result = await ApiService.fetchAnalytics(
//         provider: "AMAZON",
//         models: "inventory",
//         region: "IN",
//         dateRange: dateRange,
//         granularity: ApiService.fetchGranularity(_selectedTime),
//         timeParameter: _selectedTime);
//
//     setState(() {
//       isLoading = false;
//       if (result.containsKey("error")) {
//         errorMessage = result["error"];
//       } else {
//         products = result["data"]["getInventory"];
//
//       }
//     });
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
//     return isLoading ?  SpinKitWave(
//       color: AppColors.gold,
//       size: 50.0,
//     )
//         : Scaffold(
//         backgroundColor: AppColors.white,
//         body: Column(
//           children: [
//             // Dropdown Filters
//             // Padding(
//             //   padding: const EdgeInsets.all(8.0),
//             //   child: Row(
//             //     mainAxisAlignment: MainAxisAlignment.spaceAround,
//             //     children: [
//             //       _buildDropdown("Channel", ["Amazon", "eBay", "Shopify"],
//             //           _selectedChannel, (newValue) {
//             //         setState(() {
//             //           _selectedChannel = newValue!;
//             //         });
//             //       }),
//             //       _buildDropdown(
//             //         "Select Time Range",
//             //         [
//             //           "Today",
//             //           "This week",
//             //           "Last 30 days",
//             //           "Last 6 months",
//             //           "Last 12 months",
//             //           "Custom"
//             //         ],
//             //         _selectedTime,
//             //         (newValue) {
//             //           setState(() {
//             //             _selectedTime = newValue!;
//             //           });
//             //         },
//             //       ),
//             //     ],
//             //   ),
//             // ),
//
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: GestureDetector(
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
//                 child: Align(
//                     alignment: Alignment.centerRight,
//                     child: Container(
//                       width: 80,
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               "Filter", // Display selected items
//                               style: TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.bold),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           Icon(Icons.arrow_drop_down, color: Colors.grey),
//                         ],
//                       ),
//                     )),
//               ),
//             ),
//             // Product List
//             Expanded(
//               child: ListView.builder(
//                 itemCount: products.length,
//                 itemBuilder: (context, index) {
//                   return ProductCard(product: products[index], options: _options, selecteditems: _selectedItems);
//                 },
//               ),
//             ),
//           ],
//         ));
//   }
//
//   Widget _buildDropdown(String label, List<String> items, String selectedValue,
//       Function(String?) onChanged) {
//     return DropdownButton<String>(
//       value: selectedValue,
//       dropdownColor: AppColors.white,
//       borderRadius: BorderRadius.circular(10),
//       style: GoogleFonts.montserrat(
//           color: AppColors.gold,
//           fontSize: 14,
//           fontWeight: FontWeight.bold
//       ),
//       items: items.map((item) {
//         return DropdownMenuItem<String>(
//           value: item,
//           child: Text(item),
//         );
//       }).toList(),
//       onChanged: onChanged,
//     );
//   }
// }
//
// class ProductCard extends StatelessWidget {
//   final Map<String, dynamic> product;
//   List<String> options;
//   List<String> selecteditems;
//
//   ProductCard({Key? key, required this.product, required this.options, required this.selecteditems}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: AppColors.beige, // Beige background
//       elevation: 0,
//       margin: EdgeInsets.only(bottom: 10),
//       child:  SingleChildScrollView(
//         scrollDirection: Axis.horizontal,  // Enable full horizontal scrolling
//         child: Padding(
//           padding: EdgeInsets.all(12),
//           child: Row(
//             children: [
//
//               Column(
//                 children: [
//                   SizedBox(
//                     width: 200,
//                     child: Text(
//                       product['productName'],
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                           color: Colors.brown),
//                       // maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   Row(children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.network(
//                         'https://www.kineticasports.com/cdn/shop/files/kinetica-sports-227kg-whey-choc-974567.png?v=1715782106&width=1200',
//                         width: 100,
//                         height: 120,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) =>
//                             Icon(Icons.image_not_supported, size: 80),
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     // Product Info
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//
//
//                         SizedBox(height: 8),
//                         _buildInfoRow("SKU", product['sellerSku'].toUpperCase()),
//                         _buildInfoRow("ASIN", product['asin'].toUpperCase()),
//                       ],
//                     ),
//                     SizedBox(width: 16),
//                   ],),
//                 ],
//               ),
//               // Product Image
//               // Space before inventory details
//
//               // Inventory Details (Scrollable)
//               Row(
//                 children: options.where((option) => selecteditems.contains(option))
//                     .map((option) {
//                   switch (option) {
//                     case "Warehouse INV.":
//                       return _buildInventoryColumn("Warehouse\nInventory",
//                           product['totalQuantity'] ?? 0);
//                     case "Total Sellable":
//                       return _buildInventoryColumn(
//                           "Total\nSellable",
//                           product['inventoryDetails']?['fulfillableQuantity'] ?? 0);
//                     case "Inventory Age":
//                       return _buildInventoryColumn(
//                           "Inventory Age",
//                           product['inventoryDetails']?['researchingQuantity']
//                           ?['totalResearchingQuantity'] ?? 0);
//                     case "DOS":
//                       return _buildInventoryColumn(
//                           "DOS", product['dos'] ?? 0);
//                     case "Customer Reserved":
//                       return _buildInventoryColumn(
//                           "Customer Reserved",
//                           product['inventoryDetails']?['reservedQuantity']
//                           ?['pendingCustomerOrderQuantity'] ?? 0);
//                     case "FC Transfer":
//                       return _buildInventoryColumn(
//                           "FC Transfer",
//                           product['inventoryDetails']?['reservedQuantity']
//                           ?['pendingTransshipmentQuantity'] ?? 0);
//                     case "FC Processing":
//                       return _buildInventoryColumn(
//                           "FC Processing",
//                           product['inventoryDetails']?['reservedQuantity']
//                           ?['fcProcessingQuantity'] ?? 0);
//                     case "Unfulfilled":
//                       return _buildInventoryColumn(
//                           "Unfulfilled",
//                           product['inventoryDetails']?['unfulfillableQuantity']
//                           ?['totalUnfulfillableQuantity'] ?? 0);
//                     case "Inbound Recieving":
//                       return _buildInventoryColumn(
//                           "Inbound Recieving",
//                           product['inventoryDetails']?['inboundReceivingQuantity'] ?? 0);
//                     default:
//                       return SizedBox(); // Return an empty widget if no match
//                   }
//                 }).toList(),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.gold)),
//         // Text(value,
//         //     style: TextStyle(
//         //         fontSize: 14,
//         //         fontWeight: FontWeight.w800,
//         //         color: AppColors.primaryBlue)),
//
//         SizedBox(
//           width: 100, // tweak this value to achieve a wrap around 15 characters
//           child: Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w800,
//               color: AppColors.primaryBlue,
//             ),
//             softWrap: true,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildInventoryColumn(String title, int value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: Column(
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
//               title,
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
//               value
//                   .toString()
//                   .padLeft(4, '0'), // Formatting numbers like "0000"
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
//   }
// }
//
// class MultiSelectDialog extends StatefulWidget {
//   final List<String> options;
//   final List<String> selectedValues;
//
//   MultiSelectDialog({required this.options, required this.selectedValues});
//
//   @override
//   _MultiSelectDialogState createState() => _MultiSelectDialogState();
// }
//
// class _MultiSelectDialogState extends State<MultiSelectDialog> {
//   late List<String> _tempSelectedValues;
//
//   @override
//   void initState() {
//     super.initState();
//     _tempSelectedValues = List.from(widget.selectedValues);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       elevation: 0,
//       alignment: Alignment.centerRight,
//       backgroundColor: AppColors.filterbg,
//       title: Text(
//         "Filters",
//         style: TextStyle(
//             color: AppColors.primaryBlue,
//             fontWeight: FontWeight.bold,
//             fontSize: 19),
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           children: widget.options.map((option) {
//             return Column(
//               children: [
//                 CheckboxListTile(
//                   selectedTileColor: AppColors.primaryBlue,
//                   checkColor: Colors.transparent,
//                   title: Text(
//                     option,
//                     style: TextStyle(color: AppColors.primaryBlue),
//                   ),
//                   value: _tempSelectedValues.contains(option),
//                   onChanged: (bool? value) {
//                     setState(() {
//                       if (value == true) {
//                         _tempSelectedValues.add(option);
//                       } else {
//                         _tempSelectedValues.remove(option);
//                       }
//                     });
//                   },
//                 ),
//                 Divider(
//                   color: Colors.black, // Black border
//                   thickness: 1, // Thickness of the border
//                   height: 1, // Space between divider and list item
//                 ),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(
//               context, widget.selectedValues), // Cancel without saving
//           child: Text(
//             "Cancel",
//             style: TextStyle(color: Colors.black),
//           ),
//         ),
//         GestureDetector(
//             onTap: () => Navigator.pop(
//                 context, _tempSelectedValues), // Save selected values
//             child: Container(
//               padding: EdgeInsets.all(15),
//               width: 70,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   color: AppColors.beige),
//               child: Text("Apply"),
//             )),
//       ],
//     );
//   }
// }
