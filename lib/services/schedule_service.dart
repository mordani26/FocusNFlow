import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get sessions => _db.collection('studySessions');

  Stream<QuerySnapshot> getSessions() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return sessions
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('startTime')
        .snapshots();
  }

  Future<void> createSession({
    required String title,
    required String course,
    required DateTime startTime,
    required int durationMinutes,
    required String notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await sessions.add({
      'title': title,
      'course': course,
      'startTime': Timestamp.fromDate(startTime),
      'durationMinutes': durationMinutes,
      'notes': notes,
      'createdBy': user.uid,
      'createdByEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSession(String sessionId) async {
    await sessions.doc(sessionId).delete();
  }
}
