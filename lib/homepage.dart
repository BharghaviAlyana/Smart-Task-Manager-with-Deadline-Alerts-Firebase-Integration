//homepage.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_lab_project/edit_task_screen.dart';
import 'package:flutter_lab_project/shared_widget.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userData.exists && userData.data() != null) {
          setState(() {
            _userName = userData.data()!['name'] ?? 'User';
          });
        }
      }
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final taskDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (taskDate == DateTime(now.year, now.month, now.day)) {
      return 'Today, ${DateFormat('h:mm a').format(dateTime)}';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow, ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  Future<void> _deleteTask(BuildContext context, String taskId) async {
    try {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(taskId)
            .delete();

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: $e')),
      );
    }
  }

  Future<void> _editTask(BuildContext context, String taskId, String currentTitle, DateTime currentDateTime) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(
          taskId: taskId,
          currentTitle: currentTitle,
          currentDateTime: currentDateTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SharedScaffold(
      currentRoute: 'tasks',
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hello, $_userName!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your Tasks',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Tasks List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid) 
                    .orderBy('dateTime')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tasks = snapshot.data!.docs;

                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet. Add your first task!',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final taskDoc = tasks[index];
                      final taskData = taskDoc.data() as Map<String, dynamic>;
                      
                      return _buildTaskCard(
                        context,
                        taskData['title'] ?? '',
                        (taskData['dateTime'] as Timestamp).toDate(),
                        taskDoc.id,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),  
    );
  }

  Widget _buildTaskCard(BuildContext context, String title, DateTime dateTime, String taskId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDateTime(dateTime),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF6C63FF)),
                onPressed: () => _editTask(context, taskId, title, dateTime),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteTask(context, taskId),
              ),
            ],
          ),
        ],
      ),
    );
  }
}