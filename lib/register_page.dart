import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/home_page.dart';
import 'package:travel_app/travel_list_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';
  Future<void> _register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Map<String, dynamic> user = { "Email": _emailController.text, "Password": _passwordController.text, }; 
      await  _firestore.collection('Users').doc(_auth.currentUser!.uid).set(user);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TravelListPage()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _cancel() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 238, 224, 201),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo256.png'),
              const SizedBox(height: 20),
              const Text(
                'REGISTER',
                style: TextStyle(
                    fontSize: 50,
                    color: Color.fromARGB(255, 150, 182, 197),
                    fontWeight: FontWeight.w800),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Color.fromARGB(255, 150, 182, 197),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 10,
                      color: Color.fromARGB(255, 173, 196, 206),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Color.fromARGB(255, 150, 182, 197),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 10,
                      color: Color.fromARGB(255, 173, 196, 206),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(
                          Color.fromARGB(255, 150, 182, 197),
                        ),
                        foregroundColor: WidgetStatePropertyAll<Color>(
                          Color.fromARGB(255, 238, 224, 201),
                        ),
                      ),
                      onPressed: _register,
                      child: const Text(
                        'REGISTER',
                        style: TextStyle(fontSize: 20),
                      )),
                  const SizedBox(width: 20),
                  ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(
                          Color.fromARGB(255, 150, 182, 197),
                        ),
                        foregroundColor: WidgetStatePropertyAll<Color>(
                          Color.fromARGB(255, 238, 224, 201),
                        ),
                      ),
                      onPressed: _cancel,
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(fontSize: 20),
                      )),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
