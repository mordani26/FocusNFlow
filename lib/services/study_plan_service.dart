import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudyPlanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get tasks => _db.collection('studyTasks');

  Stream<QuerySnapshot> getTasks() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.empty();
    }

    return tasks
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addTask({
    required String title,
    required String course,
    required DateTime dueDate,
    required int effort,
    required int courseWeight,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await tasks.add({
      'userId': user.uid,
      'title': title,
      'course': course,
      'dueDate': Timestamp.fromDate(dueDate),
      'effort': effort,
      'courseWeight': courseWeight,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleCompleted(String taskId, bool completed) async {
    await tasks.doc(taskId).update({'completed': completed});
  }

  Future<void> deleteTask(String taskId) async {
    await tasks.doc(taskId).delete();
  }

  int calculateScore({
    required DateTime dueDate,
    required int effort,
    required int courseWeight,
  }) {
    final daysLeft = dueDate.difference(DateTime.now()).inDays;

    int dueScore;

    if (daysLeft <= 1) {
      dueScore = 50;
    } else if (daysLeft <= 3) {
      dueScore = 40;
    } else if (daysLeft <= 7) {
      dueScore = 30;
    } else {
      dueScore = 15;
    }

    final effortScore = effort * 5;
    final weightScore = courseWeight * 5;

    return dueScore + effortScore + weightScore;
  }

  String explainScore({
    required DateTime dueDate,
    required int effort,
    required int courseWeight,
  }) {
    final daysLeft = dueDate.difference(DateTime.now()).inDays;

    String dueText;

    if (daysLeft <= 1) {
      dueText = 'very soon';
    } else if (daysLeft <= 3) {
      dueText = 'soon';
    } else if (daysLeft <= 7) {
      dueText = 'this week';
    } else {
      dueText = 'later';
    }

    return 'Priority is based on due date ($dueText), effort level ($effort/5), and course weight ($courseWeight/5).';
  }
}
