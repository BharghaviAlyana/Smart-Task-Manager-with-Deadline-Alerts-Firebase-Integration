//main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lab_project/checkuser.dart';
import 'firebase_options.dart';

  Future<void> migrateExistingTasks() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  try {
    final tasks = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isNull: true)
        .get();

    for (var task in tasks.docs) {
      await task.reference.update({'userId': currentUser.uid});
    }
  } catch (e) {
    print('Error migrating tasks: $e');
  }
}
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await migrateExistingTasks(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:  CheckUser(),
      
    );
  }
}

