import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'ExpenseEntryDialog.dart';

void editEntryDialog(
    BuildContext context, String userId, QueryDocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;

  showDialog(
    context: context,
    builder: (context) => ExpenseEntryDialog(
      title: "Edit Expense",
      actionLabel: "UPDATE",
      initialCategory: data['category'],
      initialAmount: data['amount'],
      initialDate: DateFormat('yyyy-MM-dd').parse(data['date']),
      onSubmit: (category, amount, date) async {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("expenses")
            .doc(doc.id)
            .update({
          "date": DateFormat('yyyy-MM-dd').format(date),
          "category": category,
          "amount": amount,
        });
      },
    ),
  );
}
