import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/utils/colors.dart';
import 'package:intl/intl.dart';

class BarChartComponent extends StatelessWidget {
  final List<dynamic> apiData;
  final String granularity; // "Day", "Month", etc.
  final String yAxisMetric; // "totalSales", "unitCount", etc.

  const BarChartComponent({
    Key? key,
    required this.apiData,
    required this.granularity,
    required this.yAxisMetric,
  }) : super(key: key);

  List<BarChartGroupData> generateBarGroups() {
    List<BarChartGroupData> barGroups = [];
    
    for (int i = 0; i < apiData.length; i++) {
      var entry = apiData[i];
      double yValue = extractMetric(entry, yAxisMetric);
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: yValue,
              color: AppColors.primaryBlue,
              width: granularity == "Day" ? 10 : 20,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  String formatInterval(String interval, String granularity) {
    DateTime startDate = DateTime.parse(interval.split('--')[0]).toLocal();
    if (granularity == "Month") {
      return DateFormat.MMM().format(startDate);
    } else if (granularity == "Day") {
      int day = startDate.day;
      if (day % 5 == 0 || day == 1) {
        return DateFormat.MMMd().format(startDate);
      } else {
        return "";
      }
    } else {
      return DateFormat.yMd().format(startDate);
    }
  }

  double extractMetric(Map<String, dynamic> entry, String metric) {
    if (metric == "totalSales") {
      return entry["totalSales"]["amount"].toDouble();
    } else if (metric == "unitCount") {
      return entry["unitCount"].toDouble();
    } else if (metric == "orderCount") {
      return entry["orderCount"].toDouble();
    } else {
      return 0.0;
    }
  }

  String formatYAxisLabel(double value) {
    if (value >= 1000000000) {
        return  "${(value ~/ 1000000000).toInt()}B";
      } else if (value >= 1000000) {
        return  "${(value ~/ 1000000).toInt()}M";
      } else if (value >= 10000) {
        return  "${(value ~/ 1000).toInt()}K";
      }
    return value.toInt().toString();
  }

double getMaxYValue() {
  double maxVal = apiData.map((e) => extractMetric(e, yAxisMetric)).reduce((a, b) => a > b ? a : b);

  if (maxVal == 0) return 6; // Default minimum value

  int exponent = (maxVal / 6).floor().toString().length - 1; // Determine exponent based on maxVal
  double base = pow(10, exponent).toDouble(); // Find the power of 10
  double roundedMax = (maxVal / (6 * base)).ceil() * (6 * base);

  return roundedMax;
}

  @override
  Widget build(BuildContext context) {
    double maxY = getMaxYValue();
    return AspectRatio(
      aspectRatio: 2,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: generateBarGroups(),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: maxY / 7 != 0 ? maxY/7 : null,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.gold,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: getMaxYValue()/7,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    formatYAxisLabel(value),
                    style: TextStyle(fontSize: 7),
                  );
                },
              ),
              axisNameSize: 2,
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
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value < apiData.length) {
                    return Text(
                      formatInterval(apiData[value.toInt()]['interval'], granularity),
                      style: TextStyle(fontSize: 10),
                    );
                  }
                  return Text('');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
