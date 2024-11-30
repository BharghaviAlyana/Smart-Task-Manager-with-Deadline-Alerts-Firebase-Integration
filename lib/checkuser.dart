//checkuser.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_lab_project/homepage.dart';
import 'package:flutter_lab_project/login.dart';


class CheckUser extends StatelessWidget {
  const CheckUser({super.key});

  @override
  Widget build(BuildContext context) {
    return checkuser();
  }

  checkuser(){
    final user=FirebaseAuth.instance.currentUser;
    if(user!=null){
      return MyHomePage();
    }
    else{
      // ignore: prefer_const_constructors
      return LoginPage();
    }
  }
}