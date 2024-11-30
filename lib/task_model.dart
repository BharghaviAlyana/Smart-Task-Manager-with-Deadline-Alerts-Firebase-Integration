//task_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
class Task {
  final String id;
  final String title;
  final DateTime dateTime;
  final String status;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.dateTime,
    this.status = 'pending',
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
      'userId': userId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      userId: map['userId'] ?? '',
    );
  }
}