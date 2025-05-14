import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MultiTypeBarChart extends StatelessWidget {
  final List<double> barValues;
  final List<double> lineValues;

  MultiTypeBarChart({required this.barValues, required this.lineValues});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BarChart(
          BarChartData(
            barGroups: _generateBarGroups(),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              drawVerticalLine: false,
              drawHorizontalLine: true,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey, // Grid line color
                strokeWidth: 1, 
                dashArray: [], // Solid lines
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(
                      "M${value.toInt() + 1}",
                      style: TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: _generateLineSpots(),
                  isCurved: true,
                  barWidth: 3,
                  belowBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: true),
                  color: Colors.red, // Line color
                ),
              ],
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  /// 📊 Generate Bar Chart Data
  List<BarChartGroupData> _generateBarGroups() {
    return List.generate(barValues.length, (index) {
      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(toY: barValues[index], color: Colors.blue, width: 16)
      ]);
    });
  }

  /// 📈 Generate Line Chart Data
  List<FlSpot> _generateLineSpots() {
    return List.generate(lineValues.length, (index) => FlSpot(index.toDouble(), lineValues[index]));
  }
}
