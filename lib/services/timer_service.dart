import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference get timerDoc =>
      _db.collection('sharedTimers').doc('mainTimer');

  Stream<DocumentSnapshot> getTimerStream() {
    return timerDoc.snapshots();
  }

  Future<void> startTimer({
    required int durationSeconds,
    required String goal,
  }) async {
    final user = _auth.currentUser;

    await timerDoc.set({
      'isRunning': true,
      'durationSeconds': durationSeconds,
      'startTime': FieldValue.serverTimestamp(),
      'pausedRemainingSeconds': durationSeconds,
      'goal': goal,
      'startedBy': user?.email,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> pauseTimer(int remainingSeconds) async {
    await timerDoc.update({
      'isRunning': false,
      'pausedRemainingSeconds': remainingSeconds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resetTimer() async {
    await timerDoc.set({
      'isRunning': false,
      'durationSeconds': 1500,
      'pausedRemainingSeconds': 1500,
      'goal': '',
      'startTime': null,
      'startedBy': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
