// calendar_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_lab_project/edit_task_screen.dart';
import 'package:flutter_lab_project/shared_widget.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _isWeekView = true;
  String _getHeaderText() {
  if (_isWeekView) {
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday % 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d').format(endOfWeek)}';
  } else {
    return DateFormat('MMMM yyyy').format(selectedDate);
  }
}

void _toggleViewMode() {
  setState(() {
    _isWeekView = !_isWeekView;
  });
}


  Future<void> _deleteTask(BuildContext context, String taskId) async {
    // Show confirmation dialog
    bool? shouldDelete = await showDialog<bool>(
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
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(taskId)
            .delete();

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting task: $e')),
        );
      }
    }
  }

  Future<void> _editTask(BuildContext context, String taskId, String currentTitle, DateTime currentDateTime) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(
          taskId: taskId,
          currentTitle: currentTitle,
          currentDateTime: currentDateTime,
        ),
      ),
    );

    if (result == true) {
      // Task was updated successfully
    }
  }

  final List<String> weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  DateTime selectedDate = DateTime.now();

  void _selectDay(int weekdayIndex) {
    final now = DateTime.now();
    final currentWeekday = now.weekday % 7; // 0-6 where 0 is Sunday
    final difference = weekdayIndex - currentWeekday;
    
    setState(() {
      selectedDate = DateTime(
        now.year,
        now.month,
        now.day + difference,
      );
    });
  }

  bool _isSelectedDay(int weekdayIndex) {
    return selectedDate.weekday % 7 == weekdayIndex;
  }

  String _getDayNumber(int index) {
    final now = DateTime.now();
    final currentWeekday = now.weekday % 7; // 0-6 where 0 is Sunday
    final difference = index - currentWeekday;
    final day = now.add(Duration(days: difference));
    return day.day.toString();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SharedScaffold(
      currentRoute: 'calendar',
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.02,
              ),
              child: Column(
                children: [
                  // First row with title and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Calendar',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Second row with date range and toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getHeaderText(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Toggle switch between week and month
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (!_isWeekView) _toggleViewMode();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _isWeekView 
                                      ? const Color(0xFF6C63FF) 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Week',
                                  style: TextStyle(
                                    color: _isWeekView ? Colors.white : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_isWeekView) _toggleViewMode();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: !_isWeekView 
                                      ? const Color(0xFF6C63FF) 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Month',
                                  style: TextStyle(
                                    color: !_isWeekView ? Colors.white : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Week Days ScrollView
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.02,
                ),
                child: Row(
                  children: List.generate(
                    weekDays.length,
                    (index) => GestureDetector(
                      onTap: () => _selectDay(index),
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: _isSelectedDay(index)
                              ? const Color(0xFF6C63FF).withOpacity(0.1)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: _isSelectedDay(index)
                                  ? const Color(0xFF6C63FF)
                                  : Colors.grey,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              weekDays[index],
                              style: TextStyle(
                                color: _isSelectedDay(index)
                                    ? const Color(0xFF6C63FF)
                                    : Colors.grey,
                                fontSize: 14,
                                fontWeight: _isSelectedDay(index)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getDayNumber(index),
                              style: TextStyle(
                                color: _isSelectedDay(index)
                                    ? const Color(0xFF6C63FF)
                                    : Colors.grey,
                                fontSize: 16,
                                fontWeight: _isSelectedDay(index)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allTasks = snapshot.data!.docs;
                  
                  // Filter tasks for selected day
                  final filteredTasks = allTasks.where((doc) {
                    final taskData = doc.data() as Map<String, dynamic>;
                    final taskDate = (taskData['dateTime'] as Timestamp).toDate();
                    return _isSameDay(taskDate, selectedDate);
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks for ${DateFormat('EEEE, MMMM d').format(selectedDate)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.02,
                    ),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final taskDoc = filteredTasks[index];
                      final taskData = taskDoc.data() as Map<String, dynamic>;
                      
                      return _buildTaskCard(
                        context,
                        taskData['title'] ?? '',
                        (taskData['dateTime'] as Timestamp).toDate(),
                        taskDoc.id,
                        size,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
          floatingActionButton: FloatingActionButton(
      backgroundColor: const Color(0xFF6C63FF),
      child: const Icon(Icons.add),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EditTaskScreen(),
          ),
        );

        if (result == true) {
          // Task was added successfully
        }
      },
    ),
  );
    
    
  }

  Widget _buildTaskCard(BuildContext context, String title, DateTime dateTime, String taskId, Size size) {
  return Container(
    margin: EdgeInsets.only(bottom: size.height * 0.02),
    padding: EdgeInsets.all(size.width * 0.04),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: size.width * 0.2,
            height: size.width * 0.2,
            color: Colors.grey[200],
            child: Icon(
              Icons.task_alt,
              size: 30,
              color: Colors.grey[400],
            ),
          ),
        ),
        SizedBox(width: size.width * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('h:mm a').format(dateTime),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
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