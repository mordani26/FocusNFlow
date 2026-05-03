import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/group_service.dart';
import 'group_chat_screen.dart';

class GroupsScreen extends StatefulWidget {
  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final GroupService groupService = GroupService();

  final nameController = TextEditingController();
  final courseController = TextEditingController();
  final descriptionController = TextEditingController();

  void openChat(String groupId, String groupName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatScreen(groupId: groupId, groupName: groupName),
      ),
    );
  }

  void showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Study Group'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Group Name'),
                ),
                TextField(
                  controller: courseController,
                  decoration: InputDecoration(labelText: 'Course'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await groupService.createGroup(
                  name: nameController.text.trim(),
                  course: courseController.text.trim(),
                  description: descriptionController.text.trim(),
                );

                nameController.clear();
                courseController.clear();
                descriptionController.clear();

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    courseController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Study Groups')),
      floatingActionButton: FloatingActionButton(
        onPressed: showCreateGroupDialog,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: groupService.getGroups(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading groups'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data!.docs;

          if (groups.isEmpty) {
            return Center(child: Text('No study groups yet. Create one!'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final data = group.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'Unnamed Group';
              final course = data['course'] ?? '';
              final description = data['description'] ?? '';
              final membersCount = data['membersCount'] ?? 0;

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
                      SizedBox(height: 4),
                      Text('Course: $course'),
                      SizedBox(height: 4),
                      Text(description),
                      SizedBox(height: 8),
                      Text('Members: $membersCount'),
                      SizedBox(height: 12),

                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await groupService.joinGroup(group.id);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Joined group')),
                                );
                              }
                            },
                            child: Text('Join'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => openChat(group.id, name),
                            child: Text('Open Chat'),
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
