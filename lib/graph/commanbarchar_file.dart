/*
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
          barTouchData: BarTouchData(enabled: true,

            touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '£${rod.toY.toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
          ),

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




*/



// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class BarChartSample extends StatelessWidget {
//   final List<double> values;
//   final List<String> labels;
//   final bool isWeb;

//   const BarChartSample({
//     required this.values,
//     required this.labels,
//     Key? key,
//     this.isWeb = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     double maxY = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0;
//     print("");
//     return Container(
//       height: isWeb ? 450 : 280,
//       child: BarChart(
//         BarChartData(
//           alignment:
//           values.length <= 12 ? BarChartAlignment.start : BarChartAlignment.spaceAround,
//           maxY: maxY + maxY * 0.0, // add 10% padding at top
//           barTouchData: BarTouchData(
//             enabled: true,
//             touchTooltipData: BarTouchTooltipData(
//               tooltipBgColor: Colors.black87,
//               getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                 return BarTooltipItem(
//                   '£${rod.toY.toStringAsFixed(0)}',
//                   const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 );
//               },
//             ),
//           ),
//           titlesData: FlTitlesData(
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 25,
//                 getTitlesWidget: (value, meta) {
//                   String text;
//                   if (value >= 1000) {
//                     double valInK = value / 1000;
//                     int rounded = valInK.round();
//                     text = '${rounded}k';
//                   } else {
//                     text = value.toStringAsFixed(0);
//                   }
//                   return SideTitleWidget(
//                     axisSide: meta.axisSide,
//                     space: 6,
//                     child: Text(
//                       text,
//                       style: const TextStyle(
//                         fontSize: 8,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   );
//                 },
//               ),
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
//                 reservedSize: 30,
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
//           barGroups: List.generate(
//             values.length,
//                 (index) => makeGroupData(index, values[index]),
//           ),
//         ),
//       ),
//     );
//   }

//   BarChartGroupData makeGroupData(int x, double y) {
//     return BarChartGroupData(
//       x: x,
//       barRods: [
//         BarChartRodData(
//           width: isWeb ? 10 : 10,
//           toY: y,
//           color: const Color(0xFF073349),
//           borderRadius: BorderRadius.circular(2),
//         ),
//       ],
//     );
//   }

//   Widget getBottomTitles(double value, TitleMeta meta) {
//     int index = value.toInt();

//     // Show label only for whole integer values within label range
//     if (value % 1 != 0 || index < 0 || index >= labels.length) {
//       return const SizedBox.shrink();
//     }

//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       space: 4,
//       child: Text(
//         labels[index],
//         style: const TextStyle(fontSize: 8),
//       ),
//     );
//   }
// }


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
    // Reverse the values and labels for correct left-to-right order
    final reversedValues = values.reversed.toList();
    final reversedLabels = labels.reversed.toList();

    double maxY = reversedValues.isNotEmpty ? reversedValues.reduce((a, b) => a > b ? a : b) : 0;

    return Container(
      height: isWeb ? 450 : 280,
      child: BarChart(
        BarChartData(
          alignment: reversedValues.length <= 12
              ? BarChartAlignment.start
              : BarChartAlignment.spaceAround,
          maxY: maxY + maxY * 0.0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '£${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25,
                getTitlesWidget: (value, meta) {
                  String text;
                  if (value >= 1000) {
                    text = '${(value / 1000).round()}k';
                  } else {
                    text = value.toStringAsFixed(0);
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 6,
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 8, color: Colors.black87),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => getBottomTitles(value, meta, reversedLabels),
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
            reversedValues.length,
                (index) => makeGroupData(index, reversedValues[index]),
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
          width: isWeb ? 10 : 10,
          toY: y,
          color: const Color(0xFF073349),
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta, List<String> localLabels) {
    int index = value.toInt();
    if (value % 1 != 0 || index < 0 || index >= localLabels.length) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        localLabels[index],
        style: const TextStyle(fontSize: 8),
      ),
    );
  }
}