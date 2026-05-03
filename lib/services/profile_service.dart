import 'package:cloud_firestore/cloud_firestore.dart';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _rooms => _db.collection('studyRooms');

  Future<void> createDefaultRooms() async {
    final rooms = [
      {
        'name': 'Library Floor 2',
        'location': 'Main Library',
        'capacity': 20,
        'currentOccupancy': 0,
      },
      {
        'name': 'Tech Lab Room A',
        'location': 'Computer Science Building',
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

    for (var room in rooms) {
      final docId = room['name'].toString().replaceAll(' ', '_').toLowerCase();
      await _rooms.doc(docId).set(room, SetOptions(merge: true));
    }
  }

  Stream<QuerySnapshot> getRooms() {
    return _rooms.orderBy('name').snapshots();
  }

  Future<void> checkIn(String roomId) async {
    final roomRef = _rooms.doc(roomId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);
      final data = snapshot.data() as Map<String, dynamic>;

      final current = data['currentOccupancy'] ?? 0;
      final capacity = data['capacity'] ?? 0;

      if (current < capacity) {
        transaction.update(roomRef, {'currentOccupancy': current + 1});
      }
    });
  }

  Future<void> checkOut(String roomId) async {
    final roomRef = _rooms.doc(roomId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);
      final data = snapshot.data() as Map<String, dynamic>;

      final current = data['currentOccupancy'] ?? 0;

      if (current > 0) {
        transaction.update(roomRef, {'currentOccupancy': current - 1});
      }
    });
  }
}
