import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../utils/ApiConfig.dart';
import '../../utils/colors.dart';

class AgingScreen_details extends StatefulWidget {
  const AgingScreen_details({super.key});

  @override
  State<AgingScreen_details> createState() => _AgingScreen_detailsState();
}

class _AgingScreen_detailsState extends State<AgingScreen_details> {
  List<String> _selectedItems = [
    "0-30 Days",
    "31-60 Days",
    "61-90 Days",
    "91-180 Days",
  ];
  List<String> _selectedItemss = [
    "Unit Shipped Till 7 Days",
    "Unit Shipped Last 30 Days",
    "Unit Shipped Last 60 Days",
    "Unit Shipped Last 90 Days",
  ];

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

  final Map<String, String> fieldMapping = {
    "Warehouse Inventory": "afn-warehouse-quantity",
    "Total Sellable": "afn-fulfillable-quantity",

    "0-30 Days": "inv_age_0_to_30_days",
    "31-60 Days": "inv_age_31_to_60_days",
    "61-90 Days": "inv_age_61_to_90_days",
    "91-180 Days": "inv_age_91_to_180_days",
    "181-270 Days": "inv_age_181_to_270_days",
    "271-365 Days": "inv_age_271_to_365_days",
    "365+ Days": "inv-age-365-plus-days",

    "Unit Shipped Till 7 Days": "units_shipped_t7",
    "Unit Shipped Last 30 Days": "units_shipped_t30",
    "Unit Shipped Last 60 Days": "units_shipped_t60",
    "Unit Shipped Last 90 Days": "units_shipped_t90",

    //  "units-shipped-t7": 1,
    //         "units-shipped-t30": 13,
    //         "units-shipped-t60": 18,
    //         "units-shipped-t90": 19,

    "DOS": "afn_inbound_receiving_quantity",
    "Customer Reserved": "Customer_reserved",
    "FC Transfer": "afn_fc_transfer",
    "FC Processing": "afn_fc_processing",
    "Unfulfilled": "afn_unfulfillable_quantity",
    "Inbound Recieving": "afn_inbound_receiving_quantity",
  };

  List<dynamic> inventoryList = [];
  bool isLoading = true;
  String error = '';

  // For selecting SKU
  String? selectedSku;
  List<String> skuList = []; // To hold available SKUs

  @override
  void initState() {
    super.initState();
    fetchSkuList();
  }

  // Function to fetch the list of SKUs
  Future<void> fetchSkuList() async {
    try {
      var dio = Dio();
      var response = await dio.get('${ApiConfig.baseUrl}/sku?q=');

      if (response.statusCode == 200) {
        setState(() {
          skuList = List<String>.from(
              response.data); // Assuming the response data is a list of SKUs
          skuList.insert(0, "All"); // Add "All" option at the top
          selectedSku = skuList.isNotEmpty ? skuList[0] : null;
        });
        fetchInventoryData(); // Fetch inventory data after fetching SKU list
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

  // Function to fetch inventory data based on the selected SKU
  Future<void> fetchInventoryData() async {
    if (selectedSku == null) return;

    try {
      var dio = Dio();
      String url = selectedSku == "All"
          ? '${ApiConfig.baseUrl}/inventory' // Fetch all data
          : '${ApiConfig.baseUrl}/inventory?sku=$selectedSku'; // Fetch based on selected SKU

      var response = await dio.get(url);

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
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(60),
      //   child: AppBar(
      //     title: Row(
      //       mainAxisAlignment: MainAxisAlignment.end,
      //       children: [
      //         //const Text("Inventory Details"),
      //         // GestureDetector(
      //         //   onTap: () async {
      //         //     final List<String>? selectedValues = await showDialog(
      //         //       context: context,
      //         //       builder: (BuildContext context) {
      //         //         return MultiSelectDialog(
      //         //           options: _options,
      //         //           selectedValues: _selectedItems,
      //         //         );
      //         //       },
      //         //     );
      //         //     if (selectedValues != null) {
      //         //       setState(() {
      //         //         _selectedItems = selectedValues;
      //
      //
      //
      //         //       });
      //         //     }
      //         //   },
      //         //   child: Container(
      //         //     padding:
      //         //     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      //         //     decoration: BoxDecoration(
      //         //       borderRadius: BorderRadius.circular(8),
      //         //       color: Colors.white24,
      //         //     ),
      //         //     child: const Row(
      //         //       children: [
      //         //         Text(
      //         //           "Filter",
      //         //           style: TextStyle(
      //         //               fontSize: 18, fontWeight: FontWeight.bold),
      //         //         ),
      //         //         Icon(Icons.arrow_drop_down, color: Colors.black),
      //         //       ],
      //         //     ),
      //         //   ),
      //         // ),
      //       ],
      //     ),
      //   ),
      // ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedSku,
              onChanged: (newValue) {
                setState(() {
                  selectedSku = newValue;
                  isLoading =
                      true; // Set loading state before fetching new data
                  fetchInventoryData(); // Fetch data with the new SKU
                });
              },
              items: skuList.map<DropdownMenuItem<String>>((String sku) {
                return DropdownMenuItem<String>(
                  value: sku,
                  child: Text(sku),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                    ? Center(child: Text(error))
                    : ListView.builder(
                        itemCount: inventoryList.length,
                        itemBuilder: (context, index) {
                          var item = inventoryList[index];

                          return Card(
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
                                        // Icon(Icons.icecream_outlined),
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            '📦',
                                            //Product: name
                                            // "${item['SKU'].toString()}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 50,
                                                color: Colors.brown),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            // ClipRRect(
                                            //   borderRadius: BorderRadius.circular(8),
                                            //   child: Image.network(
                                            //     'https://www.kineticasports.com/cdn/shop/files/kinetica-sports-227kg-whey-choc-974567.png?v=1715782106&width=1200',
                                            //     width: 100,
                                            //     height: 120,
                                            //     fit: BoxFit.cover,
                                            //     errorBuilder: (context, error,
                                            //         stackTrace) =>
                                            //     const Icon(
                                            //         Icons.image_not_supported,
                                            //         size: 80),
                                            //   ),
                                            // ),
                                            // const SizedBox(width: 12),

                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // SizedBox(height: 8),

                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text("SKU",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColors
                                                                .gold)),
                                                    SizedBox(
                                                      width:
                                                          100, // tweak this value to achieve a wrap around 15 characters
                                                      child: Text(
                                                        item['SKU'].toString(),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: AppColors
                                                              .primaryBlue,
                                                        ),
                                                        softWrap: true,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                //_buildInfoRow("SKU", "product['sellerSku'].toUpperCase()"),

                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text("ASIN",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColors
                                                                .gold)),
                                                    SizedBox(
                                                      width:
                                                          100, // tweak this value to achieve a wrap around 15 characters
                                                      child: Text(
                                                        item['ASIN'].toString(),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: AppColors
                                                              .primaryBlue,
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
                                    // Column(
                                    //   crossAxisAlignment:
                                    //       CrossAxisAlignment.start,
                                    //   children: [
                                    //     Row(
                                    //       crossAxisAlignment:
                                    //           CrossAxisAlignment.start,
                                    //       children: _selectedItems
                                    //           .map((label) => buildInfoRow(
                                    //               label,
                                    //               item[fieldMapping[label]]
                                    //                       ?.toString() ??
                                    //                   "0"))
                                    //           .toList(),
                                    //     ),
                                    //     SizedBox(
                                    //       height: 10,
                                    //     ),
                                    //     Row(
                                    //       crossAxisAlignment:
                                    //           CrossAxisAlignment.start,
                                    //       children: _selectedItemss
                                    //           .map((label) => buildInfoRow(
                                    //               label,
                                    //               item[fieldMapping[label]]
                                    //                       ?.toString() ??
                                    //                   "0"))
                                    //           .toList(),
                                    //     ),
                                    //   ],
                                    // ),
                                    showAgeingContent(item),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget showAgeingContent(var item) {
    if (!kIsWeb) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _selectedItems
                .map((label) => buildInfoRow(
                    label, item[fieldMapping[label]]?.toString() ?? "0"))
                .toList(),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _selectedItemss
                .map((label) => buildInfoRow(
                    label, item[fieldMapping[label]]?.toString() ?? "0"))
                .toList(),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _selectedItems
                .map((label) => buildInfoRow(
                    label, item[fieldMapping[label]]?.toString() ?? "0"))
                .toList(),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _selectedItemss
                .map((label) => buildInfoRow(
                    label, item[fieldMapping[label]]?.toString() ?? "0"))
                .toList(),
          ),
        ],
      );
    }
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 55, // Fixed width for alignment
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gold, // Background color for title
              borderRadius: BorderRadius.circular(5),
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
            width: 100, // Matching width
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cream,
              // Background color for value
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              value
                  .toString()
                  .padLeft(4, '0'), // Formatting numbers like "0000"
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
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () => Navigator.pop(context, _tempSelected),
            child: const Text("Apply"))
      ],
    );
  }
}
