// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
//
// import 'inventory_graph.dart';
//
// class InventoryScreen extends StatefulWidget {
//   @override
//   _InventoryScreenState createState() => _InventoryScreenState();
// }
//
// class _InventoryScreenState extends State<InventoryScreen> {
//   List<String> labels = [];
//   List<double> values = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchInventoryData();
//   }
//
//   Future<void> fetchInventoryData() async {
//     try {
//       var dio = Dio();
//       var response = await dio.get(
//         'http://192.168.50.92:3000/api/inventory/productcategorysum',
//       );
//
//       if (response.statusCode == 200) {
//         List<dynamic> data = response.data;
//
//         // Clear before filling new data
//         labels.clear();
//         values.clear();
//
//         for (var item in data) {
//           labels.add(item['_id'].toString());
//           values.add((item['WH_Stock_Value'] ?? 0).toDouble());
//         }
//
//         setState(() {
//           isLoading = false;
//         });
//       } else {
//         print("Error: ${response.statusMessage}");
//       }
//     } catch (e) {
//       print("Exception: $e");
//     }
//   }
//  // InventoryGraph(values: values, labels: labels, isWeb: isWeb),
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //appBar: AppBar(title: Text("Inventory Summary")),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           :
//       InventoryGraph(values: values, labels: labels,),
//
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'inventory_graph.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<String> labels = [];
  List<double> values = [];
  List<String> labelsunder = [];
  List<double> valuesunder = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInventoryData();
  }

  Future<void> fetchInventoryData() async {
    try {
      var dio = Dio();
      var response = await dio.get(
        // 'https://api.thrivebrands.ai/api/inventory/productcategorysum',
        'https://api.thrivebrands.ai/api/inventory/productoversku', //api/inventory/productoversku
      ); //https://api.thrivebrands.ai/api/inventory/productunders

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        print("response  ${data}");

        labels.clear();
        values.clear();

        for (var item in data) {
          labels.add(item['SKU'].toString());
          values.add((item['days_of_supply'] ?? 0).toDouble());
        }

        setState(() {
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusMessage}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (labels.isEmpty || values.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Wrap in Column so it adapts height dynamically and dropdown can expand without overflow
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Your dropdown or other widgets here (if any)
        // For example: DropdownButton widget for filtering

        // Graph widget
        InventoryGraph(values: values, labels: labels, idd: "oversku"),
      ],
    );
  }
}
