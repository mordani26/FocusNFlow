import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get groups => _db.collection('groups');

  Stream<QuerySnapshot> getGroups() {
    return groups.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> createGroup({
    required String name,
    required String course,
    required String description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = await groups.add({
      'name': name,
      'course': course,
      'description': description,
      'createdBy': user.uid,
      'createdByEmail': user.email,
      'membersCount': 1,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await docRef.collection('members').doc(user.uid).set({
      'userId': user.uid,
      'email': user.email,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> joinGroup(String groupId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final groupRef = groups.doc(groupId);
    final memberRef = groupRef.collection('members').doc(user.uid);

    await _db.runTransaction((transaction) async {
      final memberSnap = await transaction.get(memberRef);

      if (!memberSnap.exists) {
        transaction.set(memberRef, {
          'userId': user.uid,
          'email': user.email,
          'joinedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(groupRef, {'membersCount': FieldValue.increment(1)});
      }
    });
  }
}
