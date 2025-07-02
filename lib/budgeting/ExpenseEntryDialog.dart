import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ExpenseEntryDialog extends StatefulWidget {
  final String title;
  final String actionLabel;
  final String? initialCategory;
  final String? initialAmount;
  final DateTime? initialDate;
  final void Function(String category, String amount, DateTime date) onSubmit;

  const ExpenseEntryDialog({
    super.key,
    required this.title,
    required this.actionLabel,
    this.initialCategory,
    this.initialAmount,
    this.initialDate,
    required this.onSubmit,
  });

  @override
  State<ExpenseEntryDialog> createState() => _ExpenseEntryDialogState();
}

class _ExpenseEntryDialogState extends State<ExpenseEntryDialog> {
  late TextEditingController _categoryController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _categoryController =
        TextEditingController(text: widget.initialCategory ?? '');
    _amountController = TextEditingController(text: widget.initialAmount ?? '');
    _selectedDate = widget.initialDate ?? DateTime.now();
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

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _categoryController.text.trim(),
        _amountController.text.trim(),
        _selectedDate,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, textAlign: TextAlign.center),
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
          ),
          child: Text(widget.actionLabel,
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
