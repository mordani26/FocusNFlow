import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getMessages(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String groupId,
    required String text,
  }) async {
    final user = _auth.currentUser;
    if (user == null || text.trim().isEmpty) return;

    await _db.collection('groups').doc(groupId).collection('messages').add({
      'text': text.trim(),
      'senderId': user.uid,
      'senderEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
