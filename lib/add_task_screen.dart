//add_task_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_lab_project/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void dispose() {
    _taskController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate() && selectedDate != null && selectedTime != null) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to create tasks')),
        );
        return;
      }
        final dateTime = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          selectedTime!.hour,
          selectedTime!.minute,
        );

        final task = Task(
          id: const Uuid().v4(),
          title: _taskController.text,
          dateTime: dateTime, userId: currentUser.uid,
          
        );

        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(task.id)
            .set(task.toMap());

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          // Implement share functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          // Implement menu functionality
                        },
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: size.height * 0.02),
              
              Text(
                'New Task',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              SizedBox(height: size.height * 0.04),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        hintText: 'Task Name',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a task name';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: size.height * 0.02),
                    
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        hintText: 'Date',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: size.height * 0.02),
                    
                    TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      onTap: () => _selectTime(context),
                      decoration: InputDecoration(
                        hintText: 'Time',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: const Icon(Icons.access_time),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: size.height * 0.03),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Task',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.04),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F2FF),
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
