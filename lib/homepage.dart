import 'package:flutter/material.dart';
import 'appbar.dart';
import 'FeatureCard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Daily Thrive'),
      body: Column(
        children: [
          // Quote section
          Container(
            height: 100,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(128, 128, 128, 0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: const Text(
                '"The future belongs to those who believe in the beauty of their dreams."',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Expanded list of cards to take all remaining space
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                buildFeatureCard(
                  context: context,
                  title: 'Daily Planner',
                  icon: Icons.checklist,
                  color: Colors.blue,
                  route: '/planner',
                ),
                const SizedBox(height: 20),
                buildFeatureCard(
                  context: context,
                  title: 'Attendance',
                  icon: Icons.event_available,
                  color: Colors.green,
                  route: '/attendance',
                ),
                const SizedBox(height: 20),
                buildFeatureCard(
                  context: context,
                  title: 'Expense Tracker',
                  icon: Icons.pie_chart,
                  color: Colors.orange,
                  route: '/expenses',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
