import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ConfirmationModal.dart';

void showAttendanceBySubjectDialog(BuildContext context, String userId) async {
  final subjRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('attendance_subjects');
  final subjectsSnap = await subjRef.get();

  String? selectedSubject;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Attendance by Subject'),
            content: Column(
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
                const SizedBox(height: 12),
                if (selectedSubject != null)
                  SizedBox(
                    height: 300,
                    width: 340,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('attendance_subjects')
                          .doc(selectedSubject)
                          .collection('records')
                          .orderBy('date')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No attendance records found.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        final records = snapshot.data!.docs;
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columnSpacing: 8,
                            columns: const [
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: records.map((doc) {
                              final data = doc.data() as Map;
                              return DataRow(cells: [
                                DataCell(Text(
                                    data['date'].toString().split('T').first)),
                                DataCell(Text(data['status'])),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      onPressed: () async {
                                        final confirmed =
                                            await showConfirmationDialog(
                                          context,
                                          content:
                                              'Are you sure you want to edit this record?',
                                          confirmLabel: 'Edit',
                                        );
                                        if (confirmed == true) {
                                          _showEditAttendanceDialog(context,
                                              userId, selectedSubject!, doc);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          size: 18, color: Colors.red),
                                      onPressed: () async {
                                        final confirmed =
                                            await showConfirmationDialog(
                                          context,
                                          content:
                                              'Are you sure you want to delete this record?',
                                          confirmLabel: 'Delete',
                                        );
                                        if (confirmed == true) {
                                          await doc.reference.delete();
                                        }
                                      },
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showEditAttendanceDialog(BuildContext context, String userId,
    String subject, QueryDocumentSnapshot doc) {
  String? newStatus;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Attendance'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Change status:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  newStatus = 'Present';
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Present'),
              ),
              ElevatedButton(
                onPressed: () {
                  newStatus = 'Absent';
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
      ),
    ),
  ).then((_) async {
    if (newStatus != null) {
      await doc.reference.update({'status': newStatus});
    }
  });
}
