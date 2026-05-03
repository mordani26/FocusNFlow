import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> registerStudent({
    required String name,
    required String email,
    required String password,
    required String major,
  }) async {
    if (!email.endsWith('.edu')) {
      throw Exception('Use a campus email');
    }

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;

    if (user != null) {
      await _db.collection('students').doc(user.uid).set({
        'name': name,
        'email': email,
        'major': major,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return user;
  }

  Future<User?> loginStudent({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
