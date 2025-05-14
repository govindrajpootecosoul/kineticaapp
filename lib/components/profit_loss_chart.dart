import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WaterfallChart extends StatelessWidget {
  final List<Map<String, dynamic>> profitLossData;

  WaterfallChart({required this.profitLossData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.5, // Adjust for horizontal view
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.start,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Text(
                        profitLossData[value.toInt()]["title"],
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.right,
                      ),
                    );
                  },
                  reservedSize: 120,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: _buildWaterfallBars(),
          ),
        ),
      ),
    );
  }

 List<BarChartGroupData> _buildWaterfallBars() {
  double runningTotal = 0;
  List<BarChartGroupData> bars = [];

  for (int index = 0; index < profitLossData.length; index++) {
    print(index);
    double value = profitLossData[index]["value"].toDouble();
    double fromY = runningTotal;  // Start from current total
    double toY = runningTotal + value; // Add new value to total
    runningTotal = toY; // Update running total

    bars.add(
      BarChartGroupData(
        x: index, // Ensure `x` is within range
        barRods: [
          BarChartRodData(
            fromY: fromY,
            toY: toY,
            width: 12,
            color: value < 0 ? Colors.red : Colors.green,
          ),
        ],
      ),
    );
  }

  return bars;
}
}
