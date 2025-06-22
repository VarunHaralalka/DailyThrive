import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../appbar.dart';
import 'Expenses_Table.dart';
import 'AddEntry.dart';
import 'CategoryBoxBuilder.dart';
import 'PieChart.dart';

class ExpensesPage extends StatefulWidget {
  static const id = 'ExpensesPage';
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Expense Tracker'),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("users")
            .doc(currentUser?.uid)
            .collection("expenses")
            .orderBy("date", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Calculate category totals (case-insensitive)
          Map<String, double> categoryTotals = {};
          double totalAmount = 0;
          for (var doc in snapshot.data!.docs) {
            String category = doc["category"].toString().toLowerCase();
            double amount = double.tryParse(doc["amount"].toString()) ?? 0;
            categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
            totalAmount += amount;
          }

          return Column(
            children: [
              Expanded(
                flex: 2,
                child: ExpensePieChart(categoryTotals: categoryTotals),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildCategoryLegend(categoryTotals),
              ),
              Expanded(
                flex: 3,
                child: ExpensesTable(userId: currentUser?.uid ?? ""),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddEntry(userId: currentUser?.uid ?? ""),
        ),
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
