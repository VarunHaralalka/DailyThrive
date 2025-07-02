import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EditEntry.dart';

String formatDate(String dateStr) {
  try {
    final date = DateFormat('yyyy-MM-dd').parse(dateStr);
    return DateFormat('dd-MM-yy').format(date);
  } catch (e) {
    return dateStr;
  }
}

String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

Color getCategoryColor(String category) {
  final normalizedCategory = category.toLowerCase();
  final colorMap = {
    'food': Colors.blue,
    'transport': Colors.green,
    'entertainment': Colors.orange,
    'shopping': Colors.purple,
    'utilities': Colors.red,
    'other': Colors.teal,
  };
  return colorMap[normalizedCategory] ??
      Colors.primaries[normalizedCategory.hashCode % Colors.primaries.length];
}
