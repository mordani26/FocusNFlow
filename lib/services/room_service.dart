import 'package:cloud_firestore/cloud_firestore.dart';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get rooms => _db.collection('studyRooms');

  Future<void> createDefaultRooms() async {
    final defaultRooms = [
      {
        'name': 'Library Floor 2',
        'location': 'Main Library',
        'capacity': 20,
        'currentOccupancy': 0,
      },
      {
        'name': 'Tech Lab Room A',
        'location': 'CS Building',
        'capacity': 12,
        'currentOccupancy': 0,
      },
      {
        'name': 'Quiet Study Room',
        'location': 'Student Center',
        'capacity': 8,
        'currentOccupancy': 0,
      },
    ];

    for (var room in defaultRooms) {
      final id = room['name'].toString().replaceAll(' ', '_').toLowerCase();
      await rooms.doc(id).set(room, SetOptions(merge: true));
    }
  }

  Stream<QuerySnapshot> getRooms() {
    return rooms.snapshots();
  }

  Future<void> checkIn(String roomId) async {
    final ref = rooms.doc(roomId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data() as Map<String, dynamic>;

      int current = data['currentOccupancy'] ?? 0;
      int capacity = data['capacity'] ?? 0;

      if (current < capacity) {
        transaction.update(ref, {'currentOccupancy': current + 1});
      }
    });
  }

  Future<void> checkOut(String roomId) async {
    final ref = rooms.doc(roomId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data() as Map<String, dynamic>;

      int current = data['currentOccupancy'] ?? 0;

      if (current > 0) {
        transaction.update(ref, {'currentOccupancy': current - 1});
      }
    });
  }
}
