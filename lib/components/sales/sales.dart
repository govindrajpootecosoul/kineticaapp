import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/info_card.dart';
import 'package:flutter_application_1/components/profit_loss.dart';
import 'package:flutter_application_1/utils/api_service.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/custom_dropdown.dart';
import 'package:flutter_application_1/utils/data_mapping_serive.dart';
import 'package:flutter_application_1/utils/date_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../barchart.dart'; // Import Bar Chart Component

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  int _selectedIndex = 0;
  String _selectedDateRange = "";
  String _selectedUnits = "Units Sold";
  String _selectedTime = "Month to date";
  String _selectedChannel = "Amazon";
  String updatedAt = "";
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

  Map<String, String> uiFields = {
    "unitCount": "Units Ordered",
    "totalSales": "Overall Sales",
  };
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

  List<Map<String, dynamic>> cardData = [];

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

  void _fetchData(String dateRange) async {
    setState(() {
      isLoading = true;
      isTotalValuesLoading = true;
      errorMessage = "";
    });

    try {
      // Run both API calls in parallel
      final results = await Future.wait([
        ApiService.fetchAnalytics(
          provider: "AMAZON",
          models: "orders",
          region: "IN",
          dateRange: dateRange,
          granularity: _fetchGranularity(_selectedTime),
          timeParameter: _selectedTime,
        ),
        ApiService.fetchAnalytics(
          provider: "AMAZON",
          models: "orders",
          region: "IN",
          dateRange: dateRange,
          granularity: "Total",
          timeParameter: _selectedTime,
        ),
      ]);

      final ordersResult = results[0];
      final totalValuesResult = results[1];

      setState(() {
        isLoading = false;
        isTotalValuesLoading = false;

        // Handling errors
        if (ordersResult.containsKey("error")) {
          errorMessage = ordersResult["error"];
        } else {
          responseData = ordersResult["data"]["getOrders"];
        }

        if (totalValuesResult.containsKey("error")) {
          errorMessage = totalValuesResult["error"];
        } else {
          totalResponseData = totalValuesResult['data']['getOrders'];
          var data = totalResponseData[0];
          double totalSales = data["totalSales"]["amount"];
          int totalOrders = data["orderCount"];
          var time = totalValuesResult['data']['updatedAt'];
          DateTime dateTime = DateTime.parse(time).toLocal(); 
          updatedAt = DateFormat('h:mm a').format(dateTime) + " IST";
          double aov = totalOrders > 0 ? totalSales / totalOrders : 0.0;
          String modifiedAov = aov.toStringAsFixed(2);
          cardData =
              DataMapping.formatApiResponse(totalResponseData[0], uiFields, _selectedTime);
              cardData.addAll([
            {
              "title": "Ad Sales",
              "value": "42051",
              "percentChange": "4%",
               "comparedTo": getComparativePeriod(_selectedTime)
            },
            {
              "title": "Organic sale %",
              "value": "55.32",
              "percentChange": "6%",
               "comparedTo": getComparativePeriod(_selectedTime)
            },
             {
              "title": "AOV",
              "value": modifiedAov,
              "percentChange": "3%",
               "comparedTo": getComparativePeriod(_selectedTime)
            },
            {
              "title": "Units Returned",
              "value": "96",
              "percentChange": "4%",
               "comparedTo": getComparativePeriod(_selectedTime)
            },
            {
              "title": "Return Value",
              "value": "4261",
              "percentChange": "4%",
               "comparedTo": getComparativePeriod(_selectedTime)
            },
            {
              "title": "Return Value %",
              "value": "3.82",
              "percentChange": "4%",
               "comparedTo": getComparativePeriod(_selectedTime)
            }
          ]);
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isTotalValuesLoading = false;
        errorMessage = "An error occurred: $e";
      });
    }
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
    return isLoading
        ? SpinKitWave(
            color: AppColors.gold,
            size: 50.0,
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDropdown(
                          "Units Sold",
                          ["Units Sold", "Product Sales"],
                          _selectedUnits, (newValue) {
                        setState(() {
                          _selectedUnits = newValue!;
                        });
                      }),
                      _buildDropdown("Channel", ["Amazon", "eBay", "Shopify"],
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
                                      granularity:
                                          _fetchGranularity(_selectedTime),
                                    ),
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
                              isLoading
                                  ? SizedBox(height: 10)
                                  : SizedBox(
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            NeverScrollableScrollPhysics(),
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
                                            percentChange:
                                                card["percentChange"],
                                            comparedTo: card["comparedTo"],
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

  String getComparativePeriod(String period) {
  switch (period) {
    case "Today":
      return "Yesterday";
    case "This week":
      return "Last week";
    case "Last 30 days":
      return "Previous 30 days";
    case "Last 6 months":
      return "Previous 6 months";
    case "Last 12 months":
      return "Previous 12 months";
    case "Month to date":
      return "last month";
    case "Year to date":
      return "last year";
    default:
      return "Unknown period";
  }
  }
}
