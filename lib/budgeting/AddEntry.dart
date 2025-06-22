import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEntry extends StatefulWidget {
  final String userId;
  const AddEntry({super.key, required this.userId});

  @override
  State<AddEntry> createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("expenses")
          .add({
        "date": DateFormat('yyyy-MM-dd').format(_selectedDate),
        "category": _categoryController.text.trim(),
        "amount": _amountController.text.trim(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Expense", textAlign: TextAlign.center),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('dd-MM-yy').format(_selectedDate)),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _pickDate(context),
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: "Category",
                prefixIcon: Icon(Icons.category),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a category' : null,
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: "Amount (₹)",
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter an amount' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCEL"),
        ),
        ElevatedButton(
          onPressed: _addData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
          ),
          child: const Text("ADD", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
