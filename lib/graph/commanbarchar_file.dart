import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartSample extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final bool isWeb;

  const BarChartSample({
    required this.values,
    required this.labels,
    Key? key,
    this.isWeb = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double maxY = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0;

    return Container(
      height: isWeb ? 450 : 280,
      child: BarChart(
        BarChartData(
          alignment:
          values.length <= 12 ? BarChartAlignment.start : BarChartAlignment.spaceAround,
          maxY: maxY + maxY * 0.1, // add 10% padding at top
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                //interval: maxY / 4 > 0 ? maxY / 4 : 0,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 6,
                    child: Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.black87,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => getBottomTitles(value, meta),
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
          ),
          barGroups: List.generate(
            values.length,
                (index) => makeGroupData(index, values[index]),
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          width: isWeb ? 20 : 10,
          toY: y,
          color: const Color(0xFF073349),
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    int index = value.toInt();
    if (index >= labels.length) return const SizedBox.shrink();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        labels[index],
        style: const TextStyle(fontSize: 8), // smaller font size here
      ),
    );
  }
}






//
//
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
//
// class BarChartSample extends StatelessWidget {
//   final List<double> values;      // Active values only
//   final List<String> labels;      // Total labels (for X-axis)
//   final bool isWeb;
//   final int activeCount;          // Number of active (blue) bars
//
//   const BarChartSample({
//     required this.values,
//     required this.labels,
//     this.isWeb = false,
//     required this.activeCount,   // New field: how many bars should be blue
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     int totalBars = labels.length;
//
//     // Fill values with zeros if needed
//     List<double> allValues = List.from(values);
//     while (allValues.length < totalBars) {
//       allValues.add(0);
//     }
//
//     double maxY = allValues.isNotEmpty
//         ? allValues.reduce((a, b) => a > b ? a : b) +0
//         : 10;
//
//     return Container(
//       height: isWeb ? 450 : 270,
//       child: BarChart(
//         BarChartData(
//           alignment: BarChartAlignment.start,
//           maxY: maxY,
//           barTouchData: BarTouchData(enabled: true),
//           titlesData: FlTitlesData(
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(showTitles: true, reservedSize: 42),
//             ),
//             rightTitles: AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             topTitles: AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 32,
//                 getTitlesWidget: (value, meta) => getBottomTitles(value, meta),
//               ),
//             ),
//           ),
//           borderData: FlBorderData(show: false),
//           gridData: FlGridData(
//             show: true,
//             drawVerticalLine: false,
//             drawHorizontalLine: true,
//           ),
//           barGroups: List.generate(totalBars, (index) {
//             return makeGroupData(index, allValues[index], index < activeCount);
//           }),
//         ),
//       ),
//     );
//   }
//
//   BarChartGroupData makeGroupData(int x, double y, bool isActive) {
//     return BarChartGroupData(
//       x: x,
//       barRods: [
//         BarChartRodData(
//           width: isWeb ? 20 : 10,
//           toY: y,
//           color: isActive ? const Color(0xFF073349) : Colors.grey[300],
//           borderRadius: BorderRadius.circular(2),
//         ),
//       ],
//     );
//   }
//
//   Widget getBottomTitles(double value, TitleMeta meta) {
//     int index = value.toInt();
//     if (index < 0 || index >= labels.length) return const SizedBox.shrink();
//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       space: 4,
//       child: Text(
//         labels[index],
//         style: const TextStyle(fontSize: 10),
//       ),
//     );
//   }
// }



