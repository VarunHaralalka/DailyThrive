import 'package:flutter/material.dart';
import 'HelperFunctions.dart';

Widget buildCategoryLegend(Map<String, double> categoryTotals) {
  return Wrap(
    alignment: WrapAlignment.center,
    spacing: 12,
    runSpacing: 8,
    children: categoryTotals.entries.map((entry) {
      String category = entry.key;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            color: getCategoryColor(category),
          ),
          const SizedBox(width: 4),
          Text(
            category[0].toUpperCase() + category.substring(1),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      );
    }).toList(),
  );
}
