import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'to_do_list_card.dart';
import '../authentication/auth_helper.dart';
import '../appbar.dart';
import '../ConfirmationModal.dart';

class DayPlannerScreen extends StatefulWidget {
  static const id = 'DayPlannerScreen';
  const DayPlannerScreen({super.key});

  @override
  State<DayPlannerScreen> createState() => _DayPlannerScreenState();
}

class _DayPlannerScreenState extends State<DayPlannerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String newTask = "";
  String userName = "";

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  // Fetches the user's first name only
  void getUserName() async {
    String? fullName = await AuthHelper.getCurrentUserName();
    if (fullName != null && fullName.isNotEmpty) {
      userName = fullName.split(' ')[0]; // Extract first name
    } else {
      userName = "";
    }
    setState(() {});
  }

  CollectionReference<Map<String, dynamic>> getUserDailyPlannerCollection() {
    final uid = AuthHelper.getCurrentUserId();
    return _firestore.collection('users').doc(uid).collection('daily_planner');
  }

  void _addNewTask() async {
    if (newTask.isEmpty) return;
    await getUserDailyPlannerCollection().add({
      'task': newTask,
      'timestamp': FieldValue.serverTimestamp(),
    });
    setState(() {
      newTask = "";
    });
  }

  void _deleteTask(String docId) async {
    await getUserDailyPlannerCollection().doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Daily Thrive'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Title and Greeting Section
            Padding(
              padding:
                  const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Day Planner",
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 18.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, $userName!",
                          style: const TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        const Text(
                          "\"Every accomplishment starts with the decision to try.\"",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18.0),
            // Section Header
            Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 8.0, bottom: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Today's Tasks",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4.0),
            // Task List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getUserDailyPlannerCollection()
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tasks = snapshot.data!.docs;
                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text(
                        "No tasks for today!\nAdd a new one using the + button.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      var taskText = tasks[index]['task'];
                      var docId = tasks[index].id;
                      return ToDoListCard(
                        text: taskText,
                        onDelete: () async {
                          final confirmed = await showConfirmationDialog(
                            context,
                            content:
                                'Are you sure you want to delete this task?',
                            confirmLabel: 'Delete',
                          );
                          if (confirmed == true) {
                            _deleteTask(docId);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String tempTask = "";
              return AlertDialog(
                title: const Text('Add Task'),
                content: TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter your task',
                    hintText: 'Type here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    tempTask = value;
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      size: 30.0,
                      color: Colors.redAccent,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (tempTask.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a new task'),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        newTask = tempTask;
                      });
                      _addNewTask();
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.check,
                      size: 30.0,
                      color: Colors.lightGreen,
                    ),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.orangeAccent,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 35.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
