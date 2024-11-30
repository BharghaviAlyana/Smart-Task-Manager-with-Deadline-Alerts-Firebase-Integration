//login.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lab_project/forgotpassword.dart';
import 'package:flutter_lab_project/signuppage.dart';
import 'package:flutter_lab_project/uihelper.dart';
import 'package:flutter_lab_project/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  bool _obscurePassword = true;
  login(String email,String password)async{
    if(email=="" && password==""){
      UiHelper.CustomAlertBox(context, "Enter Required Feilds");
    }
    else{
      // ignore: unused_local_variable
      UserCredential? userCredential;
      try{
        // ignore: body_might_complete_normally_nullable
        userCredential=await FirebaseAuth.instance.signInWithEmailAndPassword(email: email,password: password).then((value){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>const MyHomePage()));
        });
      }
      on FirebaseAuthException catch(ex){
        return UiHelper.CustomAlertBox(context, ex.code.toString());
      }
    }
  }
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login page"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        UiHelper.CustomerTextFeild(emailController,"Email", Icons.email, false),
        UiHelper.CustomerTextFeild(
            passwordController,
            "Password",
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            _obscurePassword,
            onToggleVisibility: _togglePasswordVisibility,
            
          ),
        SizedBox(height: 30),
        UiHelper.CustomButton((){
          login(emailController.text.toString(), passwordController.text.toString());
        },"Login"),
        SizedBox(height:20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Not have an account??',style: TextStyle(fontSize: 16),),
            TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpPage()));
            }, 
            child: Text("Sign Up",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),))
          ], 
        ),
        SizedBox(height:20),
        TextButton(onPressed: (){
          Navigator.push(context,MaterialPageRoute(builder: (context)=>Forgotpassword()) );
        // ignore: prefer_const_constructors
        }, child: Text("Forgot Password??",style: TextStyle(fontSize: 20),))
      ],),
    );
  }
}