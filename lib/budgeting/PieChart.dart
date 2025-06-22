import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'HelperFunctions.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const ExpensePieChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const Center(
        child: Text(
          'No expenses to display',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    List<PieChartSectionData> sections = categoryTotals.entries.map((entry) {
      final color = getCategoryColor(entry.key);
      return PieChartSectionData(
        value: entry.value,
        color: color,
        radius: 60,
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: 40,
      ),
    );
  }
}
