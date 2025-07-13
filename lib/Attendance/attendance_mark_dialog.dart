import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void showAttendanceMarkDialog(BuildContext context, String userId) async {
  final subjRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('attendance_subjects');
  final subjectsSnap = await subjRef.get();

  String? selectedSubject;
  DateTime selectedDate = DateTime.now();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Mark Attendance'),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Select Subject',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => selectedSubject = value),
                items: subjectsSnap.docs.map((doc) {
                  return DropdownMenuItem(
                    value: doc.id,
                    child: Text(doc.id),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  DateFormat('dd-MM-yyyy').format(selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() => selectedDate = pickedDate);
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: selectedSubject == null
                        ? null
                        : () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('attendance_subjects')
                                .doc(selectedSubject)
                                .collection('records')
                                .add({
                              'date': selectedDate.toIso8601String(),
                              'status': 'Present',
                            });
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Present'),
                  ),
                  ElevatedButton(
                    onPressed: selectedSubject == null
                        ? null
                        : () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('attendance_subjects')
                                .doc(selectedSubject)
                                .collection('records')
                                .add({
                              'date': selectedDate.toIso8601String(),
                              'status': 'Absent',
                            });
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Absent'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );
}
