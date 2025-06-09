
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class InventoryGraph extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const InventoryGraph({
    required this.values,
    required this.labels,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<_Category> all = List.generate(
      labels.length,
          (index) => _Category(label: labels[index], value: values[index]),
    );

    all.sort((a, b) => b.value.compareTo(a.value));

    List<_Category> topFive = all.take(5).toList();
    List<_Category> others = all.skip(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topFive.isNotEmpty) _buildSection("Top 5 Product Categories By Stock", topFive),
       // if (others.isNotEmpty)_buildExpandableSection("Other Categories", others),
      ],
    );
  }

  Widget _buildSection(String title, List<_Category> data) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _HorizontalBarChart(
              categories: data,
              maxY: data.map((e) => e.value).reduce(max) + 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(String title, List<_Category> data) {
    return Padding(
      //padding: const EdgeInsets.all(0),
      padding: const EdgeInsets.only(top: 2),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: _HorizontalBarChart(
              categories: data,
              maxY: data.map((e) => e.value).reduce(max) + 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _Category {
  final String label;
  final double value;

  _Category({required this.label, required this.value});
}

class _HorizontalBarChart extends StatelessWidget {
  final List<_Category> categories;
  final double maxY;

  const _HorizontalBarChart({required this.categories, required this.maxY});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 1, right: 1),
      child: SizedBox(
        height: categories.length * 15,
        child: RotatedBox(
          quarterTurns: 1,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  tooltipPadding: const EdgeInsets.all(6),
                  tooltipRoundedRadius: 8,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${categories[group.x].label}\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: rod.toY.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.yellowAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 110,
                    getTitlesWidget: (value, meta) =>
                        _getLabel(value, meta, categories),
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              barGroups: List.generate(categories.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: categories[index].value,
                      width: 8,
                      color: const Color(0xFF073349),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getLabel(double value, TitleMeta meta, List<_Category> data) {
    int index = value.toInt();
    if (index >= data.length) return const SizedBox.shrink();

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 1,
      child: RotatedBox(
        quarterTurns: -1,
        child: SizedBox(
          width: 100,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              data[index].label,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
    );
  }
}
