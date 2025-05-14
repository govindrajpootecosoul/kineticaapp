import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SalesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SalesScreen(),
    );
  }
}

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Map<String, dynamic>? salesData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

  Future<void> fetchSalesData() async {
    var url = Uri.parse('http://192.168.50.92:4000/api/sales/resion?filterType=year&state=Worcestershire');
    var request = http.Request('GET', url);
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        setState(() {
          salesData = json.decode(data);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.reasonPhrase ?? "Failed to fetch data.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sales Data')),
      body:

      isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Total Quantity: ${salesData!['totalQuantity']}", style: TextStyle(fontSize: 18)),
            Text("Total Sales: \$${salesData!['totalSales'].toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text("Monthly Breakdown:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...List.generate(salesData!['breakdown'].length, (index) {
              final item = salesData!['breakdown'][index];
              return ListTile(
                title: Text("${item['date']}"),
                subtitle: Text("Quantity: ${item['totalQuantity']} - Sales: \$${item['totalSales'].toStringAsFixed(2)}"),
              );
            }),
            SizedBox(height: 20),
            Text("Comparison:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Previous Quantity: ${salesData!['comparison']['previousTotalQuantity']}"),
            Text("Previous Sales: \$${salesData!['comparison']['previousTotalSales'].toStringAsFixed(2)}"),
            Text("Quantity Change: ${salesData!['comparison']['quantityChangePercent']}"),
            Text("Sales Change: ${salesData!['comparison']['salesChangePercent']}"),
          ],
        ),
      ),
    );
  }
}
