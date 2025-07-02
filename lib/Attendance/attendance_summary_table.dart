import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceSummaryTable extends StatelessWidget {
  final String userId;
  const AttendanceSummaryTable({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final subjRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('attendance_subjects');

    return StreamBuilder<QuerySnapshot>(
      stream: subjRef.snapshots(),
      builder: (context, subjSnap) {
        if (!subjSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final subjects = subjSnap.data!.docs.map((d) => d.id).toList();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Subject')),
              DataColumn(label: Text('Total Classes')),
              DataColumn(label: Text('Attendance %')),
            ],
            rows: subjects.map((subject) {
              return DataRow(cells: [
                DataCell(Text(subject)),
                DataCell(
                    _AttendanceCountCell(userId: userId, subject: subject)),
                DataCell(
                    _AttendancePercentCell(userId: userId, subject: subject)),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}

class _AttendanceCountCell extends StatelessWidget {
  final String userId;
  final String subject;
  const _AttendanceCountCell({required this.userId, required this.subject});

  @override
  Widget build(BuildContext context) {
    final recordsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('attendance_subjects')
        .doc(subject)
        .collection('records');
    return StreamBuilder<QuerySnapshot>(
      stream: recordsRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('0');
        final total = snapshot.data!.docs.length;
        return Text(total.toString());
      },
    );
  }
}

class _AttendancePercentCell extends StatelessWidget {
  final String userId;
  final String subject;
  const _AttendancePercentCell({required this.userId, required this.subject});

  @override
  Widget build(BuildContext context) {
    final recordsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('attendance_subjects')
        .doc(subject)
        .collection('records');
    return StreamBuilder<QuerySnapshot>(
      stream: recordsRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('0%');
        final docs = snapshot.data!.docs;
        final total = docs.length;
        final present = docs
            .where((doc) => (doc.data() as Map)['status'] == 'Present')
            .length;
        final percent = total == 0 ? 0 : (present / total * 100);
        return Text('${percent.toStringAsFixed(1)}%');
      },
    );
  }
}
