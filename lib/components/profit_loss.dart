// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/utils/colors.dart';
//
// class ProfitLossPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(title: Text("Profit & Loss")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: SizedBox(
//             height: 600,
//             width: 500,
//             child: WaterfallChart(),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class WaterfallChart extends StatelessWidget {
//   final List<Map<String, dynamic>> data = [
//     {"label": "Amazon Revenue", "value": 5643464.12, "positive": true},
//     {"label": "Amazon Returns", "value": -640980.80, "positive": false},
//     {"label": "Net Revenue", "value": 5000000.00, "positive": true},
//     {"label": "COGS", "value": -1000000.00, "positive": false},
//     {"label": "CM1", "value": 4000000.00, "positive": true},
//     {"label": "Inventory", "value": -300000.00, "positive": false},
//     {"label": "Liquidation Cost", "value": -5000.00, "positive": false},
//     {"label": "Reimbursement", "value": 200000.00, "positive": true},
//     {"label": "Storage Fee", "value": -200000.00, "positive": false},
//     {"label": "Shipping Service", "value": -800000.00, "positive": false},
//     {"label": "CM2", "value": 2500000.00, "positive": true},
//     {"label": "Ad Spend", "value": -1000000.00, "positive": false},
//     {"label": "Discounts", "value": -400000.00, "positive": false},
//     {"label": "Net Selling Fee", "value": -200000.00, "positive": false},
//     {"label": "Final Service Fee", "value": -5000.00, "positive": false},
//     {"label": "CM3", "value": 850000.00, "positive": true},
//   ];
//
//   List<BarChartGroupData> buildWaterfallBars() {
//     double cumulative = 0;
//     List<BarChartGroupData> bars = [];
//
//     for (int i = 0; i < data.length; i++) {
//       double previous = cumulative;
//       cumulative += data[i]["value"];
//
//       bars.add(
//         BarChartGroupData(
//           x: i,
//           barRods: [
//             // Background bar to indicate stacking
//             BarChartRodData(
//               fromY: previous / 1000000, // Scale down for better visibility
//               toY: cumulative / 1000000,
//               color: data[i]["positive"] ? AppColors.primaryBlue : AppColors.gold,
//               width: 16,
//               borderRadius: BorderRadius.zero,
//             ),
//           ],
//         ),
//       );
//     }
//     return bars;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BarChart(
//       BarChartData(
//         barGroups: buildWaterfallBars(),
//         alignment: BarChartAlignment.spaceAround,
//         titlesData: FlTitlesData(
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: true, interval: 1),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 if (value.toInt() >= data.length) return Container();
//                 return RotatedBox(
//                   quarterTurns: 3,
//                   child: Text(
//                     data[value.toInt()]["label"],
//                     style: TextStyle(fontSize: 10),
//                   ),
//                 );
//               },
//               reservedSize: 60,
//             ),
//           ),
//         ),
//         borderData: FlBorderData(show: false),
//         gridData: FlGridData(show: true),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

import '../utils/colors.dart';

class ProfitLossPage extends StatelessWidget {
  final List<FinanceItem> items = [
    FinanceItem('Amazon Revenue', 5643484.12),
    FinanceItem('Net Revenue', 500000),
    FinanceItem('COGS', -1000000),
    FinanceItem('CM1', 4000000),
    FinanceItem('Inventory', -300000),
    FinanceItem('Liquidation Cost', -5000),
    FinanceItem('Reimbursement', 400000),
    FinanceItem('Storage Fee', -200000),
    FinanceItem('Shipping Service', -300000),
    FinanceItem('GM2', 3900000),
    FinanceItem('Ad Spend', -1000000),
    FinanceItem('Discounts', -400000),
    FinanceItem('Net Selling Fee', -200000),
    FinanceItem('Final Service Fee', -8000),
    FinanceItem('GM3', 3500000),
  ];

  @override
  Widget build(BuildContext context) {
    // Find the maximum absolute value for bar scaling
    double maxValue = items.map((e) => e.amount.abs()).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png'),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Padding(
              padding: EdgeInsets.only(left: 8), // Add left padding
              child: Row(
                mainAxisSize: MainAxisSize.max, // Keeps Row compact
                children: [


                  //  InkWell(
                  //   onTap: () {
                  //     //Navigator.pop(context);
                  //   },
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Icon(Icons.arrow_back, color: Colors.white),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final barWidth = (item.amount.abs() / maxValue) * 200; // Max 200px width
            final isPositive = item.amount >= 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.title,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: barWidth,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${item.amount.abs().toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class FinanceItem {
  final String title;
  final double amount;

  FinanceItem(this.title, this.amount);
}
