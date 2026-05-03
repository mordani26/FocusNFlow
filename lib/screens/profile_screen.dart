import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final majorController = TextEditingController();
  final coursesController = TextEditingController();
  final interestsController = TextEditingController();

  bool loading = true;
  bool saving = false;
  String? message;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(user!.uid)
        .get();

    final data = doc.data();

    if (data != null) {
      nameController.text = data['name'] ?? '';
      majorController.text = data['major'] ?? '';
      coursesController.text = (data['courses'] as List?)?.join(', ') ?? '';
      interestsController.text = (data['interests'] as List?)?.join(', ') ?? '';
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> saveProfile() async {
    if (user == null) return;

    setState(() {
      saving = true;
      message = null;
    });

    final courses = coursesController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final interests = interestsController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    await FirebaseFirestore.instance
        .collection('students')
        .doc(user!.uid)
        .update({
          'name': nameController.text.trim(),
          'major': majorController.text.trim(),
          'courses': courses,
          'interests': interests,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    setState(() {
      saving = false;
      message = 'Profile saved successfully';
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    majorController.dispose();
    coursesController.dispose();
    interestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Student Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Student Profile')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              user?.email ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            TextField(
              controller: majorController,
              decoration: InputDecoration(
                labelText: 'Major',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            TextField(
              controller: coursesController,
              decoration: InputDecoration(
                labelText: 'Courses',
                hintText: 'Example: CSC 4360, CSC 3350',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            TextField(
              controller: interestsController,
              decoration: InputDecoration(
                labelText: 'Interests',
                hintText: 'Example: Flutter, Cybersecurity, AI',
                border: OutlineInputBorder(),
              ),
            ),

            if (message != null) ...[
              SizedBox(height: 12),
              Text(message!, style: TextStyle(color: Colors.green)),
            ],

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: saving ? null : saveProfile,
              child: saving
                  ? CircularProgressIndicator()
                  : Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
