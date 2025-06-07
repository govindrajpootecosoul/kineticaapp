import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/formatNumberStringWithComma.dart';

import '../../utils/ApiConfig.dart';
import '../../utils/colors.dart';
import '../Dashboard.dart';
import 'inventory_graph/product_category.dart'; // Your InventoryScreen is here?

class InventoryExecutivePage extends StatefulWidget {
  const InventoryExecutivePage({Key? key}) : super(key: key);

  @override
  State<InventoryExecutivePage> createState() => _InventoryExecutivePageState();
}

class _InventoryExecutivePageState extends State<InventoryExecutivePage> {
  List<dynamic> inventoryList = [];
  bool isLoading = true;
  String error = '';
  String Amazoninventorysum = '00';
  String LTSFsum = '00';
  String Storagecostsum = '00';
  String DaysInStock = '00';
  String DOSsum = '00';

  String WarehouseInventoryv = '00';
  String TotalSelleablev = '00';
  String InventoryAgev0_91 = '00';
  String InventoryAgev91_270 = '00';
  String Customereservedv = '00';
  String  FcTransferv= '00';
  String  FcProcessingv= '00';
  String  MTQv= '00';
  String  InstockRatev= '00';
  String  Daysinstockv= '00';
  String  Totaldayv= '00';
  String  Inventoryvaluev= '00';
  String  SellableStockvaluev= '00';

  @override
  void initState() {
    super.initState();
    fetchExecutiveData();
  }

  double calculateTotalEstimatedStorageCost(List<dynamic> data) {
    double totalCost = 0.0;

    for (var item in data) {
      final cost =
          double.tryParse(item['estimated_storage_cost_next_month'].toString()) ??
              0.0;
      totalCost += cost;
    }
    return totalCost.roundToDouble();
  }

  double calculateTotalDaysInStock(List<dynamic> data) {
    double totalCost = 0.0;

    for (var item in data) {
      final cost = double.tryParse(item['Days_In_Stock'].toString()) ?? 0.0;
      totalCost += cost;
    }
    return totalCost.roundToDouble();
  }

  double calculateTotalEstimatedAisCost(List<dynamic> data) {
    double total = 0.0;

    for (var item in data) {
      item.forEach((key, value) {
        if (key.startsWith("estimated_ais_")) {
          final cost = double.tryParse(value.toString()) ?? 0.0;
          total += cost;
        }
      });
    }
    return total.roundToDouble();
  }


  // buildLabelValueExpend("Warehouse Inventory", product['afn_warehouse_quantity'] ?? "00"),
  double Total_Warehouse_Inventory(List<dynamic> data) {
    double total = 0.0;

    for (var item in data) {
      item.forEach((key, value) {
        if (key.startsWith("afn_warehouse_quantity")) {
          final cost = double.tryParse(value.toString()) ?? 0.0;
          total += cost;
        }
      });
    }
    return total.roundToDouble();
  }
  // buildLabelValueExpend("Total Sellable", product['afn_fulfillable_quantity'] ?? "00"),
  double Total_Sellable(List<dynamic> data) {
    double total = 0.0;

    for (var item in data) {
      item.forEach((key, value) {
        if (key.startsWith("afn_fulfillable_quantity")) {
          final cost = double.tryParse(value.toString()) ?? 0.0;
          total += cost;
        }
      });
    }
    return total.roundToDouble();
  }
  // buildLabelValueExpend("Inventory Age", (product['inv_age_0_to_30_days'] ?? "00")+(product['inv_age_31_to_60_days'] ?? "00")+(product['inv_age_61_to_90_days'] ?? "00")+(product['inv_age_91_to_180_days'] ?? "00")+(product['inv_age_181_to_270_days'] ?? "00")+(product['inv_age_271_to_365_days'] ?? "00")+(product['inv_age_365_plus_days'] ?? "00")),

  double Inventory_Age01to90(List<dynamic> data) {
    double total = 0.0;

    for (var item in data) {
      item.forEach((key, value) {
        if (key == "inv_age_0_to_30_days"||
         key == "inv_age_31_to_60_days" ||
         key == "inv_age_61_to_90_days"
        // key == "inv_age_91_to_180_days"||
        // key == "inv_age_181_to_270_days"||
        // key == "inv_age_271_to_365_days"||
        // key == "inv_age_365_plus_days"

        ) {
          final cost = double.tryParse(value.toString()) ?? 0.0;
          total += cost;
        }
      });
    }

    return total.roundToDouble();
  }
  double Inventory_Age91to270(List<dynamic> data) {
    double total = 0.0;

    for (var item in data) {
      item.forEach((key, value) {
        if (
        //key == "inv_age_0_to_30_days"
        // key == "inv_age_31_to_60_days" ||
        // key == "inv_age_61_to_90_days"||
         key == "inv_age_91_to_180_days"||
         key == "inv_age_181_to_270_days"
        // key == "inv_age_271_to_365_days"||
        // key == "inv_age_365_plus_days"

        ) {
          final cost = double.tryParse(value.toString()) ?? 0.0;
          total += cost;
        }
      });
    }

    return total.roundToDouble();
  }



  // //buildLabelValueExpend("DOS", product['days_of_supply'] ?? "00"),
  // buildLabelValueExpend("Customer Reserved", product['Customer_reserved'] ?? "00"),
  double Customer_reserved(List<dynamic> data) {
    double total = 0.0;

    for (var item in data) {
      item.forEach((key, value) {
        if (key.startsWith("Customer_reserved")) {
          final cost = double.tryParse(value.toString()) ?? 0.0;
          total += cost;
        }
      });
    }
    return total.roundToDouble();
  }

  // buildLabelValueExpend("FC Transfer", product['FC_Transfer'] ?? "00"),
  double FC_Transfer(List<dynamic> data) {
    double total = 0.0;

    for (var item in data) {
      item.forEach((key, value) {
        if (key.startsWith("FC_Transfer")) {
          final cost = double.tryParse(value.toString()) ?? 0.0;
          total += cost;
        }
      });
    }
    return total.roundToDouble();
  }
  // buildLabelValueExpend("FC Processing", product['FC_Processing'] ?? "00"),
  double FC_Processing(List<dynamic> data) {
    double total = 0.0;

    for (var item in data) {
      item.forEach((key, value) {
        if (key.startsWith("FC_Processing")) {
          final cost = double.tryParse(value.toString()) ?? 0.0;
          total += cost;
        }
      });
    }
    return total.roundToDouble();
  }
  //
  //
  // buildLabelValueExpend("MTQ", product['MTQ'] ?? "00"),
  double MTQ_(List<dynamic> data) {
    double total = 0.0;

    for (var item in data) {
      item.forEach((key, value) {
        if (key.startsWith("MTQ")) {
          final cost = double.tryParse(value.toString()) ?? 0.0;
          total += cost;
        }
      });
    }
    return total.roundToDouble();
  }

  double Inventoryvalue(List<dynamic> data) {
    double total = 0.0;

    for (var item in data) {
      item.forEach((key, value) {
        if (key.startsWith("WH_Stock_Value")) {
          final cost = double.tryParse(value.toString()) ?? 0.0;
          total += cost;
        }
      });
    }
    return total.roundToDouble();
  }
  double Sellable_Stock_Valuee(List<dynamic> data) {
    double total = 0.0;

    for (var item in data) {
      item.forEach((key, value) {
        if (key.startsWith("Sellable_Stock_Value")) {
          final cost = double.tryParse(value.toString()) ?? 0.0;
          total += cost;
        }
      });
    }
    return total.roundToDouble();
  }
  // buildLabelValueExpend("Instock Rate", "${product['InStock_Rate_Percent']} %" ?? "00"),
  // double InStock_Rate_Percentt(List<dynamic> data) {
  //   double total = 0.0;
  //
  //   for (var item in data) {
  //     item.forEach((key, value) {
  //       if (key.startsWith("InStock_Rate_Percent")) {
  //         final cost = double.tryParse(value.toString()) ?? 0.0;
  //         total += cost;
  //       }
  //     });
  //   }
  //   return total.roundToDouble();
  // }


  int InStock_Rate_Percentt(List<dynamic> data) {
    double totalCost = 0.0;
    int count = 0;

    for (var item in data) {
      final cost = double.tryParse(item['InStock_Rate_Percent'].toString());
      if (cost != null) {
        totalCost += cost;
        count++;
      }
    }

    if (count == 0) return 0;

    // Return rounded whole number
    return (totalCost / count).round();
  }


  // buildLabelValueExpend("Days In Stock", "${product['Days_In_Stock']}/${product['Total_Days']}" ?? "00"),
  // double Days_In_Stockk(List<dynamic> data) {
  //   double total = 0.0;
  //
  //   for (var item in data) {
  //     item.forEach((key, value) {
  //       if (key.startsWith("Days_In_Stock/Total_Days")) {
  //         final cost = double.tryParse(value.toString()) ?? 0.0;
  //         total += cost;
  //       }
  //     });
  //   }
  //   return total.roundToDouble();
  // }

  // double Days_In_Stockk(List<dynamic> data) {
  //   double total = 0.0;
  //
  //   for (var item in data) {
  //     final stock = double.tryParse(item["Days_In_Stock"]?.toString() ?? '0') ?? 0.0;
  //     final totalDays = double.tryParse(item["Total_Days"]?.toString() ?? '1') ?? 1.0;
  //
  //     if (totalDays != 0) {
  //       total += stock / totalDays;
  //     }
  //   }
  //   return total.roundToDouble();
  // }

  double Days_In_Stockk(List<dynamic> data) {
    double total = 0.0;

    for (var item in data) {
      item.forEach((key, value) {
        if (key.startsWith("Days_In_Stock")) {
          final cost = double.tryParse(value.toString()) ?? 0.0;
          total += cost;
        }
      });
    }
    return total.roundToDouble();
  }

  double Total_Days(List<dynamic> data) {
    double total = 0.0;

    for (var item in data) {
      item.forEach((key, value) {
        if (key.startsWith("Total_Days")) {
          final cost = double.tryParse(value.toString()) ?? 0.0;
          total += cost;
        }
      });
    }
    return total.roundToDouble();
  }


  Future<void> fetchExecutiveData() async {
    try {
      var dio = Dio();
      var response = await dio.get('${ApiConfig.baseUrl}/inventory');

      if (response.statusCode == 200) {
        setState(() {
          inventoryList = response.data;

          int totalQuantity = getTotalFulfillableQuantity(inventoryList);
          Amazoninventorysum = formatNumberStringWithComma(totalQuantity.toString());

         // int totalQuantity = Total_Warehouse_Inventory(inventoryList);
          Amazoninventorysum = formatNumberStringWithComma(totalQuantity.toString());

          double totalEstimatedStorageCost = calculateTotalEstimatedStorageCost(inventoryList);
          double totalAisCost = calculateTotalEstimatedAisCost(inventoryList);
          double totalDaysInStock = calculateTotalDaysInStock(inventoryList);
          double Warehouse_Inventory = Total_Warehouse_Inventory(inventoryList);
          double Totall_Sellable = Total_Sellable(inventoryList);
          double Customer_reservedd = Customer_reserved(inventoryList);
          double FC_Transferr = FC_Transfer(inventoryList);
          double FC_Processingg = FC_Processing(inventoryList);
          double MTQq = MTQ_(inventoryList);
          int InStock_Rate_Percent = InStock_Rate_Percentt(inventoryList);
          double Days_In_Stoc = Days_In_Stockk(inventoryList);
          double Total_Day = Total_Days(inventoryList);
          double Inventory_Agee91 = Inventory_Age01to90(inventoryList);
          double Inventory_Agee270 = Inventory_Age91to270(inventoryList);
          double Inventoryvaluee = Inventoryvalue(inventoryList);
          double Sellable_Stock_Value = Sellable_Stock_Valuee(inventoryList);

          LTSFsum = formatNumberStringWithComma(totalAisCost.toString());
          DaysInStock = formatNumberStringWithComma(totalDaysInStock.toString());
          Storagecostsum = formatNumberStringWithComma(totalEstimatedStorageCost.toString());

          WarehouseInventoryv = formatNumberStringWithComma(Warehouse_Inventory.toString());
          TotalSelleablev = formatNumberStringWithComma(Totall_Sellable.toString());
          Customereservedv = formatNumberStringWithComma(Customer_reservedd.toString());
          FcTransferv = formatNumberStringWithComma(FC_Transferr.toString());
          FcProcessingv = formatNumberStringWithComma(FC_Processingg.toString());
          MTQv = formatNumberStringWithComma(MTQq.toString());
          InstockRatev= formatNumberStringWithComma(InStock_Rate_Percent.toString());
          Daysinstockv= formatNumberStringWithComma(Days_In_Stoc.toString());
          Totaldayv= formatNumberStringWithComma(Total_Day.toString());
          InventoryAgev0_91= formatNumberStringWithComma(Inventory_Agee91.toString());
          InventoryAgev91_270= formatNumberStringWithComma(Inventory_Agee270.toString());
          Inventoryvaluev= formatNumberStringWithComma(Inventoryvaluee.toString());
          SellableStockvaluev= formatNumberStringWithComma(Sellable_Stock_Value.toString());




          int totalDOSQuantity = getTotalDOSQuantity(inventoryList);
          DOSsum = formatNumberStringWithComma(totalDOSQuantity.toString());

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
    DOSsum = formatNumberStringWithComma(roundedAverage.toString());

    print('Total Days of Supply: $total');
    print('Rounded Average Days of Supply: $DOSsum');

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // appBar: AppBar(title: const Text('Inventory Executive')),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
            ? Center(child: Text(error))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // InventoryScreen should handle its own height dynamically
              InventoryScreen(),

              const SizedBox(height: 16),

              // Row(
              //   children: [
              //     Expanded(
              //       child: MetricCard(
              //         title: 'Storage Cost',
              //         value: "£ $Storagecostsum",
              //         description: 'Estimated cost for next month',
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: MetricCard(
              //         title: 'LTSF Cost',
              //         value: "£ $LTSFsum",
              //         description:
              //         'Storage cost for stock (more than 180 days)',
              //       ),
              //     ),
              //   ],
              // ),
              //
              // const SizedBox(height: 16),
              //
              // Row(
              //   children: [
              //     Expanded(
              //       child: MetricCard(
              //         title: 'Amazon Inventory',
              //         value: Amazoninventorysum,
              //         description: 'As of Today',
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: MetricCard(
              //         title: 'DOS',
              //         value: "$DOSsum Days",
              //         description: 'For all SKU Average basis',
              //       ),
              //     ),
              //   ],
              // ),
              //

              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child:Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [

                      Row(
                        children: [
                          Expanded(
                            child: MetriccardExecutive(
                              title: 'Storage Cost',
                              value: "£ $Storagecostsum",
                              compared: "Next Month",
                            ),
                          ),

                          const SizedBox(width: 8),
                          Expanded(
                            child: MetriccardExecutive(
                              title: 'Storage Cost',
                              value: "£ 00",
                              //value: '$zeroInStockRateSkuCount',
                              compared: "Previous Month",

                              // value: "${(((adssales?['totalAdSales'] ?? 0) / (adssales?['totalAdSpend'] ?? 1)) * 100).toStringAsFixed(2)} %",

                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Row(
                        children: [
                          Expanded(
                            child: MetriccardExecutive(
                              title: 'LTSF Cost',
                              value: "£ $LTSFsum",
                              //value:"\$overstockCount",
                              compared: "",
                              // value: "${(((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0))/(salesData?['totalSales'] ?? 0.0)*100).toStringAsFixed(2)} %",
                            ),
                          ),

                          const SizedBox(width: 8),
                          Expanded(
                            child: MetriccardExecutive(
                              title: "DOS",
                              value: "$DOSsum",
                              //value: "\$understockCount",
                              compared: "",
                              // value: "${(((adssales?['totalAdSales'] ?? 0) / (adssales?['totalAdSpend'] ?? 1)) * 100).toStringAsFixed(2)} %",

                            ),
                          ),
                        ],
                      ),

                    ],),
                  )
              ),
              SizedBox(height: 8,),
              // Text.rich(
              //   TextSpan(
              //     children: [
              //       TextSpan(
              //         text: 'Inventory ',
              //         style: TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //       TextSpan(
              //         text: 'as of today',
              //         style: TextStyle(
              //           fontSize: 14,
              //           fontWeight: FontWeight.w400,
              //         ),
              //       ),
              //     ],
              //   ),
              //   textAlign: TextAlign.center,
              // ),

              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child:Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [

                      Row(
                        children: [
                          Expanded(
                            child: MetriccardExecutive(
                              title: "Warehouse Inventory",
                              value: "${WarehouseInventoryv} units",
                              compared: "WH Stock Value: £${Inventoryvaluev}",
                            ),
                          ),

                          const SizedBox(width: 8),
                          Expanded(
                            child: MetriccardExecutive(
                              title: "Total Sellable",
                              value: '${TotalSelleablev} units',
                              //value: '$zeroInStockRateSkuCount',
                              compared: "Stock Value: £${SellableStockvaluev}",

                              // value: "${(((adssales?['totalAdSales'] ?? 0) / (adssales?['totalAdSpend'] ?? 1)) * 100).toStringAsFixed(2)} %",

                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Row(
                        children: [
                          Expanded(
                            child: MetriccardExecutive(
                              title: "FC Transfer",
                              value: "${FcTransferv} units",
                              compared: "",
                            ),
                          ),

                          const SizedBox(width: 8),
                          Expanded(
                            child: MetriccardExecutive(
                              title: "FC Processing",
                              value: '${FcProcessingv} units',
                              //value: '$zeroInStockRateSkuCount',
                              compared: "",

                              // value: "${(((adssales?['totalAdSales'] ?? 0) / (adssales?['totalAdSpend'] ?? 1)) * 100).toStringAsFixed(2)} %",

                            ),
                          ),
                        ],
                      ),



                    ],),
                  )
              ),
              const SizedBox(height: 8),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child:Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [



                      Row(
                        children: [
                          Expanded(
                            child: MetriccardExecutive(
                              title: "Customer Reserved",
                              value: "${Customereservedv} units",
                              //value: "\$understockCount",
                              compared: "units",
                              // value: "${(((adssales?['totalAdSales'] ?? 0) / (adssales?['totalAdSpend'] ?? 1)) * 100).toStringAsFixed(2)} %",

                            ),
                          ),

                          const SizedBox(width: 8),
                          Expanded(
                            child: MetriccardExecutive(
                              title: "Total Reserved",
                              value: "${TotalSelleablev} units",
                              //value: "\$understockCount",
                              compared: "",
                              // value: "${(((adssales?['totalAdSales'] ?? 0) / (adssales?['totalAdSpend'] ?? 1)) * 100).toStringAsFixed(2)} %",

                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Row(
                        children: [
                          Expanded(
                            child: MetriccardExecutive(
                              title: "Inventory Age",
                              //value:"00",
                              value:"${InventoryAgev0_91} units",
                              compared: "(0-91 Days)",
                              // value: "${(((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0))/(salesData?['totalSales'] ?? 0.0)*100).toStringAsFixed(2)} %",
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: MetriccardExecutive(
                              title: "Inventory Age",
                              //value:"00",
                              value:"${InventoryAgev91_270} units",
                              compared: "(91-270 Days)",
                              // value: "${(((salesData?['totalSales'] ?? 0.0) - (adssales?['totalAdSales'] ?? 0.0))/(salesData?['totalSales'] ?? 0.0)*100).toStringAsFixed(2)} %",
                            ),
                          ),


                        ],
                      ),

                    ],),
                  )
              ),


              const SizedBox(height: 8),

              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child:Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [


                      Row(
                        children: [

                          Expanded(
                            child: MetriccardExecutive(
                              title: " Avg. Instock Rate",
                              value: "${InstockRatev} %",
                              //value: "\$understockCount",
                              compared: "",
                              // value: "${(((adssales?['totalAdSales'] ?? 0) / (adssales?['totalAdSpend'] ?? 1)) * 100).toStringAsFixed(2)} %",

                            ),
                          ),


                          const SizedBox(width: 8),
                          Expanded(
                            child: MetriccardExecutive(
                              title: "Active Stock OOS",
                              value: zeroInStockRateSkuCount.toString(),
                              //value: "\$understockCount",
                              compared: "",
                              // value: "${(((adssales?['totalAdSales'] ?? 0) / (adssales?['totalAdSpend'] ?? 1)) * 100).toStringAsFixed(2)} %",

                            ),
                          ),
                        ],
                      ),

                    ],),
                  )
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String description;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEB),
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
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}


class MetriccardExecutive extends StatelessWidget {
  final String title;
  final String value;
  final String compared;

  const MetriccardExecutive(
      {super.key,
        required this.title,
        required this.value,
        required this.compared});

  @override
  Widget build(BuildContext context) {
    //  print(compared);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, style: const TextStyle(fontSize: 16),
            // textAlign: TextAlign.left
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon(
                //   compared.contains('Profit')
                //       ? Icons.arrow_upward
                //       : Icons.arrow_downward,
                //   size: 14,
                //   color:
                //   compared.contains('Profit') ? Colors.green : Colors.red,
                // ),
                const SizedBox(width: 4),
                Text(
                  compared, // e.g., "219.93%"
                  style: TextStyle(
                    color:Colors.brown,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    //  color: compared.contains('Profit') ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}