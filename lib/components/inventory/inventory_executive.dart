import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/formatNumberStringWithComma.dart';

import '../../utils/ApiConfig.dart';

class InventoryExecutivePage extends StatefulWidget {
  const InventoryExecutivePage({Key? key}) : super(key: key);

  @override
  State<InventoryExecutivePage> createState() => _InventoryExecutivePageState();
}

List<dynamic> inventoryList = [];
bool isLoading = true;
String error = '';
String Amazoninventorysum = '00';
String LTSFsum = '00';
String Storagecostsum = '00';
String DaysInStock = '00';
String DOSsum = '00';

class _InventoryExecutivePageState extends State<InventoryExecutivePage> {
  @override
  void initState() {
    super.initState();
    fetchExecutiveData();
  }

  double calculateTotalEstimatedStorageCost(List<dynamic> data) {
    double totalCost = 0.0;

    for (var item in data) {
      final cost = double.tryParse(
          item['estimated_storage_cost_next_month'].toString()) ??
          0.0;
      totalCost += cost;
    }
    // Round to nearest whole number
    return totalCost.roundToDouble();
  }

  double calculateTotalDaysInStock(List<dynamic> data) {
    double totalCost = 0.0;

    for (var item in data) {
      final cost = double.tryParse(
          item['Days_In_Stock'].toString()) ??
          0.0;
      totalCost += cost;
    }
    // Round to nearest whole number
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

    // Round to nearest whole number
    return total.roundToDouble();
  }


  Future<void> fetchExecutiveData() async {
    try {
      var dio = Dio();
      var response = await dio.get('${ApiConfig.baseUrl}/inventory');
      //var response = await dio.get(ApiConfig.ukInventory);

      if (response.statusCode == 200) {
        setState(() {
          inventoryList = response.data;
          int totalQuantity = getTotalFulfillableQuantity(inventoryList);
          print("Total afn_fulfillable_quantity: $totalQuantity");
          Amazoninventorysum = formatNumberStringWithComma(totalQuantity.toString());;

          int totalsdtorageQuantity = getTotalDOSQuantity(inventoryList);
          print("Storage sum: $totalsdtorageQuantity");
          // DOSsum=totalsdtorageQuantity.toString();
          double totalEstimatedStorageCost = calculateTotalEstimatedStorageCost(inventoryList);
          print("Total Estimated Storage Cost: £${totalEstimatedStorageCost.toStringAsFixed(2)}");
          double totalAisCost = calculateTotalEstimatedAisCost(inventoryList);
          double totaldayinstock = calculateTotalDaysInStock(inventoryList);
          print("Total estimated AIS cost: £${totalAisCost.toStringAsFixed(2)}");
          LTSFsum= formatNumberStringWithComma(totalAisCost.toString());
          DaysInStock= formatNumberStringWithComma(totaldayinstock.toString());
         // DaysInStock= formatNumberStringWithComma(Days_In_Stock.toString());

          // int StorageCost = getStorageCostQuantity(inventoryList);
          // print("Storage cost sum: $StorageCost");
          // Storagecostsum=StorageCost.toString();

          // Storagecostsum = storageCostSum.toString();
          Storagecostsum = formatNumberStringWithComma(totalEstimatedStorageCost.toString());

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
    DOSsum = formatNumberStringWithComma(roundedAverage.toString()); // Shows rounded integer

    // Print total and average to the console
    print('Total Days of Supply: $total');
    print('Rounded Average Days of Supply: $DOSsum');

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Storage Cost',
                  value: "£ ${Storagecostsum}",
                  description: 'Estimated cost for next month',
                  // value: inventoryList[1].SKU,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'LTSF Cost',
                  value: "£ ${LTSFsum}",
                  description: 'Storage cost for stock (more than 180 days)',
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Amazon Inventory',
                  value: Amazoninventorysum,
                  description: 'As of Today',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'DOS',
                  value: "${DOSsum} Days",
                  description: 'For all SKU Average basis',
                ),
              ),


            ],
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String description; // New field

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.description, // Required param
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFFAEB),
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
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}