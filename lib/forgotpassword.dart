//forgotpasswor.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lab_project/uihelper.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  TextEditingController emailController=TextEditingController();
  forgotpassword(email)async{
    if(email==""){
      return UiHelper.CustomAlertBox(context,"Enter an Email To Reset Password");
    }
    else{
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Forgot password"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Reset Your Password",style: TextStyle(fontSize: 25),textAlign: TextAlign.center,),
          Align(
            alignment: Alignment.center,
            child:Text("  Enter your Email address and we will send you instructions to reset your password.",style: TextStyle(fontSize: 15),textAlign: TextAlign.center,),
          ),
          UiHelper.CustomerTextFeild(emailController, "Email", Icons.mail, false),
          SizedBox(height: 20,),
          UiHelper.CustomButton((){
            forgotpassword(emailController.text.toString());
          }, "Continue"),
      ],),
    );
  }
}