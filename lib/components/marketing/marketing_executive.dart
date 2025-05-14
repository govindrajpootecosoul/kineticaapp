import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/info_card.dart';
import 'package:flutter_application_1/components/profit_loss.dart';
import 'package:flutter_application_1/utils/api_service.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:flutter_application_1/utils/data_mapping_serive.dart';
import 'package:flutter_application_1/utils/date_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../barchart.dart'; // Import Bar Chart Component

class MarketingExecutivePage extends StatefulWidget {
  @override
  _MarketingExecutivePageState createState() => _MarketingExecutivePageState();
}

class _MarketingExecutivePageState extends State<MarketingExecutivePage> {
  int _selectedIndex = 0;
  String _selectedUnits = "Units Sold";
  String _selectedTime = "Month to date";
  String _selectedChannel = "Amazon";
  final List<double> chartData = [10, 20, 30, 15, 40, 10, 20, 23, 33]; // Example data
  String _selectedRegion = "United States"; // Default region
  String errorMessage = '';
   List<dynamic> responseData = []; // Store API response
   List<dynamic> totalResponseData = []; 
  bool isLoading = false;
  bool isTotalValuesLoading = false;
  
  Map<String, String> uiFields = {
    "unitCount": "Total Orders",
    "orderItemCount": "Total Items Ordered",
    "orderCount": "Total Orders",
    "averageUnitPrice": "Average Price Per Unit",
    "totalSales": "Total Revenue"
  };

   List<Map<String, dynamic>> cardData1 = [];
  


  List<Map<String, dynamic>> cardData = [];

 List<Map<String, dynamic>> cardData2 = [];

  String _fetchGranularity(String selectedTime) {
  if (selectedTime == "Today" || selectedTime == "Yesterday") {
    return "Day";
  } else if (selectedTime == "Week") {
    return "Week";
  } else if (selectedTime == "Month") {
    return "Month";
  } else if (selectedTime == "Year") {
    return "Year";
  } else if (selectedTime == "Last Week" || selectedTime == "Last Month" || selectedTime == "This Month" || selectedTime == "Last 30 days") {
    return "Day";
  } else if (selectedTime == "Last Year" || selectedTime == "Last 6 months" || selectedTime == "Last 12 months") {
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

  final result = await ApiService.fetchAnalytics(
    provider: "AMAZON",
    models: "orders",
    region: "IN",
    dateRange: dateRange,
    granularity: _fetchGranularity(_selectedTime),
    timeParameter: _selectedTime
  );

  setState(() {
    isLoading = false;
    if (result.containsKey("error")) {
      errorMessage = result["error"];
    } else {
      responseData = result["data"]["getOrders"];
    }
  });

  // final totalValues = await ApiService.fetchAnalytics(
  //   provider: "AMAZON",
  //   models: "orders",
  //   region: "IN",
  //   dateRange: dateRange,
  //   granularity: "Total"
  // );


  // setState(() {
  //   isTotalValuesLoading = false;
  //   if (totalValues.containsKey("error")) {
  //     errorMessage = totalValues["error"];
  //   } else {
  //     totalResponseData = totalValues['data']['getOrders'];
  //     // cardData = DataMapping.formatApiResponse(totalResponseData[0], uiFields);
  //   }
  // });
  }

   Widget _buildDropdown(String label, List<String> items, String selectedValue, Function(String?) onChanged) {
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

  void _showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CM1", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Revenue: XXX"),
                Text("Refund: XXX"),
                SizedBox(height: 10),
                Text("CM2", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
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
    cardData1 = [{
    "title": "Ad spend",
    "value": "41360.89",
    "percentChange": "22%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "Ad sales",
    "value": "46044.79",
    "percentChange": "7%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "Ad Unit Sold",
    "value": "1353",
    "percentChange": "6%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "ACOS",
    "value": "89.83%",
    "percentChange": "14%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "TACOS",
    "value": "40.26%",
    "percentChange": "40.26%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "ROAS",
    "value": "1.11",
    "percentChange": "-12%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "TROAS",
    "value": "2.48",
    "percentChange": "2.48%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "Overall sales",
    "value": "102723.01",
    "percentChange": "7%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "Organic Sales",
    "value": "56678.22",
    "percentChange": "7%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "Organic Sales %",
    "value": "55.18",
    "percentChange": "0%",
     "comparedTo": getComparativePeriod(_selectedTime)
  }
];

cardData = [
  {
    "title": "Impressions",
    "value": "12702728",
    "percentChange": "-15%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "Clicks",
    "value": "15459",
    "percentChange": "10%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "CTR",
    "value": "0.12%",
    "percentChange": "33%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "CPC",
    "value": "2.68",
    "percentChange": "10%",
     "comparedTo": getComparativePeriod(_selectedTime)
  }
];

cardData2 = [
  {
    "title": "NTB units",
    "value": "77",
    "percentChange": "-35%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "NTB Unit %",
    "value": "60.16",
    "percentChange": "-6%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "NTB sales",
    "value": "2826.25",
    "percentChange": "-35%",
     "comparedTo": getComparativePeriod(_selectedTime)
  },
  {
    "title": "NTB sales %",
    "value": "58.85",
    "percentChange": "62%",
     "comparedTo": getComparativePeriod(_selectedTime)
  }
];


  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? SpinKitWave(
                                color: AppColors.gold,
                                size: 50.0,
                              ) : Scaffold(
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
                          yAxisMetric: 'orderCount',
                          granularity: _fetchGranularity(_selectedTime),
                        ),
                        SizedBox(height: 10),
                        Divider(color: AppColors.gold, thickness: 0.5), // Adds a line
                        SizedBox(height: 10),
                        SizedBox(
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                        Divider(color: AppColors.gold, thickness: 0.5), 
                        SizedBox(
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.7,
                            ),
                            itemCount: cardData1.length,
                            itemBuilder: (context, index) {
                              final card = cardData1[index];
                              return CommonCardComponent(
                                title: card["title"],
                                value: card["value"],
                                percentChange: card["percentChange"],
                                comparedTo: card["comparedTo"],
                              );
                            },
                          ),
                              ),
                         Divider(color: AppColors.gold, thickness: 0.5), // Adds a line
                          SizedBox(
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.7,
                            ),
                            itemCount: cardData2.length,
                            itemBuilder: (context, index) {
                              final card = cardData2[index];
                              return CommonCardComponent(
                                title: card["title"],
                                value: card["value"],
                                percentChange: card["percentChange"],
                                comparedTo: card["comparedTo"],
                              );
                            },
                          ),
                              ),
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