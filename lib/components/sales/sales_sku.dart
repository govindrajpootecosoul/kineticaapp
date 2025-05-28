import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/sales/salessku_details.dart';
import 'package:flutter_application_1/utils/api_service.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/currency_handler.dart';
import 'package:flutter_application_1/utils/custom_dropdown.dart';
import 'package:flutter_application_1/utils/date_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SalesSkuPage extends StatefulWidget {
  final VoidCallback onButtonPressed;

  const SalesSkuPage({required this.onButtonPressed});

  @override
  _SalesSkuPageState createState() => _SalesSkuPageState();
}

class _SalesSkuPageState extends State<SalesSkuPage> {
  bool isDetailsSelected = false;
  int _selectedIndex = 0;
  String _selectedUnits = "Total Orders";
  String _selectedTime = "Month to date";
  String _selectedChannel = "Amazon";
  Map<String, dynamic> selectedProduct = {};
  bool isLoading = false;
  String errorMessage = "";
  List<dynamic> responseData = [];
  String currencySymbol = "";

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
        models: "salesBySku",
        region: "IN",
        dateRange: dateRange,
        granularity: 'Total',
        timeParameter: _selectedTime);

    setState(() {
      isLoading = false;
      if (result.containsKey("error")) {
        errorMessage = result["error"];
      } else {
        products = result["data"]["fetchSalesBySku"];
      }
    });
  }

  Widget _buildDropdown(String label, List<String> items, String selectedValue,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      dropdownColor: AppColors.white,
      decoration: customInputDecoration(
        hintText: "Select Filter Type",
      ),
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
    _loadCurrencySymbol();
  }

  Future<void> _loadCurrencySymbol() async {
    String symbol = await getCurrencySymbol();
    print(symbol);
    setState(() {
      currencySymbol = symbol;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isDetailsSelected
        ? SalesskuDetails(
            onButtonPressed: onBackPressed, productData: selectedProduct)
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
                            _buildDropdown(
                              "Select Time Range",
                              [
                                "Today",
                                "This week",
                                "Last 30 days",
                                "Last 6 months",
                                "Last 12 months",
                                "Month to date",
                                "Year to date",
                                "Custom"
                              ],
                              _selectedTime,
                              (newValue) {
                                setState(() {
                                  _selectedTime = newValue!;
                                  if (_selectedTime == 'Custom') {
                                    _showDateRangePicker(context);
                                  } else {
                                    String range = DateUtilsHelper.getDateRange(
                                        _selectedTime);
                                    _fetchData(range);
                                  }
                                });
                              },
                            )
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
                                          product["name"] ?? "Unknown Product",
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
                                        // ClipRRect(
                                        //   borderRadius:
                                        //       BorderRadius.circular(8),
                                        //   child: Image.asset(
                                        //     'assets/product_image.jpg',
                                        //     width: 120,
                                        //   ),
                                        // ),
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
                                                    width:
                                                        130, // Adjust width as needed
                                                    child: Text(
                                                      product["sku"] ?? "N/A",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryBlue,
                                                        fontSize: 18,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        130, // Adjust width as needed
                                                    child: Text(
                                                      textAlign:
                                                          TextAlign.right,
                                                      product["asin"] ?? "N/A",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryBlue,
                                                        fontSize: 18,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                                  Text("Unit Ordered",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              AppColors.gold)),
                                                  Text("Overall Sales",
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
                                                      "${product["unitCount"] ?? 0}", // Directly using API field
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryBlue,
                                                        fontSize: 18,
                                                      )),
                                                  Text(
                                                      "${currencySymbol} ${product["totalSales"]?["amount"] ?? 0}", // Corrected sales format
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryBlue,
                                                        fontSize: 18,
                                                      )),
                                                ],
                                              ),
                                              SizedBox(height: 6),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("Organic Sales %",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              AppColors.gold)),
                                                  Text("Return Revenue %",
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
                                                      "N/A", // No data in API for this
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryBlue,
                                                        fontSize: 18,
                                                      )),
                                                  Text(
                                                      "N/A", // No data in API for this
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                        color: AppColors
                                                            .primaryBlue,
                                                      )),
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
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.gold),
                  ),
                  onPressed: () {
                    _selectedTime = 'Last 12 months';
                    String range = DateUtilsHelper.getDateRange(_selectedTime);
                    _fetchData(range);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Apply', style: TextStyle(color: AppColors.gold)),
                  onPressed: () {
                    if (selectedRange != null) {
                      setState(() {
                        String range = DateUtilsHelper.getDateRangeFromDates(
                            selectedRange?.startDate, selectedRange?.endDate);
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
