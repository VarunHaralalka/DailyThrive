import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_mark_dialog.dart';
import 'attendance_by_subject.dart';
import '../ConfirmationModal.dart';

class AttendanceActions extends StatelessWidget {
  final String userId;
  const AttendanceActions({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 3.0,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddSubjectDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Subject'),
        ),
        ElevatedButton.icon(
          onPressed: () => _showDeleteSubjectDialog(context, userId),
          icon: const Icon(Icons.delete),
          label: const Text('Delete Subject'),
        ),
        ElevatedButton.icon(
          onPressed: () => showAttendanceMarkDialog(context, userId),
          icon: const Icon(Icons.check),
          label: const Text('Mark Attendance'),
        ),
        ElevatedButton.icon(
          onPressed: () => showAttendanceBySubjectDialog(context, userId),
          icon: const Icon(Icons.visibility),
          label: const Text('View Attendance'),
        ),
      ],
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Subject Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final subject = controller.text.trim();
              if (subject.isNotEmpty) {
                final subjRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('attendance_subjects');
                final exists = (await subjRef.doc(subject).get()).exists;
                if (!exists) {
                  await subjRef
                      .doc(subject)
                      .set({'createdAt': FieldValue.serverTimestamp()});
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteSubjectDialog(BuildContext context, String userId) async {
    final subjRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('attendance_subjects');
    final subjectsSnap = await subjRef.get();

    showDialog(
      context: context,
      builder: (context) {
        String? selected;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Subject'),
              content: DropdownButton<String>(
                value: selected,
                hint: const Text('Select Subject'),
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    selected = value;
                  });
                },
                items: subjectsSnap.docs.map((doc) {
                  return DropdownMenuItem(
                    value: doc.id,
                    child: Text(doc.id),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selected == null
                      ? null
                      : () async {
                          // Delete all records for this subject
                          final confirmed = await showConfirmationDialog(
                            context,
                            content:
                                'Are you sure you want to delete this subject and all its attendance records?',
                            confirmLabel: 'Delete',
                          );
                          if (confirmed == true) {
                            // Delete logic...
                            final recordsRef =
                                subjRef.doc(selected).collection('records');
                            final recordsSnap = await recordsRef.get();
                            for (var doc in recordsSnap.docs) {
                              await doc.reference.delete();
                            }
                            await subjRef.doc(selected).delete();
                            Navigator.pop(context);
                          }
                        },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
