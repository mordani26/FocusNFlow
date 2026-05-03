import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/schedule_service.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleService scheduleService = ScheduleService();

  final titleController = TextEditingController();
  final courseController = TextEditingController();
  final notesController = TextEditingController();
  final durationController = TextEditingController(text: '60');

  DateTime selectedDateTime = DateTime.now().add(Duration(hours: 1));

  Future<void> pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );

    if (pickedTime == null) return;

    setState(() {
      selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> createSession() async {
    final duration = int.tryParse(durationController.text.trim()) ?? 60;

    await scheduleService.createSession(
      title: titleController.text.trim(),
      course: courseController.text.trim(),
      startTime: selectedDateTime,
      durationMinutes: duration,
      notes: notesController.text.trim(),
    );

    titleController.clear();
    courseController.clear();
    notesController.clear();
    durationController.text = '60';

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void showCreateSessionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Study Session'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: courseController,
                  decoration: InputDecoration(labelText: 'Course'),
                ),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Duration Minutes'),
                ),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(labelText: 'Notes'),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: pickDateTime,
                  child: Text('Pick Date & Time'),
                ),
                SizedBox(height: 8),
                Text(
                  'Selected: ${selectedDateTime.month}/${selectedDateTime.day}/${selectedDateTime.year} '
                  '${selectedDateTime.hour}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(onPressed: createSession, child: Text('Create')),
          ],
        );
      },
    );
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    titleController.dispose();
    courseController.dispose();
    notesController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Study Sessions')),
      floatingActionButton: FloatingActionButton(
        onPressed: showCreateSessionDialog,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: scheduleService.getSessions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data?.docs ?? [];

          if (sessions.isEmpty) {
            return Center(child: Text('No study sessions yet'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final data = session.data() as Map<String, dynamic>;

              final title = data['title'] ?? 'Untitled Session';
              final course = data['course'] ?? 'No course';
              final duration = data['durationMinutes'] ?? 0;
              final notes = data['notes'] ?? '';

              final rawStartTime = data['startTime'];
              final Timestamp? startTime = rawStartTime is Timestamp
                  ? rawStartTime
                  : null;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(
                    'Course: $course\n'
                    'Time: ${startTime == null ? 'No time saved' : formatDate(startTime)}\n'
                    'Duration: $duration minutes\n'
                    'Notes: $notes',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      scheduleService.deleteSession(session.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
