import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth/login_screen.dart';
import 'profile_screen.dart';
import 'rooms_screen.dart';
import 'groups_screen.dart';
import 'schedule_screen.dart';
import 'timer_screen.dart';
import 'study_plan_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key}); // removed const

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()), // removed const
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'Student';

    return Scaffold(
      appBar: AppBar(
        title: Text('FocusNFlow'), // removed const
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: Icon(Icons.logout), // removed const
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16), // removed const
        children: [
          Text(
            'Welcome, $email',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          ElevatedButton(
            onPressed: () => _openScreen(context, ProfileScreen()),
            child: Text('Student Profile'),
          ),
          ElevatedButton(
            onPressed: () => _openScreen(context, RoomsScreen()),
            child: Text('Study Room Finder'),
          ),
          ElevatedButton(
            onPressed: () => _openScreen(context, GroupsScreen()),
            child: Text('Study Groups'),
          ),
          ElevatedButton(
            onPressed: () => _openScreen(context, ScheduleScreen()),
            child: Text('Study Sessions'),
          ),
          ElevatedButton(
            onPressed: () => _openScreen(context, TimerScreen()),
            child: Text('Shared Study Timer'),
          ),
          ElevatedButton(
            onPressed: () => _openScreen(context, StudyPlanScreen()),
            child: Text('Weekly Study Plan Assistant'),
          ),
        ],
      ),
    );
  }
}
