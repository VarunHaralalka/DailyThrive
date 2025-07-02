import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HelperFunctions.dart';
import 'DeleteEntry.dart';
import 'EditEntry.dart';

class ExpensesTable extends StatelessWidget {
  final String userId;
  const ExpensesTable({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("expenses")
          .orderBy("date", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var expenses = snapshot.data!.docs;

        if (expenses.isEmpty) {
          return const Center(
            child: Text(
              "No expenses added yet.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              horizontalMargin: 8,
              columns: const [
                DataColumn(
                    label: Text('Date',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Category',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Amount',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('      Actions',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: expenses.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: Text(
                          formatDate(data['date']),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: getCategoryColor(data['category'])
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          capitalize(data['category']),
                          style: TextStyle(
                            color: getCategoryColor(data['category']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        "₹${data['amount']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.edit, size: 18),
                            color: Colors.blue,
                            onPressed: () =>
                                editEntryDialog(context, userId, doc),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.delete, size: 18),
                            color: Colors.red,
                            onPressed: () => deleteExpense(doc.id, userId),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
