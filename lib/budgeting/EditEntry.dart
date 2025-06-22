import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditEntry extends StatefulWidget {
  final String userId;
  final String docId;
  final Map<String, dynamic> currentData;

  const EditEntry({
    super.key,
    required this.userId,
    required this.docId,
    required this.currentData,
  });

  @override
  State<EditEntry> createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  late TextEditingController _categoryController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _categoryController =
        TextEditingController(text: widget.currentData['category']);
    _amountController =
        TextEditingController(text: widget.currentData['amount']);
    _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.currentData['date']);
  }

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

  void _updateData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("expenses")
          .doc(widget.docId)
          .update({
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
      title: const Text("Edit Expense", textAlign: TextAlign.center),
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
          onPressed: _updateData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
          ),
          child: const Text("UPDATE", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
