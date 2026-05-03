import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/study_plan_service.dart';

class StudyPlanScreen extends StatefulWidget {
  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  final StudyPlanService studyPlanService = StudyPlanService();

  final titleController = TextEditingController();
  final courseController = TextEditingController();
  final effortController = TextEditingController(text: '3');
  final weightController = TextEditingController(text: '3');

  DateTime selectedDueDate = DateTime.now().add(Duration(days: 2));

  Future<void> pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() {
      selectedDueDate = picked;
    });
  }

  Future<void> addTask() async {
    final effort = int.tryParse(effortController.text.trim()) ?? 3;
    final weight = int.tryParse(weightController.text.trim()) ?? 3;

    await studyPlanService.addTask(
      title: titleController.text.trim(),
      course: courseController.text.trim(),
      dueDate: selectedDueDate,
      effort: effort,
      courseWeight: weight,
    );

    titleController.clear();
    courseController.clear();
    effortController.text = '3';
    weightController.text = '3';

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Study Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Task Title'),
                ),
                TextField(
                  controller: courseController,
                  decoration: InputDecoration(labelText: 'Course'),
                ),
                TextField(
                  controller: effortController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Effort 1-5',
                    helperText: '1 = easy, 5 = hard',
                  ),
                ),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Course Weight 1-5',
                    helperText: '1 = low impact, 5 = high impact',
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: pickDueDate,
                  child: Text('Pick Due Date'),
                ),
                SizedBox(height: 8),
                Text(
                  'Due: ${selectedDueDate.month}/${selectedDueDate.day}/${selectedDueDate.year}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(onPressed: addTask, child: Text('Add Task')),
          ],
        );
      },
    );
  }

  String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  DateTime getDueDate(dynamic rawDate) {
    if (rawDate is Timestamp) {
      return rawDate.toDate();
    }

    return DateTime.now();
  }

  @override
  void dispose() {
    titleController.dispose();
    courseController.dispose();
    effortController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weekly Study Plan Assistant')),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: studyPlanService.getTasks(),
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

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text('No study tasks yet. Add one!'));
          }

          final tasks = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final dueDate = getDueDate(data['dueDate']);
            final effort = data['effort'] ?? 3;
            final courseWeight = data['courseWeight'] ?? 3;

            final score = studyPlanService.calculateScore(
              dueDate: dueDate,
              effort: effort,
              courseWeight: courseWeight,
            );

            return {
              'id': doc.id,
              'title': data['title'] ?? 'Untitled Task',
              'course': data['course'] ?? 'No course',
              'dueDate': dueDate,
              'effort': effort,
              'courseWeight': courseWeight,
              'completed': data['completed'] ?? false,
              'score': score,
              'explanation': studyPlanService.explainScore(
                dueDate: dueDate,
                effort: effort,
                courseWeight: courseWeight,
              ),
            };
          }).toList();

          tasks.sort(
            (a, b) => (b['score'] as int).compareTo(a['score'] as int),
          );

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${index + 1} Priority Score: ${task['score']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),

                      Text(
                        task['title'].toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: task['completed'] == true
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),

                      SizedBox(height: 4),
                      Text('Course: ${task['course']}'),
                      Text('Due: ${formatDate(task['dueDate'] as DateTime)}'),
                      Text('Effort: ${task['effort']}/5'),
                      Text('Course Weight: ${task['courseWeight']}/5'),

                      SizedBox(height: 8),
                      Text(task['explanation'].toString()),

                      SizedBox(height: 12),

                      Row(
                        children: [
                          Checkbox(
                            value: task['completed'] == true,
                            onChanged: (value) {
                              studyPlanService.toggleCompleted(
                                task['id'].toString(),
                                value ?? false,
                              );
                            },
                          ),
                          Text('Done'),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              studyPlanService.deleteTask(
                                task['id'].toString(),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
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
