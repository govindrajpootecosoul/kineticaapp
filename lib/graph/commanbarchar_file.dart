import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartSample extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final bool isWeb;

  const BarChartSample({required this.values, required this.labels, Key? key, this.isWeb = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //double maxY = values.reduce((a, b) => a > b ? a : b) + 00;
    double maxY = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) + 10 : 10;

    return Container(
      height: isWeb ? 450 : 270,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
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
                reservedSize: 52,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
          ),
          barGroups: List.generate(values.length, (index) => makeGroupData(index, values[index])),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          width: isWeb ? 20 : 30,
          toY: y,
          color: Color(0xFF073349),
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    int index = value.toInt();
    if (index >= labels.length) return SizedBox.shrink();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 2,
      child: Text(labels[index], style: TextStyle(fontSize: 10)),
    );
  }
}
