// edit_task_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditTaskScreen extends StatefulWidget {
  final String? taskId;  // null for new task, non-null for editing
  final String? currentTitle;
  final DateTime? currentDateTime;

  const EditTaskScreen({
    Key? key, 
    this.taskId,
    this.currentTitle,
    this.currentDateTime,
  }) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _taskController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.currentTitle ?? '');
    _dateController = TextEditingController(
      text: widget.currentDateTime != null 
          ? DateFormat('dd/MM/yyyy').format(widget.currentDateTime!)
          : '',
    );
    _timeController = TextEditingController(
      text: widget.currentDateTime != null 
          ? DateFormat('h:mm a').format(widget.currentDateTime!)
          : '',
    );
    selectedDate = widget.currentDateTime ?? DateTime.now();
    selectedTime = widget.currentDateTime != null 
        ? TimeOfDay.fromDateTime(widget.currentDateTime!)
        : TimeOfDay.now();
  }

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
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
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
      if (currentUser == null) return;
        final dateTime = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          selectedTime!.hour,
          selectedTime!.minute,
        );

        final task = {
          'title': _taskController.text,
          'dateTime': dateTime,
          'userId': currentUser.uid, // Replace with actual user ID
        };

        if (widget.taskId != null) {
          // Update existing task
          await FirebaseFirestore.instance
              .collection('tasks')
              .doc(widget.taskId)
              .update(task);
        } else {
          // Create new task
          await FirebaseFirestore.instance
              .collection('tasks')
              .add(task);
        }

        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
        
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.taskId != null 
                ? 'Task updated successfully'
                : 'Task added successfully'),
          ),
        );
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      widget.taskId != null ? 'Edit Task' : 'Add Task',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48), // For balance
                  ],
                ),
                
                SizedBox(height: size.height * 0.04),
                
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
                
                SizedBox(height: size.height * 0.04),
                
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
                        child: Text(
                          widget.taskId != null ? 'Update Task' : 'Add Task',
                          style: const TextStyle(
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
      ),
    );
  }
}