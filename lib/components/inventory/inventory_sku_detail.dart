import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/barchart.dart';
import 'package:flutter_application_1/components/info_card.dart';
import 'package:flutter_application_1/utils/api_service.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/data_mapping_serive.dart';
import 'package:flutter_application_1/utils/date_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
// Import Bar Chart Component

class InventorySkuDetails extends StatefulWidget {
  final VoidCallback onButtonPressed;
  final Map<String, dynamic> productData;

  const InventorySkuDetails(
      {required this.onButtonPressed, required this.productData});

  @override
  _InventorySkuDetailsState createState() => _InventorySkuDetailsState();
}

class _InventorySkuDetailsState extends State<InventorySkuDetails> {
  int _selectedIndex = 0;
  String _selectedUnits = "Total Orders";
  String _selectedTime = "Last 12 months";
  String _selectedChannel = "Amazon";
  String _selectedRegion = "United States"; // Default region
  String errorMessage = '';
  List<dynamic> responseData = []; // Store API response
  List<dynamic> totalResponseData = [];
  bool isLoading = false;
  bool isTotalValuesLoading = false;

  Map<String, String> uiFields = {
    "totalQuantity": "Amazon Inventory",
    "fulfillableQuantity": "Total Sellable",
    "dos": "Days of Sale",
    "reservedQuantity.totalReservedQuantity": "Customer Reserved",
    "inboundShippedQuantity": "FC Transfer",
    "reservedQuantity.fcProcessingQuantity": "FC Processing",
    "unfulfillableQuantity.totalUnfulfillableQuantity": "Unfulfilled",
    "inboundReceivingQuantity": "Inbound Receiving",
  };

  List<Map<String, dynamic>> cardData = [];

  String _fetchGranularity(String selectedTime) {
    if (selectedTime == "Today" || selectedTime == "Yesterday") {
      return "Day";
    } else if (selectedTime == "Week") {
      return "Week";
    } else if (selectedTime == "Month") {
      return "Month";
    } else if (selectedTime == "Year") {
      return "Year";
    } else if (selectedTime == "Last Week" ||
        selectedTime == "Last Month" ||
        selectedTime == "This Month" ||
        selectedTime == "Last 30 days") {
      return "Day";
    } else if (selectedTime == "Last Year" ||
        selectedTime == "Last 6 months" ||
        selectedTime == "Last 12 months") {
      return "Month";
    } else {
      return "Day";
    }
  }

  void _showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CM1",
                    style: GoogleFonts.montserrat(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Revenue: XXX"),
                Text("Refund: XXX"),
                SizedBox(height: 10),
                Text("CM2",
                    style: GoogleFonts.montserrat(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Net FBA Inventory Fee: XXX"),
                Text("Net Storage Fee: XXX"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> mergedObj = {
      ...widget.productData,
      ...widget.productData['inventoryDetails']
    };
    cardData = DataMapping.getNestedValue(mergedObj, uiFields);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
              padding: EdgeInsets.all(10),
              color: AppColors.cream,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: widget.onButtonPressed,
                    child: Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Inventory',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 20,
                  ),
                ],
              )),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Card(
                              color: AppColors.beige,
                              margin: EdgeInsets.only(bottom: 20),
                              elevation: 0,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                        child: Text(
                                          widget.productData["productName"] ??
                                              "Unknown Product",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppColors.brown),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ]),
                                    // Product Image (Static for now)
                                    Row(
                                      children: [
                                        // Container(
                                        //   decoration: BoxDecoration(
                                        //     borderRadius:
                                        //         BorderRadius.circular(8),
                                        //     color: Colors.grey[
                                        //         200], // Background color for the placeholder
                                        //   ),
                                        //   width: 120,
                                        //   height:
                                        //       120, // Set height to maintain square aspect ratio
                                        //   child: Icon(
                                        //     Icons
                                        //         .image_not_supported, // Icon representing "Image Not Found"
                                        //     size: 50, // Adjust size as needed
                                        //     color: Colors.grey[
                                        //         600], // Adjust color as needed
                                        //   ),
                                        // ),

                                        // ClipRRect(
                                        //   borderRadius:
                                        //       BorderRadius.circular(8),
                                        //   child: Image.asset(
                                        //     'assets/product_image.jpg',
                                        //     width: MediaQuery.of(context).size.width / 3,
                                        //   ),
                                        // ),
                                        SizedBox(width: 12),
                                        // Product Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("SKU",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              AppColors.gold)),
                                                  Text("ASIN",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              AppColors.gold)),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width /
                                                        3.5, // Adjust width as needed
                                                    child: Text(
                                                      widget.productData["sellerSku"] ??
                                                          "N/A",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryBlue,
                                                        fontSize: 16,
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width /
                                                        3.5, // Adjust width as needed
                                                    child: Text(
                                                      textAlign:
                                                          TextAlign.right,
                                                      widget.productData["asin"] ?? "N/A",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryBlue,
                                                        fontSize: 16,
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 6),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        isLoading
                            ? SizedBox(height: 10)
                            : SizedBox(
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.7,
                                  ),
                                  itemCount: cardData.length,
                                  itemBuilder: (context, index) {
                                    final card = cardData[index];
                                    return CommonCardComponent(
                                      title: card["title"],
                                      value: card["value"],
                                      // percentChange: card["percentChange"],
                                      // comparedTo: card["comparedTo"],
                                    );
                                  },
                                ),
                              ),
                        Divider(color: AppColors.gold, thickness: 0.5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
