import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lab_project/uihelper.dart';
import 'package:flutter_lab_project/homepage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      String name = nameController.text.trim();
      String email = emailController.text.trim();
      String password = passwordController.text;

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        UiHelper.CustomAlertBox(context, "Enter Required Fields");
        return;
      }

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': name,
          'email': email,
        });

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const MyHomePage()));
      } on FirebaseAuthException catch (ex) {
        UiHelper.CustomAlertBox(context, ex.message ?? "An error occurred");
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
        title: Text("Sign Up Page"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[ Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UiHelper.CustomerTextFeild(
                  nameController,
                  "Full Name",
                  Icons.person,
                  false,
                ),
                SizedBox(height: 20),
                UiHelper.CustomerTextFeild(
                  emailController,
                  "Email",
                  Icons.email,
                  false,
                ),
                SizedBox(height: 20),
                UiHelper.CustomerTextFeild(
                  passwordController,
                  "Password",
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  _obscurePassword,
                  onToggleVisibility: _togglePasswordVisibility,
                ),
                SizedBox(height: 30),
                UiHelper.CustomButton(signUp, "Sign Up"),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text("Login"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ]
      ),
    );
  }
}