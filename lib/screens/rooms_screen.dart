import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/services/room_service.dart';

class RoomsScreen extends StatefulWidget {
  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final RoomService roomService = RoomService();

  @override
  void initState() {
    super.initState();
    roomService.createDefaultRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Study Room Finder')),
      body: StreamBuilder<QuerySnapshot>(
        stream: roomService.getRooms(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading rooms'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final rooms = snapshot.data!.docs;

          if (rooms.isEmpty) {
            return Center(child: Text('No rooms found'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final data = room.data() as Map<String, dynamic>;

              final name = data['name'] ?? '';
              final location = data['location'] ?? '';
              final capacity = data['capacity'] ?? 0;
              final current = data['currentOccupancy'] ?? 0;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(location),
                      SizedBox(height: 8),
                      Text('Occupancy: $current / $capacity'),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: current >= capacity
                                ? null
                                : () => roomService.checkIn(room.id),
                            child: Text('Check In'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: current <= 0
                                ? null
                                : () => roomService.checkOut(room.id),
                            child: Text('Check Out'),
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
