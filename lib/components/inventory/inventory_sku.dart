import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/inventory/inventory_sku_detail.dart';
import 'package:flutter_application_1/utils/api_service.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/date_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class InventorySkuPage extends StatefulWidget {
  final VoidCallback onButtonPressed;

  const InventorySkuPage({required this.onButtonPressed});

  @override
  _InventorySkuPageState createState() => _InventorySkuPageState();
}

class _InventorySkuPageState extends State<InventorySkuPage> {
  bool isDetailsSelected = false;
  int _selectedIndex = 0;
  String _selectedUnits = "Total Orders";
  String _selectedTime = "Last 30 days";
  String _selectedChannel = "Amazon";
  Map<String, dynamic> selectedProduct = {};
  bool isLoading = false;
  String errorMessage = "";
  List<dynamic> responseData = [];

  onButtonPressed(product) {
    setState(() {
      selectedProduct = product;
      isDetailsSelected = !isDetailsSelected;
    });
  }

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
       var productList = result["data"]["getInventory"]
          ..sort((a, b) {
            num salesA = (a["unitCount"] ?? double.negativeInfinity) as num;
            num salesB = (b["unitCount"] ?? double.negativeInfinity) as num;
            return salesB.compareTo(salesA);
          });

        for (int i = 0; i < productList.length; i++) {
          var product = productList[i];
          if(i<productList.length-1 && productList[i+1]['asin'] == product['asin']){
            if(productList[i+1]['totalQuantity'] > product['totalQuantity']) {
              continue;
            }else{
              products.add(product);
              i++;
              continue;
            }
          }else{
            products.add(product);
          }
        }         
      }
    });
  }

  Widget _buildDropdown(String label, List<String> items, String selectedValue,
      Function(String?) onChanged) {
    return DropdownButton<String>(
      value: selectedValue,
      dropdownColor: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      style: GoogleFonts.montserrat(
          color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  void onBackPressed() {
    setState(() {
      isDetailsSelected = !isDetailsSelected;
    });
  }

  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    String range = DateUtilsHelper.getDateRange(_selectedTime);
    _fetchData(range);
  }

  @override
  Widget build(BuildContext context) {
    return isDetailsSelected
        ? InventorySkuDetails(
            onButtonPressed: onBackPressed, productData: {...selectedProduct, 'dos': calculateDOS(selectedProduct).toStringAsFixed(2)})
        : (isLoading
            ? SpinKitWave(
                color: AppColors.gold,
                size: 50.0,
              )
            : Scaffold(
                backgroundColor: Colors.white,
                body: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildDropdown(
                                "Channel",
                                ["Amazon", "eBay", "Shopify"],
                                _selectedChannel, (newValue) {
                              setState(() {
                                _selectedChannel = newValue!;
                              });
                            }),
                            // _buildDropdown(
                            //   "Select Time Range",
                            //   [
                            //     "Today",
                            //     "This week",
                            //     "Last 30 days",
                            //     "Last 6 months",
                            //     "Last 12 months",
                            //     "Custom"                                
                            //   ],
                            //   _selectedTime,
                            //   (newValue) {
                            //     setState(() {
                            //       if (_selectedTime == 'Custom') {
                            //         _showDateRangePicker(context);
                            //       } else {
                            //         String range = DateUtilsHelper.getDateRange(
                            //             _selectedTime);
                            //         _fetchData(range);
                            //       }
                            //     });
                            //   },
                            // )
                          ],
                        ),
                      ),
                      Expanded(
                          child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return GestureDetector(
                            onTap: () => onButtonPressed(products[index]),
                            child: Card(
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
                                          product["productName"] ??
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
                                                      product["sellerSku"] ??
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
                                                      product["asin"] ?? "N/A",
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
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("Available Inventory",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              AppColors.gold)),
                                                  Text("Last 30 days sales",
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
                                                  Text(
                                                      "${product["totalQuantity"] ?? 0}", // Directly using API field
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryBlue,
                                                        fontSize: 16,
                                                      )),
                                                  Text(
                                                      "${product["unitCount"] ?? 0}", // Corrected sales format
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryBlue,
                                                        fontSize: 16,
                                                      )),
                                                ],
                                              ),
                                              SizedBox(height: 6),
                                              // Row(
                                              //   mainAxisAlignment:
                                              //       MainAxisAlignment
                                              //           .spaceBetween,
                                              //   children: [
                                              //     Text("Storage Cost",
                                              //         style: TextStyle(
                                              //             fontSize: 16,
                                              //             color:
                                              //                 AppColors.gold)),
                                              //     Text("LTSF Cost",
                                              //         style: TextStyle(
                                              //             fontSize: 16,
                                              //             color:
                                              //                 AppColors.gold)),
                                              //   ],
                                              // ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("Days of Supply",
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
                                                  RichText(
                                                    text: TextSpan(
                                                      text:
                                                          "${calculateDOS(product)} ", // Main value
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: AppColors
                                                            .primaryBlue,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              "Days", // Subtext
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize:
                                                                12, // Smaller font size
                                                            color: AppColors
                                                                .primaryBlue
                                                                .withOpacity(
                                                                    0.7), // Slightly faded
                                                          ),
                                                        ),
    ],
  ),
)

                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ))
                    ])));
  }

  int calculateDOS(Map<String, dynamic> data) {
    if (data['inventoryDetails'] != null &&
        data['inventoryDetails'].containsKey('fulfillableQuantity')) {
      int fulfillableQuantity = data['inventoryDetails']['fulfillableQuantity'];
      int orderItemCount = data['orderItemCount'] ?? 0;
      int daysInInterval = 31;

      if (orderItemCount == 0) return 0;

      return ((fulfillableQuantity * daysInInterval) / orderItemCount).toInt();
    } else {
      return 0;
    }
  }

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
                  backgroundColor: AppColors.beige,
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
                      selectedRange = args.value;
                    }
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel',
                  style: TextStyle(color: AppColors.gold),),
                  onPressed: () {
                    _selectedTime = 'Last 12 months';
                    String range =
                                  DateUtilsHelper.getDateRange(_selectedTime);
                              _fetchData(range);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Apply',
                   style: TextStyle(color: AppColors.gold)),
                  onPressed: () {
                    if (selectedRange != null) {
                      setState(() {
                        String range =
                                  DateUtilsHelper.getDateRangeFromDates(selectedRange?.startDate, selectedRange?.endDate);
                        _fetchData(range);
                      });
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
}
