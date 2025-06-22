import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../appbar.dart';

class Attendance extends StatefulWidget {
  static const id = 'AttendanceForm';
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  final TextEditingController _subjectController = TextEditingController();
  final Map<String, List<Map<String, String>>> _attendanceMap = {};
  String? _selectedSubject;

  /// Add a new subject
  void _addSubject() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: TextField(
            controller: _subjectController,
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
              onPressed: () {
                final subject = _subjectController.text.trim();
                if (subject.isNotEmpty &&
                    !_attendanceMap.containsKey(subject)) {
                  setState(() {
                    _attendanceMap[subject] = [];
                  });
                }
                _subjectController.clear();
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  /// Delete a subject
  void _deleteSubject() {
    if (_attendanceMap.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Subject'),
          content: DropdownButton<String>(
            value: _selectedSubject,
            hint: const Text('Select Subject'),
            onChanged: (String? value) {
              setState(() {
                _selectedSubject = value;
              });
            },
            items: _attendanceMap.keys.map((subject) {
              return DropdownMenuItem<String>(
                value: subject,
                child: Text(subject),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedSubject != null) {
                  setState(() {
                    _attendanceMap.remove(_selectedSubject);
                    _selectedSubject = null;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Mark attendance for a subject
  void _addAttendance() {
    if (_attendanceMap.isEmpty) return;

    String? selectedSubject;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                    onChanged: (String? value) {
                      setState(() {
                        selectedSubject = value;
                      });
                    },
                    items: _attendanceMap.keys.map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (selectedSubject != null) {
                            _recordAttendance(selectedSubject!, selectedDate,
                                isPresent: true);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Present'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedSubject != null) {
                            _recordAttendance(selectedSubject!, selectedDate,
                                isPresent: false);
                            Navigator.pop(context);
                          }
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
        );
      },
    );
  }

  void _recordAttendance(String subject, DateTime date,
      {required bool isPresent}) {
    setState(() {
      _attendanceMap[subject]!.add({
        'date': date.toIso8601String(),
        'status': isPresent ? 'Present' : 'Absent',
      });
    });
  }

  /// Show attendance by selected subject with edit/delete options
  void _showAttendanceBySubject() {
    if (_attendanceMap.isEmpty) return;

    String? selectedSubject;

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    onChanged: (String? value) {
                      setState(() {
                        selectedSubject = value;
                      });
                    },
                    items: _attendanceMap.keys.map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  if (selectedSubject != null &&
                      _attendanceMap[selectedSubject] != null)
                    SizedBox(
                      height: 300,
                      width: 400,
                      child: _attendanceMap[selectedSubject]!.isEmpty
                          ? const Center(child: Text('No attendance records'))
                          : SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: _attendanceMap[selectedSubject]!
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final record = entry.value;
                                  return DataRow(cells: [
                                    DataCell(
                                        Text(record['date']!.split('T').first)),
                                    DataCell(Text(record['status']!)),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon:
                                              const Icon(Icons.edit, size: 18),
                                          onPressed: () => _editAttendance(
                                              selectedSubject!, index),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 18, color: Colors.red),
                                          onPressed: () => _deleteAttendance(
                                              selectedSubject!, index),
                                        ),
                                      ],
                                    )),
                                  ]);
                                }).toList(),
                              ),
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

  void _editAttendance(String subject, int index) {
    bool? newStatus;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Attendance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change status for ${_attendanceMap[subject]![index]['date']!.split('T').first}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      newStatus = true;
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
                      newStatus = false;
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
        );
      },
    ).then((_) {
      if (newStatus != null) {
        setState(() {
          _attendanceMap[subject]![index]['status'] =
              newStatus! ? 'Present' : 'Absent';
        });
      }
    });
  }

  void _deleteAttendance(String subject, int index) {
    setState(() {
      _attendanceMap[subject]!.removeAt(index);
    });
  }

  double _calculatePercentage(String subject) {
    final records = _attendanceMap[subject]!;
    if (records.isEmpty) return 0.0;
    final presentCount =
        records.where((record) => record['status'] == 'Present').length;
    return (presentCount / records.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          const CustomAppBar(title: 'Attendance Tracker'), // Updated app bar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Buttons in 2x2 grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 3.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: _addSubject,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subject'),
                ),
                ElevatedButton.icon(
                  onPressed: _deleteSubject,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Subject'),
                ),
                ElevatedButton.icon(
                  onPressed: _addAttendance,
                  icon: const Icon(Icons.check),
                  label: const Text('Mark Attendance'),
                ),
                ElevatedButton.icon(
                  onPressed: _showAttendanceBySubject,
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Attendance'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Subject summary table
            Expanded(
              child: _attendanceMap.isEmpty
                  ? const Center(child: Text('No subjects added yet'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Subject')),
                          DataColumn(label: Text('Total Classes')),
                          DataColumn(label: Text('Attendance %')),
                        ],
                        rows: _attendanceMap.entries.map((entry) {
                          final subject = entry.key;
                          final total = entry.value.length;
                          final percentage = _calculatePercentage(subject);
                          return DataRow(cells: [
                            DataCell(Text(subject)),
                            DataCell(Text(total.toString())),
                            DataCell(Text('${percentage.toStringAsFixed(1)}%')),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }
}
