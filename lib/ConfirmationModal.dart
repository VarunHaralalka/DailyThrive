import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(
  BuildContext context, {
  String title = 'Confirm Changes',
  String content = 'Are you sure you want to make these changes?',
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
          ),
          child:
              Text(confirmLabel, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
