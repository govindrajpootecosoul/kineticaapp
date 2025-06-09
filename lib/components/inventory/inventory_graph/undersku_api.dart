import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/components/inventory/inventory_graph/understockgraph.dart';

import 'inventory_graph.dart';

class UnderskuApiscreen extends StatefulWidget {
  const UnderskuApiscreen({Key? key}) : super(key: key);

  @override
  _UnderskuApiscreenState createState() => _UnderskuApiscreenState();
}

class _UnderskuApiscreenState extends State<UnderskuApiscreen> {
  List<String> labels = [];
  List<double> values = [];
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
        'http://192.168.50.92:3000/api/inventory/productunders',//api/inventory/productoversku
      );

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
        UnderstockgraphScreen(values: values, labels: labels,),

      ],
    );
  }
}
