import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'ExpenseEntryDialog.dart'; // Import the reusable dialog

void addEntry(BuildContext context, String userId) {
  showDialog(
    context: context,
    builder: (context) => ExpenseEntryDialog(
      title: "Add New Expense",
      actionLabel: "ADD",
      onSubmit: (category, amount, date) async {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("expenses")
            .add({
          "date": DateFormat('yyyy-MM-dd').format(date),
          "category": category,
          "amount": amount,
        });
      },
    ),
  );
}
