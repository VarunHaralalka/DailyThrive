import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'Login&Signup/login.dart';
import 'Login&Signup/signup.dart';
import 'homepage.dart';
import 'dailyPlanner/day_planner_screen.dart';
import 'Attendance/attendance.dart';
import 'budgeting/expenses.dart';
import 'Profile/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures binding is initialized
  await Firebase.initializeApp(); // Initializes Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Companion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade100,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade800,
          elevation: 4,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => const SignUp(),
        '/home': (context) => const HomePage(),
        '/planner': (context) => const DayPlannerScreen(),
        '/attendance': (context) => const Attendance(),
        '/expenses': (context) => const ExpensesPage(),
        '/profile': (context) => const Profile(),
      },
    );
  }
}
