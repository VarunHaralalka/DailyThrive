import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../appbar.dart';
import 'attendance_actions.dart';
import 'attendance_summary_table.dart';

class Attendance extends StatefulWidget {
  static const id = 'AttendanceForm';
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Attendance Tracker'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AttendanceActions(userId: userId),
            const SizedBox(height: 20),
            Expanded(child: AttendanceSummaryTable(userId: userId)),
          ],
        ),
      ),
    );
  }
}
