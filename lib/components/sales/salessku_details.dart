import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/barchart.dart';
import 'package:flutter_application_1/components/info_card.dart';
import 'package:flutter_application_1/utils/api_service.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/custom_dropdown.dart';
import 'package:flutter_application_1/utils/data_mapping_serive.dart';
import 'package:flutter_application_1/utils/date_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
// Import Bar Chart Component

class SalesskuDetails extends StatefulWidget {
  final VoidCallback onButtonPressed;
  final Map<String, dynamic> productData;

  const SalesskuDetails(
      {required this.onButtonPressed, required this.productData});

  @override
  _SalesskuDetailsState createState() => _SalesskuDetailsState();
}

class _SalesskuDetailsState extends State<SalesskuDetails> {
  int _selectedIndex = 0;
  String _selectedUnits = "Units Sold";
  String _selectedTime = "Month to date";
  String _selectedChannel = "Amazon";
  final List<double> chartData = [
    10,
    20,
    30,
    15,
    40,
    10,
    20,
    23,
    33
  ]; // Example data
  String _selectedRegion = "United States"; // Default region
  String errorMessage = '';
  List<dynamic> responseData = []; // Store API response
  List<dynamic> totalResponseData = [];
  bool isLoading = false;
  bool isTotalValuesLoading = false;
  String updatedAt = "";
  final List<Map<String, dynamic>> data = [
    {"label": "Amazon Revenue", "value": 5643464.12, "positive": true},
    {"label": "Amazon Returns", "value": -640980.80, "positive": false},
    {"label": "Net Revenue", "value": 5000000.00, "positive": true},
    {"label": "COGS", "value": -1000000.00, "positive": false},
    {"label": "CM1", "value": 4000000.00, "positive": true},
    {"label": "Inventory", "value": -300000.00, "positive": false},
    {"label": "Liquidation Cost", "value": -5000.00, "positive": false},
    {"label": "Reimbursement", "value": 200000.00, "positive": true},
    {"label": "Storage Fee", "value": -200000.00, "positive": false},
    {"label": "Shipping Service", "value": -800000.00, "positive": false},
    {"label": "CM2", "value": 2500000.00, "positive": true},
    {"label": "Ad Spend", "value": -1000000.00, "positive": false},
    {"label": "Discounts", "value": -400000.00, "positive": false},
    {"label": "Net Selling Fee", "value": -200000.00, "positive": false},
    {"label": "Final Service Fee", "value": -5000.00, "positive": false},
    {"label": "CM3", "value": 850000.00, "positive": true},
  ];

  String _fetchGranularity(String selectedTime) {
    if (selectedTime == "Today" || selectedTime == "Yesterday" || selectedTime == "Month to date") {
      return "Day";
    } else if (selectedTime == "Week" || selectedTime == "Custom") {
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
        selectedTime == "Last 12 months" || selectedTime == "Year to date") {
      return "Month";
    } else {
      return "Day";
    }
  }

  Map<String, String> uiFields = {
    "unitCount": "Units Ordered",
    "orderItemCount": "Total Items Ordered",
    "orderCount": "Total Orders",
    "averageUnitPrice": "Average Price Per Unit",
    "totalSales": "Total Revenue"
  };
  List<Map<String, dynamic>> cardData = [];

  void _fetchData(String dateRange) async {
    setState(() {
      isLoading = true;
      isTotalValuesLoading = true;
      errorMessage = "";
    });
    final result = await ApiService.fetchAnalytics(
        provider: "AMAZON",
        models: "orders",
        region: "IN",
        dateRange: dateRange,
        granularity: _fetchGranularity(_selectedTime),
        asin: widget.productData['asin'],
        timeParameter: _selectedTime);

        var time = result['data']['updatedAt'];
          DateTime dateTime = DateTime.parse(time).toLocal(); 
          updatedAt = DateFormat('h:mm a').format(dateTime) + " IST";

    setState(() {
      isLoading = false;
      if (result.containsKey("error")) {
        errorMessage = result["error"];
      } else {
        responseData = result["data"]["getOrders"];
      }
    });

    final totalValues = await ApiService.fetchAnalytics(
        provider: "AMAZON",
        models: "orders",
        region: "IN",
        dateRange: dateRange,
        granularity: "Total",
        asin: widget.productData['asin'],
        timeParameter: _selectedTime);

    setState(() {
      isTotalValuesLoading = false;
      if (result.containsKey("error")) {
        errorMessage = result["error"];
      } else {
        totalResponseData = totalValues['data']['getOrders'];
        cardData =
            DataMapping.formatApiResponse(totalResponseData[0], uiFields, _selectedTime);
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
    String range = DateUtilsHelper.getDateRange(_selectedTime);
    _fetchData(range);
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
                    'Sales',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 20,
                  ),
                ],
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDropdown(
                    "Units Sold",
                          ["Units Sold", "Product Sales"], _selectedUnits,
                    (newValue) {
                  setState(() {
                    _selectedUnits = newValue!;
                  });
                }),
                _buildDropdown(
                    "Channel", ["Amazon", "eBay", "Shopify"], _selectedChannel,
                    (newValue) {
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
                    'Custom'
                  ],
                  _selectedTime,
                  (newValue) {
                    setState(() {
                      _selectedTime = newValue!;
                       if (_selectedTime == 'Custom') {
                              _showDateRangePicker(context);
                            } else {
                              String range =
                                  DateUtilsHelper.getDateRange(_selectedTime);
                              _fetchData(range);
                            }
                    });
                  },
                )
              ],
            ),
          ),
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
                        isLoading
                            ? SpinKitWave(
                                color: AppColors.gold,
                                size: 50.0,
                              )
                            : BarChartComponent(
                                apiData: responseData,
                                yAxisMetric: _selectedUnits == 'Units Sold' ? 'unitCount' : 'totalSales',
                                granularity: _fetchGranularity(_selectedTime),
                              ),
                        SizedBox(height: 10),
                        SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Updated ${updatedAt}',
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.bold
                                    ),
                                  )
                                ],
                              ),
                        Divider(
                            color: AppColors.gold,
                            thickness: 0.5), // Adds a line
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
                                          widget.productData['name']
                                                .toString() ?? "Unknown Product",
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
                                                      widget.productData["sku"] ?? "N/A",
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
                                                      widget.productData["asin"] ?? "N/A",
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
                                              
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]))),
                        isTotalValuesLoading
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
                                      percentChange: card["percentChange"],
                                      comparedTo: card["comparedTo"],
                                    );
                                  },
                                ),
                              ),
                              isLoading
                                  ? SizedBox(height: 10)
                                  : TextButton(
                                      onPressed: () {
                                        // Add your action here
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: AppColors.beige,
                                              title:
                                                  Text('Profit & Loss Summary',
                                                  style: TextStyle(
                                                    color: AppColors.gold
                                                  ),),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: data.map((item) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            item['label'],
                                                            style: TextStyle(
                                                              color: AppColors.gold,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            '\$${item['value'].toStringAsFixed(2)}',
                                                            style: TextStyle(
                                                              color: item[
                                                                      'positive']
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text('Close',
                                                  style: TextStyle(
                                                    color: AppColors.brown
                                                  ),),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //       builder: (context) => ProfitLossPage()),
                                        // );
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center, // Centers the text
                                        children: [
                                          Text(
                                            'View SKU P&L',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.gold,
                                            ),
                                          ),
                                          SizedBox(
                                              width:
                                                  8), // Space between text and icon
                                          Icon(Icons.arrow_forward,
                                              color: AppColors.gold),
                                        ],
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
